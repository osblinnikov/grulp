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

    grulp ../cnetsjs default --testnorun

Available grulp tasks:
    default
    build
    build-tests
    run-tests
    clean

Available grulp options:
    --testnorun    #disable test runs

Examples:

    grulp ../cnetsjs default --testnorun
    grulp ../cnetsjs build-tests
    grulp ../cnetsjs run-tests
    grulp ../cnetsjs clean
