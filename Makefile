ENV=julia --project=.
FORMATTER=julia --project=@runic --startup-file=no -e 'using Runic; exit(Runic.main(ARGS))' --
LINTER=runic

PWD := $(shell pwd)

.PHONY: setup lint format precommit test help

help: ## Print this message
	@echo "usage: make [target] ..."
	@echo ""
	@echo "Available targets:"
	@grep --no-filename "##" $(MAKEFILE_LIST) | \
		grep --invert-match $$'\t' | \
		sed -e "s/\(.*\):.*## \(.*\)/ - \1:  \t\2/"

setup: ## Setup environment for development
	$(ENV) -e "using Pkg; Pkg.instantiate()"
	$(ENV) -e "using Pkg; Pkg.precompile()"
	julia --project=@runic -e 'using Pkg; Pkg.add("Runic")'

lint: ## Lint project codebase
	$(LINTER) -c -d .

format: ## Format project codebase
	$(FORMATTER) --inplace .

precommit: lint format ## Prepare codebase for commiting changes to GitHub

test: ## Test project codebase
	julia --project=./test test/runtests.jl

install: ## Create executable
	julia --project=@hypergen -e "using Pkg; Pkg.develop(path=\"$(PWD)\")'"
	julia --project=@hypergen -e "using Pkg; Pkg.precompile()"
	echo -e '#!/usr/bin/env bash\njulia --project=@hypergen -m "HyperGen" $1' > ~/.local/bin/hypergenjl
	chmod +x ~/.local/bin/hypergenjl
