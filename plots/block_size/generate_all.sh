#!/bin/sh

PLOTS="
    distance_calls
    function_execution_time
    function_run_time_complexity.lin
    function_run_time_complexity.log
    legend-datasets
    legend-block_sizes
    total_execution_time
    total_run_time_complexity.lin
    total_run_time_complexity.log
    vectors_pruned
"

for PLOT in $PLOTS; do
	OUTPUT="$(dirname $0)/${PLOT}.tex"
	SCRIPT="$(dirname $0)/${OUTPUT}.pl"
    echo "$(basename ${SCRIPT}) --> $(basename ${OUTPUT})"
	perl "$SCRIPT" "$OUTPUT"
done
