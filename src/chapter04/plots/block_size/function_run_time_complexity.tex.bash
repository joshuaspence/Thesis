#!/bin/bash

# Make sure an output file was specified
if [ $# -ne 1 ]; then
	echo "No output file specified" >&2
	exit 1
fi

source $(dirname $0)/common.sh

gnuplot -persist <<END_OF_GNUPLOT
$GNUPLOT_HEADER

################################################################################
# FUNCTION RUN TIME COMPLEXITY
################################################################################
set log x
set xlabel "Problem size"
set format x "\$10^{%L}\$"
set ylabel "Execution time"
set autoscale
set key below

set output "$1"
plot \
    $(for i in ${ALL_BLOCKSIZES[*]}; do
        BLOCKSIZE_VALUE=${BLOCKSIZE_NAMES[$i]}
        BLOCKSIZE_NAME="block_size=$BLOCKSIZE_VALUE"
        COLOUR=${BLOCKSIZE_COLOURS[$i]}
        
        echo "'$DATA_FILE' using $COL_VECTORS:(\$$COL_BLOCKSIZE == $BLOCKSIZE_VALUE ? \$$COL_FUNCTIME : 1/0) smooth unique title '$(echo $BLOCKSIZE_NAME | sed -e 's/_/\\_/g')' with linespoints lt 1 lc $COLOUR, \\"
    done)
    1/0 notitle

END_OF_GNUPLOT
