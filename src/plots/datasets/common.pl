#!/usr/bin/perl

use strict;
use warnings;

use Cwd qw(abs_path);
use File::Basename qw(basename dirname);
use File::Spec::Functions qw(catdir catfile devnull updir);

#===============================================================================
# Configuration
#===============================================================================
use constant DATA_DIR => catdir(updir(), updir(), updir(), 'data', 'datasets');
use constant DATA_EXT => '.csv';
use constant MATLAB_TO_TIKZ_DIR => catdir(updir(), updir(), updir(), 'lib', 'matlab2tikz', 'src');
#-------------------------------------------------------------------------------

# Make sure an output file was specified
scalar(@ARGV) >= 1 || die('No output file specified!');
my $output_file = $ARGV[0];

# The data file
my $data_file = catfile(dirname($0), DATA_DIR, basename($0, ".tex.pl") . DATA_EXT);
(-f $data_file) || die("Data file not found: $data_file");

# Create the graphs
open(MATLAB, "|matlab -nosplash -nodisplay >${\(devnull())}");
print MATLAB <<END_OF_MATLAB;
addpath('${\(catdir(dirname($0), MATLAB_TO_TIKZ_DIR))}');

in_file = '$data_file';
out_file = '$output_file';

X = csvread(in_file);
n = size(X, 1);
d = size(X, 2);

if d == 2 || d == 3
    if d == 2
        h = scatter(X(:,1), X(:,2), 'x');
    elseif d == 3
        h = scatter3(X(:,1), X(:,2), X(:,3), 'x');
    end
    matlab2tikz(out_file, 'height', '\\figureheight', 'width', '\\figurewidth', 'showInfo', false);
else
    % Touch an empty file
    fclose(fopen(out_file, 'w'));
end
END_OF_MATLAB

# Clean up
close(MATLAB);
