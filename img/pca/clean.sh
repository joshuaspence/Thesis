#!/bin/bash

################################################################################
#
# Clean all generated graphs.
#
################################################################################

source $(dirname $0)/common.sh

echo "Cleaning PCA plots..."
echo "Let's not delete these figures unless we really have to... it requires a lot of" >&2
echo "memory for MATLAB to load the FIG files." >&2
#for DATASET in $DATASETS; do
#    OUTPUT=$(get_output_name $DATASET)
#    echo "Deleting $(basename ${OUTPUT})"
#    rm "$OUTPUT" $@ 2>/dev/null
#done