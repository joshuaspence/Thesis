#!/bin/bash

################################################################################
#
# A script to spell check the Thesis.
#
# Usage:
#     ./spell_checks.sh
#
################################################################################

#===============================================================================
# Configuration
#===============================================================================
DOC_ROOT="$(dirname $0)/../src"
TEX_COMMANDS=""
#-------------------------------------------------------------------------------

for FILE in $(find "$DOC_ROOT" -type f \( -name "*.tex" -o -name "*.bib" \)); do
    if [[ -f "$FILE.sh" || -f "$FILE.pl" || -f "$FILE.py" ]]; then
        continue
    fi
    
    # Run the spell checker
    echo "Spell checking '$FILE'..."
    aspell \
        --dont-backup \
        --mode=tex \
        -c "$FILE"
done