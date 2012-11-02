# Plots
This directory contains pie charts comparing function execution time within the
`commute_distance_anomaly` algorithm. The plots are produced from CSV data from
the file [data/profiling/matlab.csv](https://github.com/joshuaspence/Thesis/blob/master/data/profiling/matlab.csv)
and are rendered using LaTex `pieplots` macros.

# Scripts
In addition, this directory contains scripts with a name `DATASET.tex.pl` (which
all symlink to the `common.pl` script), which can be used to regenerate the TEX
plots. This should rarely need to be done, but is included here for
completeness.

# Dependencies
- The following Perl modules are required to regenerate the data plots:
    -- Cwd
    -- File::Basename
    -- File::Spec