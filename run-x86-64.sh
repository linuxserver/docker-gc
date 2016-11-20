#!/bin/bash
docker pull lsiodev/docker-gc

docker run --rm \
	-v /var/run/docker.sock:/var/run/docker.sock \
	-v "${WORKSPACE}"/etc:/etc lsiodev/docker-gc FORCE_OPTIONS_IMAGE FORCE_OPTIONS_CONTAINER || true

