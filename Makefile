REGISTRY ?= ghcr.io/superbrothers
IMAGE ?= $(REGISTRY)/debug
ARCH ?= amd64
ALL_ARCH ?= amd64 arm64
QEMU_VERSION ?= 5.2.0-2

.PHONY: build
build:
ifneq ($(ARCH),amd64)
	docker run --rm --privileged multiarch/qemu-user-static:$(QEMU_VERSION) --reset -p yes
	docker buildx version
	BUILDER=$$(docker buildx create --use)
endif
	docker buildx build --pull --load --platform $(ARCH) -t $(IMAGE)-$(ARCH) .
ifneq ($(ARCH),amd64)
	docker buildx rm "$${BUILDER}"
endif

build-%:
	$(MAKE) ARCH=$* build

.PHONY: build-all
build-all: $(addprefix build-,$(ALL_ARCH))

.PHONY: push
push:
	docker push $(IMAGE)-$(ARCH)

push-%:
	$(MAKE) ARCH=$* push

.PHONY: push-all
push-all: $(addprefix push-,$(ALL_ARCH))

.PHONY: push-manifest
push-manifest:
	docker manifest create --amend $(IMAGE) $(shell echo $(ALL_ARCH) | sed -e "s~[^ ]*~$(IMAGE)\-&~g")
	@for arch in $(ALL_ARCH); do docker manifest annotate --arch $${arch} $(IMAGE) $(IMAGE)-$${arch}; done
	docker manifest push --purge $(IMAGE)

.PHONY: all-push
all-push: push-all push-manifest

.PHONY: run
run:
	docker run --rm -it $(IMAGE)-$(ARCH) /bin/bash
