grulp
=====

Scripts for building JS application from modules in golang-like workspace

Installation
---

Clone repo, add to the PATH and run `npm` in cloned folder:

    npm install

Enjoy your crossplatform usage of grulp!

Usage
---

grulp [ProjectPath] [grulp task] [list of options]

ProjectPath can be absolute or relative to current path or
relative to workspace sources root directory e.g.:

    grulp .. --testlast --useconfig --runlast

Available grulp tasks:

    default
    build
    build-tests
    test
    clean

Available grulp options:

    --testlast     #enable test only for selected project
    --useconfig    #take gulpfile.js  if available from each working directory of every project
    --runlast      #run tasks only for target project, not dependencies
    

Examples:

    grulp .. default --testlast --useconfig
    grulp .. build-tests
    grulp .. run-tests
    grulp .. clean
