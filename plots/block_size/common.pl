#!/usr/bin/perl

use strict;
use warnings;

use Cwd qw(abs_path);
use File::Basename qw(basename dirname);
use File::Spec::Functions qw(catdir catfile devnull updir);

use lib catdir(dirname($0), updir(), updir(), 'scripts');
require 'util.pl';

#===============================================================================
# Configuration
#===============================================================================
use constant DATA_FILE             => catfile(updir(), updir(), 'data', 'profiling', 'block_size.csv');
use constant NO_BLOCKING_BLOCKSIZE => 0;

use constant COL_DATASET           => 0;
use constant COL_BLOCKSIZE         => 1;
use constant COL_DIMENSIONS        => 3;
use constant COL_VECTORS           => 4;
use constant COL_TOTALTIME         => 5;
use constant COL_TOTALTIME_NORM    => 6;
use constant COL_FUNCTIME          => 9;
use constant COL_FUNCTIME_NORM     => 10;
use constant COL_DISTCALLS         => 11;
use constant COL_DISTCALLS_NORM    => 12;
use constant COL_PRUNED            => 13;
use constant COL_PRUNED_NORM       => 14;
#-------------------------------------------------------------------------------

# Make sure an output file was specified
scalar(@ARGV) >= 1 || die('No output file specified!');
my $output_file = $ARGV[0];

