#!/bin/sh

################################################################################
#
# Generate all plots that can be generated dynamically.
#
################################################################################

echo "================================================================================"
echo "GENERATING PLOTS"
echo "================================================================================"
./block_size/generate_all.sh
echo "--------------------------------------------------------------------------------"
./c/generate_all.sh
echo "--------------------------------------------------------------------------------"
./matlab/generate_all.sh
echo "--------------------------------------------------------------------------------"
echo ""