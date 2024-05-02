GOCMD=go
GOTEST=$(GOCMD) test
GOVET=$(GOCMD) vet
GOINSTALL=$(GOCMD) install
PROTOC=protoc
BINARY_CLIENT=ijrctl
BINARY_SERVER=ijrd
VERSION?=0.0.1

GREEN  := $(shell tput -Txterm setaf 2)
YELLOW := $(shell tput -Txterm setaf 3)
WHITE  := $(shell tput -Txterm setaf 7)
CYAN   := $(shell tput -Txterm setaf 6)
RESET  := $(shell tput -Txterm sgr0)

.PHONY: all test build vendor generate install-tools godoc

all: help

## Build:
build: ## Build CLI programs and put the output binaries in out/bin/
	mkdir -p out/bin
	GO111MODULE=on $(GOCMD) build -mod vendor -o out/bin/$(BINARY_CLIENT) ./cmd/$(BINARY_CLIENT)/$(BINARY_CLIENT).go
	GO111MODULE=on $(GOCMD) build -mod vendor -o out/bin/$(BINARY_SERVER) ./cmd/$(BINARY_SERVER)/$(BINARY_SERVER).go

clean: ## Remove build related files
	rm -fr ./bin
	rm -fr ./out
	rm -f ./profile.cov

vendor: ## Copy of all packages needed to support builds and tests into the vendor directory
	$(GOCMD) mod vendor

generate: ## Compile protobuf definitions and output to pkg/api/
	$(PROTOC) --proto_path=proto --go_out=pkg/api/job --go-grpc_out=pkg/api --go_opt=paths=source_relative job.proto

## Test:
test: ## Run the unit tests
	$(GOTEST) -v -race ./... $(OUTPUT_OPTIONS)

coverage: ## Run the unit tests and export the coverage
	$(GOTEST) -cover -covermode=count -coverprofile=profile.cov ./...
	$(GOCMD) tool cover -func profile.cov

## Developer Setup:
install-tools: ## Install local protoc, grpc plugin, and godoc if you need them
	$(GOINSTALL) google.golang.org/protobuf/cmd/protoc-gen-go@latest
	$(GOINSTALL) google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
	$(GOINSTALL) golang.org/x/tools/cmd/godoc@latest
	$(GOINSTALL) github.com/princjef/gomarkdoc/cmd/gomarkdoc@latest

## Help:
help: ## Show this help
	@echo ''
	@echo 'Usage:'
	@echo '  ${YELLOW}make${RESET} ${GREEN}<target>${RESET}'
	@echo ''
	@echo 'Targets:'
	@awk 'BEGIN {FS = ":.*?## "} { \
		if (/^[a-zA-Z_-]+:.*?##.*$$/) {printf "    ${YELLOW}%-20s${GREEN}%s${RESET}\n", $$1, $$2} \
		else if (/^## .*$$/) {printf "  ${CYAN}%s${RESET}\n", substr($$1,4)} \
		}' $(MAKEFILE_LIST)