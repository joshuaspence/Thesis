#------------------------------------------------------------------------------#
#                                                                              #
#                               DEFAULT TARGET                                 #
#                                                                              #
#------------------------------------------------------------------------------#
.SUFFIXES:
.DEFAULT: default
.PHONY: default
default: all


#------------------------------------------------------------------------------#
#                                                                              #
#                                CONFIGURATION                                 #
#                                                                              #
#------------------------------------------------------------------------------#
ALL_TARGETS :=
DATASETS    := ball1 \
               connect4 \
               letter-recognition \
               magicgamma \
               mesh_network \
               musk \
               pendigits \
               runningex1k \
               runningex10k \
               runningex20k \
               runningex30k \
               runningex40k \
               runningex50k \
               segmentation \
               spam \
               spam_train \
               testCD \
               testCDST \
               testCDST2 \
               testCDST3 \
               testoutrank
DATASETS_2D := ball1 \
               runningex1k \
               runningex10k \
               runningex20k \
               runningex30k \
               runningex40k \
               runningex50k \
               testCD \
               testCDST \
               testCDST2 \
               testCDST3 \
               testoutrank
DATASETS_3D :=
EXTENSIONS  := png tex

include configuration.mk


#------------------------------------------------------------------------------#
#                                                                              #
#                                   MACROS                                     #
#                                                                              #
#------------------------------------------------------------------------------#
# $(call create-gitignore,FILES)
# Create a .gitignore file.
define create-gitignore
@echo "# Automatically generated" > $@
@$(foreach FILE,$(1),echo "$(FILE)" >> $@;)
endef

# $(eval $(call expand-build-targets,TARGET))
# Used to create target rules using macro expansion.
define expand-build-targets
# $(1): Build targets
.PHONY: $(1) pre-build-$(1) build-$(1) post-build-$(1)
$(1): pre-build-$(1) build-$(1) post-build-$(1)
pre-build-$(1):
	$$(call print-subheader-generate,$$($(1)_TITLE))
build-$(1): $$(foreach TARGET,$$($(1)_TARGETS),$(1)/$$(TARGET))
post-build-$(1):
	$$(call print-subfooter)

endef

# $(eval $(call expand-clean-targets,TARGET))
# Used to create target rules using macro expansion.
define expand-clean-targets
# $(1): Clean targets
.PHONY: clean-$(1) force-clean-$(1)
clean-$(1):
	$$(call print-subheader-clean,$$($(1)_TITLE))
	@$$(foreach TARGET,$$($(1)_TARGETS),echo "Deleting $$(TARGET)"; rm --force "$(1)/$$(TARGET)";)
	$$(call print-subfooter)
force-clean-$(1): clean-$(1)

endef

# $(eval $(call expand-gitignore-target,TARGET))
# Used to create target rules using macro expansion.
define expand-gitignore-target
# $(1): .gitignore target
.PHONY: $(1)/.gitignore
$(1)/.gitignore:
	-@echo "Creating $$@"
	$$(call create-gitignore,$$($(1)_TARGETS))

endef

# $(eval $(call expand-gitignore-noclean-target,TARGET))
# Used to create target rules using macro expansion.
define expand-gitignore-noclean-target
# $(1): .gitignore target
.PHONY: $(1)/.gitignore
$(1)/.gitignore:
	-@echo "Creating $$@"
	$$(call create-gitignore,)

endef

# $(eval $(call expand-noclean-targets,TARGET))
# Used to create target rules using macro expansion.
define expand-noclean-targets
# $(1): Clean targets
.PHONY: clean-$(1) force-clean-$(1)
clean-$(1):
	$$(call print-subheader-clean,$$($(1)_TITLE))
	$$($(1)_NO_CLEAN)
	$$(call print-subfooter)
force-clean-$(1):
	$$(call print-subheader-clean,$$($(1)_TITLE))
	@$$(foreach TARGET,$$($(1)_TARGETS),echo "Deleting $$(TARGET)"; rm --force "$(1)/$$(TARGET)";)
	$$(call print-subfooter)

endef

# $(eval $(call expand-targets,TARGET))
# Used to create target rules using macro expansion.
define expand-targets
ALL_TARGETS += $(1)
$(call expand-build-targets,$(1))
$(call expand-clean-targets,$(1))
$(call expand-gitignore-target,$(1))
endef

# $(eval $(call expand-targets-no-clean,TARGET))
# Used to create target rules using macro expansion.
define expand-targets-no-clean
ALL_TARGETS += $(1)
$(call expand-build-targets,$(1))
$(call expand-noclean-targets,$(1))
$(call expand-gitignore-noclean-target,$(1))
endef

# $(call print-footer)
# Print footer text.
define print-footer
-@echo ""
endef

# $(call print-header-clean)
# Print header text for clean operation.
define print-header-clean
-@echo "================================================================================"
-@echo "CLEANING $(TITLE)"
-@echo "================================================================================"
endef

# $(call print-header-generate)
# Print header text for generate operation.
define print-header-generate
-@echo "================================================================================"
-@echo "GENERATING $(TITLE)"
-@echo "================================================================================"
endef

# $(call print-subfooter)
# Print subfooter text.
define print-subfooter
-@echo "--------------------------------------------------------------------------------"
endef

# $(call print-subheader-clean,TARGET)
# Print subheader text for clean operation.
define print-subheader-clean
-@echo "Cleaning $(1)..."
endef

# $(call print-subheader-generate,TARGET)
# Print subheader text for generate operation.
define print-subheader-generate
-@echo "Generating $(1)..."
endef


#------------------------------------------------------------------------------#
#                                                                              #
#                                   RULES                                      #
#                                                                              #
#------------------------------------------------------------------------------#
# $(eval $(call generate-rules,EXTENSIONS))
# Generate rules to create targets from scripting sources.
define generate-rules
%.$(1): %.$(1).pl
	-@echo "$$(shell basename $$<) --> $$(shell basename $$@)"
	@perl "$$<" "$$@"

%.$(1): %.$(1).py
	-@echo "$$(shell basename $$<) --> $$(shell basename $$@)"
	@python "$$<" "$$@"

%.$(1): %.$(1).sh
	-@echo "$$(shell basename $$<) --> $$(shell basename $$@)"
	@sh "$$<" "$$@"

endef
$(foreach EXT,$(EXTENSIONS),$(eval $(call generate-rules,$(EXT))))


#------------------------------------------------------------------------------#
#                                                                              #
#                                  TARGETS                                     #
#                                                                              #
#------------------------------------------------------------------------------#
# Expand all targets
$(foreach TARGET,$(TARGETS),$(eval $(call expand-targets,$(TARGET))))
$(foreach TARGET,$(TARGETS_NO_CLEAN),$(eval $(call expand-targets-no-clean,$(TARGET))))

# Generate targets from sources
.PHONY: all pre-all main-all post-all
all: pre-all main-all post-all
pre-all:
	$(call print-header-generate)
main-all: $(ALL_TARGETS)
post-all:
	$(call print-footer)

# Clean all generated files
.PHONY: clean force-clean pre-clean main-clean post-clean
clean: pre-clean main-clean post-clean
force-clean: pre-clean force-clean post-clean
pre-clean:
	$(call print-header-clean)
main-clean: $(foreach TARGET,$(ALL_TARGETS),clean-$(TARGET))
force-clean: $(foreach TARGET,$(ALL_TARGETS),force-clean-$(TARGET))
post-clean:
	$(call print-footer)

# Create all .gitignore files
.PHONY: .gitignore gitignore
.gitignore gitignore: $(foreach TARGET,$(ALL_TARGETS),$(TARGET)/.gitignore)
