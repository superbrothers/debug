REGISTRY ?= ghcr.io/superbrothers
IMAGE ?= $(REGISTRY)/debug
ARCH ?= amd64
ALL_ARCH ?= amd64 arm64
# renovate: datasource=docker depName=docker.io/multiarch/qemu-user-static versioning=docker
QEMU_VERSION ?= 5.2.0-2

DOCKER_BUILDX_BUILD_FLAGS :=
ifeq ($(PULL_CACHE),1)
DOCKER_BUILDX_BUILD_FLAGS += --cache-from=type=registry,ref=$(IMAGE)-$(ARCH):buildcache
endif
ifeq ($(PUSH_CACHE),1)
DOCKER_BUILDX_BUILD_FLAGS += --cache-to=type=registry,ref=$(IMAGE)-$(ARCH):buildcache
endif

.PHONY: build
build:
ifneq ($(ARCH),amd64)
	docker run --rm --privileged docker.io/multiarch/qemu-user-static:$(QEMU_VERSION) --reset -p yes
endif
	docker buildx version
	BUILDER=$$(docker buildx create --use --driver docker-container)
	docker buildx build --pull --load --platform $(ARCH) -t $(IMAGE)-$(ARCH) $(DOCKER_BUILDX_BUILD_FLAGS) .
	docker buildx rm "$${BUILDER}"

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
