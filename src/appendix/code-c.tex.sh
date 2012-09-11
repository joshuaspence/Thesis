#!/bin/sh

# Make sure an output file was specified
if [ $# -ne 1 ]; then
	echo "No output file specified" >&2
	exit 1
fi

SOURCE_FILES="
    $(dirname $0)/../../data/TopN_Outlier_Pruning_Block/top_n_outlier_pruning_block.c
"
OUTPUT_FILE="$1"

rm --force $OUTPUT_FILE
for SOURCE_FILE in $SOURCE_FILES; do
    if [ ! -f $SOURCE_FILE ]; then
        echo "Source file not found: $SOURCE_FILE" >&2
        exit 1
    fi
    
    cat <<EOF >>$OUTPUT_FILE
\\lstloadlanguages{C}
\\lstset{language=C}
\\begin{lstlisting}
$(cat $SOURCE_FILE)
\\end{lstlisting}

EOF
done
