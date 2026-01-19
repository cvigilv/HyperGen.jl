CLI=julia --project=. --startup-file=no -t 8 -m HyperGen
FASTA=test/test_data/example.fasta

.PHONY: sketch compare

help: ## Print this message
	@echo "usage: make [target] ..."
	@echo ""
	@echo "Available targets:"
	@grep --no-filename "##" $(MAKEFILE_LIST) | \
		grep --invert-match $$'\t' | \
		sed -e "s/\(.*\):.*## \(.*\)/ - \1:  \t\2/"

sketch: ## Test sketch command
	$(CLI) -V sketch $(FASTA) $(FASTA).sketch

compare: ## Test compare command
	$(CLI) -V compare --ani $(FASTA).sketch $(FASTA).compare=ani.mat
	$(CLI) -V compare --distance $(FASTA).sketch $(FASTA).compare=jaccard.mat
	$(CLI) -V compare --distance --method containment $(FASTA).sketch $(FASTA).compare=containment.mat

combine: ## Test combine command
	$(CLI) -V combine $(FASTA).sketch=kmersize_11.txt $(FASTA).sketch=kmersize_21.txt -o $(FASTA).combine

tree: ## Test tree command
	$(CLI) -V tree --distance $(FASTA).compare=ani.mat $(FASTA).tree=nj.nw
	$(CLI) -V tree --distance --method fastnj $(FASTA).compare=ani.mat $(FASTA).tree=fastnj.nw
	$(CLI) -V tree --distance --method upgma $(FASTA).compare=ani.mat $(FASTA).tree=upgma.nw
