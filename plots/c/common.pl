#!/usr/bin/perl

use strict;
use warnings;

use Cwd qw(abs_path);
use File::Basename qw(basename dirname);
use File::Spec::Functions qw(catdir catfile devnull updir);
use Getopt::Long;

use lib catdir(dirname($0), updir(), updir(), 'scripts');
require 'util.pl';

#===============================================================================
# Configuration
#===============================================================================
use constant DATA_FILE         => catfile(updir(), updir(), 'data', 'profiling', 'c.csv');
use constant THIS_DIR          => 'plots/c'; # for LaTeX \input command

use constant OTHER_FUNCTION    => 'Other';
use constant THRESHOLD         => '0.01';
use constant PROFILE           => 'TopN_Outlier_Pruning_Block_UNSORTED';

use constant COL_PROFILE       => 0;
use constant COL_DATASET       => 1;
use constant COL_ITERATION     => 2;
use constant COL_FUNCTION      => 3;
use constant COL_CALLS         => 4;
use constant COL_CALLSREL      => 5;
use constant COL_SELFTIME      => 6;
use constant COL_SELFTIMEREL   => 7;
use constant COL_PROPORTION    => 8;
use constant COL_PROPORTIONREL => 9;
#-------------------------------------------------------------------------------

sub format_name($) {
    my $function = $_[0];
    return $function;
}

my %default_colours = (
    'top_n_outlier_pruning_block' => 'yellow!60',
    'distance_squared'            => 'blue!60',
    'add_neighbour'               => 'orange!60',
    ${\OTHER_FUNCTION}            => 'white!60'
);

# All available colours
my @colours = (
    'blue!60',
    'cyan!60',
    'yellow!60',
    'orange!60',
    'red!60',
    'blue!60!cyan!60',
    'cyan!60!yellow!60',
    'red!60!cyan!60',
    'red!60!blue!60',
    'orange!60!cyan!60',
    'green!60',
    'magenta!60',
    'black!60',
    'gray!60',
    'white!60',
    'brown!60',
    'lime!60',
    'olive!60',
    'pink!60',
    'purple!60',
    'teal!60',
    'violet!60'
);
sub get_colour($) {
    if (scalar(@colours) <= 0) {
        die('No more available colours');
    }

    my $colour;
    if (exists $default_colours{format_name($_[0])}) {
        my $requested_colour = $default_colours{format_name($_[0])};

        for (my $i = 0; $i < scalar(@colours); $i++) {
            $colour = shift(@colours);
            if ($colour ne $requested_colour) {
                push(@colours, $colour);
            } else {
                $i++;
            }
        }

        return $requested_colour;
    } else {
        $colour = shift(@colours);
        push(@colours, $colour);
        return $colour;
    }
}

sub format_number($) {
    return sprintf("%0.2f", $_[0]);
}
#-------------------------------------------------------------------------------

# Make sure an output file was specified
scalar(@ARGV) >= 1 || die('No output file specified!');
my $output_file = $ARGV[0];

# If the output file already exists, check if forced execution was specified
my $force = 0;
GetOptions("f|force" => \$force);
(-f $output_file) && !$force && exit 0;

# Parse the data
my %data = ();
my %function_colours = ();
open(FILE, "<${\(catfile(dirname($0), DATA_FILE))}") || die("Cannot open file: ${\(catfile(dirname($0), DATA_FILE))}");
my $in_header = 1;
for (<FILE>) {
    # Skip the header
    if ($in_header) {
        $in_header = 0;
        next;
    }

    my @columns        = csv_get_fields($_);
    my $profile        = $columns[COL_PROFILE];
    my $dataset        = $columns[COL_DATASET];
    my $iteration      = $columns[COL_ITERATION];
    my $function       = format_name($columns[COL_FUNCTION]);
    my $selftime_rel   = $columns[COL_SELFTIMEREL];
    my $proportion_rel = $columns[COL_PROPORTIONREL];

    # If this function is fairly small, bundle it with other small functions
    if ($proportion_rel < THRESHOLD) {
        $function = OTHER_FUNCTION;
    }

    if ($iteration eq 'average') {
        if (!exists $data{$dataset}) {
            $data{$dataset} = ();
        }
        if (!exists $data{$dataset}{$profile}) {
            $data{$dataset}{$profile} = ();
        }
        if (!exists $data{$dataset}{$profile}{$function}) {
            $data{$dataset}{$profile}{$function} = 0;
        }
        if (!exists $function_colours{$function}) {
            $function_colours{$function} = get_colour($function);
        }

        $data{$dataset}{$profile}{$function} += $proportion_rel;
    }
}
close(FILE);

# Write to output file
open(TEX, ">$output_file") or die("Cannot open file: $output_file");

if (basename($0) =~ m/all_datasets.tex.pl/) {
    print TEX "\\begin{pieplots}{fig:profiling:c}{C profiling plots}\n";

    for my $dataset (keys %data) {
        print TEX "\\pieplot{\\escape{$dataset}}{\\input{${\THIS_DIR}/$dataset}}\n";
    }
    print TEX "\\end{pieplots}\n";
} elsif (basename($0) =~ m/legend.tex.pl/) {
    # Colours
    my @the_colours = ();
    my @the_functions = ();
    for my $function (keys %function_colours) {
        push(@the_colours, $function_colours{$function});

        $function = format_name($function);
        push(@the_functions, "1/\\escape{$function}");
    }

    my $colour_string   = join(',', @the_colours);
    my $function_string = join(",\n", @the_functions);

    print TEX <<END_OF_TEX;
\\pielegend[bound,color={$colour_string}]{
$function_string
}
END_OF_TEX
} else { # we assume that the output file relates to a data set
    my $the_dataset = basename($0, ".tex.pl");
    my $the_profile = PROFILE;
    my @output = (); # buffered output

    # Colours
    my @the_colours = ();
    for my $function (keys %{$data{$the_dataset}{$the_profile}}) {
        push(@the_colours, $function_colours{$function});
    }

    my $colour_string = join(',', @the_colours);
    print TEX <<END_OF_TEX;
\\pie[bound,text=none,radius=1.5,color={$colour_string}]{
END_OF_TEX

    # Data
    for my $function (keys %{$data{$the_dataset}{$the_profile}}) {
        my $proportion = format_number(100 * $data{$the_dataset}{$the_profile}{$function});
        $function = format_name($function);
        push(@output, "$proportion/\\escape{$function}");
    }

    print TEX join(",\n", @output);
    print TEX <<END_OF_TEX;

}
END_OF_TEX
}

close(TEX);
