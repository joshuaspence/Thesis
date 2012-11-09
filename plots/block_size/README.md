# Plots
This directory contains plots comparing various benchmarks across the
`commute_distance_anomaly` algorithm against a varying block size. The plots
were produced by `gnuplot` (using the Tikz terminal) and are stored as TEX
files, using data from the file
[data/profiling/block_size.csv](https://github.com/joshuaspence/Thesis/blob/master/data/profiling/block_size.csv).

# Scripts
In addition, this directory contains scripts with a name `DATASET.tex.pl` (which
all symlink to the `common.pl` script), which can be used to regenerate the TEX
plots. This should rarely need to be done, but is included here for
completeness.
