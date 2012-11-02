#!/bin/sh

################################################################################
#
# This script should be run to generate all dynamically-created source files.
#
################################################################################

$(dirname $0)/img/generate_all.sh $@
$(dirname $0)/plots/generate_all.sh $@