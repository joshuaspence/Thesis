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

function get_output_name() {
    echo $(dirname $0)/$1.tex
}

function get_script_name() {
    echo $(get_output_name $1).pl
}