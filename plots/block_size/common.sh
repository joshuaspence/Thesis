PLOTS="
    distance_calls
    function_execution_time
    function_run_time_complexity.lin
    function_run_time_complexity.log
    legend
    total_execution_time
    total_run_time_complexity.lin
    total_run_time_complexity.log
    vectors_pruned
"

function get_output_name() {
    echo $(dirname $0)/$1.tex
}

function get_script_name() {
    echo $(get_output_name $1).pl
}