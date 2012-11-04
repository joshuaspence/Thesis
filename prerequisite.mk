SUBDIRS := code img plots

.PHONY: all
all:
	@$(foreach SUBDIR,$(SUBDIRS),make --no-print-directory -C $(SUBDIR);)

.PHONY: clean
clean:
	@$(foreach SUBDIR,$(SUBDIRS),make --no-print-directory -C $(SUBDIR) $@;)