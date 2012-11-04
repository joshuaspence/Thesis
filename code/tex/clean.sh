#!/bin/bash

################################################################################
#
# Clean all LaTeX source code transcriptions.
#
################################################################################

source $(dirname $0)/common.sh

echo "Cleaning source code transcriptions..."
for SOURCE in $SOURCES; do
    OUTPUT=$(get_output_name $SOURCE)
    echo "Deleting $(basename ${OUTPUT})"
    rm "$OUTPUT" $@ 2>/dev/null
done