#!/bin/sh
OUTPUT_PDF=$(readlink -f $(dirname $0))/../src/thesis.pdf
pdftotext $OUTPUT_PDF - | egrep -e '\w\w\w+' | iconv -f ISO-8859-15 -t UTF-8 | wc -w
