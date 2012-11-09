TARGETS := QuickReference.pdf TechDoc.pdf TeXcount.pdf
CLEAN_EXTS := aux log pdf toc

all: $(TARGETS)

$(TARGETS):
	pdflatex $(@:%.pdf=%)

.PHONY: clean
clean:
	rm -f $(TARGETS) $(foreach EXT,$(CLEAN_EXTS),*.$(EXT))
