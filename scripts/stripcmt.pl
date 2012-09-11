#!/usr/bin/perl

undef $/;
$text = <>;

# C style comments (// comment)
$text =~ s/\/\*+([^*]|\*(?!\/))*\*+\///g;

# C++ style comments (/* comment */)
$text =~ s/\/\/[^\n\r]*(\n\r)?//g;

# Remove double blank lines
$text =~ s/\n(\s+\n)+/\n/g;

print $text;
