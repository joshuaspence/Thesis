#!/usr/bin/perl

use strict;
use warnings;

use Cwd 'abs_path';
use File::Basename;
use Math::Trig ':pi';
use Text::CSV;
my $csv = Text::CSV->new();

#===============================================================================
# Configuration
#===============================================================================
my $DATA_FILE = abs_path(dirname($0))."/../../../../data/matlab_profile.csv";

use constant OTHER_FUNCTION => "__other__";
use constant THRESHOLD      => "0.01";
use constant PROFILE        => "matlab_unsorted_inline";

use constant COL_PROFILE      => 0;
use constant COL_DATASET      => 1;
use constant COL_ITERATION    => 2;
use constant COL_FUNCTION     => 3;
use constant COL_CALLS        => 4;
use constant COL_CALLSREL     => 5;
use constant COL_TOTALTIME    => 6;
use constant COL_TOTALTIMEREL => 7;
use constant COL_SELFTIME     => 8;
use constant COL_SELFTIMEREL  => 9;
#-------------------------------------------------------------------------------

# Make sure an output file was specified
scalar(@ARGV) >= 1 || die("No output file specified!\n");
my $output_file = $ARGV[0];

# Parse the data
my %data = ();
open(FILE, "< $DATA_FILE") || die("Cannot open file: $DATA_FILE");
my $in_header = 1;
for (<FILE>) {
    # Skip the header
    if ($in_header) {
        $in_header = 0;
        next;
    }
    
    my @columns;
    if ($csv->parse($_)) {
        @columns = $csv->fields();
    } else {
        my $err = $csv->error_input;
        die("Failed to parse line: $err");
    }
    
    my $profile       = $columns[COL_PROFILE];
    my $dataset       = $columns[COL_DATASET];
    my $iteration     = $columns[COL_ITERATION];
    my $function      = $columns[COL_FUNCTION];
    my $totaltime_rel = $columns[COL_TOTALTIMEREL];
    my $selftime_rel  = $columns[COL_SELFTIMEREL];
    
    if ($totaltime_rel < THRESHOLD || $selftime_rel < THRESHOLD) {
        $function = OTHER_FUNCTION;
    }
    
    if ($iteration eq "average") {
        if (!exists $data{$dataset}) {
            $data{$dataset} = ();
        }
        if (!exists $data{$dataset}{$profile}) {
            $data{$dataset}{$profile} = ();
        }
        if (!exists $data{$dataset}{$profile}{$function}) {
            $data{$dataset}{$profile}{$function} = 0;
        }
        
        $data{$dataset}{$profile}{$function} += $totaltime_rel;
    }
}
close(FILE);

if (basename($0) =~ m/all_datasets.tex.pl/) {
    open(TEX, ">$output_file") or die("Cannot open file: $output_file");
    
    for my $dataset (keys %data) {
        print TEX <<END_OF_TEX;
\\begin{figure}
	\\centering
	\\input{chapter04/plots/matlab_profiling/$dataset}
	\\caption{}
	\\label{fig:matlabProfiling:$dataset}
\\end{figure}

END_OF_TEX
    }
    
    close(TEX);
} else {
    open(GNUPLOT,"|gnuplot");
    print GNUPLOT <<END_OF_GNUPLOT;
reset
set terminal tikz solid color size 10cm, 20.88cm
set datafile separator ','

# Global options
set size square
set isosample 50,50
set parametric
set xrange [-1:1]
set yrange [-1:1]
set vrange [0:1]
unset border
unset xtics
unset ytics
unset colorbox

set view map
#set palette rgbformulae 7,5,15
set palette defined (0 0 0 0, 1 0 0 1, 3 0 1 0, 4 1 0 0, 6 1 1 1)
set cbrange [0:50] # the color palette

END_OF_GNUPLOT

    my $u_begin = 0;
    my $u_end = 0;
    my $i = 0;
    my $dataset = basename($0, ".tex.pl");
    
    print GNUPLOT <<END_OF_GNUPLOT;
################################################################################
# $dataset
################################################################################
set output "$output_file"
set multiplot

END_OF_GNUPLOT
    
    my $the_profile = PROFILE;
    for my $function (keys %{$data{$dataset}{$the_profile}}) {
        my $proportion = $data{$dataset}{$the_profile}{$function};
        
        if ($proportion > 0) {
            $u_end = $u_begin + $proportion;
            my $angle = ($u_begin + $u_end) * pi;
            
            my $x = cos($angle);
            $x = ($x > 0 && $x + 0.2 || $x - 0.2);
            my $y = sin($angle);
            $y = ($y > 0 && $y + 0.2 || $y - 0.2);
            
            my $i_plus_one = $i + 1;
            
            print GNUPLOT <<END_OF_GNUPLOT;
set urange [$u_begin*2*pi : $u_end*2*pi]
splot cos(u)*v,sin(u)*v,$i w pm3d notitle
#set label $i_plus_one center "$function" at $x,$y rotate by $angle*180/pi
END_OF_GNUPLOT
            
            $u_begin = $u_end;
            $i++;
        }
    }
    
    print GNUPLOT <<END_OF_GNUPLOT;
unset multiplot

END_OF_GNUPLOT

    close(GNUPLOT);
}
