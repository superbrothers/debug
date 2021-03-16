REPO ?= ghcr.io/superbrothers
IMAGE ?= debug
IMG := $(REPO)/$(IMAGE)

.PHONY: build
build:
	docker build -t $(IMG) .

.PHONY: push
push:
	docker push $(IMG)

.PHONY: run
run:
	docker run --rm -it $(IMG) /bin/bash
