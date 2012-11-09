TARGETS := pgf-pie-manual
CLEAN_EXTS := aux log out pdf toc

all: $(TARGETS)

$(TARGETS):
	pdflatex $(@:%.pdf=%)

.PHONY: clean
clean:
	rm -f $(TARGETS) $(foreach EXT,$(CLEAN_EXTS),*.$(EXT))
