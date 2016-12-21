#!/bin/bash

set -ex

# clean any prexisting variable values
unset BASE_ARCH GC_ARCH

# set arch for base image pulls and docker-gc
if [[ "${NODE_LABELS}"  == *"ARMHF"* ]]; then
BASE_ARCH="armhf"
elif [[ "${NODE_LABELS}"  == *"ARM64"* ]]; then
BASE_ARCH="arm64"
else
BASE_ARCH=""
fi

if [[ "${BASE_ARCH}" == "" ]]; then
GC_ARCH=""
else
GC_ARCH="-${BASE_ARCH}"
fi

# pull docker images reading from docker-gc excludes file, ignoring readme-sync and shellcheck
while read -r excludes
do
	if [[ -z "${excludes}" || "${excludes}" == *"readme-sync"* \
	|| "${excludes}" == *"shellcheck"* ]]; then
		:
	elif [[ "${excludes}" == *"$BASE_ARCH"* && "$BASE_ARCH" == "arm64" ]]; then
		docker pull "${excludes}"
	elif [[ "${excludes}" == *"$BASE_ARCH"* && "$BASE_ARCH" == "armhf" ]]; then
		docker pull "${excludes}"
	elif [[ "${excludes}" != *"armhf"* && "${excludes}" != *"arm64"* && "$BASE_ARCH" == "" ]]; then
		docker pull "${excludes}"
fi
done < "${WORKSPACE}"/etc/docker-gc-exclude

# pull shellcheck image
docker pull lsiodev/shellcheck"${GC_ARCH}"

# run docker gc
docker run --rm \
	-v /var/run/docker.sock:/var/run/docker.sock \
	-v "${WORKSPACE}"/etc:/etc lsiodev/docker-gc"${GC_ARCH}" || true
