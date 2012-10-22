# Introduction
This is my Thesis that was undertaken during my final year of study at the
*University of Sydney*, as a part of my *Bachelor of Electrical Engineering
(Computer)* undergraduate degree.

# Subdirectories
**data:** Data obtained during the thesis project. Data in this directory is
parsed and plotted during the build process.
**ext:** External library code.
**forms:** University administrivia.
**img:** Images used in the Thesis.
**scripts:** Generally useful scripts (**not** used in the build process).
**src:** LaTeX source files.

# Building
To compile the Thesis, simply run the following command. Please note that I have
only tested the build process under a Linux (Ubuntu) system. Some tools and/or
scripting languages may be required to complete the build process. The compiled
Thesis will be output to `src/thesis.pdf`.

```shell
make -C src
```