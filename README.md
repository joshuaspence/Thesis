# Introduction
This is my Thesis that was undertaken during my final year of study at the
*University of Sydney*, as a part of my *Bachelor of Electrical Engineering
(Computer)* undergraduate degree.

# Building
To compile the Thesis, simply run the following command. Please note that I have
only tested the build process under a Linux (Ubuntu) system. Some tools and/or
scripting languages may be required to complete the build process. The compiled
Thesis will be output to `src/thesis.pdf`.

```shell
make -C src
```

I have used the [latex-makefile](http://code.google.com/p/latex-makefile/), by
Chris Monson, to build the LaTeX project. This makefile has proved to be a
useful tool to manage the convoluted LaTeX build process, and also for the
generation of TeX files from scripting language (Python, Perl and Shell)
scripts. This feature was used to create plots from my raw data.

# Dependencies
The following are required to compile my Thesis. Please note that this list is
not exhaustive.
    - TODO