include $(PWD)/.env

PACKAGE_NAME=poppr-$(shell basename $(PWD))
OS_S := $(shell uname -s)
ifeq ($(OS_S), Darwin)
	C_RUNNER := docker
else
	C_RUNNER := podman
endif

.PHONY: generate start d package console show-tables clean-db
generate:
	go generate ./...

start:
	PORT=${PORT} go run server.go

d:
	PORT=${PORT} go run server.go

package:
	./package.sh

console:
	$(C_RUNNER) exec -it -u postgres postgres psql -d ${PACKAGE_NAME}

show-tables:
	$(C_RUNNER) exec -it -u postgres postgres psql -d ${PACKAGE_NAME} -c "\dt"

clean-db:
	$(C_RUNNER) exec -it -u postgres postgres psql -c "drop database if exists \"${PACKAGE_NAME}\";"
	$(C_RUNNER) exec -it -u postgres postgres psql -c "create database \"${PACKAGE_NAME}\";"
	$(C_RUNNER) exec -it -u postgres postgres psql -c "\l"
