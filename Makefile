##################################################################
# Executables
##################################################################

ACROREAD		:= acroread
BACKGROUND		:= &
DELETE			:= rm --force
ECHO			:= echo
EVINCE			:= evince
FIND			:= find
IGNORE_RESULT 	:= -
LINK		  	:= ln --symbolic --verbose
MAKE			:= make
MKDIR			:= mkdir --parents
MUTE			:= @
SILENT			:= >/dev/null
SPACE 			:= $(empty) $(empty)
VERYSILENT		:= 1>/dev/null 2>/dev/null
XDVI		  	:= xdvi


##################################################################
# Configuration
##################################################################

BUILD_DIR		:= build
DATA_DIR		:= data
EXT_DIR			:= ext
IMG_DIR			:= img
SRC_DIR			:= src
OUT_DIR			:= output

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
	$(MUTE)$(MAKE) -C $(BUILD_DIR) $@
		
# To be run before make
.PHONY: pre
pre: create-out-directories create-symlinks
	
# Create output directories
.PHONY: create-out-directories
create-out-directories:
	$(IGNORE_RESULT)$(MUTE)$(ECHO) "Creating directories."
	$(MUTE)$(MKDIR) $(OUT_DIR)
	
# Create symbolic links
.PHONY: create-symlinks
create-symlinks: remove-symlinks
	$(IGNORE_RESULT)$(MUTE)$(ECHO) "Creating symbolic links."
	$(MUTE)$(LINK) $(foreach bib, $(BIB_SRC), "$(realpath $(bib))") $(BUILD_DIR)/ || true
	$(MUTE)$(LINK) $(foreach bst, $(BST_SRC), "$(realpath $(bst))") $(BUILD_DIR)/ || true
	$(MUTE)$(LINK) $(foreach sty, $(STY_SRC), "$(realpath $(sty))") $(BUILD_DIR)/ || true
	$(MUTE)$(LINK) $(foreach tex, $(TEX_SRC), "$(realpath $(tex))") $(BUILD_DIR)/ || true
	$(MUTE)$(LINK) "$(realpath $(IMG_DIR))" $(BUILD_DIR)/ || true
	$(MUTE)$(LINK) "$(realpath $(DATA_DIR))" $(BUILD_DIR)/ || true

# Remove output directories
.PHONY: remove-out-directories
remove-out-directories:
	$(IGNORE_RESULT)$(MUTE)$(ECHO) "Deleting directories."
	$(MUTE)$(DELETE) -r $(OUT_DIR)

# Remove symbolic links
.PHONY: remove-symlinks
remove-symlinks:
	$(IGNORE_RESULT)$(MUTE)$(ECHO) "Deleting symbolic links."
	$(MUTE)$(DELETE) $(shell find $(BUILD_DIR) -mindepth 1 \( -type l \) -print)


##################################################################

# Removes build files but not output files
.PHONY: clean
clean: remove-symlinks
	$(MUTE)$(MAKE) -C $(BUILD_DIR) $@

# Remove build files and output files
.PHONY: distclean
distclean: remove-out-directories remove-symlinks
	$(MUTE)$(MAKE) -C $(BUILD_DIR) clean
