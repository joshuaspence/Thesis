#!/bin/bash

################################################################################
#
# Clean all generated graphs.
#
################################################################################

source $(dirname $0)/common.sh

echo "Cleaning MATLAB profiling plots..."
for PLOT in $PLOTS; do
    OUTPUT=$(get_output_name $PLOT)
    echo "Deleting $(basename ${OUTPUT})"
    rm "$OUTPUT" $@ 2>/dev/null
done