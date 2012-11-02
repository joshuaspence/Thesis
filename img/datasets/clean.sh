#!/bin/bash

################################################################################
#
# Clean all generated graphs.
#
################################################################################

source $(dirname $0)/common.sh

echo "Cleaning data set plots..."
for DATASET in $DATASETS; do
    OUTPUT=$(get_output_name $DATASET)
    echo "Deleting $(basename ${OUTPUT})"
    rm "$OUTPUT" "${OUTPUT}.none" $@ 2>/dev/null
done