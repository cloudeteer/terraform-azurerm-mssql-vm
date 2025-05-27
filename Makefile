SHELL := /usr/bin/env bash

##
# Console Colors
##
GREEN  := $(shell tput -Txterm setaf 2)
YELLOW := $(shell tput -Txterm setaf 3)
WHITE  := $(shell tput -Txterm setaf 7)
CYAN   := $(shell tput -Txterm setaf 6)
RESET  := $(shell tput -Txterm sgr0)

.PHONY: help
help: ## show this help.
	@echo 'Usage:'
	@echo '  ${GREEN}make${RESET} ${YELLOW}<target>${RESET}'
	@echo ''
	@echo 'Targets:'
	@awk 'BEGIN {FS = ":.*?## "} { \
		if (/^[a-zA-Z_-]+:.*?##.*$$/) {printf "  ${GREEN}%-21s${YELLOW}%s${RESET}\n", $$1, $$2} \
		else if (/^## .*$$/) {printf "  ${CYAN}%s${RESET}\n", substr($$1,4)} \
		}' $(MAKEFILE_LIST)

.PHONY: clean
clean:
	rm -rf .terraform
	rm -rf .terraform.lock.hcl

.PHONY: test-default
test-default: ## Run tests on default
	@echo "Running tests on default"
	terraform init
	terraform test

.PHONY: test-examples
test-examples: ## Run tests on examples
	@echo "Running tests on examples"
	terraform init -test-directory=tests/examples
	terraform test -test-directory=tests/examples

.PHONY: test-local
test-local: ## Run tests on local
	@echo "Running tests on local"
	terraform init -test-directory=tests/local
	terraform test -test-directory=tests/local

.PHONY: test-remote
test-remote: ## Run tests on remote
	@echo "Running tests on remote"
	terraform init -test-directory=tests/remote
	terraform test -test-directory=tests/remote

.PHONY: test
test: test-default test-examples test-local clean test-remote ## Run all tests

.PHONY: docs
generate-docs: README.md ## Generate Terraform docs and update README.md

README.md: $(wildcard *.tf) .terraform-docs.yaml
	@echo "Generating Terraform docs for README.md"
	@terraform-docs  . --config .terraform-docs.yaml
