#!/bin/bash

# Open browser
nautilus "$(readlink -f `dirname $0`)" 2>/dev/null & 

# Edit LaTeX files
LATEX_FILES=$(find `dirname $0`/src -type f \( -name "*.tex" -o -name "*.sty" \) -print0 | xargs -0 echo)
gedit $LATEX_FILES 2>/dev/null &

# Edit bibtex files
BIBTEX_FILES=$(find `dirname $0`/src -type f \( -name "*.bib" \) -print0 | xargs -0 echo)
jabref $BIBTEX_FILES 2>/dev/null &
