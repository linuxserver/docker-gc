#!/bin/bash
docker pull spotify/docker-gc
docker run --rm \
	-v /var/run/docker.sock:/var/run/docker.sock \
	-v "${WORKSPACE}"/etc:/etc spotify/docker-gc || true
