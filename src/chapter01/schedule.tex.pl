#!/usr/bin/perl

use strict;
use warnings;

use constant START_INDEX => 1;

use Date::Parse;
use File::Basename;
use XML::Simple;

sub days_in_month($) {
    $_[0] = $_[0] % 12;
    
    if ($_[0] == 0) {
        return 31;
    } elsif ($_[0] == 1) {
        return 29;
    } elsif ($_[0] == 2) {
        return 31;
    } elsif ($_[0] == 3) {
        return 30;
    } elsif ($_[0] == 4) {
        return 31;
    } elsif ($_[0] == 5) {
        return 30;
    } elsif ($_[0] == 6) {
        return 31;
    } elsif ($_[0] == 7) {
        return 31;
    } elsif ($_[0] == 8) {
        return 30;
    } elsif ($_[0] == 9) {
        return 31;
    } elsif ($_[0] == 10) {
        return 30;
    } elsif ($_[0] == 11) {
        return 31;
    }
}

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

sub to_tabs($) {
    my $str = "";
    for (my $i = 0; $i < 4 * $_[0]; $i++) {
        $str = "$str ";
    }
    return $str;
}

################################################################################

# The argument should be the base directory for the profiling data
scalar(@ARGV) >= 1 || die("No output file specified!\n");
my $output_file = $ARGV[0];
open(FILE, ">$output_file") || die("Failed to open file: $output_file");

my $xml = new XML::Simple (KeyAttr=>[]);
my $data = $xml->XMLin(dirname($0)."/schedule.xml");
my @tasks = $data->{tasks};
my @milestones = $data->{milestones};


################################################################################
# HEADER
################################################################################
my $tabs = 0;
$start_month = $data->{start} - 1;
$end_month = $data->{end} - 1;
$divisions = $data->{divisions};
my $cols = ($end_month - $start_month + 1) * $divisions;
print FILE <<END;
A Gantt chart showing the anticipated schedule for the project is shown in 
\\autoref{fig:ganttChart}. This will be updated as the project progresses.

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
$tabs = 3;

################################################################################
# TASKS
################################################################################
for my $task (@{$data->{task}}) {   
    my $start       = date_position($task->{start});
    my $end         = date_position($task->{end});
    my $length      = $end - $start;
    print FILE to_tabs($tabs)."\\ganttbar[name=$task->{id}]{$task->{name}}{$start}{$length} \\ganttnewline\n";
    
    for my $dep (%{$task->{dependency}}) {
        print FILE to_tabs($tabs)."\\ganttlink{$dep}{$task->{id}}\n";
    }
    if (ref($task->{dependency}) eq 'ARRAY') {
        for my $dep (@{$task->{dependency}}) {
            print FILE to_tabs($tabs)."\\ganttlink{$dep->{id}}{$task->{id}}\n";
        }
    } elsif (ref($task->{dependency}) eq 'HASH' && $task->{dependency}->{id}) {
        print FILE to_tabs($tabs)."\\ganttlink{$task->{dependency}->{id}}{$task->{id}}\n";
    }
}
print FILE "\n";

################################################################################
# MILESTONES
################################################################################
for my $milestone (@{$data->{milestone}}) {    
    my $position = date_position($milestone->{date});
    print FILE to_tabs($tabs)."\\ganttmilestone[name=$milestone->{id}]{$milestone->{name}}{$position} \\ganttnewline\n";
    
    if (ref($milestone->{dependency}) eq 'ARRAY') {
        for my $dep (@{$milestone->{dependency}}) {
            print FILE to_tabs($tabs)."\\ganttlink{$dep->{id}}{$milestone->{id}}\n";
        }
    } elsif (ref($milestone->{dependency}) eq 'HASH' && $milestone->{dependency}->{id}) {
        print FILE to_tabs($tabs)."\\ganttlink{$milestone->{dependency}->{id}}{$milestone->{id}}\n";
    }
}

################################################################################
# FOOTER
################################################################################
print FILE <<END;
        \\end{ganttchart}
    }
    \\caption{Schedule for thesis work}
    \\label{fig:ganttChart}
\\end{figure}
END

close(FILE);
