# Plots
This directory contains principal component analysis (PCA) plots of the
[data/datasets](https://github.com/joshuaspence/Thesis/tree/master/data/datasets)
which were used in this Thesis. The plots were produced by MATLAB and are stored
as PNG files.

# Scripts
In addition, this directory contains scripts with a name `DATASET.png.pl` (which
all symlink to the `common.pl` script), which can be used to regenerate the PNG
plots. This should rarely need to be done, but is included here for
completeness.

In order to plot the PCA plot, this script loads the PCA plot figure (which was
saved using MATLAB) from the
[data/pca](https://github.com/joshuaspence/Thesis/tree/master/data/pca)
directory.

# Dependencies
- bash
- MATLAB is required in order to regenerate the data plots.
- The following Perl modules are required to regenerate the data plots:
    + Cwd
    + File::Basename
    + File::Spec

# Warning
These plots can take a long time to generate, and require a fair amount of
memory. It would be advisable not to regenerate these unless you really have to.