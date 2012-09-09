#!/bin/bash

# Make sure an output file was specified
if [[ $# -ne 1 ]]; then
	echo "No output file specified";
	exit 1;
fi

source $(dirname $0)/common.sh

gnuplot -persist <<END_OF_GNUPLOT
$GNUPLOT_HEADER

################################################################################
# FUNCTION EXECUTION TIME
################################################################################
set log x
set xlabel "Block size"
set format x "\$10^{%L}\$"
set ylabel "Function execution time (normalised)"
set autoscale
set key below

set output "$1"
plot \
    $(for i in ${ALL_DATASETS[*]}; do
        DATASET=${DATASET_NAMES[$i]};
        COLOUR=${DATASET_COLOURS[$i]};
        NO_BLOCKING_VALUE=$(perl <<END_OF_PERL
use strict;
use warnings;
use Text::CSV;

my \$csv = Text::CSV->new();
open(FILE, "< $DATA_FILE") || die "Can't open file: $DATA_FILE";
my \$in_header = 1;
while (<FILE>) {
    if (\$in_header) {
        \$in_header = 0;
        next;
    }
    
    if (\$csv->parse(\$_)) {
        my @columns = \$csv->fields();
        if (\$columns[$(expr $COL_DATASET - 1)] eq "$DATASET" && \$columns[$(expr $COL_BLOCKSIZE - 1)] eq $NO_BLOCKING_BLOCKSIZE) {
            print \$columns[$(expr $COL_FUNCTIME_NORM - 1)];
            exit;
        }
    } else {
        my \$err = \$csv->error_input;
        die("Failed to parse line: \$err");
    }
}
close FILE;
END_OF_PERL
);
        
        echo "'$DATA_FILE' using (\$$COL_BLOCKSIZE != 0 ? \$$COL_BLOCKSIZE : 1/0):(stringcolumn($COL_DATASET) eq '$DATASET' ? \$$COL_FUNCTIME_NORM : 1/0) smooth unique title '$(echo $DATASET | sed -e 's/_/\\_/g')' with linespoints lt 1 lc $COLOUR, \\";
        echo "$NO_BLOCKING_VALUE title '$(echo $DATASET | sed -e 's/_/\\_/g')*' with line lt 0 lc $COLOUR, \\";
    done)
    1/0 notitle

END_OF_GNUPLOT
