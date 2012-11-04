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
include configuration.mk

#------------------------------------------------------------------------------#
#                                                                              #
#                                   MACROS                                     #
#                                                                              #
#------------------------------------------------------------------------------#
# $(eval $(call expand-targets,TARGET))
define expand-targets
ALL_TARGETS += $(1)
$(call expand-build-targets,$(1))
$(call expand-clean-targets,$(1))
$(call expand-gitignore-target,$(1))
endef

# $(eval $(call expand-targets-no-clean,TARGET))
define expand-targets-no-clean
ALL_TARGETS += $(1)
$(call expand-build-targets,$(1))
$(call expand-noclean-targets,$(1))
$(call expand-gitignore-noclean-target,$(1))
endef

# $(eval $(call expand-build-targets,TARGET))
define expand-build-targets
# $(1): Build targets
.PHONY: $(1) pre-$(1) main-$(1) post-$(1)
$(1): pre-$(1) main-$(1) post-$(1)
pre-$(1):
	$$(call print-subheader-generate,$$($(1)_TITLE))
main-$(1): $$(foreach TARGET,$$($(1)_TARGETS),$(1)/$$(TARGET))
post-$(1):
	$$(call print-subfooter)

endef

# $(eval $(call expand-clean-targets,TARGET))
define expand-clean-targets
# $(1): Clean targets
.PHONY: clean-$(1) pre-clean-$(1) main-clean-$(1) post-clean-$(1)
clean-$(1): pre-clean-$(1) main-clean-$(1) post-clean-$(1)
pre-clean-$(1):
	$$(call print-subheader-clean,$$($(1)_TITLE))
main-clean-$(1):
	@$$(foreach TARGET,$$($(1)_TARGETS),echo "Deleting $$(TARGET)"; rm --force "$(1)/$$(TARGET)";)
post-clean-$(1):
	$$(call print-subfooter)

endef

# $(eval $(call expand-noclean-targets,TARGET))
define expand-noclean-targets
# $(1): Clean targets
.PHONY: clean-$(1) pre-clean-$(1) main-clean-$(1) post-clean-$(1)
clean-$(1): pre-clean-$(1) main-clean-$(1) post-clean-$(1)
pre-clean-$(1):
	$$(call print-subheader-clean,$$($(1)_TITLE))
main-clean-$(1):
	$$($(1)_NO_CLEAN)
post-clean-$(1):
	$$(call print-subfooter)

endef

# $(eval $(call expand-gitignore-target,TARGET))
define expand-gitignore-target
# $(1): .gitignore target
.PHONY: $(1)/.gitignore
$(1)/.gitignore:
	-@echo "Creating $$@"
	$$(call create-gitignore,$$($(1)_TARGETS))

endef

# $(eval $(call expand-gitignore-noclean-target,TARGET))
define expand-gitignore-noclean-target
# $(1): .gitignore target
.PHONY: $(1)/.gitignore
$(1)/.gitignore:
	-@echo "Creating $$@"
	$$(call create-gitignore,)

endef

# $(call print-header-clean)
define print-header-clean
-@echo "================================================================================"
-@echo "CLEANING $(TITLE)"
-@echo "================================================================================"
endef

# $(call print-header-generate)
define print-header-generate
-@echo "================================================================================"
-@echo "GENERATING $(TITLE)"
-@echo "================================================================================"
endef

# $(call print-footer)
define print-footer
-@echo ""
endef

# $(call print-subheader-clean,TARGET)
define print-subheader-clean
-@echo "Cleaning $(1)..."
endef

# $(call print-subheader-generate,TARGET)
define print-subheader-generate
-@echo "Generating $(1)..."
endef

# $(call print-subfooter)
define print-subfooter
-@echo "--------------------------------------------------------------------------------"
endef

# $(call create-gitignore,FILES)
define create-gitignore
@echo "# Automatically generated" > $@
@$(foreach FILE,$(1),echo "$(FILE)" >> $@;)
endef

# Expand all targets
$(foreach TARGET,$(TARGETS),$(eval $(call expand-targets,$(TARGET))))
$(foreach TARGET,$(TARGETS_NO_CLEAN),$(eval $(call expand-targets-no-clean,$(TARGET))))

#------------------------------------------------------------------------------#
#                                                                              #
#                                   RULES                                      #
#                                                                              #
#------------------------------------------------------------------------------#
%.tex: %.tex.pl
	-@echo "$(shell basename $<) --> $(shell basename $@)"
	@perl "$<" "$@"
%.png: %.png.pl
	-@echo "$(shell basename $<) --> $(shell basename $@)"
	@perl "$<" "$@"

#------------------------------------------------------------------------------#
#                                                                              #
#                                  TARGETS                                     #
#                                                                              #
#------------------------------------------------------------------------------#
.PHONY: all pre-all main-all post-all
all: pre-all main-all post-all
pre-all:
	$(call print-header-generate)
main-all: $(ALL_TARGETS)
post-all:
	$(call print-footer)

.PHONY: clean pre-clean main-clean post-clean
clean: pre-clean main-clean post-clean
pre-clean:
	$(call print-header-clean)
main-clean: $(foreach TARGET,$(ALL_TARGETS),clean-$(TARGET))
post-clean:
	$(call print-footer)

.PHONY: .gitignore gitignore
.gitignore gitignore: $(foreach TARGET,$(ALL_TARGETS),$(TARGET)/.gitignore)