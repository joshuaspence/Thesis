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
LINK		  	:= ln --symbolic
MAKE			:= make
MKDIR			:= mkdir --parents
MUTE			:= @
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
pre: .directories.done .symlinks.done
	
# Create output directories
.directories.done:
	$(IGNORE_RESULT)$(MUTE)$(ECHO) "Creating directories."
	$(MUTE)$(MKDIR) $(OUT_DIR)
	$(MUTE)$(TOUCH) $@
	
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

# Remove output directories
.PHONY: rm-directories
rm-directories:
	$(IGNORE_RESULT)$(MUTE)$(ECHO) "Deleting directories."
	$(MUTE)$(DELETE) -r $(OUT_DIR)
	$(MUTE)$(DELETE) .directories.done

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
	$(MUTE)$(MAKE) -C $(BUILD_DIR) $@

# Remove build files and output files
.PHONY: distclean
distclean: rm-directories rm-symlinks
	$(MUTE)$(MAKE) -C $(BUILD_DIR) clean
	
##################################################################

.PHONY: read
read: all
	$(MUTE)$(ACROREAD) $(OUT_DIR)/*.pdf
