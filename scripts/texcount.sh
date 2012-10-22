#!/bin/sh

################################################################################
#
# A script to count the number of words in the Thesis.
#
# Usage:
#     ./texcount.sh
#
################################################################################

#===============================================================================
# Configuration
#===============================================================================
TEXCOUNT="$(dirname $0)/../lib/texcount/texcount.pl"
SRC_DIR="$(dirname $0)/../src"
#-------------------------------------------------------------------------------

if [ -x $TEXCOUNT ]; then
    $TEXCOUNT -col -merge -incbib -total -dir=$SRC_DIR/ $SRC_DIR/thesis.tex
else
    echo "Executable not found: $TEXCOUNT" >&2
    exit 1
fi