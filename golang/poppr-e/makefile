OS_S := $(shell uname -s)
ifeq ($(OS_S), Darwin)
	C_RUNNER := docker
else
	C_RUNNER := podman
endif

.PHONY: start-db start-minio sync console show-dbs

PG_EXIT_STATUS := $(shell $(C_RUNNER) inspect --format="{{.Id}}" postgres &>/dev/null; echo $$?)
ifeq ($(PG_EXIT_STATUS), 1)
start-db:
	$(C_RUNNER) pull -q docker.io/library/postgres:16-alpine
	$(C_RUNNER) run --name postgres \
		-e POSTGRES_PASSWORD=secret \
		-v postgres-data:/var/lib/postgresql/data \
		-d -p 5432:5432 \
		postgres:16-alpine
else
start-db:
	$(C_RUNNER) restart postgres
endif

# Run on default credentials which is minioadmin:minioadmin
IO_EXIT_STATUS := $(shell $(C_RUNNER) inspect --format="{{.Id}}" minio &>/dev/null; echo $$?)
ifeq ($(IO_EXIT_STATUS), 1)
start-minio:
	$(C_RUNNER) pull -q quay.io/minio/minio:latest
	$(C_RUNNER) run --name minio \
		-d -p 9000:9000 -p 9001:9001 \
		quay.io/minio/minio server /data --console-address ":9001"
else
start-minio:
	$(C_RUNNER) restart minio
endif

sync:
	./sync-commons.sh

console:
	$(C_RUNNER) exec -it -u postgres postgres psql

show-dbs:
	$(C_RUNNER) exec -it -u postgres postgres psql -c "\l"
