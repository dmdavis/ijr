Requirements
============

As defined in the [challenge] documentation, the isolated job runner MUST have 
the following features:

## Library

* Worker library with methods to start/stop/query status and get the output of a job.
* Library should be able to stream the output of a running job.
    * Output should be from start of process execution.
    * Multiple concurrent clients should be supported.
* Add resource control for CPU, Memory and Disk IO per job using cgroups.
* Add resource isolation for using PID, mount, and networking namespaces.

## API

* [GRPC](https://grpc.io) API to start/stop/get status/stream output of a running process.
* Use mTLS authentication and verify client certificate. Set up strong set of
  cipher suites for TLS and good crypto setup for certificates. Do not use any
  other authentication protocols on top of mTLS.
* Use a simple authorization scheme.

## Client

* CLI should be able to connect to worker service and start, stop, get status, and stream output of a job.

# Implementation Constraints

* All code must be written in Go.
* With the exceptions of uuid and gRPC, library usage is limited to the Go Standard Library.
* Documentation must be formatted in Markdown.

[challenge]: https://github.com/gravitational/careers/blob/main/challenges/systems/challenge-1.md