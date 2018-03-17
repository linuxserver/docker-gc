#!/bin/bash

set -ex

# clean any prexisting variable values
unset BASEIMAGE_ARCH CLEANUP_ARCH SHELLCHECK_ARCH

# set arch for baseimage
if [[ "${NODE_LABELS}"  == *"ARMHF"* ]]; then
BASEIMAGE_ARCH="armhf"
elif [[ "${NODE_LABELS}"  == *"ARM64"* ]]; then
BASEIMAGE_ARCH="arm64"
elif [[ "${NODE_LABELS}"  == *"README"* ]]; then
BASEIMAGE_ARCH="readme"
elif [[ "${NODE_LABELS}"  == *"X86"* ]]; then
BASEIMAGE_ARCH="x86-64"
fi

# set arch for cleanup and shellcheck
if [[ "${NODE_LABELS}" == *"ARM"* ]]; then
CLEANUP_ARCH="-${BASEIMAGE_ARCH}"
SHELLCHECK_ARCH="-armhf"
else
CLEANUP_ARCH=""
SHELLCHECK_ARCH=""
fi

# pull docker images reading from docker-gc excludes file, ignoring readme-sync and shellcheck
while read -r excludes_file
do
	if [[ -z "${excludes_file}" || "${excludes_file}" == *"readme-sync"* \
	|| "${excludes_file}" == *"shellcheck"* ]]; then
		:

	elif [[ "${excludes_file}" == *"$BASEIMAGE_ARCH"* && "$BASEIMAGE_ARCH" == "arm64" ]]; then
		docker pull "${excludes_file}"

	elif [[ "${excludes_file}" == *"$BASEIMAGE_ARCH"* && "$BASEIMAGE_ARCH" == "armhf" ]]; then
		docker pull "${excludes_file}"

	elif [[ "${excludes_file}" != *"armhf"* && "${excludes_file}" != *"arm64"* \
	&& "$BASEIMAGE_ARCH" == "x86-64" ]]; then
		docker pull "${excludes_file}"
fi
done < "${WORKSPACE}"/exclude_list

# pull shellcheck image
if [[ "$BASEIMAGE_ARCH" == "readme" ]]; then \
docker pull lsiodev/readme-sync-armhf
else
docker pull lsiodev/shellcheck"${SHELLCHECK_ARCH}"
fi

# run docker gc
docker run --rm \
	-v /var/run/docker.sock:/var/run/docker.sock \
	-v "${WORKSPACE}"/exclude_list:/etc/docker-gc-exclude lsiodev/docker-gc"${CLEANUP_ARCH}" || true
