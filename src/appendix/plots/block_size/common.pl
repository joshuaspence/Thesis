#!/usr/bin/perl

use strict;
use warnings;

use Cwd 'abs_path';
use File::Basename;

use FindBin;
use lib $FindBin::Bin . '/../../../../scripts';
require 'util.pl';

#===============================================================================
# Configuration
#===============================================================================
my $NO_BLOCKING_BLOCKSIZE = 0;
my $DATA_FILE = abs_path(dirname($0)).'/../../../../data/profiling/block_size.csv';

use constant COL_DATASET         => 0;
use constant COL_BLOCKSIZE       => 1;
use constant COL_DIMENSIONS      => 3;
use constant COL_VECTORS         => 4;
use constant COL_TOTALTIME       => 5;
use constant COL_TOTALTIME_NORM  => 6;
use constant COL_FUNCTIME        => 9;
use constant COL_FUNCTIME_NORM   => 10;
use constant COL_DISTCALLS       => 11;
use constant COL_DISTCALLS_NORM  => 12;
use constant COL_PRUNED          => 13;
use constant COL_PRUNED_NORM     => 14;

my $gnuplot_col_dataset        = COL_DATASET + 1;
my $gnuplot_col_blocksize      = COL_BLOCKSIZE + 1;
my $gnuplot_col_dimensions     = COL_DIMENSIONS + 1;
my $gnuplot_col_vectors        = COL_VECTORS + 1;
my $gnuplot_col_totaltime      = COL_TOTALTIME + 1;
my $gnuplot_col_totaltime_norm = COL_TOTALTIME_NORM + 1;
my $gnuplot_col_functime       = COL_FUNCTIME + 1;
my $gnuplot_col_functime_norm  = COL_FUNCTIME_NORM + 1;
my $gnuplot_col_distcalls      = COL_DISTCALLS_NORM + 1;
my $gnuplot_col_distcalls_norm = COL_DISTCALLS_NORM + 1;
my $gnuplot_col_pruned         = COL_PRUNED + 1;
my $gnuplot_col_pruned_norm    = COL_PRUNED_NORM + 1;
#-------------------------------------------------------------------------------

# Make sure an output file was specified
scalar(@ARGV) >= 1 || die('No output file specified!');
my $output_file = $ARGV[0];

# Parse the data
my %data = ();
my @block_sizes = ();
open(FILE, "<$DATA_FILE") || die("Cannot open file: $DATA_FILE");
my $in_header = 1;
for (<FILE>) {
    # Skip the header
    if ($in_header) {
        $in_header = 0;
        next;
    }
    
    my @columns    = csv_get_fields($_);
    my $dataset    = $columns[COL_DATASET];
    my $block_size = $columns[COL_BLOCKSIZE];
    my $distcalls  = $columns[COL_DISTCALLS_NORM];
    my $functime   = $columns[COL_FUNCTIME_NORM];
    my $totaltime  = $columns[COL_TOTALTIME_NORM];
    my $pruned     = $columns[COL_PRUNED_NORM];
    
    if (!exists $data{$dataset}) {
        $data{$dataset} = ();
    }
    if (!exists $data{$dataset}{$block_size}) {
        $data{$dataset}{$block_size} = ();
    }
    
    if (!($block_size ~~ @block_sizes)) {
        push(@block_sizes, $block_size);
    }
    
    $data{$dataset}{$block_size}{'distcalls'} = $distcalls;
    $data{$dataset}{$block_size}{'functime'}  = $functime;
    $data{$dataset}{$block_size}{'totaltime'} = $totaltime;
    $data{$dataset}{$block_size}{'pruned'}    = $pruned;
}
close(FILE);

# Create the graphs
open(GNUPLOT, '|gnuplot');
print GNUPLOT <<END_OF_GNUPLOT;
reset
set terminal tikz solid color size 10cm, 20.88cm
set datafile separator ','

# Define axis
# Remove border on top and right and set color to gray
set style line 11 lc rgb '#808080' lt 1
set border 3 back ls 11

# Global options
set autoscale
set key below

END_OF_GNUPLOT

