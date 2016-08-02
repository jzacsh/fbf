BIN_DIR     =  bin
TEST_OPTS  := # --tap

# Documentation
MARKDN_EXT  =  adoc
MARKUP_EXT  =  auto.html
DOCS_DIR    =  doc
DOCS_MRKDN  =  $(wildcard $(DOCS_DIR)/*.$(MARKDN_EXT))
DOCS_MRKUP  =  $(DOCS_MRKDN:.$(MARKDN_EXT)=.$(MARKUP_EXT))

all: clean doc test e2e

e2e:
	$(BIN_DIR)/e2e.sh test/ $(TEST_OPTS)

test:
	@echo 'OOOH FKK, no test yet!'
	@false

# TODO compile README in this recipe
doc: $(DOCS_MRKUP)
$(DOCS_DIR)/%: $(DOCS_DIR)/%.$(MARKUP_EXT)
$(DOCS_DIR)/%.$(MARKUP_EXT): $(DOCS_DIR)/%.$(MARKDN_EXT)
	asciidoc --out-file $@ $<

clean:
	$(RM) $(DOCS_DIR)/*.$(MARKUP_EXT)

.PHONY: clean all test e2e
