#!/usr/bin/perl

use strict;
use warnings;

use FindBin;
use lib $FindBin::Bin . "/../../scripts";
require "util.pl";

#===============================================================================
# Configuration
#===============================================================================
my $data_set_dir = 'datasets';
my @data_sets = (
    'testoutrank',
    'ball1',
    'testCD',
    'runningex1k',
    'testCDST2',
    'testCDST3',
    'testCDST',
    'runningex10k',
    'runningex20k',
    'segmentation',
    'spam_train',
    'runningex30k',
    'pendigits',
    'runningex40k',
    'runningex50k',
    'spam',
    'letter-recognition',
    'mesh_network',
    'magicgamma',
    'musk',
    'connect4'
);
#-------------------------------------------------------------------------------

# Make sure an output file was specified
scalar(@ARGV) >= 1 || die('No output file specified');
my $output_file = $ARGV[0];
open(OUTPUT, ">$output_file") || die("Cannot open file: $output_file");

my $counter = 1;

foreach my $data_set (@data_sets) {
    my $data_set_cleaned = latex_escape($data_set);
    my $formatted_counter = sprintf("%02u", $counter);
    
    print OUTPUT <<EOF;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DATASET $formatted_counter: $data_set
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\\section{$data_set_cleaned}
\\label{sec:dataSets:$data_set}
\\begin{figure}[H]
    \\centering
    \\includegraphics[width=\\textwidth]{$data_set_dir/$data_set}
    \\caption{A PCA plot for the `$data_set_cleaned' data set.}
    \\label{fig:dataSets:$data_set_cleaned}
\\end{figure}

EOF
    $counter++;
}
