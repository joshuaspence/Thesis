##################################################################
# Author details
##################################################################
AUTHOR			:= $(shell cat AUTHORS)

##################################################################
# Executables
##################################################################

ACROREAD		:= acroread
BACKGROUND		:= &
CHANGE_DIR		:= cd
DELETE			:= rm --force
ECHO			:= echo
FIND			:= find
IGNORE_RESULT 	:= -
LATEXMK			:= latexmk
LINK		  	:= ln --symbolic
MAKE			:= make
#MUTE			:= @
READLINK		:= readlink --canonicalize
SILENT			:= >/dev/null
SPACE 			:= $(empty) $(empty)
TOUCH			:= touch
VERYSILENT		:= 1>/dev/null 2>/dev/null


##################################################################
# Configuration
##################################################################

BUILD_DIR		:= build
DATA_DIR		:= data
EXT_DIR			:= ext
IMG_DIR			:= img
SRC_DIR			:= src

OUTPUT_PDF		:= thesis.pdf

# Files in the build directory which should not be deleted on a 'clean'
BUILD_PERSIST   := Makefile Variables.ini latexmkrc

# The location of the LaTeX sources files
BIB_SRC			:= $(shell $(FIND) $(SRC_DIR) -type f -name "*.bib")
BST_SRC			:= $(shell $(FIND) $(EXT_DIR) -type f -name "*.bst")
STY_SRC			:= $(shell $(FIND) $(EXT_DIR) -type f -name "*.sty") $(shell $(FIND) $(SRC_DIR) -type f -name "*.sty")
TEX_SRC			:= $(shell $(FIND) $(SRC_DIR) -type f -name "*.tex")


##################################################################
# Targets
##################################################################

# Main target.
# - Simply runs `latexmk' in the build directory.
.PHONY: all
all: pre $(OUTPUT_FILE)
	$(MUTE)$(CHANGE_DIR) $(BUILD_DIR); $(LATEXMK)
		
# Tasks to be execute before the thesis is compiled. 
# - Creates symbolic links in the build directory.
.PHONY: pre
pre: .symlinks.done

# Create symbolic links to the LaTeX source files in the build subdirectory.
# Creates a .done file to indicate to make that this task need not be completed 
# again.
.symlinks.done:
	$(IGNORE_RESULT)$(MUTE)$(ECHO) "Creating symbolic links."
	$(MUTE)$(LINK) $(foreach bib, $(BIB_SRC), "$(realpath $(bib))") $(BUILD_DIR)/
	$(MUTE)$(LINK) $(foreach bst, $(BST_SRC), "$(realpath $(bst))") $(BUILD_DIR)/
	$(MUTE)$(LINK) $(foreach sty, $(STY_SRC), "$(realpath $(sty))") $(BUILD_DIR)/
	$(MUTE)$(LINK) $(foreach tex, $(TEX_SRC), "$(realpath $(tex))") $(BUILD_DIR)/
	$(MUTE)$(LINK) "$(realpath $(IMG_DIR))" $(BUILD_DIR)/
	$(MUTE)$(LINK) "$(realpath $(DATA_DIR))" $(BUILD_DIR)/
	$(MUTE)$(ECHO) "This file prevents make from creating symbolic links in the 'build' directory." > $@
	
# Delete leftover auxillary files from the build subdirectory.
.PHONY: rm-files
rm-files:
	$(IGNORE_RESULT)$(MUTE)$(ECHO) "Deleting any leftover build files."
	$(MUTE)$(DELETE) $(shell find $(BUILD_DIR) -mindepth 1 -type f \( -false $(foreach persist, $(BUILD_PERSIST), -o -name $(persist)) \) -prune -o -print)

# Delete symbolic links from the build subdirectory.
.PHONY: rm-symlinks
rm-symlinks:
	$(IGNORE_RESULT)$(MUTE)$(ECHO) "Deleting symbolic links."
	$(MUTE)$(DELETE) $(shell find $(BUILD_DIR) -mindepth 1 \( -type l \) -print)
	$(MUTE)$(DELETE) .symlinks.done

##################################################################

# Removes build files but not output files.
.PHONY: clean
clean:
	$(MUTE)$(CHANGE_DIR) $(BUILD_DIR); $(LATEXMK) -c

# Remove build files and output files
.PHONY: distclean
distclean: rm-symlinks rm-files
	
##################################################################

# Create a symbolic link to the output PDF
$(OUTPUT_PDF):
	$(MUTE)$(LINK) "$(shell $(FIND) $(BUILD_DIR) -type f -name "$(OUTPUT_PDF)" -exec $(READLINK) {} \;)" "$@"

# Read the output PDF
.PHONY: read
read: all $(OUTPUT_PDF)
	$(ACROREAD) $(OUTPUT_PDF) $(BACKGROUND)
	

##################################################################
# Help
##################################################################
.PHONY: help
help:
	$(MUTE)$(ECHO) "================================================================================"
	$(MUTE)$(ECHO) "Makefile for compiling the thesis."
	$(MUTE)$(ECHO) "Author: $(AUTHOR)"
	$(MUTE)$(ECHO) "================================================================================"
	$(MUTE)$(ECHO) "Targets are:"
	$(MUTE)$(ECHO) "    all                  Compile the thesis. The thesis will be output to "
	$(MUTE)$(ECHO) "                         '$(OUTPUT_PDF)'."
	$(MUTE)$(ECHO) "    pre                  Runs any tasks that must be executed before compilation"
	$(MUTE)$(ECHO) "                         can begin."
	$(MUTE)$(ECHO) "    .symlinks.done       Create symbolic links in the '$(BUILD_DIR)' "
	$(MUTE)$(ECHO) "                         subdirectory to all required files for the build."
	$(MUTE)$(ECHO) "    rm-files             Deletes all remaining auxillary files from the "
	$(MUTE)$(ECHO) "                         '$(BUILD_DIR)' subdirectory."
	$(MUTE)$(ECHO) "    rm-symlinks          Deletes the symbolic links from the '$(BUILD_DIR)' "
	$(MUTE)$(ECHO) "                         subdirectory."
	$(MUTE)$(ECHO) "    clean                Cleans the '$(BUILD_DIR)' subdirectory."
	$(MUTE)$(ECHO) "    distclean            Removes symbolic links and remaining auxillary files "
	$(MUTE)$(ECHO) "                         from the '$(BUILD_DIR)' subdirectory."
	$(MUTE)$(ECHO) "    read                 Compiles the thesis and then opens the document with "
	$(MUTE)$(ECHO) "                         '$(ACROREAD)'."
	$(MUTE)$(ECHO) "    help                 Display the help file for instructions on how to "
	$(MUTE)$(ECHO) "                         compile the thesis."
	$(MUTE)$(ECHO) "--------------------------------------------------------------------------------"
