PWD							:= $(shell pwd)
OS							?= $(shell uname | awk '{print tolower($$0)}')
ARCH						:= $(shell uname -m | awk '{print tolower($$0)}')
CURRENT_USER		:= $(shell id -u)
CURRENT_GROUP		:= $(shell id -g)

GO_PKG					:= go-command-map
GO_CMD					?= $(GO_PKG)
GO_SRC_PATH			:= /go/src
GO_PKG_PATH			:= $(GO_SRC_PATH)/github.com/bmo-tv/$(GO_PKG)
GO_IMAGE				:= golang
GO_VERSION			:= alpine
GO_PKG_FLAG			:= $(GO_PKG)_$(OS)_$(ARCH)

DOCKER_COMMAND	:= docker run -it --rm \
	-e CURRENT_USER_ID=$(CURRENT_USER) \
	-e CURRENT_GROUP_ID=$(CURRENT_GROUP) \
	-v $(PWD):$(GO_PKG_PATH) \
	-w $(GO_PKG_PATH) \
	$(GO_IMAGE):$(GO_VERSION)

all: clean test build

go-run-%:
	$(DOCKER_COMMAND) go run src/$*.go

go-build-%:
	$(DOCKER_COMMAND) /bin/sh -c \
		'GOOS=$(OS) \
		go build -o $(GO_PKG_PATH)/bin/$* ./src/... && \
		chown -R $$CURRENT_USER_ID:$$CURRENT_GROUP_ID $(GO_PKG_PATH)/bin'

go-install-%:
	if [ -f ./bin/$* ]; then \
		cp ./bin/$* /usr/local/bin/$(GO_CMD); \
	fi

go-test:
	$(DOCKER_COMMAND) go test ./src

go-clean-%:
	@rm -f $$(pwd)/bin/$* || true

run:
	@echo "Running script"
	@$(MAKE) -s go-run-main

clean:
	@echo "Cleaning old build"
	@$(MAKE) -s go-clean-$(GO_PKG_FLAG)

build: clean
	@echo "Building binary"
	@$(MAKE) -s go-build-$(GO_PKG_FLAG)

test:
	@echo "Running test"
	@$(MAKE) -s go-test

install: test build
	@echo "Installing $(PKG)"
	@$(MAKE) -s go-install-$(GO_PKG_FLAG)

.PHONY: run clean build test install
