FROM scratch
ADD rootfs.tar.gz /
MAINTAINER sparklyballs

# environment variables
ENV FORCE_CONTAINER_REMOVAL=1
ENV FORCE_IMAGE_REMOVAL=1

# install runtime packages
RUN \
 apk add --no-cache \
	bash && \
 apk add --no-cache \
	--repository http://nl.alpinelinux.org/alpine/edge/community \
	docker && \

# install build packages
 apk add --no-cache --virtual=build-dependencies \
	git && \

# fetch docker-gc repo to get latest ver of script
 git clone https://github.com/spotify/docker-gc /tmp/docker-gc && \

# link docker executable, copy and make docker-gc executable
 ln -s /usr/bin/docker \
	/bin/docker && \
 cp /tmp/docker-gc/docker-gc /docker-gc && \
 chmod +x \
	/docker-gc && \

# cleanup
 apk del --purge \
	build-dependencies && \
 rm -rf \
	/tmp/*

# port and volumes
VOLUME /var/lib/docker-gc

# run command
CMD ["/docker-gc"]
