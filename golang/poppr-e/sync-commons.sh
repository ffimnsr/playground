#!/usr/bin/env bash

set -e

[[ ! -d "$PWD/packages" ]] && exit 0

for d in $PWD/packages/*/; do
	dir=$(basename $d)
	# skip symbolic links
	[[ -L "${d%/}" ]] && continue
	# skip default package
	[[ "$dir" = "zz-default" ]] && continue

	echo "Syncing $dir common files"

	# sync package from default to new package
	rsync -avhi "$PWD/packages/zz-default/" "$PWD/packages/$dir"
done
