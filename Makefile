BIN_DIR     =  bin
TEST_OPTS  := # --tap

# Documentation
MRKDN_EXT   =  adoc
MRKUP_EXT   =  auto.html
DOCS_DIR    =  doc
DOCS_MRKDN :=  $(wildcard *.$(MRKDN_EXT) $(DOCS_DIR)/*.$(MRKDN_EXT))
DOCS_MRKUP :=  $(patsubst %.$(MRKDN_EXT),%.$(MRKUP_EXT),$(DOCS_MRKDN))

all: clean doc test e2e

e2e:
	$(BIN_DIR)/e2e.sh test/ $(TEST_OPTS)

test:
	@echo 'OOOH FKK, no test yet!'
	@false

doc: $(DOCS_MRKUP)
%: %.$(MRKUP_EXT)
%.$(MRKUP_EXT): %.$(MRKDN_EXT)
	asciidoc --out-file $@ $<
$(DOCS_DIR)/%: $(DOCS_DIR)/%.$(MRKUP_EXT)
$(DOCS_DIR)/%.$(MRKUP_EXT): $(DOCS_DIR)/%.$(MRKDN_EXT)
	asciidoc --out-file $@ $<

clean:
	$(RM) $(DOCS_MRKUP)

.PHONY: clean all test e2e