# Parse the data
my %data = ();
my @block_sizes = ();
open(DATA, "<${\(catfile(dirname($0), DATA_FILE))}") || die("Cannot open data file: ${\(catfile(dirname($0), DATA_FILE))}");
my $in_header = 1;
for (<DATA>) {
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
close(DATA);

# Create the graphs
open(GNUPLOT, "| gnuplot >${\(devnull())}");
print GNUPLOT <<END_OF_GNUPLOT;
reset
set terminal tikz color size 10cm, 10cm
set datafile separator ','

# Define axis
# Remove border on top and right and set color to gray
set style line 11 lc rgb '#808080' lt 1
set border 3 back ls 11

# Global options
set autoscale
set nokey

END_OF_GNUPLOT

# Output the header
my $loop_over;
if (basename($0) =~ m/legend.tex.pl/) {
    $loop_over = 'dataset';
    print GNUPLOT <<END_OF_GNUPLOT;
################################################################################
# LEGEND
################################################################################
set key above
set terminal tikz color size 10cm, 20cm
END_OF_GNUPLOT
} elsif (basename($0) =~ m/distance_calls.tex.pl/) {
    $loop_over = 'dataset';
    print GNUPLOT <<END_OF_GNUPLOT;
################################################################################
# DISTANCE CALLS
################################################################################
set log x
set xlabel "\\textbf{Block size}"
set format x "\$10^{%L}\$"
set ylabel "\\textbf{Calls to the distance function (normalised)}"
END_OF_GNUPLOT
} elsif (basename($0) =~ m/function_execution_time.linear.tex.pl/) {
    $loop_over = 'dataset';
    print GNUPLOT <<END_OF_GNUPLOT;
################################################################################
# FUNCTION EXECUTION TIME
################################################################################
set log x
set xlabel "\\textbf{Block size}"
set format x "\$10^{%L}\$"
set ylabel "\\textbf{Function execution time (normalised)}"
END_OF_GNUPLOT
} elsif (basename($0) =~ m/function_execution_time.logarithmic.tex.pl/) {
    $loop_over = 'dataset';
    print GNUPLOT <<END_OF_GNUPLOT;
################################################################################
# FUNCTION EXECUTION TIME
################################################################################
set log x
set xlabel "\\textbf{Block size}"
set format x "\$10^{%L}\$"
set ylabel "\\textbf{Function execution time (normalised)}"
set logscale xy
END_OF_GNUPLOT
} elsif (basename($0) =~ m/total_execution_time.linear.tex.pl/) {
    $loop_over = 'dataset';
    print GNUPLOT <<END_OF_GNUPLOT;
################################################################################
# TOTAL EXECUTION TIME
################################################################################
set log x
set xlabel "\\textbf{Block size}"
set format x "\$10^{%L}\$"
set ylabel "\\textbf{Total execution time (normalised)}"
END_OF_GNUPLOT
} elsif (basename($0) =~ m/total_execution_time.logarithmic.tex.pl/) {
    $loop_over = 'dataset';
    print GNUPLOT <<END_OF_GNUPLOT;
################################################################################
# TOTAL EXECUTION TIME
################################################################################
set log x
set xlabel "\\textbf{Block size}"
set format x "\$10^{%L}\$"
set ylabel "\\textbf{Total execution time (normalised)}"
set logscale xy
END_OF_GNUPLOT
} elsif (basename($0) =~ m/vectors_pruned.tex.pl/) {
    $loop_over = 'dataset';
    print GNUPLOT <<END_OF_GNUPLOT;
################################################################################
# NUMBER OF VECTORS PRUNED
################################################################################
set log x
set xlabel "\\textbf{Block size}"
set format x "\$10^{%L}\$"
set ylabel "\\textbf{Number of vectors pruned (normalised)}"
END_OF_GNUPLOT
} elsif (basename($0) =~ m/function_run_time_complexity.tex.pl/) {
    $loop_over = "blocksize";
    print GNUPLOT <<END_OF_GNUPLOT;
################################################################################
# FUNCTION RUN TIME COMPLEXITY
################################################################################
set log x
set xlabel "\\textbf{Problem size}"
set format x "\$10^{%L}\$"
set ylabel "\\textbf{Function execution time}"
END_OF_GNUPLOT
} elsif (basename($0) =~ m/total_run_time_complexity.tex.pl/) {
    $loop_over = 'blocksize';
    print GNUPLOT <<END_OF_GNUPLOT;
################################################################################
# TOTAL RUN TIME COMPLEXITY
################################################################################
set log x
set xlabel "\\textbf{Problem size}"
set format x "\$10^{%L}\$"
set ylabel "\\textbf{Total execution time}"
END_OF_GNUPLOT
} else {
    close(GNUPLOT);
    unlink($output_file);
    die("No action to take for script: ${\(basename($0))}");
}
print GNUPLOT <<END_OF_GNUPLOT;
set output "$output_file"
plot \\
END_OF_GNUPLOT

# Output the data
my @all_data = ();
if ($loop_over =~ m/dataset/) {
    my $colour_counter = 0;
    for my $dataset (sort keys %data) {
        my $dataset_clean = latex_escape($dataset);

        my $the_column;
        my $no_blocking_value;
        if (basename($0) =~ m/legend.tex.pl/) {
            $the_column = ${\(COL_DISTCALLS_NORM + 1)};
            $no_blocking_value = $data{$dataset}{${\NO_BLOCKING_BLOCKSIZE}}{'distcalls'};
        } elsif (basename($0) =~ m/distance_calls.tex.pl/) {
            $the_column = ${\(COL_DISTCALLS_NORM + 1)};
            $no_blocking_value = $data{$dataset}{${\NO_BLOCKING_BLOCKSIZE}}{'distcalls'};
        } elsif (basename($0) =~ m/function_execution_time.(linear|logarithmic).tex.pl/) {
            $the_column = ${\(COL_FUNCTIME_NORM + 1)};
            $no_blocking_value = $data{$dataset}{${\NO_BLOCKING_BLOCKSIZE}}{'functime'};
        } elsif (basename($0) =~ m/total_execution_time.(linear|logarithmic).tex.pl/) {
            $the_column = ${\(COL_TOTALTIME_NORM + 1)};
            $no_blocking_value = $data{$dataset}{${\NO_BLOCKING_BLOCKSIZE}}{'totaltime'};
        } elsif (basename($0) =~ m/vectors_pruned.tex.pl/) {
            $the_column = ${\(COL_PRUNED_NORM + 1)};
            $no_blocking_value = $data{$dataset}{${\NO_BLOCKING_BLOCKSIZE}}{'pruned'};
        } else {
            close(GNUPLOT);
            unlink($output_file);
            die("No action to take for script: ${\(basename($0))}");
        }
        my $data =<<END_OF_GNUPLOT;
    "<perl -e \\" \\
use strict; \\
use warnings; \\
\\
use lib '${\(catdir(dirname($0), updir(), updir(), 'scripts'))}'; \\
require 'util.pl'; \\
\\
open(FILE, '<${\(catdir(dirname($0), DATA_FILE))}'); \\
my \\\\\$in_header = 1; \\
for my \\\\\$line (<FILE>) { \\
    if (\\\\\$in_header) { \\
        \\\\\$in_header = 0; \\
        next; \\
    } \\
    \\
    my \@columns = csv_get_fields(\\\\\$line); \\
    if (\\\\\$columns[${\COL_BLOCKSIZE}] != 0 && \\\\\$columns[${\COL_DATASET}] eq '$dataset') { \\
        print \\\\\$line; \\
    } \\
} \\
close(FILE);\\"" \\
        using ${\(COL_BLOCKSIZE + 1)}:$the_column smooth unique \\
        title '$dataset_clean' with linespoints lt 1 lc $colour_counter, \\
    $no_blocking_value title '$dataset_clean (no blocking)' with line lt 0 lc $colour_counter \\
END_OF_GNUPLOT
        push(@all_data, $data);
        $colour_counter++;
    }
} elsif ($loop_over =~ m/blocksize/) {
    my $colour_counter = 0;
    for my $blocksize (@block_sizes) {
        my $blocksize_text = latex_escape("block_size=$blocksize");

        my $the_column;
        if (basename($0) =~ m/total_run_time_complexity.tex.pl/) {
            $the_column = ${\(COL_TOTALTIME + 1)};
        } elsif (basename($0) =~ m/function_run_time_complexity.tex.pl/) {
            $the_column = ${\(COL_FUNCTIME + 1)};
        } else {
            close(GNUPLOT);
            unlink($output_file);
            die('No action to take');
        }
        my $data = <<END_OF_GNUPLOT;
    "<perl -e \\" \\
use strict; \\
use warnings; \\
\\
use lib '${\(catdir(dirname($0), updir(), updir(), 'scripts'))}'; \\
require 'util.pl'; \\
\\
open(FILE, '<${\(catfile(dirname($0), DATA_FILE))}'); \\
my \\\\\$in_header = 1; \\
for my \\\\\$line (<FILE>) { \\
    if (\\\\\$in_header) { \\
        \\\\\$in_header = 0; \\
        next; \\
    } \\
    \\
    my \@columns = csv_get_fields(\\\\\$line); \\
    if (\\\\\$columns[${\COL_BLOCKSIZE}] == $blocksize) { \\
        print \\\\\$line; \\
    } \\
} \\
close(FILE);\\\"" \\
        using ${\(COL_VECTORS + 1)}:$the_column smooth unique \\
        title '$blocksize_text' with linespoints lt 1 lc $colour_counter \\
END_OF_GNUPLOT
        push(@all_data, $data);
        $colour_counter++;
    }
} else {
    close(GNUPLOT);
    unlink($output_file);
    die('No action to take');
}

print GNUPLOT join(',', @all_data);
close(GNUPLOT);

# Remove data point from legend output file.
# This is used so that we can show one (common) legend for all data sets instead
# of showing one legend per plot.
if (basename($0) =~ m/legend.tex.pl/) {
    open(LEGEND, "<$output_file") || die("Cannot open file: $output_file");
    my @output = ();
    my $in_legend = 0;
    for my $line (<LEGEND>) {
        use constant FLOAT_REGEX => '\d+(\.\d+)?';
        use constant POS_REGEX => '(left|center|right)';
        use constant ROT_REGEX => 'rotate=(\+|-)?\d{1-3}';
        use constant SIZE_REGEX => '(cm|mm)';
        use constant COMMENT_REGEX => '%%.*';
        chomp($line);
        if ($in_legend) {
            if ($line =~ m/^${\COMMENT_REGEX}/) {
                next;
            } elsif ($line =~ m/^\\draw\[gp path\] \(${\FLOAT_REGEX},${\FLOAT_REGEX}\)--\(${\FLOAT_REGEX},${\FLOAT_REGEX}\);$/) {
                $in_legend = 0;
            }
            push(@output, $line);
        } else {
            if ($line =~ m/^\\gpcolor\{gp lt color border\}$/) {
                $in_legend = 1;
            } elsif ($line =~ m/^\\(begin|end)\{tikzpicture\}(\[gnuplot\])?$/) {
                push(@output, $line);
            } elsif ($line =~ m/^\\gpcolor\{\\gprgb(\{\d+\}){3}\}$/) {
                push(@output, $line);
            } elsif ($line =~ m/\\gpsetlinetype\{gp lt plot \d+\}$/) {
                push(@output, $line);
            } elsif ($line =~ m/\\gpsetlinewidth\{${\FLOAT_REGEX}\}$/) {
                push(@output, $line);
            }

            next;
        }
    }
    close(LEGEND);

    open(LEGEND, ">$output_file") || die("Cannot open file: $output_file");
    print LEGEND join("\n", @output);
    close(LEGEND);
}
