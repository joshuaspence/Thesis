#!/bin/bash
SRC_DIR="$(dirname $0)/../src"
$(dirname $0)/texcount/texcount.pl -col -merge -incbib -total -dir=$SRC_DIR/ $SRC_DIR/thesis.tex
