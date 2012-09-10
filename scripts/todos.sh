#!/bin/bash
grep --recursive --line-number --color=auto --include="*.tex" "%.*TODO" $(dirname $0)/../src
