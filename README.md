# Isolated Job Runner (IJR)

IJR is a library, service, and client for execute jobs with namespace and cgroup
isolation.

## Documentation

* [Design Proposal](./docs/design-proposal.md)
* [Library Godocs](./docs/godocs) - use `make godocs` to view on localhost:8000
* [gRPC API proto definitions](./proto)

## Building

Run `make` or `make help` to list build targets.

```plain
Usage:
  make <target>

Targets:
  Build:
    build               Build CLI programs and put the output binaries in out/bin/
    clean               Remove build related files
    vendor              Copy of all packages needed to support builds and tests into the vendor directory
    generate            Compile protobuf definitions and output to pkg/api/
  Test:
    test                Run the unit tests
    coverage            Run the unit tests and export the coverage
  Developer Setup:
    install-tools       Install local protoc and godoc if you need them
  Help:
    help                Show this help
```
