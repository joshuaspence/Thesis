#!/usr/bin/perl

# Script to convert Matlab profiler output into CSV format

use strict;
use warnings;
use HTML::TableExtract;

my $te = HTML::TableExtract->new();
$te->parse(<STDIN>);

foreach my $ts ($te->tables()) {
	my $data_rows = $ts->rows();
	my $header_row = splice(@$data_rows, 0, 1);

	my $function_name_header = @$header_row[0];
	my $calls_header = @$header_row[1];
	my $total_time_header = @$header_row[2];
	
	my $self_time_header = @$header_row[3];
	$self_time_header =~ s/\*//;

	print "$function_name_header,$calls_header,$total_time_header,$self_time_header\n";

    foreach my $row (@$data_rows) {
    	my $function_name = @$row[0];    	
    	my $calls = @$row[1];
    	
    	my $total_time = @$row[2];
    	$total_time =~ s/\s*s//;
    	
    	my $self_time = @$row[3];
    	$self_time =~ s/\s*s//;
    
	    print "\"$function_name\",$calls,$total_time,$self_time\n";
    }
}
