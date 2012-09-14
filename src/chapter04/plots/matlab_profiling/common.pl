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

sub clean($) {
    my $cleaned = $_[0];
    $cleaned =~ s/_/\\_/g;
    $cleaned =~ s/\.\.\./\\ldots{}/g;
    return $cleaned;
}

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

open(TEX, ">$output_file") or die("Cannot open file: $output_file");

for my $dataset (keys %data) {
    print TEX <<END_OF_TEX;
\\begin{tikzpicture}
	\\centering
	\\pie[text=legend]{
END_OF_TEX
    
    my $the_profile = PROFILE;
    my @output = ();
    for my $function (keys %{$data{$dataset}{$the_profile}}) {
        my $function_clean = clean($function);
        my $proportion = 100 * $data{$dataset}{$the_profile}{$function};
        push(@output, "$proportion/{$function_clean}");
    }
    print TEX join(",\n", @output);
    
    print TEX <<END_OF_TEX;
    
	}
	%\\caption{}
	\\label{fig:matlabProfiling:$dataset}
\\end{tikzpicture}

END_OF_TEX
}

close(TEX);
