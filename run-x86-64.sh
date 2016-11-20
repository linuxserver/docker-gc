#!/bin/bash

set -ex

docker pull lsiodev/docker-gc

docker run --rm \
	-v /var/run/docker.sock:/var/run/docker.sock \
	-v "${WORKSPACE}"/etc:/etc lsiodev/docker-gc || true

