#!/bin/bash

# Open browser
nautilus "$(readlink -f `dirname $0`)/.."  2>/dev/null &

# Edit LaTeX files
LATEX_FILES=$(find `dirname $0`/src -type f \( -name "*.tex" -o -name "*.sty"  -o -name "*.bib" \) -print0 | xargs -0 echo)
gedit $LATEX_FILES 2>/dev/null &
