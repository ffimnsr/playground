#!/usr/bin/env bash

set -e

[[ -z $1 ]] && exit 1

# create new package directory
mkdir -p "$PWD/packages/$1"

# sync package from default to new package
rsync -avhi "$PWD/packages/zz-default/" "$PWD/packages/$1"

# insert new package into go.work
sed -i "/)/i \\\t./packages/$1" go.work

pushd "$PWD/packages/$1"
go mod init github.com/ffimnsr/poppr-$1
cat > tools.go <<EOF
//go:build tools

package tools

import (
	_ "github.com/99designs/gqlgen"
	_ "github.com/99designs/gqlgen/graphql/introspection"
)
EOF
go mod tidy
go run github.com/99designs/gqlgen init
touch .env
popd
