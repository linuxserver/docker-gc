#!/bin/bash

set -ex

# clean any prexisting variable values
unset BASEIMAGE_ARCH CLEANUP_ARCH README_SYNC SHELLCHECK_ARCH

# test if node is for readme-sync
if [[ "${NODE_LABELS}"  == *"README"* ]]; then
	README_SYNC="true"
fi

# set arch for shellcheck readme-sync and cleanup based on node labels
if [[ "${NODE_LABELS}"  == *"X86"* ]]; then
	BASEIMAGE_ARCH="x86-64"
	README_SYNC_ARCH=""
	SHELLCHECK_ARCH=""
	CLEANUP_ARCH=""
elif [[ "${NODE_LABELS}" == *"ARM"* ]]; then
	SHELLCHECK_ARCH="-armhf"
	README_SYNC_ARCH="-armhf"
		if [[ "${NODE_LABELS}"  == *"ARM64"* ]]; then
		BASEIMAGE_ARCH="arm64"
		elif [[ "${NODE_LABELS}"  == *"ARMHF"* ]]; then
		BASEIMAGE_ARCH="armhf"
		fi
	CLEANUP_ARCH="-${BASEIMAGE_ARCH}"
fi

# pull docker images reading from docker-gc excludes file, ignoring readme-sync and shellcheck
while read -r excludes_file
do
	if [[ -z "${excludes_file}" || "${excludes_file}" == *"readme-sync"* \
	|| "${excludes_file}" == *"shellcheck"* ]]; then
		:

	elif [[ "${excludes_file}" == *"$BASEIMAGE_ARCH"* && "$BASEIMAGE_ARCH" == "arm64" ]]; then
		docker pull "${excludes_file}"

	elif [[ "${excludes_file}" == *"$BASEIMAGE_ARCH"* && "$BASEIMAGE_ARCH" == "armhf" \
	&& "${NODE_LABELS}"  != *"README"* ]]; then
		docker pull "${excludes_file}"

	elif [[ "${excludes_file}" != *"armhf"* && "${excludes_file}" != *"arm64"* \
	&& "$BASEIMAGE_ARCH" == "x86-64" ]]; then
		docker pull "${excludes_file}"
fi
done < "${WORKSPACE}"/exclude_list

# pull shellcheck image
if [[ "${README_SYNC}" == "true" ]]; then \
docker pull lsiodev/readme-sync"${README_SYNC_ARCH}"
else
docker pull lsiodev/shellcheck"${SHELLCHECK_ARCH}"
fi

# pull cleanup image
docker pull lsiodev/docker-gc"${CLEANUP_ARCH}"

# run docker gc
docker run --rm \
	-v /var/run/docker.sock:/var/run/docker.sock \
	-v "${WORKSPACE}"/exclude_list:/etc/docker-gc-exclude lsiodev/docker-gc"${CLEANUP_ARCH}" || true
