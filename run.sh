#!/bin/bash

set -ex

unset GC_ARCH PULL_ARCH

# set docker architecture based on NODE_LABELS variable from job
[[ "${NODE_LABELS}"  == *"ARM"* ]] && \
	GC_ARCH="-armhf"
[[ "${NODE_LABELS}"  == *"ARMHF"* ]] && \
	PULL_ARCH=".armhf"
[[ "${NODE_LABELS}"  == *"ARM64"* ]] && \
	PULL_ARCH=".arm64"


docker pull lsiobase/alpine"${PULL_ARCH}"
docker pull lsiobase/alpine.python"${PULL_ARCH}"
docker pull lsiobase/alpine.nginx"${PULL_ARCH}"
docker pull lsiobase/xenial"${PULL_ARCH}"
docker pull lsiodev/shellcheck"${GC_ARCH}"
docker pull lsiodev/docker-gc"${GC_ARCH}"

docker run --rm \
	-v /var/run/docker.sock:/var/run/docker.sock \
	-v "${WORKSPACE}"/etc:/etc lsiodev/docker-gc"${GC_ARCH}" || true
