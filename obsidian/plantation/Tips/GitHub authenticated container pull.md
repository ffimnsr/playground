Simple way to pull docker images from GitHub container registry, with authenticated version pull and parsing of JSON.  

Replace the `jq` arguments and also all arguments inside the `<>` marks.

```bash
#!/usr/bin/env bash

set +xe

PACKAGE_VERSION=$(curl -u $CR_USERNAME:$CR_PAT -H "Accept: application/vnd.github.v3+json" https://api.github.com/orgs/<ORG>/packages/container/<PKG_NAME>/versions | jq -r .[0].metadata.container.tags[1])

docker pull ghcr.io/<ORG>/<PKG_NAME>:$PACKAGE_VERSION
docker pull ghcr.io/<ORG>/<PKG_NAME>:latest
```