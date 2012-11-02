#!/bin/sh

PLOTS="
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
	all_datasets
	legend
"

for PLOT in $PLOTS; do
	OUTPUT="$(dirname $0)/${PLOT}.tex"
	SCRIPT="$(dirname $0)/${OUTPUT}.pl"
	echo "$(basename ${SCRIPT}) --> $(basename ${OUTPUT})"
	perl "$SCRIPT" "$OUTPUT"
done