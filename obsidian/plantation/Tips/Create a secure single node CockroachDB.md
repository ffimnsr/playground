Create a CA certificate and key:

```bash
podman run --rm -v ./cockroachdb:/data:Z -it cockroach:latest cert create-ca --certs-dir=/data/certs --ca-key=/data/certs/ca.key
```

Create a node certificate and key:

```bash
podman run --rm -v ./cockroachdb:/data:Z -it cockroach:latest cert create-node <external-ip> cockroachnode1 crdb localhost 127.0.0.1 --certs-dir=/data/certs --ca-key=/data/certs/ca.key
```

Create a client certificate and key:

```bash
podman run --rm -v ./cockroachdb:/data:Z -it cockroach:latest cert create-client podmgr --certs-dir=/data/certs --ca-key=/data/certs/ca.key
```

List certificates:

```bash
podman run --rm -v ./cockroachdb:/data:Z -it cockroach:latest cert list --certs-dir=/data/certs
```

Start DB in secure mode:

```bash
podman run --rm -v ./cockroachdb:/data:Z -it cockroach:latest start --certs-dir=/data/certs –-advertise-addr=<external-ip> –-join=<external-ip> 
```

Initialize the certificates with node:

```
podman run --rm -v ./cockroachdb:/data:Z -it cockroach:latest init -–certs-dir=/data/certs -–host=<external-ip>
```

Access the cluster and create a user:

```bash
podman run --rm -v ./cockroachdb:/data:Z -it cockroach:latest sql -–certs-dir=/data/certs -–host=<external-ip>

...
> CREATE USER podmgr WITH PASSWORD ‘mysecretpassword’;
...
```

