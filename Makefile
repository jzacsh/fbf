MARKDN_EXT  =  adoc
MARKUP_EXT  =  auto.html
DOCS_DIR    =  doc
DOCS_MRKDN  =  $(wildcard $(DOCS_DIR)/*.$(MARKDN_EXT))
DOCS_MRKUP  =  $(DOCS_MRKDN:.$(MARKDN_EXT)=.$(MARKUP_EXT))

all: clean doc test

test:
	@echo 'OOOH FKK, no test yet!'
	@false

doc: $(DOCS_MRKUP)
$(DOCS_DIR)/%: $(DOCS_DIR)/%.$(MARKUP_EXT)
$(DOCS_DIR)/%.$(MARKUP_EXT): $(DOCS_DIR)/%.$(MARKDN_EXT)
	asciidoc --out-file $@ $<

clean:
	$(RM) $(DOCS_DIR)/*.$(MARKUP_EXT)

.PHONY: clean all test
