#!/bin/bash

# Make sure an output file was specified
if [[ $# -ne 1 ]]; then
	echo "No output file specified" >&2
	exit 1
fi

SOURCE_FILES="
    $(dirname $0)/../../data/TopN_Outlier_Pruning_Block/TopN_Outlier_Pruning_Block_MATLAB_SORTED.m
    $(dirname $0)/../../data/TopN_Outlier_Pruning_Block/TopN_Outlier_Pruning_Block_MATLAB_SORTED_INLINE.m
    $(dirname $0)/../../data/TopN_Outlier_Pruning_Block/TopN_Outlier_Pruning_Block_MATLAB_UNSORTED.m
    $(dirname $0)/../../data/TopN_Outlier_Pruning_Block/TopN_Outlier_Pruning_Block_MATLAB_UNSORTED_INLINE.m
"
OUTPUT_FILE="$1"

rm --force $OUTPUT_FILE
for SOURCE_FILE in $SOURCE_FILES; do
    if [[ ! -f $SOURCE_FILE ]]; then
        echo "Source file not found: $SOURCE_FILE" >&2
        exit 1
    fi
    
    cat <<EOF >> $OUTPUT_FILE
\\lstloadlanguages{Matlab}
\\lstset{language=Matlab}
\\begin{lstlisting}
$(cat $SOURCE_FILE)
\\end{lstlisting}

EOF
done
