SOURCES="
	c
	matlab
"

function get_output_name() {
    echo $(dirname $0)/$1.tex
}

function get_script_name() {
    echo $(get_output_name $1).pl
}