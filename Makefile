##################################################################
# Executables
##################################################################

ACROREAD		:= acroread
BACKGROUND		:= &
DELETE			:= rm --force
ECHO			:= echo
FIND			:= find
IGNORE_RESULT 	:= -
LATEXMK			:= latexmk
LINK		  	:= ln --symbolic
MAKE			:= make
MUTE			:= @
PUSHD			:= pushd
POPD			:= popd
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

OUTPUT_FILE		:= thesis.pdf

BIB_SRC			:= $(shell $(FIND) $(SRC_DIR) -type f -name "*.bib")
BST_SRC			:= $(shell $(FIND) $(EXT_DIR) -type f -name "*.bst")
STY_SRC			:= $(shell $(FIND) $(EXT_DIR) -type f -name "*.sty") $(shell $(FIND) $(SRC_DIR) -type f -name "*.sty")
TEX_SRC			:= $(shell $(FIND) $(SRC_DIR) -type f -name "*.tex")


##################################################################
# Targets
##################################################################

# Main target
.PHONY: all
all: pre
	$(MUTE)$(PUSHD) $(BUILD_DIR)
	$(MUTE)$(LATEXMK)
	$(MUTE)$(POPD)
		
# To be run before make
.PHONY: pre
pre: .symlinks.done

# Create symbolic links
.symlinks.done:
	$(IGNORE_RESULT)$(MUTE)$(ECHO) "Creating symbolic links."
	$(MUTE)$(LINK) $(foreach bib, $(BIB_SRC), "$(realpath $(bib))") $(BUILD_DIR)/
	$(MUTE)$(LINK) $(foreach bst, $(BST_SRC), "$(realpath $(bst))") $(BUILD_DIR)/
	$(MUTE)$(LINK) $(foreach sty, $(STY_SRC), "$(realpath $(sty))") $(BUILD_DIR)/
	$(MUTE)$(LINK) $(foreach tex, $(TEX_SRC), "$(realpath $(tex))") $(BUILD_DIR)/
	$(MUTE)$(LINK) "$(realpath $(IMG_DIR))" $(BUILD_DIR)/
	$(MUTE)$(LINK) "$(realpath $(DATA_DIR))" $(BUILD_DIR)/
	$(MUTE)$(TOUCH) $@
	
# Delete leftover files
.PHONY: rm-files
rm-files:
	$(IGNORE_RESULT)$(MUTE)$(ECHO) "Deleting any leftover build files."
	$(MUTE)$(DELETE) $(shell find $(BUILD_DIR) -mindepth 1 -type f \( -name Makefile -o -name Variables.ini -o -name latexmkrc \) -prune -o -print)

# Remove symbolic links
.PHONY: rm-symlinks
rm-symlinks:
	$(IGNORE_RESULT)$(MUTE)$(ECHO) "Deleting symbolic links."
	$(MUTE)$(DELETE) $(shell find $(BUILD_DIR) -mindepth 1 \( -type l \) -print)
	$(MUTE)$(DELETE) .symlinks.done
	

##################################################################

# Removes build files but not output files
.PHONY: clean
clean: rm-symlinks
	$(MUTE)$(PUSHD) $(BUILD_DIR)
	$(MUTE)$(LATEXMK) -c
	$(MUTE)$(POPD)

# Remove build files and output files
.PHONY: distclean
distclean: rm-symlinks rm-files
	$(MUTE)$(PUSHD) $(BUILD_DIR)
	$(MUTE)$(LATEXMK) -C
	$(MUTE)$(POPD)
	
##################################################################

.PHONY: read
read: all
	$(ACROREAD) $(OUTPUT_FILE) $(BACKGROUND)
