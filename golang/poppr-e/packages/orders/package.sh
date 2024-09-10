#!/usr/bin/env bash

set -e

latest_version=$(git describe --tags | tr -d '\t\n ')
name=$(basename $PWD)
podman build \
	--label org.opencontainers.image.created=$(date --iso-8601=ns) \
	--label org.opencontainers.image.authors=gh:@ffimnsr \
	--label org.opencontainers.image.description="poppr-e-$name $latest_version" \
	--label org.opencontainers.image.revision=$(git rev-parse HEAD) \
	--label org.opencontainers.image.source=$(git remote get-url origin) \
	--label org.opencontainers.image.title=poppr-e-$name \
	--label org.opencontainers.image.url=https://github.com/ffimnsr/poppr-e \
	-t docker.io/ifn4/poppr-e-$name:$latest_version .

podman push docker.io/ifn4/poppr-e-$name:$latest_version
podman push docker.io/ifn4/poppr-e-$name:$latest_version docker.io/ifn4/poppr-e-$name:latest
