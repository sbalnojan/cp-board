PROJECT_NAME := "cp-board"
PKG := "github.com/sbalnojan/$(PROJECT_NAME)"
PKG_LIST := $(shell go list ${PKG}/... | grep -v /vendor/)
GO_FILES := $(shell find . -name '*.go' | grep -v /vendor/ | grep -v _test.go)
VERSION := "0.0.1"

.PHONY: all dep build

build_linux: ## build linux amd64 binary
	env GOOS=linux GOARCH=amd64 go build -o target/cp-board-linux-amd64-$(VERSION) cmd/main.go
	chmod +x target/cp-board-darwin-amd64-$(VERSION)

build_mac: ## build mac amd64 binary
	env GOOS=darwin GOARCH=amd64 go build -o target/cp-board-darwin-amd64-$(VERSION) cmd/main.go
	chmod +x target/cp-board-darwin-amd64-$(VERSION)

dep: ## Get the dependencies
	@go get -v -d ./...

build_cf: ## install tropo-mods, create CF
	pip install git+https://github.com/sbalnojan/tropo-mods/
	python cf/build.py > cf/generated_cf.yml

build_ami: ## build ami with packer
	@packer build  cf/packer.json

run_local_bb:
	@./bitbar-cp-board-plugin/cpBoard.5s.sh dummyArg

help: ## Display this help screen
	@grep -h -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
