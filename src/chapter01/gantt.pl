#!/usr/bin/perl

use strict;
use warnings;

use constant START_MONTH    => 2;
use constant END_MONTH      => 10;
use constant DIVS_PER_MONTH => 4;
use constant START_INDEX    => 1;

use Date::Parse;
use Text::CSV;

sub get_month($) {
    $_[0] = $_[0] % 12;
    
    if ($_[0] == 0) {
        return 'Jan';
    } elsif ($_[0] == 1) {
        return 'Feb';
    } elsif ($_[0] == 2) {
        return 'Mar';
    } elsif ($_[0] == 3) {
        return 'Apr';
    } elsif ($_[0] == 4) {
        return 'May';
    } elsif ($_[0] == 5) {
        return 'Jun';
    } elsif ($_[0] == 6) {
        return 'Jul';
    } elsif ($_[0] == 7) {
        return 'Aug';
    } elsif ($_[0] == 8) {
        return 'Sep';
    } elsif ($_[0] == 9) {
        return 'Oct';
    } elsif ($_[0] == 10) {
        return 'Nov';
    } elsif ($_[0] == 11) {
        return 'Dec';
    }
}

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

sub date_position($$) {
    my $month = ($_[0]);
    my $day = ($_[1]);
    
    my $width = ($month - START_MONTH) * DIVS_PER_MONTH;
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

my $tabs = 0;
print <<END;
\\begin{gantt}[
    xunitlength=0.5cm,
	fontsize=\\small,
	titlefontsize=\\small,
	drawledgerline=true
	]{18}{36}
END
$tabs++;

# Months
print to_tabs($tabs++)."\\begin{ganttitle}\n";
for (my $month = START_MONTH; $month <= END_MONTH; $month++) {
	print to_tabs($tabs)."\\titleelement{", get_month($month), "}{", DIVS_PER_MONTH, "}\n";
}
print to_tabs(--$tabs)."\\end{ganttitle}\n";

# Split months into divisons
print to_tabs($tabs++)."\\begin{ganttitle}\n";
for (my $month = START_MONTH; $month <= END_MONTH; $month++) {
	print to_tabs($tabs)."\\numtitle{1}{1}{", DIVS_PER_MONTH, "}{1}\n";
}
print to_tabs(--$tabs)."\\end{ganttitle}\n\n";

my $csv = Text::CSV->new();
open(TASKS, "schedule.data") || die("Could not open file");
my $in_header = 1;
while (<TASKS>) {
    if ($in_header) {
        $in_header = 0;
        next;
    }
    
    # Parse CSV
    if ($csv->parse($_)) {
        my @columns = $csv->fields();
        my $task       = $columns[0];
        my $start_date = $columns[1];
        my $end_date   = $columns[2];
        
        my $dummy;
        ($dummy,$dummy,$dummy,my $start_day,my $start_month,$dummy,$dummy) = strptime($start_date);
        ($dummy,$dummy,$dummy,my $end_day,my $end_month,$dummy,$dummy) = strptime($end_date);
        
        my $start       = date_position($start_month, $start_day);
        my $end         = date_position($end_month,   $end_day);
        my $length      = $end - $start;
        print to_tabs($tabs)."ganttbar{$task}{$start}{$length}\n";
    } else {
        my $err = $csv->error_input;
        die("Failed to parse line: $err");
    }
}
close(TASKS);

print "\\end{gantt}";
