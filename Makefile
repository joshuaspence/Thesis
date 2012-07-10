# Makefile for compiling a latex document split into multiple directories.
#
# TO OBTAIN INSTRUCTIONS FOR USING THIS FILE, RUN:
#    make help
################################################################################

################################################################################
# External Programs
################################################################################
# Basic Shell Utilities
BASENAME     ?= basename
CONCATENATE  ?= cat
COMPARE      ?= cmp
COPY_FORCE   ?= cp --force
COPY_SAFE    ?= cp
DELETE_FORCE ?= rm --force
DELETE_SAFE  ?= rm
DIRNAME      ?= dirname
ECHO         ?= echo
EXPRESSION   ?= expr
FIND         ?= find
GREP         ?= egrep
LINK         ?= ln --symbolic
MAKE         ?= make
MD5SUM       ?= md5sum
MOVE_FORCE   ?= mv --force
MOVE_SAFE    ?= mv
PERL         ?= perl
READLINK     ?= readlink --canonicalize
SED          ?= sed
SLEEP        ?= sleep
SORT         ?= sort
TAIL         ?= tail
TEST         ?= test
TOUCH        ?= touch
UNIQUE       ?= uniq
XARGS        ?= xargs

# Check whether or not to use 'safe' commands
ifdef SAFE
COPY         ?= $(COPY_SAFE)
DELETE       ?= $(DELETE_SAFE)
MOVE         ?= $(MOVE_SAFE)
else
COPY         ?= $(COPY_FORCE)
DELETE       ?= $(DELETE_FORCE)
MOVE         ?= $(MOVE_FORCE)
endif

# Non-essential programs
PDF_READER   ?= acroread

# Define "DEBUG" to echo commands
ifndef DEBUG
MUTE        ?= @
else
MUTE        ?= 
endif

# Define "VERBOSE" to add verbose options to commands
ifdef VERBOSE
COPY        += --verbose
DELETE      += --verbose
LINK        += --verbose
MAKE        += --debug
MOVE        += --verbose
endif

# Suppress output
NO_STDERR   ?= 2>/dev/null
NO_STDOUT   ?= 1>/dev/null

################################################################################
# Utility macros
################################################################################

