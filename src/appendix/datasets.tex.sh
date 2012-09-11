#!/bin/sh

# Make sure an output file was specified
if [ $# -ne 1 ]; then
	echo "No output file specified" >&2
	exit 1
fi

DATA_SETS="
    testoutrank
    ball1
    testCD
    runningex1k
    testCDST2
    testCDST3
    testCDST
    runningex10k
    runningex20k
    segmentation
    spam_train
    runningex30k
    pendigits
    runningex40k
    runningex50k
    spam
    letter-recognition
    mesh_network
    magicgamma
    musk
    connect4
"
OUTPUT_FILE="$1"

COUNTER=1
rm --force $OUTPUT_FILE
for DATA_SET in $DATA_SETS; do
    DATA_SET_CLEANED=$(echo $DATA_SET | sed -e 's/_/\\_/g')
    cat <<EOF >>$OUTPUT_FILE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DATASET $(printf "%02u" $COUNTER): $DATA_SET
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\\section{$DATA_SET_CLEANED}
\\label{sec:dataSets:$DATA_SET}
\\begin{figure}[H]
	\\centering
	\\includegraphics[width=\\textwidth]{datasets/$DATA_SET}
	\\caption{A PCA plot for the \`$DATA_SET_CLEANED' data set.}
	\\label{fig:dataSets:$DATA_SET}
\\end{figure}

EOF
    COUNTER=$(expr $COUNTER + 1)
done
