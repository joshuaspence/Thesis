#!/usr/bin/perl

use strict;
use warnings;

use Cwd 'abs_path';
use File::Basename;

#===============================================================================
# Configuration
#===============================================================================
my $source_dir = dirname($0).'/../../data/TopN_Outlier_Pruning_Block';
my @source_files_c = (
    'top_n_outlier_pruning_block.c'
);
my @source_files_matlab = (
    'TopN_Outlier_Pruning_Block_MATLAB_SORTED.m',
    'TopN_Outlier_Pruning_Block_MATLAB_UNSORTED.m'
);
#-------------------------------------------------------------------------------

my @source_files;
if (basename($0) =~ m/code-c.tex.pl/) {
    @source_files = @source_files_c;
} elsif (basename($0) =~ m/code-matlab.tex.pl/) {
    @source_files = @source_files_matlab;
} else {
    die('No action to take');
}

# Make sure an output file was specified
scalar(@ARGV) >= 1 || die('No output file specified');
my $output_file = $ARGV[0];
open(OUTPUT, "> $output_file") || die("Cannot open file: $output_file");

foreach my $source_file (@source_files) {
    my $source_file = "$source_dir/$source_file";
    
    (-f $source_file) || die("Source file not found: $source_file");
    
    if (basename($0) =~ m/code-c.tex.pl/) {
        print OUTPUT "\\lstset{language=C}\n";
    } elsif (basename($0) =~ m/code-matlab.tex.pl/) {
        print OUTPUT "\\lstset{language=Matlab}\n";
    } else {
        die('No action to take');
    }
    print OUTPUT "\\begin{lstlisting}\n";
    
    # Concatenate file contents
    open(FILE, "< $source_file");
    {
        local $/;
        undef $/;
        print OUTPUT <FILE>;
    }
    close(FILE);
    
    print OUTPUT "\\end{lstlisting}\n";
}

close(OUTPUT);
