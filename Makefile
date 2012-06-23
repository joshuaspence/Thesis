##################################################################
# Author details (read from AUTHORS file)
##################################################################
AUTHOR = $(shell cat AUTHORS | perl -p -n -e 's/\r?\n/, /;' | perl -p -e 's/, $$//;')


##################################################################
# Programs
##################################################################

ACROREAD   := acroread
DELETE     := rm
DELETE_V   := rm --verbose
ECHO       := echo
FIND       := find
LATEXMK    := latexmk
LINK       := ln --symbolic
LINK_V     := ln --symbolic --verbose
MAKE       := make
MD5SUM     := md5sum
MUTE       := @
NO_STDERR  := 2>/dev/null
NO_STDOUT  := 1>/dev/null
READLINK   := readlink --canonicalize
SED        := sed
SORT       := sort
SPACE      := $(empty) $(empty)
VERYSILENT := $(NO_STDOUT) $(NO_STDERR)


##################################################################
# Configuration
##################################################################

# Directories
BUILD_DIR := build
DATA_DIR  := data
EXT_DIR   := ext
IMG_DIR   := img
SRC_DIR   := src

# Name of the output PDF (within the build directory)
OUTPUT_PDF := thesis.pdf

# Checksum files
SYMLINKS_DONE := .symlinks
SYMLINKS_NEW  := .symlinks.new

# Files in the build directory which should not be deleted on a 'clean'
BUILD_PERSIST := Makefile Variables.ini latexmkrc

# The location of the LaTeX sources files
BIB_SRC = $(shell $(FIND) $(SRC_DIR) -type f -name "*.bib")
BST_SRC	= $(shell $(FIND) $(EXT_DIR) -type f -name "*.bst")
CLS_SRC	= $(shell $(FIND) $(EXT_DIR) -type f -name "*.cls")
STY_SRC	= $(shell $(FIND) $(EXT_DIR) -type f -name "*.sty") $(shell $(FIND) $(SRC_DIR) -type f -name "*.sty")
TEX_SRC	= $(shell $(FIND) $(SRC_DIR) -type f -name "*.tex")


##################################################################
# LaTeX build configurations
##################################################################

define build-latex
	$(MUTE)$(MAKE) -C $(BUILD_DIR)
endef

define clean-latex
	$(MUTE)$(MAKE) -C $(BUILD_DIR) clean
endef


##################################################################
# Other macros
##################################################################

define create-symlink-hash
	-$(MUTE)$(DELETE) $@.content $@.hash $(NO_STDERR) || true
	@$(foreach bib, $(BIB_SRC), $(ECHO) $(realpath $(bib)) >> $@.content;)
	@$(foreach bst, $(BST_SRC), $(ECHO) $(realpath $(bst)) >> $@.content;)
	@$(foreach cls, $(CLS_SRC), $(ECHO) $(realpath $(cls)) >> $@.content;)
	@$(foreach sty, $(STY_SRC), $(ECHO) $(realpath $(sty)) >> $@.content;)
	@$(foreach tex, $(TEX_SRC), $(ECHO) $(realpath $(tex)) >> $@.content;)
	@$(ECHO) $(realpath $(IMG_DIR)) >> $@.content
	@$(ECHO) $(realpath $(DATA_DIR)) >> $@.content
	$(MUTE)$(SORT) $@.content -o $@.content
	$(MUTE)$(MD5SUM) $@.content > $@.hash
	$(MUTE)$(SED) -n 's/\([0-9a-f]\{32\}\)\s\+$@.content/\1/p' $@.hash >> $@
	$(MUTE)$(DELETE) $@.content $@.hash
endef

define display-help
	@$(ECHO) "================================================================================"
	@$(ECHO) "Makefile for compiling the thesis."
	@$(ECHO) "Author: $(AUTHOR)"
	@$(ECHO) "================================================================================"
	@$(ECHO) "Targets are:"
	@$(ECHO) "    all                  Compile the thesis. The thesis will be output to "
	@$(ECHO) "                         '$(OUTPUT_PDF)'."
	@$(ECHO) "    pre                  Runs any tasks that must be executed before compilation"
	@$(ECHO) "                         can begin."
	@$(ECHO) "    .symlinks.done       Create symbolic links in the '$(BUILD_DIR)' "
	@$(ECHO) "                         subdirectory to all required files for the build."
	@$(ECHO) "    rm-files             Deletes all remaining auxillary files from the "
	@$(ECHO) "                         '$(BUILD_DIR)' subdirectory."
	@$(ECHO) "    rm-symlinks          Deletes the symbolic links from the '$(BUILD_DIR)' "
	@$(ECHO) "                         subdirectory."
	@$(ECHO) "    clean                Cleans the '$(BUILD_DIR)' subdirectory."
	@$(ECHO) "    distclean            Removes symbolic links and remaining auxillary files "
	@$(ECHO) "                         from the '$(BUILD_DIR)' subdirectory."
	@$(ECHO) "    read                 Compiles the thesis and then opens the document with "
	@$(ECHO) "                         '$(ACROREAD)'."
	@$(ECHO) "    help                 Display the help file for instructions on how to "
	@$(ECHO) "                         compile the thesis."
	@$(ECHO) "--------------------------------------------------------------------------------"
