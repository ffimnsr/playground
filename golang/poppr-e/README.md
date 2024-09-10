# poppr-e(ngine)

The engine for poppr platform. The poppr platform main goal is to provide humane services that would help people rent other people's time for certain services.

## Create new packages

To create new package, first run:

```
go mod init github.com/ffimnsr/poppr-[package name]
```

Then after that run `gqlgen` to initialize package directory:

```
go get github.com/99designs/gqlgen
go mod tidy

go run github.com/99designs/gqlgen init
```

**Note**: Before doing a tidy, make sure the package directory is in `go.work` file. It seems it conflicts that's why there's an error on generation.

Re-generate files:

```
go run github.com/99designs/gqlgen generate
```


## Run the server

See the `makefile` for the available commands.
