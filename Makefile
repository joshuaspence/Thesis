# Makefile for compiling my thesis
#
# TO OBTAIN INSTRUCTIONS FOR USING THIS FILE, RUN:
#    make help
################################################################################

################################################################################
# External Programs
################################################################################
# Basic Shell Utilities
BASENAME     ?= basename
CAT          ?= cat
COMPARE      ?= cmp
COPY_FORCE   ?= cp --force
COPY_SAFE    ?= cp
DELETE_FORCE ?= rm --force
DELETE_SAFE  ?= rm
DIRNAME      ?= dirname
ECHO         ?= echo
EXPR         ?= expr
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

# Options
ifndef DEBUG
MUTE        ?= @
else
MUTE        ?= 
endif
ifdef VERBOSE
COPY        += --verbose
DELETE      += --verbose
LINK        += --verbose
MOVE        += --verbose
endif
NO_STDERR   ?= 2>/dev/null
NO_STDOUT   ?= 1>/dev/null

################################################################################
# Author details
#-------------------------------------------------------------------------------
# Author details are parsed from the 'AUTHORS' text file. This file should 
# contain each author on a new line.
################################################################################	
AUTHOR := $(shell $(CAT) AUTHORS | $(PERL) -p -n -e 's/\r?\n/, /;' | $(PERL) -p -e 's/, $$//;')

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

# Files in the build directory which should not be deleted on a 'clean'
BUILD_PERSIST += Makefile Variables.ini latexmkrc

# If set to something, will cause temporary files to not be deleted immediately
KEEP_TEMP ?=

# The location of the LaTeX sources files
BIB_SRC = $(strip $(foreach d, $(BIB_DIRS), $(shell $(FIND) $d -type f -name "*.bib")))
BST_SRC	= $(strip $(foreach d, $(BST_DIRS), $(shell $(FIND) $d -type f -name "*.bst")))
CLS_SRC	= $(strip $(foreach d, $(CLS_DIRS), $(shell $(FIND) $d -type f -name "*.cls")))
STY_SRC	= $(strip $(foreach d, $(STY_DIRS), $(shell $(FIND) $d -type f -name "*.sty")))
TEX_SRC	= $(strip $(foreach d, $(TEX_DIRS), $(shell $(FIND) $d -type f -name "*.tex")))

# Files/directories to symlink in the build directory
SYMLINKS = $(foreach f, $(BIB_SRC), $(realpath $f)) \
           $(foreach f, $(BST_SRC), $(realpath $f)) \
		   $(foreach f, $(CLS_SRC), $(realpath $f)) \
		   $(foreach f, $(STY_SRC), $(realpath $f)) \
		   $(foreach f, $(TEX_SRC), $(realpath $f)) \
		   $(realpath $(IMG_DIR)) \
		   $(foreach d, $(DATA_DIR), $(realpath $d)) \

# Files to indicate that symlinks have been created
SYMLINKS_DONE ?= .symlinks
SYMLINKS_NEW  ?= .symlinks.new

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
# Utility macros
################################################################################

# $(call trace-message,msg)
trace-message = -@$(ECHO) $1

# $(call verbose-message,msg)
ifdef VERBOSE
verbose-message = -@$(ECHO) $1
endif

# $(call count,var)
count = $(shell $(EXPR) 0 $(foreach V,$1,+ 1))

# $(call print-variable,var)
print-variable = $(info $1=$($1))

define print-variables
	$(foreach V,$(sort $(filter-out print-variable%, $(.VARIABLES))), 
		$(if $(filter file,$(origin $V)),
			$(call print-variable,$V)))
endef

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

copy-if-exists = $(if $(call test-exists,$1),$(COPY) '$1' '$2')

# $(call create-symlink,source,destination)
create-symlink = $(if $(call test-exists,$1),$(LINK) '$1' '$2')

# $(call remove-temporary-files,filenames)
remove-temporary-files = $(if $(KEEP_TEMP),:,$(if $1,$(DELETE) $1,:))

# Don't call this directly - it is here to avoid calling wildcard more than
# once in remove-files.
remove-files-helper	= $(if $(call test-exists,$1),$(DELETE) $1,$(sh_true))

# $(call remove-files,file1 file2)
remove-files = $(call remove-files-helper,$(wildcard $1))

# Test that a file exists
# $(call test-exists,file)
test-exists		= [ -e '$1' ]
# $(call test-not-exists,file)
test-not-exists = [ ! -e '$1' ]

# Characters that are hard to specify in certain places
space := $(empty) $(empty)
colon := \:
comma := ,

# Useful shell definitions
sh_true	 := :
sh_false := ! :


# Create a hash based on the list of symlinks for the build directory
CONTENT_SUFFIX := .content
HASH_SUFFIX    := .hash
define create-symlink-hash
	$(call verbose-message, "Hashing list of build symlinks to '$@'. There are $(call count,$(SYMLINKS)) build symlinks.")
	$(MUTE)$(call remove-files, $@$(CONTENT_SUFFIX) $@$(HASH_SUFFIX))
	$(MUTE)$(foreach s, $(SYMLINKS), $(ECHO) $(realpath $s) >> $@$(CONTENT_SUFFIX);)
	$(MUTE)$(SORT) $@$(CONTENT_SUFFIX) -o $@$(CONTENT_SUFFIX)
	$(MUTE)$(UNIQUE) $@$(CONTENT_SUFFIX) > $@$(CONTENT_SUFFIX)
	$(MUTE)$(MD5SUM) $@$(CONTENT_SUFFIX) > $@$(HASH_SUFFIX)
	$(MUTE)$(SED) -n 's/\([0-9a-f]\{32\}\)\s\+$@$(CONTENT_SUFFIX)/\1/p' $@$(HASH_SUFFIX) >> $@
	$(call remove-temporary-files,$@$(CONTENT_SUFFIX) $@$(HASH_SUFFIX))
