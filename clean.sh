#!/bin/sh

################################################################################
#
# This script should be run to clean all dynamically-created source files.
#
################################################################################

$(dirname $0)/img/clean.sh $@
$(dirname $0)/plots/clean.sh $@