my $loop_over;
if (basename($0) =~ m/distance_calls.tex.pl/) {
    $loop_over = 'dataset';
    print GNUPLOT <<END_OF_GNUPLOT;
################################################################################
# DISTANCE CALLS
################################################################################
set log x
set xlabel "Block size"
set format x "\$10^{%L}\$"
set ylabel "Calls to the distance function (normalised)"
END_OF_GNUPLOT
} elsif (basename($0) =~ m/function_execution_time.tex.pl/) {
    $loop_over = 'dataset';
    print GNUPLOT <<END_OF_GNUPLOT;
################################################################################
# FUNCTION EXECUTION TIME
################################################################################
set log x
set xlabel "Block size"
set format x "\$10^{%L}\$"
set ylabel "Function execution time (normalised)"
END_OF_GNUPLOT
} elsif (basename($0) =~ m/total_execution_time/) {
    $loop_over = 'dataset';
    print GNUPLOT <<END_OF_GNUPLOT;
################################################################################
# TOTAL EXECUTION TIME
################################################################################
set log x
set xlabel "Block size"
set format x "\$10^{%L}\$"
set ylabel "Total execution time (normalised)"
END_OF_GNUPLOT
} elsif (basename($0) =~ m/vectors_pruned.tex.pl/) {
    $loop_over = 'dataset';
    print GNUPLOT <<END_OF_GNUPLOT;
################################################################################
# NUMBER OF VECTORS PRUNED
################################################################################
set log x
set xlabel "Block size"
set format x "\$10^{%L}\$"
set ylabel "Number of vectors pruned (normalised)"
END_OF_GNUPLOT
} elsif (basename($0) =~ m/function_run_time_complexity/) {
    $loop_over = "blocksize";
    print GNUPLOT <<END_OF_GNUPLOT;
################################################################################
# FUNCTION RUN TIME COMPLEXITY
################################################################################
set log x
set xlabel "Problem size"
set format x "\$10^{%L}\$"
set ylabel "Execution time"
END_OF_GNUPLOT
} elsif (basename($0) =~ m/total_run_time_complexity.tex.pl/) {
    $loop_over = 'blocksize';
    print GNUPLOT <<END_OF_GNUPLOT;
################################################################################
# TOTAL RUN TIME COMPLEXITY
################################################################################
set log x
set xlabel "Problem size"
set format x "\$10^{%L}\$"
set ylabel "Execution time"
END_OF_GNUPLOT
} else {
    close(GNUPLOT);
    unlink($output_file);
    die('No action to take');
}

print GNUPLOT <<END_OF_GNUPLOT;
set output "$output_file"
plot \\
END_OF_GNUPLOT
if ($loop_over =~ m/dataset/) {
    my $colour_counter = 0;
    for my $dataset (sort keys %data) {
        my $dataset_clean = latex_escape($dataset);
        
        my $the_column;
        my $no_blocking_value;
        if (basename($0) =~ m/distance_calls.tex.pl/) {
            $the_column = $gnuplot_col_distcalls_norm;
            $no_blocking_value = $data{$dataset}{$NO_BLOCKING_BLOCKSIZE}{'distcalls'};
        } elsif (basename($0) =~ m/function_execution_time.tex.pl/) {
            $the_column = $gnuplot_col_functime_norm;
            $no_blocking_value = $data{$dataset}{$NO_BLOCKING_BLOCKSIZE}{'functime'};
        } elsif (basename($0) =~ m/total_execution_time.tex.pl/) {
            $the_column = $gnuplot_col_totaltime_norm;
            $no_blocking_value = $data{$dataset}{$NO_BLOCKING_BLOCKSIZE}{'totaltime'};
        } elsif (basename($0) =~ m/vectors_pruned.tex.pl/) {
            $the_column = $gnuplot_col_pruned_norm;
            $no_blocking_value = $data{$dataset}{$NO_BLOCKING_BLOCKSIZE}{'pruned'};
        } else {
            close(GNUPLOT);
            unlink($output_file);
            die('No action to take');
        }
        print GNUPLOT <<END_OF_GNUPLOT;
    '$DATA_FILE' using (\$$gnuplot_col_blocksize != 0 ? \$$gnuplot_col_blocksize : 1/0):(stringcolumn($gnuplot_col_dataset) eq '$dataset' ? \$$gnuplot_col_functime : 1/0) smooth unique title '$dataset_clean' with linespoints lt 1 lc $colour_counter, \\
    $no_blocking_value title '$dataset_clean*' with line lt 0 lc $colour_counter, \\
END_OF_GNUPLOT
        
        $colour_counter++;
    }
} elsif ($loop_over =~ m/blocksize/) {
    my $colour_counter = 0;
    for my $blocksize (@block_sizes) {
        my $blocksize_text = latex_escape("block_size=$blocksize");
        
        my $the_column;
        if (basename($0) =~ m/total_run_time_complexity.tex.pl/) {
            $the_column = $gnuplot_col_totaltime;
        } elsif (basename($0) =~ m/function_run_time_complexity.tex.pl/) {
            $the_column = $gnuplot_col_functime;
        } else {
            close(GNUPLOT);
            unlink($output_file);
            die('No action to take');
        }
        
        print GNUPLOT <<END_OF_GNUPLOT;
    '$DATA_FILE' using $gnuplot_col_vectors:(\$$gnuplot_col_blocksize == $blocksize ? \$$the_column : 1/0) smooth unique title '$blocksize_text' with linespoints lt 1 lc $colour_counter, \\
END_OF_GNUPLOT
        
        $colour_counter++;
    }
} else {
    close(GNUPLOT);
    unlink($output_file);
    die('No action to take');
}

print GNUPLOT <<END_OF_GNUPLOT;
    1/0 notitle
END_OF_GNUPLOT
close(GNUPLOT);