endef

define check-and-recreate-symlinks
	$(MUTE)$(TAIL) -n 1 .symlinks | $(COMPARE) -s .symlinks.new; \
	if $(TEST) $$? -ne 0; then \
		$(ECHO) "Symlinks out of date. Recreating symlinks."; \
		$(MAKE) rm-symlinks create-symlinks; \
	else \
		$(ECHO) "Symlinks do not need updating."; \
	fi
	$(call remove-temporary-files,$(SYMLINKS_NEW))
endef

################################################################################
# Automatic configuration
################################################################################

BUILD_FILES          = $(strip $(shell $(FIND) $(BUILD_DIR) -mindepth 1 -type f \( -false $(foreach persist, $(BUILD_PERSIST), -o -name "$(persist)") \) -prune -o -print))
BUILD_FILES_SYMLINKS = $(strip $(shell $(FIND) $(BUILD_DIR) -mindepth 1 \( -type l \) -print))
OUTPUT_PDF 			 = $(strip $(shell $(FIND) $(BUILD_DIR) -mindepth 1 -name "*.pdf" -print))
OUTPUT_PDF_SYMLINKS  = $(strip $(shell $(FIND) $(BUILD_DIR) -mindepth 1 -name "*.pdf" -exec $(BASENAME) {} \;))

################################################################################
# Error checking
################################################################################

# Additional error checking
ifneq ($(call count,$(BUILD_DIR)),1)
$(error Only one build directory sould be specified.)
endif

################################################################################
# Targets
################################################################################

.PHONY: info
info:
	$(variable-dump)

# Main target.
.PHONY: all
all: pre compile $(OUTPUT_FILE)

# Compile the LaTeX document.
.PHONY: compile
compile: pre
ifneq ($(BUILD_DIR),)
	
else
	$(error No build directory specified.)
endif

.PHONY: $(BUILD_DIR)
$(BUILD_DIR):
	$(build-latex)
	$(MAKE) -C $@

# Tasks to be execute before the thesis is compiled.
.PHONY: pre
pre: check-symlinks

# Read the output PDF
.PHONY: read
read: all $(OUTPUT_PDF)
	$(ACROREAD) $(OUTPUT_PDF) &

################################################################################
# Symlink targets
################################################################################

# Checks if the symlinks in the build directory are up to date.
.PHONY: check-symlinks
check-symlinks: $(SYMLINKS_DONE) $(SYMLINKS_NEW)
	$(call trace-message,"Checking if symlinks are up to date... comparing hashes $(shell $(TAIL) -n 1 $(SYMLINKS_DONE)) and $(shell $(CAT) $(SYMLINKS_NEW)).")
	$(check-and-recreate-symlinks)

# Create a file containing a hash of the symlinks
.PHONY: $(SYMLINKS_NEW)
$(SYMLINKS_NEW):
	$(call remove-files,$(SYMLINKS_NEW))
	$(create-symlink-hash)

# Create symbolic links to the LaTeX source files in the build subdirectory.
create-symlinks: $(SYMLINKS_DONE)
	$(call trace-message,"Creating symbolic links.")
	$(foreach s,$(SYMLINKS),$(call create-symlink,$s,$(BUILD_DIR)/);)

# Create a file to mark the symlink creation as done
$(SYMLINKS_DONE):
	$(call verbose-message,"Creating '$(SYMLINKS_DONE)' file.")
	$(MUTE)$(ECHO) "This file prevents make from recreating symbolic links in the 'build' directory." >> $@
	$(MUTE)$(ECHO) "================================================================================" >> $@
	$(create-symlink-hash)
	$(call verbose-message,"Creating '$(SYMLINKS_NEW)' file.")

# Create a symbolic link to the output PDF
#$(OUTPUT_PDF_SYMLINKS):
#	$(shell $(FIND) $(BUILD_DIR) -type f -name "$(OUTPUT_PDF)" -exec $(LINK) "`$(READLINK) {}`" "$@" \;)


################################################################################
# Clean targets
################################################################################
# Removes build files but not output files.
.PHONY: clean
clean:
	$(MAKE_LATEX) $@

# Remove build files and output files
.PHONY: distclean
distclean: rm-symlinks rm-files

# Delete leftover auxillary files from the build subdirectory.
.PHONY: rm-files
rm-files:
	-@$(ECHO) "Deleting any leftover build files."
	$(call remove-files,$(BUILD_FILES))

# Delete symbolic links from the build subdirectory.
.PHONY: rm-symlinks
rm-symlinks:
	-@$(ECHO) "Deleting symbolic links from build subdirectory."
	$(call remove-files,$(BUILD_FILES_SYMLINKS) $(SYMLINKS_DONE))

################################################################################
# Help targets
################################################################################
	
# Display help
.PHONY: help
help:
	$(help-text)
	
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
