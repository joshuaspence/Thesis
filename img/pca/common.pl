#!/usr/bin/perl

use strict;
use warnings;

use Cwd qw(abs_path);
use File::Basename qw(basename dirname);
use File::Spec::Functions qw(catdir catfile devnull updir);
use Getopt::Long;

#===============================================================================
# Configuration
#===============================================================================
use constant DATA_DIR => catdir(updir(), updir(), 'data', 'pca');
use constant DATA_EXT => '.fig';
use constant MATLAB_TO_TIKZ_DIR => catdir(updir(), updir(), 'lib', 'matlab2tikz', 'src');
#-------------------------------------------------------------------------------

# Make sure an output file was specified
scalar(@ARGV) >= 1 || die('No output file specified!');
my $output_file = $ARGV[0];

# If the output file already exists, check if forced execution was specified
my $force = 0;
GetOptions("f|force" => \$force);
if ($force) {
    print STDERR <<EOF;
Let's not regenerate these figures unless we really have to... it requires a lot
of memory for MATLAB to load the FIG files.
EOF
    $force = 0;
}
(-f $output_file) && !$force && exit 0;

# The figure file
my $data_file = catfile(dirname($0), DATA_DIR, basename($0, ".png.pl") . DATA_EXT);
(-f $data_file) || die("Data file not found: $data_file");

# Create the graphs
open(MATLAB, "|matlab -nosplash -nodisplay >${\(devnull())}");
print MATLAB <<END_OF_MATLAB;
addpath('${\(catdir(dirname($0), MATLAB_TO_TIKZ_DIR))}');

f = hgload('$data_file');
%matlab2tikz('$data_file.tex','height','\\figureheight','width','\\figurewidth','showInfo',false);
print(f,'-dpng','$output_file');
END_OF_MATLAB

# Clean up
close(MATLAB);