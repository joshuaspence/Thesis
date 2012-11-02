#!/bin/bash

################################################################################
#
# Generate all data set PCA graphs from the MATLAB figure file. Uses MATLAB to
# do so. Note that this script can take a long time to complete.
#
################################################################################

source $(dirname $0)/common.sh

echo "Generating PCA plots..."
for DATASET in $DATASETS; do
	OUTPUT=$(get_output_name $DATASET)
	SCRIPT=$(get_script_name $DATASET)
	echo "$(basename ${SCRIPT}) --> $(basename ${OUTPUT})"
	perl "$SCRIPT" "$OUTPUT" $@
done