endef


##################################################################
# Automatic configuration
##################################################################

BUILD_FILES          = $(shell find $(BUILD_DIR) -mindepth 1 -type f \( -false $(foreach persist, $(BUILD_PERSIST), -o -name $(persist)) \) -prune -o -print)
BUILD_FILES_SYMLINKS = $(shell find $(BUILD_DIR) -mindepth 1 \( -type l \) -print)


##################################################################
# Targets
##################################################################

# Main target.
.PHONY: all
all: pre compile $(OUTPUT_FILE)

# Compile the LaTeX document.
.PHONY: compile
compile: pre
ifneq ($(BUILD_DIR),)
	$(build-latex)
else
	$(error No build directory specified.)
endif
		
# Tasks to be execute before the thesis is compiled.
.PHONY: pre
pre: check-symlinks

# Removes build files but not output files.
.PHONY: clean
clean:
ifneq ($(BUILD_DIR),)
	$(clean-latex)
else
	$(error No build directory specified.)
endif
ifneq ($(OUTPUT_PDF),)
	-$(MUTE)[ -L "$(OUTPUT_PDF)" ] && $(DELETE_V) "$(OUTPUT_PDF)"
endif

# Remove build files and output files
.PHONY: distclean
distclean: rm-symlinks rm-files

# Read the output PDF
.PHONY: read
read: all $(OUTPUT_PDF)
	$(ACROREAD) $(OUTPUT_PDF) &

# Display help
.PHONY: help
help:
	$(display-help)

##################################################################
# Symlink targets
##################################################################

# Checks if the symlinks in the build directory are up to date.
.PHONY: check-symlinks
check-symlinks: $(SYMLINKS_DONE) $(SYMLINKS_NEW)
	-@$(ECHO) "Checking if symlinks are up to date... comparing hashes $(shell tail -n 1 $(SYMLINKS_DONE)) and $(shell cat $(SYMLINKS_NEW))."
	$(MUTE)tail -n 1 .symlinks | cmp -s .symlinks.new; \
	if test $$? -ne 0; then \
		$(ECHO) "Symlinks out of date. Recreating symlinks."; \
		$(MAKE) rm-symlinks; \
		$(MAKE) $(SYMLINKS_DONE); \
	else \
		$(ECHO) "Symlinks do not need updating."; \
	fi
	$(MUTE)$(DELETE) $(SYMLINKS_NEW)

# Create a file containing a hash of the symlinks
$(SYMLINKS_NEW):
	$(create-symlink-hash)

# Create symbolic links to the LaTeX source files in the build subdirectory.
$(SYMLINKS_DONE):
	-@$(ECHO) "Creating symbolic links."
ifneq ($(BIB_SRC),)
	$(MUTE)$(LINK_V) $(foreach bib, $(BIB_SRC), "$(realpath $(bib))") $(BUILD_DIR)/
endif
ifneq ($(BST_SRC),)
	$(MUTE)$(LINK_V) $(foreach bst, $(BST_SRC), "$(realpath $(bst))") $(BUILD_DIR)/
endif
ifneq ($(CLS_SRC),)
	$(MUTE)$(LINK_V) $(foreach cls, $(CLS_SRC), "$(realpath $(cls))") $(BUILD_DIR)/
endif
ifneq ($(STY_SRC),)
	$(MUTE)$(LINK_V) $(foreach sty, $(STY_SRC), "$(realpath $(sty))") $(BUILD_DIR)/
endif
ifneq ($(TEX_SRC),)
	$(MUTE)$(LINK_V) $(foreach tex, $(TEX_SRC), "$(realpath $(tex))") $(BUILD_DIR)/
endif
ifneq ($(IMG_DIR),)
	$(MUTE)$(LINK_V) "$(realpath $(IMG_DIR))" $(BUILD_DIR)/
endif
ifneq ($(DATA_DIR),)
	$(MUTE)$(LINK_V) "$(realpath $(DATA_DIR))" $(BUILD_DIR)/
endif
	$(MUTE)$(ECHO) "This file prevents make from recreating symbolic links in the 'build' directory." >> $@
	$(MUTE)$(ECHO) "================================================================================" >> $@
	$(create-symlink-hash)

# Create a symbolic link to the output PDF
$(OUTPUT_PDF):
	$(shell $(FIND) $(BUILD_DIR) -type f -name "$(OUTPUT_PDF)" -exec $(LINK_V) "`$(READLINK) {}`" "$@" \;)


##################################################################
# Clean targets
##################################################################

# Delete leftover auxillary files from the build subdirectory.
.PHONY: rm-files
rm-files:
	-@$(ECHO) "Deleting any leftover build files."
	$(MUTE)[ -n "$(BUILD_FILES)" ] && $(DELETE_V) $(BUILD_FILES) || true

# Delete symbolic links from the build subdirectory.
.PHONY: rm-symlinks
rm-symlinks:
	-@$(ECHO) "Deleting symbolic links."
	$(MUTE)[ -n "$(BUILD_FILES_SYMLINKS)" ] && $(DELETE_V) $(BUILD_FILES_SYMLINKS) || true
	$(MUTE)[ -f "$(SYMLINKS_DONE)" ] && $(DELETE_V) "$(SYMLINKS_DONE)" || true
