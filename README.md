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

    grulp ../cnetsjs default --testnorun --useconfig

Available grulp tasks:
    default
    build
    build-tests
    test
    clean

Available grulp options:
    --testnorun    #disable test runs
    --useconfig    #take gulpfile.js  if available from each working directory of every project

Examples:

    grulp ../cnetsjs default --testnorun --useconfig
    grulp ../cnetsjs build-tests
    grulp ../cnetsjs run-tests
    grulp ../cnetsjs clean
