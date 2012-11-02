#!/bin/sh

################################################################################
#
# Generate all block size profiling plots from the CSV data file.
#
################################################################################

PLOTS="
    distance_calls
    function_execution_time
    function_run_time_complexity.lin
    function_run_time_complexity.log
    legend
    total_execution_time
    total_run_time_complexity.lin
    total_run_time_complexity.log
    vectors_pruned
"

echo "Generating block size profiling plots..."
for PLOT in $PLOTS; do
	OUTPUT="$(dirname $0)/${PLOT}.tex"
	SCRIPT="$(dirname $0)/$(basename ${OUTPUT}).pl"
    echo "$(basename ${SCRIPT}) --> $(basename ${OUTPUT})"
	perl "$SCRIPT" "$OUTPUT" $@
done