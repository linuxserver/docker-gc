#!/bin/bash

set -ex

docker pull lsiodev/docker-gc-armhf

docker run --rm \
	-v /var/run/docker.sock:/var/run/docker.sock \
	-v "${WORKSPACE}"/etc:/etc lsiodev/docker-gc-armhf FORCE_OPTIONS_IMAGE FORCE_OPTIONS_CONTAINER || true

