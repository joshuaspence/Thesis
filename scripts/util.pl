#!/usr/bin/perl

################################################################################
#
# A utility file with various common functions.
#
################################################################################

#===============================================================================
# Escapes special characters for LaTeX
#
# Usage:
#     latex_escape($string)
#===============================================================================
sub latex_escape($) {
    my $string = $_[0];
    $string =~ s/_/\\_/g;
    return $string;
}

# Necessary to "require" this file from other perl scripts.
1;
