#!/bin/bash

################################################################################
#
# Generate all data set graphs from the raw data CSV file. Uses MATLAB to do so.
#
################################################################################

source $(dirname $0)/common.sh

echo "Generating data set plots..."
for DATASET in $DATASETS; do
	OUTPUT=$(get_output_name $DATASET)
	SCRIPT=$(get_script_name $DATASET)
	echo "$(basename ${SCRIPT}) --> $(basename ${OUTPUT})"
	perl "$SCRIPT" "$OUTPUT" $@
done