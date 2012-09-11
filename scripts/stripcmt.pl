#!/usr/bin/perl

################################################################################
#
# Script to remove comments from C/C++ source code, as well as make various 
# other modifications to improve the readability of the code.
#
# Usage:
#     ./stripcmt.pl SOURCE_FILE
#
# Output: Processed source code is output to STDOUT.
#
################################################################################

use strict;
use warnings;

undef $/;
$text = <>;

# C style comments (// comment)
$text =~ s/\/\*+([^*]|\*(?!\/))*\*+\///g;

# C++ style comments (/* comment */)
$text =~ s/\/\/[^\n\r]*(\n\r)?//g;

# Remove double blank lines
$text =~ s/\n(\s+\n)+/\n/g;

print $text;
