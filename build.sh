#!/bin/sh

cmake -S . -B build -G Ninja # Need ninja because CMake doesn't support Swift in basic Unix Makefiles
cmake --build build