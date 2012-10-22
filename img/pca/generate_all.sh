#!/bin/sh

################################################################################
#
# Generate all data set PCA graphs from the MATLAB figure file. Uses MATLAB to
# do so. Note that this script can take a long time to complete.
#
################################################################################

DATASETS="
	ball1
	connect4
	letter-recognition
	magicgamma
	mesh_network
	musk
	pendigits
	runningex1k
	runningex10k
	runningex20k
	runningex30k
	runningex40k
	runningex50k
	segmentation
	spam
	spam_train
	testCD
	testCDST
	testCDST2
	testCDST3
	testoutrank
"

for DATASET in $DATASETS; do
	OUTPUT="$(dirname $0)/${DATASET}.png"
	SCRIPT="$(dirname $0)/${OUTPUT}.pl"
	echo "$(basename ${SCRIPT}) --> $(basename ${OUTPUT})"
	perl "$SCRIPT" "$OUTPUT"
done