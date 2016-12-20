#!/bin/bash

set -ex

# set docker architecture based on NODE_LABELS variable from job
if [[ "${NODE_LABELS}"  == *"ARMHF"* ]]; then
GC_ARCH="-armhf"
PULL_ARCH="-armhf"
elif [[ "${NODE_LABELS}"  == *"ARM64"* ]]; then
GC_ARCH="-armhf"
PULL_ARCH="-arm64"
else
GC_ARCH=""
PULL_ARCH=""
fi

docker pull lsiobase/alpine"${PULL_ARCH}"
docker pull lsiobase/alpine.python"${PULL_ARCH}"
docker pull lsiobase/alpine.nginx"${PULL_ARCH}"
docker pull lsiobase/xenial"${PULL_ARCH}"
docker pull lsiodev/shellcheck"${GC_ARCH}"
docker pull lsiodev/docker-gc"${GC_ARCH}"

docker run --rm \
	-v /var/run/docker.sock:/var/run/docker.sock \
	-v "${WORKSPACE}"/etc:/etc lsiodev/docker-gc"${GC_ARCH}" || true
