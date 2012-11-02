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
use constant DATA_DIR => catdir(updir(), updir(), 'data', 'datasets');
use constant DATA_EXT => '.csv';
use constant MATLAB_EXE => "matlab -nosplash -nodisplay >${\(devnull())}";
use constant MATLAB_TO_TIKZ_DIR => catdir(updir(), updir(), 'lib', 'matlab2tikz', 'src');
#-------------------------------------------------------------------------------

# Make sure an output file was specified
scalar(@ARGV) >= 1 || die('No output file specified!');
my $output_file = $ARGV[0];
my $output_file_none = $output_file . ".none";

# If the output file already exists, check if forced execution was specified
my $force = 0;
GetOptions("f|force" => \$force);
(-f $output_file || -f $output_file_none) && !$force && exit 0;

# The data file
my $data_file = catfile(dirname($0), DATA_DIR, basename($0, ".png.pl") . DATA_EXT);
(-f $data_file) || die("Data file not found: $data_file");

# Create the graphs
open(MATLAB, "|${\MATLAB_EXE}");
print MATLAB <<END_OF_MATLAB;
addpath('${\(catdir(dirname($0), MATLAB_TO_TIKZ_DIR))}');

in_file = '$data_file';
out_file = '$output_file';
out_file_none = '$output_file_none';

X = csvread(in_file);
n = size(X,1);
d = size(X,2);

if d == 2 || d == 3
    f = figure
    if d == 2
        scatter(X(:,1),X(:,2),5,'filled');
    elseif d == 3
        scatter3(X(:,1),X(:,2),X(:,3),5,'filled');
    end
    %matlab2tikz(out_file,'height','\\figureheight','width','\\figurewidth','showInfo',false);
    print(f,'-dpng',out_file);
else
    fclose(fopen(out_file_none,'wb'));
end
END_OF_MATLAB

# Clean up
close(MATLAB);