# $(call clean-whitespace,string)
#
# Note that "\$$" is used for a single "$" symbol. The backslash is used to 
# escape the "$" symbol for the shell. The additional "$" symbol is used to 
# escape the "$" symbol for make.
define clean-whitespace
$(shell $(ECHO) -n '$1' | \
$(PERL) -e "
use Text::ParseWords;
@words = quotewords('\s+', 1, <STDIN>);
my \$$output = "\"\"";
foreach (@words) {
	\$$output = "\""\$$output \$$_"\""
}
\$$output =~ s/^\s+//;
\$$output =~ s/\s+\$$//;
print(\$$output);")
endef

# $(call trace-message,msg)
trace-message = -@$(ECHO) '$1'

# $(call verbose-message,msg)
ifdef VERBOSE
verbose-message = -@$(ECHO) '$1'
endif

# $(call count,var)
# Count the number of elements in a variable.
count = $(shell $(EXPRESSION) 0 $(foreach V,$1,+ 1))

# $(call print-variable,var)
# Print the name and value of a variable.
print-variable = $(info $1=$($1))

# $(call print-variables)
# Print all makefile variables
define print-variables
$(foreach V,$(sort $(filter-out print-variable%,$(.VARIABLES))), 
	$(if $(filter file,$(origin $V)),
		$(call print-variable,$V)))
endef

# $(call copy,source1 source2 ...,destination)
copy = $(if $1,$(COPY) $1 $2,$(sh_true))

# $(call copy-if-exists,source,destination)
copy-if-exists = $(if $(call test-exists,$1),$(call copy,$1,$2),$(sh_true))

# $(call create-symlinks,source1 source2 ...,destination)
create-symlinks = $(if $1,$(LINK) $1 $2,$(sh_true))

# $(call remove-temporary-files,filenames)
remove-temporary-files = $(if $(KEEP_TEMP),$(sh_true),$(if $1,$(DELETE) $1,$(sh_true)))

# Don't call this directly - it is here to avoid calling wildcard more than
# once in remove-files.
remove-files-helper	= $(if $(call test-exists,$1),$(DELETE) $1,$(sh_true))

# $(call remove-files,file1 file2)
remove-files = $(call remove-files-helper,$(wildcard $1))

# Don't call this directly - it is here to avoid calling wildcard more than
# once in remove-symlinks.
remove-symlinks-helper = $(if $(call test-symlink,$1),$(DELETE) $1,$(sh_true))

# $(call remove-symlinks,file1 file2)
remove-symlinks = $(call remove-symlinks-helper,$(wildcard $1))

# $(call touch-file,file1 file2 ...)
touch-file = $(TOUCH) $1

# $(call create-dependency-file,dependents,dependencies,dependency-file)
create-dependency-file = @$(ECHO) '$1: $2' >> $3

# Test that a file exists
# $(call test-exists,file)
test-exists		= [ -e '$1' ]
# $(call test-not-exists,file)
test-not-exists = [ ! -e '$1' ]

# Test that a symlink exists
# $(call test-symlink,file)
test-symlink	= [ -L '$1' ]

# $(call find-files,path,name)
find-files = $(shell $(FIND) $1 -type f -name $2)

# $(call find-all-files,directory1 directory2 ...,name)
find-all-files = $(strip $(foreach d,$1,$(call find-files,$d,$2)))

# $(call get-relative-path,from,to)
get-relative-path = $(shell \
source="$$($(READLINK) $1)"; \
target="$$($(READLINK) $2)"; \
\
common_part="$$source"; \
back="."; \
while [ "$${target\#$$common_part}" = "$${target}" ]; do \
	common_part="$$($(DIRNAME) $$common_part)"; \
	back="$${back}/.."; \
done; \
\
back=$$($(ECHO) $$back | $(SED) 's/\.\///'); \
\
echo $${back}$${target\#$$common_part}; \
)

# Characters that are hard to specify in certain places
space := $(empty) $(empty)
colon := \:
comma := ,

# Useful shell definitions
sh_true	 := :
sh_false := ! :

# Removes all cleanable files in the given list
# $(call clean-files,file1 file2 file3 ...)
# Works exactly like remove-files, but filters out files in $(neverclean)
clean-files = $(call remove-files-helper,$(call cleanable-files,$(wildcard $1)))

# Utility function for obtaining all files not specified in $(neverclean)
# $(call cleanable-files,file1 file2 file3 ...)
# Returns the list of files that is not in $(wildcard $(neverclean))
cleanable-files = $(filter-out $(wildcard $(neverclean)), $1)

################################################################################
# Author details
#-------------------------------------------------------------------------------
# Author details are parsed from the 'AUTHORS' text file. This file should 
# contain each author on a new line.
################################################################################	
AUTHOR := $(shell $(CONCATENATE) AUTHORS | $(PERL) -p -n -e 's/\r?\n/, /;' | $(PERL) -p -e 's/, $$//;')

################################################################################
# Configuration
#-------------------------------------------------------------------------------
# This makefile is configured in a file named "Configuration.mk".
################################################################################
include Configuration.mk

# Error checking
# To make sure the configuration file contained the appropriate definitions.
ifndef BUILD_DIR
$(error Build directory not specified. 'BUILD_DIR' not defined.)
endif
ifndef EXT_DIRS
$(warning External directory not specified. 'EXT_DIRS' not defined.)
endif
ifndef IMG_DIRS
$(warning Image directory not specified. 'IMG_DIRS' not defined.)
endif
ifndef SRC_DIRS
$(error Source directory not specified. 'SRC_DIRS' not defined.)
endif

ifneq ($(call count,$(BUILD_DIR)),1)
$(error Only one build directory sould be specified.)
endif

# Set default configuration variables
# If these variables were not set in the configuration file
BUILD_DIR  ?=
EXT_DIRS   ?=
IMG_DIRS   ?=
OTHER_DIRS ?=
SRC_DIRS   ?=

BIB_DIRS   ?= $(strip $(SRC_DIRS))
BST_DIRS   ?= $(strip $(EXT_DIRS))
CLS_DIRS   ?= $(strip $(EXT_DIRS))
STY_DIRS   ?= $(strip $(EXT_DIRS)) $(strip $(SRC_DIRS))
TEX_DIRS   ?= $(strip $(SRC_DIRS))

# If set to something, will cause temporary files to not be deleted immediately
KEEP_TEMP ?=

# Some other directories
ROOT_DIR   = .
BUILD_DIR_RELATIVE = $(call get-relative-path,$(BUILD_DIR),$(ROOT_DIR))/

################################################################################
# Automatic stuff
################################################################################
# File extensions
BIB_EXT       := .bib
BST_EXT       := .bst
CLS_EXT       := .cls
DEPS_EXT      := .d
STY_EXT       := .sty
TEX_EXT       := .tex
TIMESTAMP_EXT := .timestamp

# The location of the LaTeX sources files
BIB_SRC = $(call find-all-files,$(BIB_DIRS),"*$(BIB_EXT)")
BST_SRC	= $(call find-all-files,$(BST_DIRS),"*$(BST_EXT)")
CLS_SRC	= $(call find-all-files,$(CLS_DIRS),"*$(CLS_EXT)")
STY_SRC	= $(call find-all-files,$(STY_DIRS),"*$(STY_EXT)")
TEX_SRC	= $(call find-all-files,$(TEX_DIRS),"*$(TEX_EXT)")

# Files/directories to symlink in the build directory
SYMLINK_FILE_DIRS = $(BIB_DIRS) $(BST_DIRS) $(CLS_DIRS) $(STY_DIRS) $(TEX_DIRS)
SYMLINK_FILES     = $(BIB_SRC) $(BST_SRC) $(CLS_SRC) $(STY_SRC) $(TEX_SRC)
SYMLINK_DIRS      = $(IMG_DIRS) $(OTHER_DIRS)
SYMLINKS = $(call clean-whitespace,\
           $(foreach f,$(SYMLINK_FILES),$f) \
		   $(foreach d,$(SYMLINK_DIRS),$d))
SYMLINKS_RELATIVE = $(call clean-whitespace,\
           $(foreach f,$(SYMLINK_FILES),$(call addprefix,$(BUILD_DIR_RELATIVE),$f)) \
		   $(foreach d,$(SYMLINK_DIRS),$(call addprefix,$(BUILD_DIR_RELATIVE),$d)))

all_d_targets         := $(BUILD_DIR)$(DEPS_EXT)
all_timestamp_targets := $(BUILD_DIR)$(TIMESTAMP_EXT)

################################################################################
# Make configuration
################################################################################
.DEFAULT_GOAL := all

# Clear out the standard interfering make suffixes
.SUFFIXES:

################################################################################
# LaTeX build configurations
#-------------------------------------------------------------------------------
# Define rules for compiling the project with LaTeX.
################################################################################
MAKE_LATEX ?= $(MAKE) -C $(BUILD_DIR)

ifdef DEBUG
MAKE_LATEX += SHELL_DEBUG=1
endif

ifdef VERBOSE
MAKE_LATEX += VERBOSE=1
endif

ifdef KEEP_TEMP
MAKE_LATEX += KEEP_TEMP=1
endif

################################################################################
# Automatic configuration
################################################################################

BUILD_FILES          = $(strip $(shell $(FIND) $(BUILD_DIR) -mindepth 1 -type f \( -false $(foreach persist, $(BUILD_PERSIST), -o -name "$(persist)") \) -prune -o -print))
BUILD_FILES_SYMLINKS = $(strip $(shell $(FIND) $(BUILD_DIR) -mindepth 1 \( -type l \) -print))
OUTPUT_PDF 			 = $(strip $(shell $(FIND) $(BUILD_DIR) -mindepth 1 -name "*.pdf" -print))
OUTPUT_PDF_SYMLINKS  = $(strip $(shell $(FIND) $(BUILD_DIR) -mindepth 1 -name "*.pdf" -exec $(BASENAME) {} \;))
BUILD_DEPS           =

################################################################################
# Targets
################################################################################

# Main target.
.PHONY: all
all: $(BUILD_DIR) $(OUTPUT_FILE)

# Compile the LaTeX document.
# Build directory depends on build directory timestamp, which will be 
# out-of-date if symlinks need to be regenerated.
.PHONY: $(BUILD_DIR)
$(BUILD_DIR): $(BUILD_DIR)$(TIMESTAMP_EXT)
	$(MAKE_LATEX)

# Read the output PDF
.PHONY: read
read: $(BUILD_DIR) $(OUTPUT_PDF)
	$(ACROREAD) $(OUTPUT_PDF) &

################################################################################
# Dependency targets
################################################################################

# Build directory dependencies
$(BUILD_DIR)$(DEPS_EXT):
	$(call verbose-message,"Creating $@.")
	$(call create-dependency-file,$(BUILD_DIR)$(TIMESTAMP_EXT),$(SYMLINK_FILE_DIRS),$@)

include $(BUILD_DIR)$(DEPS_EXT)
$(BUILD_DIR)$(TIMESTAMP_EXT): $(BUILD_DIR)$(DEPS_EXT)
	$(call trace-message,"Creating symbolic links.")
	$(call verbose-message,"Deleting existing symlinks.")
	$(call remove-symlinks,$(foreach s,$(SYMLINKS),$(BUILD_DIR)/$(shell $(BASENAME) $s)))
	$(call verbose-message,"Creating new symlinks.")
	$(call create-symlinks,$(SYMLINKS_RELATIVE),$(BUILD_DIR)/)
	$(call verbose-message,"Updating $@.")
	$(call touch-file,$@)

############## ##################################################################
# Symlink targets
################################################################################

# Create a symbolic link to the output PDF
#$(OUTPUT_PDF_SYMLINKS):
#	$(shell $(FIND) $(BUILD_DIR) -type f -name "$(OUTPUT_PDF)" -exec $(LINK) "`$(READLINK) {}`" "$@" \;)


################################################################################
# Clean targets
################################################################################
# Removes build files but not output files.
.PHONY: clean
clean:

# Remove build files and output files
.PHONY: distclean
distclean: clean clean-deps rm-symlinks force-clean-build

# Clean latex build
.PHONY: clean-latex
clean-latex:
	$(call trace-message,"Cleaning latex build.")
	$(MAKE_LATEX) clean

# Remove dependency files
.PHONY: clean-deps
clean-deps:
	$(call trace-message,"Cleaning dependency files.")
	$(MUTE)$(call clean-files,$(all_d_targets))

# Delete symbolic links from the build subdirectory.
.PHONY: rm-symlinks
rm-symlinks:
	$(call trace-message,"Deleting symbolic links from build subdirectory.")
	$(call remove-files,$(foreach s,$(SYMLINKS),$(BUILD_DIR)/$(shell $(BASENAME) $s)) $(SYMLINKS_DONE))

# Delete leftover auxillary files from the build subdirectory.
BUILD_DIR_FILES = $(strip $(shell $(FIND) $(BUILD_DIR) -mindepth 1 -type f \( -false $(foreach p, $(BUILD_PERSIST), -o -name '$p') \) -prune -o -print))
x.PHONY: force-clean-build
force-clean-build:
	$(call trace-message,"Manually removing leftover build files.")
	$(call remove-files,$(BUILD_DIR_FILES))
	
################################################################################
# Informational targets
################################################################################
# Dump makefile variables
.PHONY: info
info:
	$(call variable-dump)

# TODO: Check
define variable-dump
	$(info # Basic Shell Utilities)
	$(call print-variable,BASENAME)
	$(call print-variable,CAT)
	$(call print-variable,COPY_FORCE)
	$(call print-variable,COPY_SAFE)
	$(call print-variable,DELETE_FORCE)
	$(call print-variable,DELETE_SAFE)
	$(call print-variable,DIRNAME)
	$(call print-variable,ECHO)
	$(call print-variable,FIND)
	$(call print-variable,GREP)
	$(call print-variable,LINK)
	$(call print-variable,MAKE)
	$(call print-variable,MD5SUM)
	$(call print-variable,MOVE)
	$(call print-variable,PERL)
	$(call print-variable,READLINK)
	$(call print-variable,SED)
	$(call print-variable,SLEEP)
	$(call print-variable,SORT)
	$(call print-variable,TOUCH)
	$(call print-variable,UNIQUE)
	$(call print-variable,XARGS)
	$(info )
	
	$(info # Configuration)
	$(call print-variable,BUILD_DIR)
	$(call print-variable,EXT_DIRS)
	$(call print-variable,IMG_DIRS)
	$(call print-variable,OTHER_DIRS)
	$(call print-variable,SRC_DIRS)
	$(call print-variable,BIB_DIRS)
	$(call print-variable,BST_DIRS)
	$(call print-variable,CLS_DIRS)
	$(call print-variable,STY_DIRS)
	$(call print-variable,TEX_DIRS)
	$(call print-variable,KEEP_TEMP)
	$(call print-variable,BUILD_PERSIST)
	$(info )
	
	$(info # Sources)
	$(call print-variable,BIB_SRC)
	$(call print-variable,BST_SRC)
	$(call print-variable,CLS_SRC)
	$(call print-variable,STY_SRC)
	$(call print-variable,TEX_SRC)
	$(info )
	
	$(info # Symlinks)
	$(call print-variable,SYMLINKS)
	$(call print-variable,SYMLINKS_DONE)
	$(call print-variable,SYMLINKS_NEW)
endef

# Display help
.PHONY: help
help:
	$(call help-text)

# TODO: Finish
define help-text
#===============================================================================
# Makefile for compiling my thesis.
#-------------------------------------------------------------------------------
# Name:    $(fileinfo)
# Author:  $(author)
# Version: $(version)
#===============================================================================
#
# USAGE:
#     make [VERBOSE=1] [DEBUG=1] [KEEP_TEMP=1] <target(s)>
#
# TARGETS:
#     all                 Runs all tasks necessary to compile the thesis. The
#                         thesis will be output to '$(OUTPUT_PDF)'.
#     compile             Compile the thesis.
#     pre                 Runs any tasks that must be executed before 
#                         compilation can begin.
#     clean               Cleans the '$(BUILD_DIR)' subdirectory.
#     distclean           Removes symbolic links and remaining auxillary files 
#                         from the '$(BUILD_DIR)' subdirectory.
#     read                Compiles the thesis and then opens the document with 
#                         '$(ACROREAD)'.
#     help                Display the help file for instructions on how to 
#                         compile the thesis.
#     check-symlinks      Checks that the symbolic links in the '$(BUILD_DIR)' 
#                         subdirectory are up-to-date. If not, recreate the 
#                         symbolic links.
#     rm-files            Deletes all remaining auxillary files from the 
#                         '$(BUILD_DIR)' subdirectory."
#     rm-symlinks         Deletes the symbolic links from the '$(BUILD_DIR)' 
#                         subdirectory.
#------------------------------------------------------------------------------- 
endef
