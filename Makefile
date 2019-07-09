PREFIX := $(HOME)
MAKE_PATH := $(dir $(realpath $(firstword $(MAKEFILE_LIST))))
DOCKERHUB_USER ?= ctxswitch
TWEMPROXY_VERSION ?= 0.4.1

all: build

.PHONY: build
build: # Build the container
	@docker build \
		--tag $(DOCKERHUB_USER)/twemproxy:$(TWEMPROXY_VERSION) \
		.

.PHONY: release
release: # Release all versions
	@docker tag $(DOCKERHUB_USER)/twemproxy:$(TWEMPROXY_VERSION) $(DOCKERHUB_USER)/twemproxy:latest
	@docker push $(DOCKERHUB_USER)/twemproxy:latest
	@docker push $(DOCKERHUB_USER)/twemproxy:$(TWEMPROXY_VERSION)

.PHONY: clean
clean:
	@docker rm $(shell docker ps -qa) || true
	@docker rmi $(shell docker images -q $(DOCKERHUB_USER)/twemproxy) --force || true
