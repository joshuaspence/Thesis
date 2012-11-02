# Plots
This directory contains plots of the raw
[data/datasets](https://github.com/joshuaspence/Thesis/tree/master/data/datasets)
which were used in this Thesis. The plots were produced by MATLAB and are stored
as PNG files.

# Scripts
In addition, this directory contains scripts with a name `DATASET.png.pl` (which
all symlink to the `common.pl` script), which can be used to regenerate the PNG
plots. This should rarely need to be done, but is included here for
completeness.

Plots are only generated for 2D or 3D data sets.

# Dependencies
- bash
- MATLAB is required in order to regenerate the data plots.
- The following Perl modules are required to regenerate the data plots:
    + Cwd
    + File::Basename
    + File::Spec