#!/bin/bash

################################################################################
#
# Generate all LaTeX source code transcriptions from the original source code.
#
################################################################################

source $(dirname $0)/common.sh

echo "Generating source code transcriptions..."
for SOURCE in $SOURCES; do
    OUTPUT=$(get_output_name $SOURCE)
    SCRIPT=$(get_script_name $SOURCE)
    echo "$(basename ${SCRIPT}) --> $(basename ${OUTPUT})"
	perl "$SCRIPT" "$OUTPUT" $@
done