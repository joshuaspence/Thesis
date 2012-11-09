#!/usr/bin/perl

use strict;
use warnings;

use File::Basename qw(basename dirname);
use File::Spec::Functions qw(catdir catfile updir);

#===============================================================================
# Configuration
#===============================================================================
use constant SOURCE_DIR => catdir(dirname($0), updir(), 'source');
my @source_files_c = (
    'top_n_outlier_pruning_block.c'
);
my @source_files_matlab = (
    'TopN_Outlier_Pruning_Block_MATLAB_SORTED.m',
    'TopN_Outlier_Pruning_Block_MATLAB_UNSORTED.m'
);
#-------------------------------------------------------------------------------

my @source_files;
if (basename($0) =~ m/c.tex.pl/) {
    @source_files = @source_files_c;
} elsif (basename($0) =~ m/matlab.tex.pl/) {
    @source_files = @source_files_matlab;
} else {
    die("No action to take for script: ${\(basename($0))}");
}

# Make sure an output file was specified
scalar(@ARGV) >= 1 || die('No output file specified');
my $output_file = $ARGV[0];
open(OUTPUT, ">$output_file") || die("Cannot open output file: $output_file");

foreach my $source_file (@source_files) {
    my $source_file = catfile(SOURCE_DIR, $source_file);
    (-f $source_file) || die("Source file not found: $source_file");

    if (basename($0) =~ m/c.tex.pl/) {
        print OUTPUT "\\lstset{language=C}\n";
    } elsif (basename($0) =~ m/matlab.tex.pl/) {
        print OUTPUT "\\lstset{language=Matlab}\n";
    } else {
        die("No action to take for script: ${\(basename($0))}");
    }
    print OUTPUT "\\begin{lstlisting}[basicstyle=\\tiny\\ttfamily]\n";

    # Concatenate file contents
    open(FILE, "<$source_file");
    {
        local $/;
        undef $/;
        print OUTPUT <FILE>;
    }
    close(FILE);

    print OUTPUT "\n\\end{lstlisting}\n";
}

close(OUTPUT);
