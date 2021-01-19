REPO ?= ghcr.io/superbrothers
IMAGE ?= debug
IMG := $(REPO)/$(IMAGE)

.PHONY: build
build:
	docker build -t $(IMG) .
