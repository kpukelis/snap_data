#!/bin/bash


#find . -name "*.zip" -exec unzip {} \;
find -name '*.zip' -exec sh -c 'unzip -d "${1%.*}" "$1"' _ {} \;

