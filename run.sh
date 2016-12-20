#!/bin/bash

set -ex

# set arch for base image pulls
if [[ "${NODE_LABELS}"  == *"ARMHF"* ]]; then
BASE_ARCH="armhf"
elif [[ "${NODE_LABELS}"  == *"ARM64"* ]]; then
BASE_ARCH="arm64"
else
BASE_ARCH=""
fi

# pull base images read from excludes file and based on node arch
while read -r excludes
do
	if [[ -z "${excludes}" || "${excludes}" == *"readme-sync"* || "${excludes}" == *"shellcheck"* ]]; then
		:
	elif [[ "${excludes}" == *"$BASE_ARCH"* && "$BASE_ARCH" == "arm64" ]]; then
		docker pull "${excludes}"
	elif [[ "${excludes}" == *"$BASE_ARCH"* && "$BASE_ARCH" == "armhf" ]]; then
		docker pull "${excludes}"
	elif [[ "${excludes}" != *"armhf"* && "${excludes}" != *"arm64"* && "$BASE_ARCH" == "" ]]; then
		docker pull "${excludes}"
fi
done < "${WORKSPACE}"/etc/docker-gc-exclude

# set arch for docker-gc and shellcheck based on NODE_LABELS variable from job
[[ "${NODE_LABELS}"  == *"ARM"* ]] && \
	GC_ARCH="-armhf"

# pull docker-gc and shellcheck
docker pull lsiodev/docker-gc"${GC_ARCH}"
docker pull lsiodev/shellcheck"${GC_ARCH}"

# run docker gc
docker run --rm \
	-v /var/run/docker.sock:/var/run/docker.sock \
	-v "${WORKSPACE}"/etc:/etc lsiodev/docker-gc"${GC_ARCH}" || true
