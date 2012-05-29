#!/usr/bin/perl

# Script to convert Matlab profiler output into CSV format

use strict;
use warnings;
use HTML::TableExtract;
use File::Util;
use File::Spec;
use constant USEFUL_HTML_FILE => "file0.html";
use constant OUTPUT_HEADER => "Data set,Iteration,Function Name,Calls,Total Time,Self Time";

# The argument should be the base directory for the profiling data
my $base_dir = $ARGV[0];
my $fu = File::Util->new;

# Get datasets from subdirectories below base directory
my @datasets = $fu->list_dir($base_dir, '--dirs-only', '--no-fsdots', '--with-paths');

# Print header
print(OUTPUT_HEADER);

# Loop through each data set
for my $dataset (@datasets) {
	# String to appear in output data
	my $dataset_string = $dataset;
	$dataset_string =~ s/\/.*\///g;
	
	# Get dataset iterations from subdirectories below base directory
	my @dataset_iterations = $fu->list_dir($dataset, '--dirs-only', '--no-fsdots', '--with-paths');
	
	# Loop through each iteration
	for my $iteration (@dataset_iterations) {
		# String to appear in output data
		my $iteration_string = $iteration;
		$iteration_string =~ s/\/.*\///g;
	
		# Retrieve the input HTML file
		my $html_table_extract = HTML::TableExtract->new();
		my $useful_html_file = File::Spec->catfile($iteration, USEFUL_HTML_FILE);
		$html_table_extract->parse_file($useful_html_file);

		# Loop through each table in the HTML file
		foreach my $table ($html_table_extract->tables()) {
			my @data_rows = $table->rows();

			# Remove header information from data
			splice(@data_rows, 0, 1);

			# Output the data
			foreach my $row (@data_rows) {
				my $function_name = @$row[0];
				my $calls = @$row[1];
		
				my $total_time = @$row[2];
				$total_time =~ s/\s*s//;
		
				my $self_time = @$row[3];
				$self_time =~ s/\s*s//;
	
				print("\"$dataset_string\",\"$iteration_string\",\"$function_name\",$calls,$total_time,$self_time\n");
			}
		}
	}
}
