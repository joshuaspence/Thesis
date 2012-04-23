#!/bin/bash

# Open browser
nautilus "$(readlink -f `dirname $0`)" &

# Edit LaTeX files
find `dirname $0`/src -type f \( -name "*.tex" -o -name "*.bib" -o -name "*.sty" \) -print0 | `xargs -0 gedit` &
