# Introduction
This is treatise of my Thesis that was undertaken during my final year of study
at the *University of Sydney*, as a part of my *Bachelor of Electrical
Engineering (Computer)* undergraduate degree.

# Abstract
In this Thesis I design a hardware-based approach to an anomaly detection
algorithm. The anomaly detection algorithm uses commute distance to determine
outliers, but suffers largely from a performance bottleneck due to software
limitations. By offloading an algorithmic step to a dedicated hardware
processing unit, it is possible to gain dramatic run time improvements for the
anomaly detection algorithm.

# Treatise
## Building
To compile the treatise, simply run the `make` command. Please note that I have
only tested the build process under a Linux (Ubuntu) system. Some tools and/or
scripting languages may be required to complete the build process. The compiled
Thesis will be output to `src/thesis.pdf`.

I have used [latex-makefile](http://code.google.com/p/latex-makefile/), by Chris
Monson, to build the LaTeX project. This makefile has proved to be a useful tool
to manage the convoluted LaTeX build process, and also for the generation of TeX
files from scripting language (Python, Perl and Shell) scripts.

Before the actual Thesis is compiled (from the
[src](https://github.com/joshuaspence/Thesis/tree/master/src) directory), some
prerequisite sources will be generated from raw data sources. These generated
sources exist in the following locations:
- [code](https://github.com/joshuaspence/Thesis/tree/master/code)
- [img](https://github.com/joshuaspence/Thesis/tree/master/img)
- [plots](https://github.com/joshuaspence/Thesis/tree/master/plots)

## Dependencies
The following are required to compile my Thesis. Please note that this list is
not exhaustive.

## Plotting
- `gnuplot` is required in order to regenerate the data plots in the
    [plots](https://github.com/joshuaspence/Thesis/tree/master/plots)
    subdirectory.
- The gnuplot Tikz terminal is required in order to regenerate the data plots.
- MATLAB is required in order to regenerate the data plots.

## Scripting
- perl

### Perl modules
- Cwd
- File::Basename
- File::Spec
- Text::CSV (from the `libtext-csv-perl` package)

# Presentation
## Building
To build the Thesis presentation, simply run the `make` command in the
[src](https://github.com/joshuaspence/Thesis/tree/master/src) directory, as per
the treatise. The presentation will be output to `src/presentation.pdf`.

# Thesis Works
The source code for the research completed as a part of this Thesis can be found
in a separate repository, at https://github.com/joshuaspence/ThesisCode.
