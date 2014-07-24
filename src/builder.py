import inspect
import re
import stat
import sys
from attrs import attrs
import json, os
import shutil, errno


join = os.path.join

#PLEASE change it if you don't want the standard workspace root folder location
PROJECTS_ROOT_PATH = os.path.abspath(join(os.path.dirname(__file__), '..', '..', '..', '..', '..'))

DefaultMapBuffer = 'com.github.airutech.cnets.mapBuffer'

def copytree(src, dst, symlinks = False, ignore = None):
    if not os.path.exists(dst):
        os.makedirs(dst)
        shutil.copystat(src, dst)
    lst = os.listdir(src)
    if ignore:
        excl = ignore(src, lst)
        lst = [x for x in lst if x not in excl]
    for item in lst:
        s = os.path.join(src, item)
        d = os.path.join(dst, item)
        if symlinks and os.path.islink(s):
            if os.path.lexists(d):
                os.remove(d)
            os.symlink(os.readlink(s), d)
            try:
                st = os.lstat(s)
                mode = stat.S_IMODE(st.st_mode)
                os.lchmod(d, mode)
            except:
                pass # lchmod not available
        elif os.path.isdir(s):
            copytree(s, d, symlinks, ignore)
        else:
            shutil.copy2(s, d)

def copyanything(src, dst):
    try:
        copytree(src, dst)
    except OSError as exc: # python >2.5
        if exc.errno == errno.ENOTDIR:
            shutil.copy(src, dst)
        else: raise

def readJson(filename):
    json_file_to_read = os.path.join(filename)
    read_data = None
    with open (json_file_to_read, "r") as jsonfile:
        pat=re.compile(r'/\*.*?\*/',re.DOTALL|re.M)
        json_data = re.sub(pat, '', jsonfile.read())
        try:
            read_data = json.loads(json_data)
        except:
            print json_file_to_read+" invalid"
            jsonfile.close()
            raise
        jsonfile.close()
    return read_data

def getRootPath(path):
    countstepsup = len(path.split('.')) - 2
    if countstepsup < 0:
        countstepsup = 0
    countstepsup += 2

    rd = []
    for v in range(0, countstepsup):
        rd.append("..")
    rd = os.path.join(*rd)
    return rd

def getCompanyDomain(path):
    fullNameList = path.split('.')
    return fullNameList[1]+'.'+fullNameList[0]

def getDomainPath(path):
    fullNameList = path.split('.')
    to_delete = [0,1]
    for offset, index in enumerate(to_delete):
        index -= offset
        del fullNameList[index]
    return getCompanyDomain(path)+'/'+('/'.join(fullNameList))

def getDependenciesDict(rootDir, working_dir):
    read_data = readJson(os.path.abspath(os.path.join(working_dir,'..','gernet.json')))
    dependenciesList = []

    #in case we are kernel, add default map buffer
    if len(read_data["blocks"]) > 0 or len(read_data["connection"]["writeTo"]) > 0 or len(read_data["connection"]["readFrom"]) > 0:
        dependenciesList.append(DefaultMapBuffer)

    #foreach dependency
    for v in read_data["blocks"]+read_data["depends"]:
        dependenciesList.append(v["path"])


    depDict = dict()
    for v in set(dependenciesList):
        if not depDict.has_key(v):
            depDict[v] = getDependenciesDict(rootDir, os.path.join(rootDir, getDomainPath(v), 'js'))

    return depDict

def buildSubtrees(builtDepsDict, fullDepDict, firstRealArgI, argv, rootDir):
    for k, v in fullDepDict.items():
        #if not built yet, scan through the subtrees in first place
        if not builtDepsDict.has_key(k):
            buildSubtrees(builtDepsDict, v, firstRealArgI, argv, rootDir)

        #key can be filled on the lower levels of hierarchy, so double-check goes here
        if not builtDepsDict.has_key(k):
            builtDepsDict[k] = True
            executeGulp(firstRealArgI, argv, os.path.join(rootDir, getDomainPath(k), 'js'), v, rootDir)

def copyDependencies(rootDir, working_dir, topLevelDepsDict):
    for k, v in topLevelDepsDict.items():
        copyanything(os.path.join(rootDir, getDomainPath(k), 'js', 'dist'), os.path.join(working_dir, 'dist'))

def executeGulp(firstRealArgI, argv, working_dir, topLevelDepsDict, rootDir):
    if not('clean' in argv):
        copyDependencies(rootDir, working_dir, topLevelDepsDict)
    argv = argv[firstRealArgI+1:]
    gulpFile = os.path.abspath(join(os.path.dirname(__file__), '..', 'gulpfile.js'))
    gulpBin = os.path.abspath(join(os.path.dirname(__file__), '..', 'node_modules','gulp','bin','gulp.js'))
    argv.append("--gulpfile "+gulpFile)
    argv.append("--cwd "+working_dir)
    cmd = gulpBin+" "+(' '.join(argv))
    # print cmd
    # print argv
    os.system(cmd)

def runGrulp(firstRealArgI, argv, working_dir):
    read_data = readJson(os.path.abspath(os.path.join(working_dir,'..','gernet.json')))
    rootDir = os.path.abspath(os.path.join(working_dir,getRootPath(read_data["path"])))

    topLevelDepsDict = getDependenciesDict(rootDir, working_dir)
    buildSubtrees(dict(), topLevelDepsDict, firstRealArgI, argv, rootDir)
    executeGulp(firstRealArgI, argv, working_dir, topLevelDepsDict, rootDir)


