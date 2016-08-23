export BIN_DIR      =  bin
export SRC_DIR      =  src
export E2E_DIR      =  test
export TMP_E2E_DIR :=  $(E2E_DIR)/.tmp
export E2E_SSHKEY  :=  $(TMP_E2E_DIR)/ssh-internal-key

TEST_OPTS   :=  # --tap
# Documentation:
MRKDN_EXT    =  adoc
MRKUP_EXT    =  auto.html
DOCS_DIR     =  doc
DOCS_MRKDN  :=  $(wildcard *.$(MRKDN_EXT) $(DOCS_DIR)/*.$(MRKDN_EXT))
DOCS_MRKUP  :=  $(patsubst %.$(MRKDN_EXT),%.$(MRKUP_EXT),$(DOCS_MRKDN))

all: clean doc e2e

doc: $(DOCS_MRKUP)
%: %.$(MRKUP_EXT)
%.$(MRKUP_EXT): %.$(MRKDN_EXT)
	asciidoc --out-file $@ $<
$(DOCS_DIR)/%: $(DOCS_DIR)/%.$(MRKUP_EXT)
$(DOCS_DIR)/%.$(MRKUP_EXT): $(DOCS_DIR)/%.$(MRKDN_EXT)
	asciidoc --out-file $@ $<

clean:
	$(RM) $(DOCS_MRKUP)
	vagrant destroy --force receptacle
	vagrant destroy --force client
	$(RM) $(TMP_E2E_DIR) -rf

vms:
	mkdir $(TMP_E2E_DIR)
	vagrant up receptacle
	vagrant up client

# Manual labor expected to be done by a person IRL
manualsetup:
	$(SRC_DIR)/post-provision-mocklabor.sh

e2e: vms manualsetup
	$(BIN_DIR)/e2e.sh test/ $(TEST_OPTS)

.PHONY: clean all e2e vms manualsetup
