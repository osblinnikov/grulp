import inspect
import re
import sys
from attrs import attrs
import json, os

join = os.path.join

#PLEASE change it if you don't want the standard workspace root folder location
PROJECTS_ROOT_PATH = os.path.abspath(join(os.path.dirname(__file__), '..', '..', '..', '..', '..'))

def runGrulp(firstRealArgI, argv, working_dir):
    argv = argv[firstRealArgI+1:]
    gulpFile = os.path.abspath(join(os.path.dirname(__file__), '..', 'gulpfile.js'))
    gulpBin = os.path.abspath(join(os.path.dirname(__file__), '..', 'node_modules','gulp','bin','gulp.js'))
    argv.append("--gulpfile "+gulpFile)
    argv.append("--cwd "+working_dir)
    cmd = gulpBin+" "+(' '.join(argv))
    print cmd
    # print argv
    os.system(cmd)
