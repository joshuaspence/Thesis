#===============================================================================
# Configuration
#===============================================================================
NO_BLOCKING_BLOCKSIZE=0
DATA_FILE="$(dirname $0)/../../../data/block_size.csv"
UNIQUE_FROM_CSV="$(dirname $0)/../../../scripts/unique_from_csv.pl"

COL_DATASET=1
COL_BLOCKSIZE=2
COL_DIMENSIONS=4
COL_VECTORS=5
COL_TOTALTIME=6
COL_TOTALTIME_NORM=7
COL_FUNCTIME=10
COL_FUNCTIME_NORM=11
COL_DISTCALLS=12
COL_DISTCALLS_NORM=13
COL_PRUNED=14
COL_PRUNED_NORM=15
#-------------------------------------------------------------------------------

DATASET_NAMES=( $(cat $DATA_FILE | $UNIQUE_FROM_CSV $(expr $COL_DATASET - 1)) )
DATASET_COLOURS=( $(for i in $(seq 0 ${#DATASET_NAMES[*]}); do echo "$(expr 1 + $i)"; done) )
ALL_DATASETS=( $(seq 0 $(expr ${#DATASET_NAMES[*]} - 1) ) )

BLOCKSIZE_NAMES=( $(cat $DATA_FILE | $UNIQUE_FROM_CSV $(expr $COL_BLOCKSIZE - 1) | sed -e "/^$NO_BLOCKING_BLOCKSIZE\$/d") )
BLOCKSIZE_COLOURS=( $(for i in $(seq 0 ${#BLOCKSIZE_NAMES[*]}); do echo "$(expr 1 + $i)"; done) )
ALL_BLOCKSIZES=( $(seq 0 $(expr ${#BLOCKSIZE_NAMES[*]} - 1) ) )

GNUPLOT_HEADER=<<END_OF_GNUPLOT
reset
set terminal tikz solid color size 10cm, 20.88cm
set datafile separator ","

# Define axis
# Remove border on top and right and set color to gray
set style line 11 lc rgb '#808080' lt 1
set border 3 back ls 11

# Style definitions
set style line 1 lc rgb '#8b1a0e' pt 1 ps 1 lt 1 lw 2 # --- red
set style line 2 lc rgb '#5e9c36' pt 6 ps 1 lt 1 lw 2 # --- green
END_OF_GNUPLOT
