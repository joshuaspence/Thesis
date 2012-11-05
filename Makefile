#------------------------------------------------------------------------------#
#                                                                              #
#                               DEFAULT TARGET                                 #
#                                                                              #
#------------------------------------------------------------------------------#
.PHONY: all
all: latex


#------------------------------------------------------------------------------#
#                                                                              #
#                               CONFIGURATION                                  #
#                                                                              #
#------------------------------------------------------------------------------#
PREREQUISITES := code img plots
MAIN          := src

define subdir-target
.PHONY: $(1)
$(1):
	@make --no-print-directory -C $$@
endef
$(foreach SUBDIR,$(PREREQUISITES) $(MAIN),$(eval $(call subdir-target,$(SUBDIR))))


#------------------------------------------------------------------------------#
#                                                                              #
#                                DEPENDENCIES                                  #
#                                                                              #
#------------------------------------------------------------------------------#
src: prerequisites


#------------------------------------------------------------------------------#
#                                                                              #
#                                  TARGETS                                     #
#                                                                              #
#------------------------------------------------------------------------------#
.PHONY: all
all: latex

.PHONY: latex
latex: $(MAIN)

.PHONY: prerequisites
prerequisites: $(PREREQUISITES)

.PHONY: clean distclean
clean: clean-main
distclean: clean-main clean-prerequisites

.PHONY: clean-main clean-prerequisites
clean-main:
	@make --no-print-directory -C $(MAIN) clean
clean-prerequisites:
	@$(foreach SUBDIR,$(PREREQUISITES),make --no-print-directory -C $(SUBDIR) clean;)