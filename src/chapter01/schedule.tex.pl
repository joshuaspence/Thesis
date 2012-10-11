#!/usr/bin/perl

use strict;
use warnings;

use File::Basename qw(basename dirname);
use File::Spec::Functions qw(catdir catfile updir);

use Date::Parse;
use File::Basename;
use XML::Simple;

use FindBin;
use lib $FindBin::Bin . "/../../scripts";
require "util.pl";

#===============================================================================
# Configuration
#===============================================================================
use constant START_INDEX => 1;
use constant SCHEDULE_FILE => catfile(dirname($0), updir(), updir(), 'data', 'schedule.xml');
#-------------------------------------------------------------------------------

my $start_month;
my $end_month;
my $divisions;
sub date_position($) {
    my $dummy;
    my $month;
    my $day;
    ($dummy,$dummy,$dummy,$day,$month,$dummy,$dummy) = strptime($_[0]);
    
    my $width = ($month - $start_month) * $divisions;
    $width = $width + (($day - 1) / days_in_month($month));
    $width = START_INDEX + $width;
    return $width;
}

# The argument should be the base directory for the profiling data
scalar(@ARGV) >= 1 || die('No output file specified');
my $output_file = $ARGV[0];
open(OUTPUT, ">$output_file") || die("Failed to open output file: $output_file");

my $xml        = new XML::Simple (KeyAttr=>[]);
my $data       = $xml->XMLin(SCHEDULE_FILE) || die("Failed to open input file: ${\SCHEDULE_FILE}");
my @tasks      = $data->{tasks};
my @milestones = $data->{milestones};

# HEADER
$start_month = $data->{start} - 1;
$end_month   = $data->{end} - 1;
$divisions   = $data->{divisions};
my $cols     = ($end_month - $start_month + 1) * $divisions;
print OUTPUT <<END;
A Gantt chart showing the anticipated schedule for the project is shown in
\\autoref{ganttChart}. This will be updated as the project progresses.

% Gantt chart
\\begin{figure}[h]
    \\centering
    \\scalebox{0.5}{
        \\begin{ganttchart}[$data->{options}]{$cols}
            \\gantttitle{2012}{$cols} \\ganttnewline
            \\gantttitlelist[title list options={%
                var=\\y, evaluate=\\y as \\x%
                using "\\pgfcalendarmonthshortname{\\y}"%
                }]{$start_month,...,$end_month}{$divisions} \\ganttnewline
END

# TASKS
for my $task (@{$data->{task}}) {   
    my $start  = date_position($task->{start});
    my $end    = date_position($task->{end});
    my $length = $end - $start;
    print OUTPUT "\\ganttbar[name=$task->{id}]{$task->{name}}{$start}{$length} \\ganttnewline\n";
    
    if (ref($task->{dependency}) eq 'ARRAY') {
        for my $dep (@{$task->{dependency}}) {
            print OUTPUT "\\ganttlink{$dep->{id}}{$task->{id}}\n";
        }
    } elsif (ref($task->{dependency}) eq 'HASH' && $task->{dependency}->{id}) {
        print OUTPUT "\\ganttlink{$task->{dependency}->{id}}{$task->{id}}\n";
    }
}

# MILESTONES
for my $milestone (@{$data->{milestone}}) {    
    my $position = date_position($milestone->{date});
    print OUTPUT "\\ganttmilestone[name=$milestone->{id}]{$milestone->{name}}{$position} \\ganttnewline\n";
    
    if (ref($milestone->{dependency}) eq 'ARRAY') {
        for my $dep (@{$milestone->{dependency}}) {
            print OUTPUT "\\ganttlink{$dep->{id}}{$milestone->{id}}\n";
        }
    } elsif (ref($milestone->{dependency}) eq 'HASH' && $milestone->{dependency}->{id}) {
        print OUTPUT "\\ganttlink{$milestone->{dependency}->{id}}{$milestone->{id}}\n";
    }
}

# FOOTER
print OUTPUT <<END;
        \\end{ganttchart}
    }
    \\caption{Schedule for Thesis work}
    \\label{ganttChart}
\\end{figure}
END

close(OUTPUT);
