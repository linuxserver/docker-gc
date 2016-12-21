#!/bin/bash

set -ex

# clean any prexisting variable values
unset BASE_ARCH GC_ARCH

# set arch for base image pulls and docker-gc
if [[ "${NODE_LABELS}"  == *"ARMHF"* ]]; then
BASE_ARCH="armhf"
GC_ARCH="-armhf"
elif [[ "${NODE_LABELS}"  == *"ARM64"* ]]; then
BASE_ARCH="arm64"
GC_ARCH="-armhf"
else
BASE_ARCH=""
GC_ARCH=""
fi

# pull docker images reading from docker-gc excludes file, ignoring readme-sync, docker-gc and shellcheck
while read -r excludes
do
	if [[ -z "${excludes}" || "${excludes}" == *"readme-sync"* \
	|| "${excludes}" == *"shellcheck"* || "${excludes}" == *"docker-gc"* ]]; then
		:
	elif [[ "${excludes}" == *"$BASE_ARCH"* && "$BASE_ARCH" == "arm64" ]]; then
		docker pull "${excludes}"
	elif [[ "${excludes}" == *"$BASE_ARCH"* && "$BASE_ARCH" == "armhf" ]]; then
		docker pull "${excludes}"
	elif [[ "${excludes}" != *"armhf"* && "${excludes}" != *"arm64"* && "$BASE_ARCH" == "" ]]; then
		docker pull "${excludes}"
fi
done < "${WORKSPACE}"/etc/docker-gc-exclude

# pull docker-gc and shellcheck images
docker pull lsiodev/docker-gc"${GC_ARCH}"
docker pull lsiodev/shellcheck"${GC_ARCH}"

# run docker gc
docker run --rm \
	-v /var/run/docker.sock:/var/run/docker.sock \
	-v "${WORKSPACE}"/etc:/etc lsiodev/docker-gc"${GC_ARCH}" || true
