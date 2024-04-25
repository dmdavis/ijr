# Design Proposal: Isolated Job Runner

Author(s): Dale Davis

Last updated: 2024-04-30

Discussion at [int-cloud-swe-dale](https://app.slack.com/client/TF04GMFKN/C070ZARGD6U) 
Slack channel.

<!-- TOC -->
* [Design Proposal: Isolated Job Runner](#design-proposal-isolated-job-runner)
  * [Abstract](#abstract)
  * [Proposal](#proposal)
    * [IJR Library](#ijr-library)
      * [Technology Stack](#technology-stack)
    * [ijrd](#ijrd)
    * [ijrctl](#ijrctl)
      * [ijrctl rootfs](#ijrctl-rootfs)
      * [ijrctl job](#ijrctl-job)
  * [Testing Strategy](#testing-strategy)
  * [Milestones](#milestones)
<!-- TOC -->

## Abstract

There is a need to execute jobs on Linux workers with process ID, mount, and
networking isolation. Users need to define CPU, memory, and disk I/O limits for
created jobs. Users can start and stop jobs, query job status, and stream the
output of running jobs.

## Proposal

The solution will consist of one git repository for library package code, client
and server CLI applications, unit tests, documentation, and build files. It 
provides the ability to upload archive root file systems and to execute jobs
consisting of commands or scripts located on the uploaded file systems. For this
release, file system archives will be gzipped tarballs.

Executing jobs cannot see the file system of the host the service is running on,
or any of the other uploaded file systems other than the one its being executed
on. Executing jobs have cannot access the host's network interfaces and have
no network access of their own in this release.

### IJR Library

The library will be a Go package with all the code and APIs for job lifecycle 
management. Documentation for the library can currently be found at in the 
[docs/godocs](./godocs) and can be viewed by running the `make godocs` target 
and navigating in a web browser to http://localhost:8000. Documentation is 
currently statically generated files. This static documentation will be removed
once the library is merged and documentation will be served by the `godocs`
too.

#### Technology Stack

The library and its CLI apps will be implemented with the following technologies:

* Golang 1.22 or later
* Make for builds (see the [Makefile](../Makefile) for build targets)
* gRPC for client/server transport
* mTLS for client/server encryption

The TLS 1.3 cipher suites that will be used include:

* tls.TLS_AES_128_GCM_SHA256
* tls.TLS_AES_256_GCM_SHA384
* tls.TLS_CHACHA20_POLY1305_SHA256

`tls.TLS_AES_128_GCM_SHA256` and `tls.TLS_AES_256_GCM_SHA384` both use the AES 
cipher in Galois/Counter Mode (GCM) for symmetric encryption. AES is a widely 
used symmetric encryption algorithm that is considered safe and efficient. 128 
and 256 represent key sizes, where a larger key size generally means more 
security but at the cost of more computational power. The numbers in the 
SHA256 and SHA384 are the lengths of hashes in bits. SHA-256 and SHA-384 are 
examples of hash functions in the SHA-2 family and are widely used in 
cryptographic applications and protocols. They have longer hash lengths 
compared to SHA-1 which is considered insecure now.

`tls.TLS_CHACHA20_POLY1305_SHA256` uses the ChaCha20 stream cipher and Poly1305
for message authentication. Stream ciphers are an alternative to block ciphers
like AES. ChaCha20 is a newer stream cipher that is designed to offer improved
performance on devices without hardware AES acceleration, such as some mobile
devices. Poly1305 is used for ensuring message integrity. A fundamental
component of secure communications, message authentication codes (MACs) like
Poly1305 help assure that a message has not been tampered with in transit.

The use of these cipher suites in TLS 1.3 implies encryption which offers 
confidentiality along with integrity and authenticity, which are crucial for 
secure communication. 

### ijrd

The `ijrd` service provides APIs for uploading, listing and deleting root file
systems on which jobs will execute, as well as start, stop, and stream the output
of running job commands. The gRPC API is defined by the following protobuf
definitions:

* [job.proto](../proto/job.proto) - Job management APIs
* [rootfs.proto](../proto/rootfs.proto) - Root file system management API

```shell
$ ijrd help
Usage: ijrd

Flags:
  --server - the server name (should match that used in certificates)
  --port   - the port to listin on (default: 50051)
  --cert   - path to X509 certificates
  --key    - path to X509 key file
  --rootfs - folder in which to extract root file systems to
```
The `ijrd` command requires all flags but `--port` to be defined.

### ijrctl

The `irjctl` command line application will allow the user to manage jobs and
root file systems on the `ijrd` service. It has two sub-commands: `job` and 
`rootfs`:

```shell
$ ijrctl help
Usage: ijrctl [job|rootfs]
Use 'ijrctl [job|rootfs] help' for more information about a command.
```

Encryption cert and key paths will be set in a config file so the user doesn't have
to specify them each call.

#### ijrctl rootfs

The rootfs sub-command in turn provides sub-commands for uploading, deleting, 
and listing root file systems commands will execute under.

```shell
$ ijrctl rootfs help
Usage: ijrctl rootfs [upload|list|delete]

upload options:
 --file=string - gzipped tarball of root file system
 --name=string - the sub-folder name to extract the file system to

delete options:
 --name=string - the sub-folder name of the root file system to remove
```
* The `ijrctl rootfs upload` command extracts a gzipped tarball to a sub-folder
under the `ijrd` server's specified root file system storage folder.
* The `ijrctl rootfs list` command lists available root file systems sub-folders.
* The `ijrclt rootfs delete` command removes a root file system. Trying to remove
  a root file system with an executing command will return an error. You must
  stop all jobs or wait for their completion before a file system they're using
  can be deleted.

#### ijrctl job

The `ijrctl job` sub-command controls the starting, stopping, streaming output, 
and listing of jobs.

```shell
$ ijrctl job help
Usage: ijrctl job [start|stop|list|output]

start options:
 --rootfs=string - root file system name (e.g. "alpine")
 --command=string - job command and args (e.g. "sleep 25", "/dosomething.sh", "etc.")
 --cpu=int - proportion of cpu shares the job has (e.g. 512, default: 1024)
 --memory=string - memory limit in (b)ytes, (k)ilobytes, (m)egs, or (g)igs (e.g. "100", "1024k", "2m")
 --disk-read-iops=string - limit read rate (IO per second) from a device (format: <device-path>:<number>)
 --disk-write-iops=string - limit write rate (IO per second) from a device (format: <device-path>:<number>)
 --output - if this flag is present, the start command will stream command output after listing the job ID 

stop and output options:
 --job=string - the job ID returned from job start
```
* The `ijrctl job start` command returns the job ID of the executing job.
* The `ijrctl job stop <jobID>` command stops the job with the specified job ID.
* The `ijrctl job list` command returns a list of all of executing jobs.
* The `ijrctl job output <jobID>` command streams the output of a running job

## Testing Strategy

Unit tests will be written for verifying library components. Unit tests can be
executed via the `make test` and `make coverage` build targets.

## Milestones

IJR will consist of three deliverables. Each will be its own pull request.

1. Design proposal, protobuf definitions for the gRPC API
2. Library code and unit tests
3. `ijrd` server and `ijrctl` client CLI apps