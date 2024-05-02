# Design Proposal: Isolated Job Runner

Author(s): Dale Davis

Last updated: 2024-05-02

Discussion at [int-cloud-swe-dale](https://app.slack.com/client/TF04GMFKN/C070ZARGD6U) 
Slack channel.

<!-- TOC -->
* [Design Proposal: Isolated Job Runner](#design-proposal-isolated-job-runner)
  * [Abstract](#abstract)
  * [Proposal](#proposal)
    * [IJR Library](#ijr-library)
      * [Job Lifecycle](#job-lifecycle)
      * [Technology Stack](#technology-stack)
      * [Authentication](#authentication)
    * [IJR ProtoBuf Definition](#ijr-protobuf-definition)
    * [Command-Line Applications](#command-line-applications)
      * [ijrtoken](#ijrtoken)
      * [ijrd](#ijrd)
      * [ijrctl](#ijrctl)
  * [Testing Strategy](#testing-strategy)
  * [Milestones](#milestones)
  * [GoDocs](#godocs)
    * [pkg/auth](#pkgauth)
      * [Index](#index)
      * [type TokenData](#type-tokendata)
        * [func \(\*TokenData\) Generate](#func-tokendata-generate)
        * [func \(\*TokenData\) Load](#func-tokendata-load)
        * [func \(\*TokenData\) Save](#func-tokendata-save)
    * [pkg/job](#pkgjob)
      * [Index](#index-1)
      * [type ExecAttributes](#type-execattributes)
      * [type ExecutionState](#type-executionstate)
      * [type ExecutionStateStore](#type-executionstatestore)
        * [func NewExecutionStateStore](#func-newexecutionstatestore)
        * [func \(\*ExecutionStateStore\) Add](#func-executionstatestore-add)
        * [func \(\*ExecutionStateStore\) Delete](#func-executionstatestore-delete)
        * [func \(\*ExecutionStateStore\) List](#func-executionstatestore-list)
      * [type Job](#type-job)
        * [func \(\*Job\) GetJobId](#func-job-getjobid)
        * [func \(\*Job\) Start](#func-job-start)
        * [func \(\*Job\) Stop](#func-job-stop)
      * [type Server](#type-server)
        * [func \(Server\) ListJobs](#func-server-listjobs)
        * [func \(Server\) StartJob](#func-server-startjob)
        * [func \(Server\) StopJob](#func-server-stopjob)
        * [func \(Server\) StreamJobOutput](#func-server-streamjoboutput)
    * [pkg/api](#pkgapi)
      * [Index](#index-2)
      * [type OutputSender](#type-outputsender)
      * [type PrintOutputSender](#type-printoutputsender)
        * [func \(PrintOutputSender\) Send](#func-printoutputsender-send)
    * [pkg/api/job](#pkgapijob)
      * [Index](#index-3)
      * [Constants](#constants)
      * [Variables](#variables)
      * [func RegisterJobServiceServer](#func-registerjobserviceserver)
      * [type JobIdentifier](#type-jobidentifier)
        * [func \(\*JobIdentifier\) Descriptor](#func-jobidentifier-descriptor)
        * [func \(\*JobIdentifier\) GetJobId](#func-jobidentifier-getjobid)
        * [func \(\*JobIdentifier\) ProtoMessage](#func-jobidentifier-protomessage)
        * [func \(\*JobIdentifier\) ProtoReflect](#func-jobidentifier-protoreflect)
        * [func \(\*JobIdentifier\) Reset](#func-jobidentifier-reset)
        * [func \(\*JobIdentifier\) String](#func-jobidentifier-string)
      * [type JobOutput](#type-joboutput)
        * [func \(\*JobOutput\) Descriptor](#func-joboutput-descriptor)
        * [func \(\*JobOutput\) GetOutput](#func-joboutput-getoutput)
        * [func \(\*JobOutput\) ProtoMessage](#func-joboutput-protomessage)
        * [func \(\*JobOutput\) ProtoReflect](#func-joboutput-protoreflect)
        * [func \(\*JobOutput\) Reset](#func-joboutput-reset)
        * [func \(\*JobOutput\) String](#func-joboutput-string)
      * [type JobRecord](#type-jobrecord)
        * [func \(\*JobRecord\) Descriptor](#func-jobrecord-descriptor)
        * [func \(\*JobRecord\) GetCpuShares](#func-jobrecord-getcpushares)
        * [func \(\*JobRecord\) GetDiskReadIopsLimit](#func-jobrecord-getdiskreadiopslimit)
        * [func \(\*JobRecord\) GetDiskWriteIopsLimit](#func-jobrecord-getdiskwriteiopslimit)
        * [func \(\*JobRecord\) GetJobCommand](#func-jobrecord-getjobcommand)
        * [func \(\*JobRecord\) GetJobId](#func-jobrecord-getjobid)
        * [func \(\*JobRecord\) GetJobStart](#func-jobrecord-getjobstart)
        * [func \(\*JobRecord\) GetMemoryLimitInBytes](#func-jobrecord-getmemorylimitinbytes)
        * [func \(\*JobRecord\) ProtoMessage](#func-jobrecord-protomessage)
        * [func \(\*JobRecord\) ProtoReflect](#func-jobrecord-protoreflect)
        * [func \(\*JobRecord\) Reset](#func-jobrecord-reset)
        * [func \(\*JobRecord\) String](#func-jobrecord-string)
      * [type JobServiceClient](#type-jobserviceclient)
        * [func NewJobServiceClient](#func-newjobserviceclient)
      * [type JobServiceServer](#type-jobserviceserver)
      * [type JobService\\\_StreamJobOutputClient](#type-jobservice_streamjoboutputclient)
      * [type JobService\\\_StreamJobOutputServer](#type-jobservice_streamjoboutputserver)
      * [type ListJobsRequest](#type-listjobsrequest)
        * [func \(\*ListJobsRequest\) Descriptor](#func-listjobsrequest-descriptor)
        * [func \(\*ListJobsRequest\) ProtoMessage](#func-listjobsrequest-protomessage)
        * [func \(\*ListJobsRequest\) ProtoReflect](#func-listjobsrequest-protoreflect)
        * [func \(\*ListJobsRequest\) Reset](#func-listjobsrequest-reset)
        * [func \(\*ListJobsRequest\) String](#func-listjobsrequest-string)
      * [type ListJobsResponse](#type-listjobsresponse)
        * [func \(\*ListJobsResponse\) Descriptor](#func-listjobsresponse-descriptor)
        * [func \(\*ListJobsResponse\) GetJobRecords](#func-listjobsresponse-getjobrecords)
        * [func \(\*ListJobsResponse\) ProtoMessage](#func-listjobsresponse-protomessage)
        * [func \(\*ListJobsResponse\) ProtoReflect](#func-listjobsresponse-protoreflect)
        * [func \(\*ListJobsResponse\) Reset](#func-listjobsresponse-reset)
        * [func \(\*ListJobsResponse\) String](#func-listjobsresponse-string)
      * [type StartRequest](#type-startrequest)
        * [func \(\*StartRequest\) Descriptor](#func-startrequest-descriptor)
        * [func \(\*StartRequest\) GetCpuShares](#func-startrequest-getcpushares)
        * [func \(\*StartRequest\) GetDiskReadIopsLimit](#func-startrequest-getdiskreadiopslimit)
        * [func \(\*StartRequest\) GetDiskWriteIopsLimit](#func-startrequest-getdiskwriteiopslimit)
        * [func \(\*StartRequest\) GetJobArguments](#func-startrequest-getjobarguments)
        * [func \(\*StartRequest\) GetJobCommand](#func-startrequest-getjobcommand)
        * [func \(\*StartRequest\) GetMemoryLimitInBytes](#func-startrequest-getmemorylimitinbytes)
        * [func \(\*StartRequest\) ProtoMessage](#func-startrequest-protomessage)
        * [func \(\*StartRequest\) ProtoReflect](#func-startrequest-protoreflect)
        * [func \(\*StartRequest\) Reset](#func-startrequest-reset)
        * [func \(\*StartRequest\) String](#func-startrequest-string)
      * [type StartResponse](#type-startresponse)
        * [func \(\*StartResponse\) Descriptor](#func-startresponse-descriptor)
        * [func \(\*StartResponse\) GetJobId](#func-startresponse-getjobid)
        * [func \(\*StartResponse\) GetJobStart](#func-startresponse-getjobstart)
        * [func \(\*StartResponse\) ProtoMessage](#func-startresponse-protomessage)
        * [func \(\*StartResponse\) ProtoReflect](#func-startresponse-protoreflect)
        * [func \(\*StartResponse\) Reset](#func-startresponse-reset)
        * [func \(\*StartResponse\) String](#func-startresponse-string)
      * [type StopResponse](#type-stopresponse)
        * [func \(\*StopResponse\) Descriptor](#func-stopresponse-descriptor)
        * [func \(\*StopResponse\) GetStatus](#func-stopresponse-getstatus)
        * [func \(\*StopResponse\) ProtoMessage](#func-stopresponse-protomessage)
        * [func \(\*StopResponse\) ProtoReflect](#func-stopresponse-protoreflect)
        * [func \(\*StopResponse\) Reset](#func-stopresponse-reset)
        * [func \(\*StopResponse\) String](#func-stopresponse-string)
      * [type StopResponse\\\_JobStatus](#type-stopresponse_jobstatus)
        * [func \(StopResponse\_JobStatus\) Descriptor](#func-stopresponse_jobstatus-descriptor)
        * [func \(StopResponse\_JobStatus\) Enum](#func-stopresponse_jobstatus-enum)
        * [func \(StopResponse\_JobStatus\) EnumDescriptor](#func-stopresponse_jobstatus-enumdescriptor)
        * [func \(StopResponse\_JobStatus\) Number](#func-stopresponse_jobstatus-number)
        * [func \(StopResponse\_JobStatus\) String](#func-stopresponse_jobstatus-string)
        * [func \(StopResponse\_JobStatus\) Type](#func-stopresponse_jobstatus-type)
      * [type StreamServiceOutputSender](#type-streamserviceoutputsender)
        * [func \(StreamServiceOutputSender\) Send](#func-streamserviceoutputsender-send)
      * [type UnimplementedJobServiceServer](#type-unimplementedjobserviceserver)
        * [func \(UnimplementedJobServiceServer\) ListJobs](#func-unimplementedjobserviceserver-listjobs)
        * [func \(UnimplementedJobServiceServer\) StartJob](#func-unimplementedjobserviceserver-startjob)
        * [func \(UnimplementedJobServiceServer\) StopJob](#func-unimplementedjobserviceserver-stopjob)
        * [func \(UnimplementedJobServiceServer\) StreamJobOutput](#func-unimplementedjobserviceserver-streamjoboutput)
      * [type UnsafeJobServiceServer](#type-unsafejobserviceserver)
<!-- TOC -->

## Abstract

There is a need to execute jobs on Linux workers with process ID, mount, and
networking isolation. Users need to define CPU, memory, and disk I/O limits for
created jobs. Users can start and stop jobs, query job status, and stream the
output of running jobs.

## Proposal

The solution will consist of one git repository for library package code, client
and server CLI applications, unit tests, documentation, and build files. It 
provides the ability execute jobs consisting of commands or scripts located on 
host file systems.

The job's `/proc` folder will be remounted to provide process isolation from the
host and other executing jobs. Executing jobs have cannot access the host's 
network interfaces and have no network access of their own in this release.

### IJR Library

The library will be a Go package with all the code and APIs for job lifecycle 
management. Documentation for the library can currently be found at the bottom
of this document.

Once the library is merged, you'll be able to view the actual go documentation 
via `make godocs` target. 

#### Job Lifecycle

The basic lifecycle of a job is as follows:

1. A client requests a job execute a command via the `ijrctl start` command.
2. The `ijrctl` app makes a gRPC call to the `ijrd` server with the command,
   0 or more arguments to supply to the command, its CPU, memory, and disk I/O
   settings, and an access token previously generated with `ijrtoken`.
3. The `ijrd` app uses the `job.Server` class to receive and validate the 
   request. If the access token and request are valid, the `job.Server` type 
   creates a new `job.Job` type to spawn the job process.
   * The `job.Job.Start` method sets up the cgroup limits for the job.
   * It then creates the `exec.Command` with the job command and arguments.
   * It configures system process namespaces for the `exec.Command`.
   * It sets up STDOUT and STDIN pipes and connects them to the 
     `job.Job.OuputSender` for streaming job output.
   * It remaps the host's `/proc` folder to a tmp folder to isolate the job from
     the other processes running on the host and other jobs.
   * It then assigns a unique job ID to the job, saves the job ID to the 
     `ExecutionStateStore` and starts the job.
4. The `irjd` service returns a job ID to the client they may use to stop the 
   job if desired.
5. It optionally begins streaming the command output back to the client if
   requested. Otherwise, the caller can use the job ID to view output with
   another `ijrctl output` call.

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

#### Authentication

Users create access tokens using the `ijrtoken` command line app. Given a user
ID and a secret key, the app generates and stores access tokens on the host 
server file system as JSON-encoded data where the file name matches the access 
token.

The `ijrd` server is given the path to where the JSON files are stored along 
with the secret key used to generate the tokens. Clients provide the auth token
via a metadata pair of `"authorization"` and `"Bearer "+token`. The gRPC API 
will provide basic authentication of client calls via a server-side
[interceptor](https://grpc.io/docs/guides/interceptors/) that will validate the
tokens using the `auth.TokenData` type.

### IJR ProtoBuf Definition

The job gRPC service messages, requests, and responses are defined as follows:

```protobuf
// The file defines the JobService API.
syntax = "proto3";

package job;

option go_package = "/job";

import "google/protobuf/timestamp.proto";

// JobService provides methods for starting a job and streaming its output.
service JobService {
  // Starts the job and returns an identifier for the job.
  rpc StartJob(StartRequest) returns (StartResponse) {}
  // Returns a list of running jobs with their jobId and jobStart timestamps.
  rpc ListJobs(ListJobsRequest) returns (ListJobsResponse) {}
  // Stream the output of the job.
  rpc StreamJobOutput(JobIdentifier) returns (stream JobOutput) {}
  // Stops a running job.
  rpc StopJob(JobIdentifier) returns (StopResponse) {}
}

// StartRequest contains the job command, arguments, and resource constraints.
message StartRequest {
  // The job command line to run.
  string job_command = 1;
  // Arguments for the job command.
  repeated string job_arguments = 2;
  // A number representing the proportion of CPU shares the job has.
  uint32 cpu_shares = 3;
  // Maximum memory limit in bytes.
  uint64 memory_limit_in_bytes = 4;
  // A string in the form <device>:<io/s limit> (ex. /dev/sdc:1200) use to limit
  // read I/O operations per second.
  string disk_read_iops_limit = 5;
  // A string in the form <device>:<io/s limit> (ex. /dev/sdc:1200) use to limit
  // write I/O operations per second.
  string disk_write_iops_limit = 6;
}

// StartResponse is returned by StartJob if there is no error.
message StartResponse {
  // A unique string representing the running job.
  string job_id = 1;
  // The host system timestamp for when the job started.
  google.protobuf.Timestamp job_start = 2;
}

// JobIdentifier contains a jobId field. Set this field to the jobId value
// returned when a job successfully starts.
message JobIdentifier {
  // A unique string representing the running job.
  string job_id = 1;
}

// JobOutput contains the streamed output of the running job.
message JobOutput {
  // The streamed output of an executing job.
  bytes output = 1;
}

// StopResponse will return a status of STOPPED once the job command is stopped.
message StopResponse {
  // The status of the job.
  enum JobStatus {
    UNKNOWN = 0;    // Placeholder for an unknown job status
    STOPPED = 1;    // The job was stopped successfully
  }
  // JobStatus represents the final status of the job after stopping.
  JobStatus status = 1;
}

// ListJobsRequest contains no fields. Merely pass it to the ListJobs method to
// retrieve the list of running jobs.
message ListJobsRequest {
}

// ListJobsResponse returns the JobInfo for each running job.
message ListJobsResponse {
  repeated JobRecord job_records = 1;
}

// JobRecord contains the settings of each running job.
message JobRecord {
  // A unique string representing the running job.
  string job_id = 1;
  // The host system timestamp for when the job started.
  google.protobuf.Timestamp job_start = 2;
  // The job command line being executed.
  string job_command = 3;
  // A number representing the proportion of CPU shares the job has.
  uint32 cpu_shares = 4;
  // Maximum memory limit in bytes.
  uint64 memory_limit_in_bytes = 5;
  // A string in the form <device>:<io/s limit> (ex. /dev/sdc:1200) use to limit
  // read I/O operations per second.
  string disk_read_iops_limit = 6;
  // A string in the form <device>:<io/s limit> (ex. /dev/sdc:1200) use to limit
  // write I/O operations per second.
  string disk_write_iops_limit = 7;
}
```

### Command-Line Applications

IJR consists of thre command line apps: []()

#### ijrtoken

The `ijrtoken` app generates access tokens from a supplied user ID and secret
key. It writes a JSON file containing the generated auth token, the user ID, the
creation timestamp, and the pseudo-random number used to generate the token to a
specified path.

```shell
$ ijrtoken help
Usage: ijrtoken <userId> <flags>

Flags:
  --secret - the secret key 
  --path   - the path to store the generated <token>.json file
```

#### ijrd

The `ijrd` service provides APIs for starting, stopping, and streaming the 
output of running job commands.

```shell
$ ijrd help
Usage: ijrd

Flags:
  --server - the server name (should match that used in certificates)
  --port   - the port to listin on (default: 50051)
  --cert   - path to X509 certificates
  --key    - path to X509 key file
  --secret - the secret used to validate access tokens
```
The `ijrd` command requires all flags but `--port` to be defined.

####  ijrctl

The `irjctl` command line application will allow the user to manage jobs on the
`ijrd` service. It looks for a `.ijrctl-config` file in the user's home directory
or at the path specified by the `--config` flag containing the client X509 cert
and key, the address and port of the running `ijrd` service.

```shell
$ ijrctl help
Usage: ijrctl [start|stop|list|output]

Flags: 
  --config=path            - an optional path to the config file

start options:
  --command=string         - job command and args (e.g. "sleep", "/dosomething.sh", "etc.")
  --arg=string             - individual arguments to be passed to the job command (e.g. --arg "10" --arg "foo")
  --cpu=int                - proportion of cpu shares the job has (e.g. 512, default: 1024)
  --memory=string          - memory limit in (b)ytes, (k)ilobytes, (m)egs, or (g)igs (e.g. "100", "1024k", "2m")
  --disk-read-iops=string  - limit read rate (IO per second) from a device (format: <device-path>:<number>)
  --disk-write-iops=string - limit write rate (IO per second) from a device (format: <device-path>:<number>)
  --output                 - if this flag is present, the start command will stream command output after listing the job ID 
 
stop and output options:
  --job=string             - the job ID returned from job start
```
* The `ijrctl start` command returns the job ID of the executing job.
* The `ijrctl stop <jobID>` command stops the job with the specified job ID.
* The `ijrctl list` command returns a list of all of executing jobs.
* The `ijrctl output <jobID>` command streams the output of a running job

## Testing Strategy

Unit tests will be written for verifying library components. Unit tests can be
executed via the `make test` and `make coverage` build targets.

## Milestones

IJR will consist of three deliverables. Each will be its own pull request.

1. Design proposal, protobuf definitions for the gRPC API
2. Library code and unit tests
3. `ijrtoken`, `ijrd` server, and `ijrctl` client CLI apps

## GoDocs

The Go documentation is broken down into three subsections.

1. [pkg/auth]()
   * The `auth.TokenData` type for generating access tokens.
2. [pkg/job]()
   * The `job.Job` type responsible for job process setup and execution.
   * The `job.Server` type that implements the `api/jobs` protobuf interface and
     manages Jobs in response to gRPC calls.
3. [pkg/api]()
   * OutputSender interface for decoupling streamed command output for easier
     unit testing.
4. [pkg/api/jobs]()
   * gRPC client and server boilerplate generated from `job.proto`.

### pkg/auth

```go
import "github.com/dmdavis/ijr/pkg/auth"
```

Package auth contains the [TokenData](<#TokenData>) type for generating access tokens from a user ID, the current unix timestamp, pseudo\-random number and a secret key.

#### Index

- [type TokenData](<#TokenData>)
    - [func \(t \*TokenData\) Generate\(secretKey string\) error](<#TokenData.Generate>)
    - [func \(t \*TokenData\) Load\(path string\) error](<#TokenData.Load>)
    - [func \(t \*TokenData\) Save\(path string\) error](<#TokenData.Save>)


<a name="TokenData"></a>
#### type [TokenData](<https://github.com/dmdavis/ijr/blob/main/pkg/auth/auth.go#L19-L24>)

TokenData contains the hex\-encoded AccessToken along with the UserId, unix Timestamp, and RandNumber used to generate the access token. The secretKey used is not stored.

```go
type TokenData struct {
    UserId      string `json:"userId"`
    Timestamp   int64  `json:"timestamp"`
    RandNumber  int    `json:"randNumber"`
    AccessToken string `json:"accessToken"`
}
```

<a name="TokenData.Generate"></a>
##### func \(\*TokenData\) [Generate](<https://github.com/dmdavis/ijr/blob/main/pkg/auth/auth.go#L43>)

```go
func (t *TokenData) Generate(secretKey string) error
```

Generate takes the UserId and secretKey and generates a hex\-encoded access token using the SHA\-256 hash of a colon\-delimited string consisting of the UserId, the current unix Timestamp, and a pseudo\-random number between 0 and 100,000. Any existing values for Timestamp, RandNumber, and AccessToken will be overwritten. If the UserId is empty, this method will return an error.

<a name="TokenData.Load"></a>
##### func \(\*TokenData\) [Load](<https://github.com/dmdavis/ijr/blob/main/pkg/auth/auth.go#L84>)

```go
func (t *TokenData) Load(path string) error
```

Load opens a JSON file at the specified path and decodes its contents into the TokenData struct. The file is expected to have the following JSON format:

```
{
  "userId": "example_user",
  "timestamp": 1635947358,
  "randNumber": 12345,
  "accessToken": "c66636a3d9adb6cefac24379f74953b2b0baae94377a1db40d68a1f4e1ac16e7"
}
```

The UserId, Timestamp, RandNumber, and AccessToken fields of the TokenData struct will be overwritten with the values from the file.

If the file cannot be opened or if the JSON decoding fails, an error is returned. The file is closed before returning.

<a name="TokenData.Save"></a>
##### func \(\*TokenData\) [Save](<https://github.com/dmdavis/ijr/blob/main/pkg/auth/auth.go#L55>)

```go
func (t *TokenData) Save(path string) error
```

Save writes the TokenData to disk as a JSON file. If JSON marshalling or writing the file fails, Save will return an error.

### pkg/job

```go
import "github.com/dmdavis/ijr/pkg/job"
```

Package job contains the [Job](<#Job>), [Server](<#Server>), and [ExecutionStateStore](<#ExecutionStateStore>) structs and code.

#### Index

- [type ExecAttributes](<#ExecAttributes>)
- [type ExecutionState](<#ExecutionState>)
- [type ExecutionStateStore](<#ExecutionStateStore>)
    - [func NewExecutionStateStore\(\) \*ExecutionStateStore](<#NewExecutionStateStore>)
    - [func \(s \*ExecutionStateStore\) Add\(id uuid.UUID, jobState ExecutionState\)](<#ExecutionStateStore.Add>)
    - [func \(s \*ExecutionStateStore\) Delete\(id uuid.UUID\)](<#ExecutionStateStore.Delete>)
    - [func \(s \*ExecutionStateStore\) List\(\) map\[uuid.UUID\]ExecutionState](<#ExecutionStateStore.List>)
- [type Job](<#Job>)
    - [func \(j \*Job\) GetJobId\(\) string](<#Job.GetJobId>)
    - [func \(j \*Job\) Start\(attributes ExecAttributes, wg \*sync.WaitGroup\) error](<#Job.Start>)
    - [func \(j \*Job\) Stop\(\) error](<#Job.Stop>)
- [type Server](<#Server>)
    - [func \(s Server\) ListJobs\(context.Context, \*job.ListJobsRequest\) \(\*job.ListJobsResponse, error\)](<#Server.ListJobs>)
    - [func \(s Server\) StartJob\(context.Context, \*job.StartRequest\) \(\*job.StartResponse, error\)](<#Server.StartJob>)
    - [func \(s Server\) StopJob\(context.Context, \*job.JobIdentifier\) \(\*job.StopResponse, error\)](<#Server.StopJob>)
    - [func \(s Server\) StreamJobOutput\(\*job.JobIdentifier, job.JobService\_StreamJobOutputServer\) error](<#Server.StreamJobOutput>)


<a name="ExecAttributes"></a>
#### type [ExecAttributes](<https://github.com/dmdavis/ijr/blob/main/pkg/job/job.go#L36-L49>)

ExecAttributes holds the execution settings for a job initiated with Job.Start.

```go
type ExecAttributes struct {
// CPUShares is a number representing the proportion of CPU shares the job has.
CPUShares string
// MemoryLimit represents the memory limit of a job in bytes.
MemoryLimit string
// DiskReadIOLimit represents the limit on disk read I/O for a job in IOPS per second.
DiskReadIOLimit string
// DiskWriteIOLimit represents the limit on disk write I/O for a job in IOPS per second.
DiskWriteIOLimit string
// JobCommand represents the command to be executed by a Job.
JobCommand string
// JobArguments represents any arguments to supply to the job command.
JobArguments []string
}
```

<a name="ExecutionState"></a>
#### type [ExecutionState](<https://github.com/dmdavis/ijr/blob/main/pkg/job/state.go#L10-L13>)

ExecutionState contains information about a running job.

```go
type ExecutionState struct {
RootFS     string
JobCommand string
}
```

<a name="ExecutionStateStore"></a>
#### type [ExecutionStateStore](<https://github.com/dmdavis/ijr/blob/main/pkg/job/state.go#L18-L21>)

ExecutionStateStore represents a basic in\-memory data store for the execution state of running jobs. It provides methods to add, delete, and list job state and is safe to call from multiple goroutines.

```go
type ExecutionStateStore struct {
// contains filtered or unexported fields
}
```

<a name="NewExecutionStateStore"></a>
##### func [NewExecutionStateStore](<https://github.com/dmdavis/ijr/blob/main/pkg/job/state.go#L24>)

```go
func NewExecutionStateStore() *ExecutionStateStore
```

NewExecutionStateStore returns a new instance of ExecutionStateStore.

<a name="ExecutionStateStore.Add"></a>
##### func \(\*ExecutionStateStore\) [Add](<https://github.com/dmdavis/ijr/blob/main/pkg/job/state.go#L32>)

```go
func (s *ExecutionStateStore) Add(id uuid.UUID, jobState ExecutionState)
```

Add adds a new job execution state to the ExecutionStateStore by associating the provided \`id\` with the given \`jobState\`.

<a name="ExecutionStateStore.Delete"></a>
##### func \(\*ExecutionStateStore\) [Delete](<https://github.com/dmdavis/ijr/blob/main/pkg/job/state.go#L39>)

```go
func (s *ExecutionStateStore) Delete(id uuid.UUID)
```

Delete removes the ExecutionState with the specified \`id\` from the store.

<a name="ExecutionStateStore.List"></a>
##### func \(\*ExecutionStateStore\) [List](<https://github.com/dmdavis/ijr/blob/main/pkg/job/state.go#L48>)

```go
func (s *ExecutionStateStore) List() map[uuid.UUID]ExecutionState
```

List acquires a read lock before returning the \`store\` field of the ExecutionStateStore instance, which is a map of UUID keys to ExecutionState values.

<a name="Job"></a>
#### type [Job](<https://github.com/dmdavis/ijr/blob/main/pkg/job/job.go#L54-L60>)

Job represents an executable job.

```go
type Job struct {
// OutputSender sends job command STDOUT and STDERR text via OutputSender.Send().
OutputSender api.OutputSender
// contains filtered or unexported fields
}
```

<a name="Job.GetJobId"></a>
##### func \(\*Job\) [GetJobId](<https://github.com/dmdavis/ijr/blob/main/pkg/job/job.go#L147>)

```go
func (j *Job) GetJobId() string
```

GetJobId returns the UUID of the running job.

<a name="Job.Start"></a>
##### func \(\*Job\) [Start](<https://github.com/dmdavis/ijr/blob/main/pkg/job/job.go#L70>)

```go
func (j *Job) Start(attributes ExecAttributes, wg *sync.WaitGroup) error
```

Start starts the job with the supplied ExecAttributes and an optional sync.WaitGroup wg. Set wg to nil if you don't need to wait on completion.

<a name="Job.Stop"></a>
##### func \(\*Job\) [Stop](<https://github.com/dmdavis/ijr/blob/main/pkg/job/job.go#L167>)

```go
func (j *Job) Stop() error
```

Stop kills the job process.

<a name="Server"></a>
#### type [Server](<https://github.com/dmdavis/ijr/blob/main/pkg/job/server.go#L11-L13>)

Server serves the job and rootfs gRPC services.

```go
type Server struct {
job.UnimplementedJobServiceServer
}
```

<a name="Server.ListJobs"></a>
##### func \(Server\) [ListJobs](<https://github.com/dmdavis/ijr/blob/main/pkg/job/server.go#L22>)

```go
func (s Server) ListJobs(context.Context, *job.ListJobsRequest) (*job.ListJobsResponse, error)
```

ListJobs returns a list of all running jobs.

<a name="Server.StartJob"></a>
##### func \(Server\) [StartJob](<https://github.com/dmdavis/ijr/blob/main/pkg/job/server.go#L17>)

```go
func (s Server) StartJob(context.Context, *job.StartRequest) (*job.StartResponse, error)
```

StartJob is a method that starts a job with the given context and request. It returns a StartResponse and an error.

<a name="Server.StopJob"></a>
##### func \(Server\) [StopJob](<https://github.com/dmdavis/ijr/blob/main/pkg/job/server.go#L32>)

```go
func (s Server) StopJob(context.Context, *job.JobIdentifier) (*job.StopResponse, error)
```

StopJob terminates a running job.

<a name="Server.StreamJobOutput"></a>
##### func \(Server\) [StreamJobOutput](<https://github.com/dmdavis/ijr/blob/main/pkg/job/server.go#L27>)

```go
func (s Server) StreamJobOutput(*job.JobIdentifier, job.JobService_StreamJobOutputServer) error
```

StreamJobOutput streams command output from a running job.

### pkg/api

```go
import "github.com/dmdavis/ijr/pkg/api"
```

Package api houses the Go gRPC implementations of job protobuf definitions and OutputSender to adapt streaming job output bytes to various targets.

#### Index

- [type OutputSender](<#OutputSender>)
- [type PrintOutputSender](<#PrintOutputSender>)
    - [func \(s PrintOutputSender\) Send\(output \[\]byte\) error](<#PrintOutputSender.Send>)


<a name="OutputSender"></a>
#### type [OutputSender](<https://github.com/dmdavis/ijr/blob/main/pkg/api/output.go#L7-L9>)

OutputSender is an interface that provides a Send method for sending scanned text to receiver as bytes.

```go
type OutputSender interface {
    Send([]byte) error
}
```

<a name="PrintOutputSender"></a>
#### type [PrintOutputSender](<https://github.com/dmdavis/ijr/blob/main/pkg/api/output.go#L12>)

PrintOutputSender print command output to the console.

```go
type PrintOutputSender struct{}
```

<a name="PrintOutputSender.Send"></a>
##### func \(PrintOutputSender\) [Send](<https://github.com/dmdavis/ijr/blob/main/pkg/api/output.go#L15>)

```go
func (s PrintOutputSender) Send(output []byte) error
```

Send prints output text via fmt.Println.

### pkg/api/job

```go
import "github.com/dmdavis/ijr/pkg/api/job"
```

Package job contains the Go gRPC implementation of the job.proto definitions.

#### Index

- [Constants](<#constants>)
- [Variables](<#variables>)
- [func RegisterJobServiceServer\(s grpc.ServiceRegistrar, srv JobServiceServer\)](<#RegisterJobServiceServer>)
- [type JobIdentifier](<#JobIdentifier>)
    - [func \(\*JobIdentifier\) Descriptor\(\) \(\[\]byte, \[\]int\)](<#JobIdentifier.Descriptor>)
    - [func \(x \*JobIdentifier\) GetJobId\(\) string](<#JobIdentifier.GetJobId>)
    - [func \(\*JobIdentifier\) ProtoMessage\(\)](<#JobIdentifier.ProtoMessage>)
    - [func \(x \*JobIdentifier\) ProtoReflect\(\) protoreflect.Message](<#JobIdentifier.ProtoReflect>)
    - [func \(x \*JobIdentifier\) Reset\(\)](<#JobIdentifier.Reset>)
    - [func \(x \*JobIdentifier\) String\(\) string](<#JobIdentifier.String>)
- [type JobOutput](<#JobOutput>)
    - [func \(\*JobOutput\) Descriptor\(\) \(\[\]byte, \[\]int\)](<#JobOutput.Descriptor>)
    - [func \(x \*JobOutput\) GetOutput\(\) \[\]byte](<#JobOutput.GetOutput>)
    - [func \(\*JobOutput\) ProtoMessage\(\)](<#JobOutput.ProtoMessage>)
    - [func \(x \*JobOutput\) ProtoReflect\(\) protoreflect.Message](<#JobOutput.ProtoReflect>)
    - [func \(x \*JobOutput\) Reset\(\)](<#JobOutput.Reset>)
    - [func \(x \*JobOutput\) String\(\) string](<#JobOutput.String>)
- [type JobRecord](<#JobRecord>)
    - [func \(\*JobRecord\) Descriptor\(\) \(\[\]byte, \[\]int\)](<#JobRecord.Descriptor>)
    - [func \(x \*JobRecord\) GetCpuShares\(\) uint32](<#JobRecord.GetCpuShares>)
    - [func \(x \*JobRecord\) GetDiskReadIopsLimit\(\) string](<#JobRecord.GetDiskReadIopsLimit>)
    - [func \(x \*JobRecord\) GetDiskWriteIopsLimit\(\) string](<#JobRecord.GetDiskWriteIopsLimit>)
    - [func \(x \*JobRecord\) GetJobCommand\(\) string](<#JobRecord.GetJobCommand>)
    - [func \(x \*JobRecord\) GetJobId\(\) string](<#JobRecord.GetJobId>)
    - [func \(x \*JobRecord\) GetJobStart\(\) \*timestamppb.Timestamp](<#JobRecord.GetJobStart>)
    - [func \(x \*JobRecord\) GetMemoryLimitInBytes\(\) uint64](<#JobRecord.GetMemoryLimitInBytes>)
    - [func \(\*JobRecord\) ProtoMessage\(\)](<#JobRecord.ProtoMessage>)
    - [func \(x \*JobRecord\) ProtoReflect\(\) protoreflect.Message](<#JobRecord.ProtoReflect>)
    - [func \(x \*JobRecord\) Reset\(\)](<#JobRecord.Reset>)
    - [func \(x \*JobRecord\) String\(\) string](<#JobRecord.String>)
- [type JobServiceClient](<#JobServiceClient>)
    - [func NewJobServiceClient\(cc grpc.ClientConnInterface\) JobServiceClient](<#NewJobServiceClient>)
- [type JobServiceServer](<#JobServiceServer>)
- [type JobService\_StreamJobOutputClient](<#JobService_StreamJobOutputClient>)
- [type JobService\_StreamJobOutputServer](<#JobService_StreamJobOutputServer>)
- [type ListJobsRequest](<#ListJobsRequest>)
    - [func \(\*ListJobsRequest\) Descriptor\(\) \(\[\]byte, \[\]int\)](<#ListJobsRequest.Descriptor>)
    - [func \(\*ListJobsRequest\) ProtoMessage\(\)](<#ListJobsRequest.ProtoMessage>)
    - [func \(x \*ListJobsRequest\) ProtoReflect\(\) protoreflect.Message](<#ListJobsRequest.ProtoReflect>)
    - [func \(x \*ListJobsRequest\) Reset\(\)](<#ListJobsRequest.Reset>)
    - [func \(x \*ListJobsRequest\) String\(\) string](<#ListJobsRequest.String>)
- [type ListJobsResponse](<#ListJobsResponse>)
    - [func \(\*ListJobsResponse\) Descriptor\(\) \(\[\]byte, \[\]int\)](<#ListJobsResponse.Descriptor>)
    - [func \(x \*ListJobsResponse\) GetJobRecords\(\) \[\]\*JobRecord](<#ListJobsResponse.GetJobRecords>)
    - [func \(\*ListJobsResponse\) ProtoMessage\(\)](<#ListJobsResponse.ProtoMessage>)
    - [func \(x \*ListJobsResponse\) ProtoReflect\(\) protoreflect.Message](<#ListJobsResponse.ProtoReflect>)
    - [func \(x \*ListJobsResponse\) Reset\(\)](<#ListJobsResponse.Reset>)
    - [func \(x \*ListJobsResponse\) String\(\) string](<#ListJobsResponse.String>)
- [type StartRequest](<#StartRequest>)
    - [func \(\*StartRequest\) Descriptor\(\) \(\[\]byte, \[\]int\)](<#StartRequest.Descriptor>)
    - [func \(x \*StartRequest\) GetCpuShares\(\) uint32](<#StartRequest.GetCpuShares>)
    - [func \(x \*StartRequest\) GetDiskReadIopsLimit\(\) string](<#StartRequest.GetDiskReadIopsLimit>)
    - [func \(x \*StartRequest\) GetDiskWriteIopsLimit\(\) string](<#StartRequest.GetDiskWriteIopsLimit>)
    - [func \(x \*StartRequest\) GetJobArguments\(\) \[\]string](<#StartRequest.GetJobArguments>)
    - [func \(x \*StartRequest\) GetJobCommand\(\) string](<#StartRequest.GetJobCommand>)
    - [func \(x \*StartRequest\) GetMemoryLimitInBytes\(\) uint64](<#StartRequest.GetMemoryLimitInBytes>)
    - [func \(\*StartRequest\) ProtoMessage\(\)](<#StartRequest.ProtoMessage>)
    - [func \(x \*StartRequest\) ProtoReflect\(\) protoreflect.Message](<#StartRequest.ProtoReflect>)
    - [func \(x \*StartRequest\) Reset\(\)](<#StartRequest.Reset>)
    - [func \(x \*StartRequest\) String\(\) string](<#StartRequest.String>)
- [type StartResponse](<#StartResponse>)
    - [func \(\*StartResponse\) Descriptor\(\) \(\[\]byte, \[\]int\)](<#StartResponse.Descriptor>)
    - [func \(x \*StartResponse\) GetJobId\(\) string](<#StartResponse.GetJobId>)
    - [func \(x \*StartResponse\) GetJobStart\(\) \*timestamppb.Timestamp](<#StartResponse.GetJobStart>)
    - [func \(\*StartResponse\) ProtoMessage\(\)](<#StartResponse.ProtoMessage>)
    - [func \(x \*StartResponse\) ProtoReflect\(\) protoreflect.Message](<#StartResponse.ProtoReflect>)
    - [func \(x \*StartResponse\) Reset\(\)](<#StartResponse.Reset>)
    - [func \(x \*StartResponse\) String\(\) string](<#StartResponse.String>)
- [type StopResponse](<#StopResponse>)
    - [func \(\*StopResponse\) Descriptor\(\) \(\[\]byte, \[\]int\)](<#StopResponse.Descriptor>)
    - [func \(x \*StopResponse\) GetStatus\(\) StopResponse\_JobStatus](<#StopResponse.GetStatus>)
    - [func \(\*StopResponse\) ProtoMessage\(\)](<#StopResponse.ProtoMessage>)
    - [func \(x \*StopResponse\) ProtoReflect\(\) protoreflect.Message](<#StopResponse.ProtoReflect>)
    - [func \(x \*StopResponse\) Reset\(\)](<#StopResponse.Reset>)
    - [func \(x \*StopResponse\) String\(\) string](<#StopResponse.String>)
- [type StopResponse\_JobStatus](<#StopResponse_JobStatus>)
    - [func \(StopResponse\_JobStatus\) Descriptor\(\) protoreflect.EnumDescriptor](<#StopResponse_JobStatus.Descriptor>)
    - [func \(x StopResponse\_JobStatus\) Enum\(\) \*StopResponse\_JobStatus](<#StopResponse_JobStatus.Enum>)
    - [func \(StopResponse\_JobStatus\) EnumDescriptor\(\) \(\[\]byte, \[\]int\)](<#StopResponse_JobStatus.EnumDescriptor>)
    - [func \(x StopResponse\_JobStatus\) Number\(\) protoreflect.EnumNumber](<#StopResponse_JobStatus.Number>)
    - [func \(x StopResponse\_JobStatus\) String\(\) string](<#StopResponse_JobStatus.String>)
    - [func \(StopResponse\_JobStatus\) Type\(\) protoreflect.EnumType](<#StopResponse_JobStatus.Type>)
- [type StreamServiceOutputSender](<#StreamServiceOutputSender>)
    - [func \(j StreamServiceOutputSender\) Send\(output \[\]byte\) error](<#StreamServiceOutputSender.Send>)
- [type UnimplementedJobServiceServer](<#UnimplementedJobServiceServer>)
    - [func \(UnimplementedJobServiceServer\) ListJobs\(context.Context, \*ListJobsRequest\) \(\*ListJobsResponse, error\)](<#UnimplementedJobServiceServer.ListJobs>)
    - [func \(UnimplementedJobServiceServer\) StartJob\(context.Context, \*StartRequest\) \(\*StartResponse, error\)](<#UnimplementedJobServiceServer.StartJob>)
    - [func \(UnimplementedJobServiceServer\) StopJob\(context.Context, \*JobIdentifier\) \(\*StopResponse, error\)](<#UnimplementedJobServiceServer.StopJob>)
    - [func \(UnimplementedJobServiceServer\) StreamJobOutput\(\*JobIdentifier, JobService\_StreamJobOutputServer\) error](<#UnimplementedJobServiceServer.StreamJobOutput>)
- [type UnsafeJobServiceServer](<#UnsafeJobServiceServer>)


#### Constants

<a name="JobService_StartJob_FullMethodName"></a>

```go
const (
    JobService_StartJob_FullMethodName        = "/job.JobService/StartJob"
    JobService_ListJobs_FullMethodName        = "/job.JobService/ListJobs"
    JobService_StreamJobOutput_FullMethodName = "/job.JobService/StreamJobOutput"
    JobService_StopJob_FullMethodName         = "/job.JobService/StopJob"
)
```

#### Variables

<a name="StopResponse_JobStatus_name"></a>Enum value maps for StopResponse\_JobStatus.

```go
var (
    StopResponse_JobStatus_name = map[int32]string{
        0:  "UNKNOWN",
        1:  "STOPPED",
    }
    StopResponse_JobStatus_value = map[string]int32{
        "UNKNOWN": 0,
        "STOPPED": 1,
    }
)
```

<a name="File_job_proto"></a>

```go
var File_job_proto protoreflect.FileDescriptor
```

<a name="JobService_ServiceDesc"></a>JobService\_ServiceDesc is the grpc.ServiceDesc for JobService service. It's only intended for direct use with grpc.RegisterService, and not to be introspected or modified \(even as a copy\)

```go
var JobService_ServiceDesc = grpc.ServiceDesc{
    ServiceName: "job.JobService",
    HandlerType: (*JobServiceServer)(nil),
    Methods: []grpc.MethodDesc{
        {
            MethodName: "StartJob",
            Handler:    _JobService_StartJob_Handler,
        },
        {
            MethodName: "ListJobs",
            Handler:    _JobService_ListJobs_Handler,
        },
        {
            MethodName: "StopJob",
            Handler:    _JobService_StopJob_Handler,
        },
    },
    Streams: []grpc.StreamDesc{
        {
            StreamName:    "StreamJobOutput",
            Handler:       _JobService_StreamJobOutput_Handler,
            ServerStreams: true,
        },
    },
    Metadata: "job.proto",
}
```

<a name="RegisterJobServiceServer"></a>
#### func [RegisterJobServiceServer](<https://github.com/dmdavis/ijr/blob/main/pkg/api/job/job_grpc.pb.go#L151>)

```go
func RegisterJobServiceServer(s grpc.ServiceRegistrar, srv JobServiceServer)
```



<a name="JobIdentifier"></a>
#### type [JobIdentifier](<https://github.com/dmdavis/ijr/blob/main/pkg/api/job/job.pb.go#L229-L236>)

JobIdentifier contains a jobId field. Set this field to the jobId value returned when a job successfully starts.

```go
type JobIdentifier struct {

    // A unique string representing the running job.
    JobId string `protobuf:"bytes,1,opt,name=job_id,json=jobId,proto3" json:"job_id,omitempty"`
    // contains filtered or unexported fields
}
```

<a name="JobIdentifier.Descriptor"></a>
##### func \(\*JobIdentifier\) [Descriptor](<https://github.com/dmdavis/ijr/blob/main/pkg/api/job/job.pb.go#L266>)

```go
func (*JobIdentifier) Descriptor() ([]byte, []int)
```

Deprecated: Use JobIdentifier.ProtoReflect.Descriptor instead.

<a name="JobIdentifier.GetJobId"></a>
##### func \(\*JobIdentifier\) [GetJobId](<https://github.com/dmdavis/ijr/blob/main/pkg/api/job/job.pb.go#L270>)

```go
func (x *JobIdentifier) GetJobId() string
```



<a name="JobIdentifier.ProtoMessage"></a>
##### func \(\*JobIdentifier\) [ProtoMessage](<https://github.com/dmdavis/ijr/blob/main/pkg/api/job/job.pb.go#L251>)

```go
func (*JobIdentifier) ProtoMessage()
```



<a name="JobIdentifier.ProtoReflect"></a>
##### func \(\*JobIdentifier\) [ProtoReflect](<https://github.com/dmdavis/ijr/blob/main/pkg/api/job/job.pb.go#L253>)

```go
func (x *JobIdentifier) ProtoReflect() protoreflect.Message
```



<a name="JobIdentifier.Reset"></a>
##### func \(\*JobIdentifier\) [Reset](<https://github.com/dmdavis/ijr/blob/main/pkg/api/job/job.pb.go#L238>)

```go
func (x *JobIdentifier) Reset()
```



<a name="JobIdentifier.String"></a>
##### func \(\*JobIdentifier\) [String](<https://github.com/dmdavis/ijr/blob/main/pkg/api/job/job.pb.go#L247>)

```go
func (x *JobIdentifier) String() string
```



<a name="JobOutput"></a>
#### type [JobOutput](<https://github.com/dmdavis/ijr/blob/main/pkg/api/job/job.pb.go#L278-L285>)

JobOutput contains the streamed output of the running job.

```go
type JobOutput struct {

    // The streamed output of an executing job.
    Output []byte `protobuf:"bytes,1,opt,name=output,proto3" json:"output,omitempty"`
    // contains filtered or unexported fields
}
```

<a name="JobOutput.Descriptor"></a>
##### func \(\*JobOutput\) [Descriptor](<https://github.com/dmdavis/ijr/blob/main/pkg/api/job/job.pb.go#L315>)

```go
func (*JobOutput) Descriptor() ([]byte, []int)
```

Deprecated: Use JobOutput.ProtoReflect.Descriptor instead.

<a name="JobOutput.GetOutput"></a>
##### func \(\*JobOutput\) [GetOutput](<https://github.com/dmdavis/ijr/blob/main/pkg/api/job/job.pb.go#L319>)

```go
func (x *JobOutput) GetOutput() []byte
```



<a name="JobOutput.ProtoMessage"></a>
##### func \(\*JobOutput\) [ProtoMessage](<https://github.com/dmdavis/ijr/blob/main/pkg/api/job/job.pb.go#L300>)

```go
func (*JobOutput) ProtoMessage()
```



<a name="JobOutput.ProtoReflect"></a>
##### func \(\*JobOutput\) [ProtoReflect](<https://github.com/dmdavis/ijr/blob/main/pkg/api/job/job.pb.go#L302>)

```go
func (x *JobOutput) ProtoReflect() protoreflect.Message
```



<a name="JobOutput.Reset"></a>
##### func \(\*JobOutput\) [Reset](<https://github.com/dmdavis/ijr/blob/main/pkg/api/job/job.pb.go#L287>)

```go
func (x *JobOutput) Reset()
```



<a name="JobOutput.String"></a>
##### func \(\*JobOutput\) [String](<https://github.com/dmdavis/ijr/blob/main/pkg/api/job/job.pb.go#L296>)

```go
func (x *JobOutput) String() string
```



<a name="JobRecord"></a>
#### type [JobRecord](<https://github.com/dmdavis/ijr/blob/main/pkg/api/job/job.pb.go#L464-L485>)

JobRecord contains the settings of each running job.

```go
type JobRecord struct {

    // A unique string representing the running job.
    JobId string `protobuf:"bytes,1,opt,name=job_id,json=jobId,proto3" json:"job_id,omitempty"`
    // The host system timestamp for when the job started.
    JobStart *timestamppb.Timestamp `protobuf:"bytes,2,opt,name=job_start,json=jobStart,proto3" json:"job_start,omitempty"`
    // The job command line being executed.
    JobCommand string `protobuf:"bytes,3,opt,name=job_command,json=jobCommand,proto3" json:"job_command,omitempty"`
    // A number representing the proportion of CPU shares the job has.
    CpuShares uint32 `protobuf:"varint,4,opt,name=cpu_shares,json=cpuShares,proto3" json:"cpu_shares,omitempty"`
    // Maximum memory limit in bytes.
    MemoryLimitInBytes uint64 `protobuf:"varint,5,opt,name=memory_limit_in_bytes,json=memoryLimitInBytes,proto3" json:"memory_limit_in_bytes,omitempty"`
    // A string in the form <device>:<io/s limit> (ex. /dev/sdc:1200) use to limit
    // read I/O operations per second.
    DiskReadIopsLimit string `protobuf:"bytes,6,opt,name=disk_read_iops_limit,json=diskReadIopsLimit,proto3" json:"disk_read_iops_limit,omitempty"`
    // A string in the form <device>:<io/s limit> (ex. /dev/sdc:1200) use to limit
    // write I/O operations per second.
    DiskWriteIopsLimit string `protobuf:"bytes,7,opt,name=disk_write_iops_limit,json=diskWriteIopsLimit,proto3" json:"disk_write_iops_limit,omitempty"`
    // contains filtered or unexported fields
}
```

<a name="JobRecord.Descriptor"></a>
##### func \(\*JobRecord\) [Descriptor](<https://github.com/dmdavis/ijr/blob/main/pkg/api/job/job.pb.go#L515>)

```go
func (*JobRecord) Descriptor() ([]byte, []int)
```

Deprecated: Use JobRecord.ProtoReflect.Descriptor instead.

<a name="JobRecord.GetCpuShares"></a>
##### func \(\*JobRecord\) [GetCpuShares](<https://github.com/dmdavis/ijr/blob/main/pkg/api/job/job.pb.go#L540>)

```go
func (x *JobRecord) GetCpuShares() uint32
```



<a name="JobRecord.GetDiskReadIopsLimit"></a>
##### func \(\*JobRecord\) [GetDiskReadIopsLimit](<https://github.com/dmdavis/ijr/blob/main/pkg/api/job/job.pb.go#L554>)

```go
func (x *JobRecord) GetDiskReadIopsLimit() string
```



<a name="JobRecord.GetDiskWriteIopsLimit"></a>
##### func \(\*JobRecord\) [GetDiskWriteIopsLimit](<https://github.com/dmdavis/ijr/blob/main/pkg/api/job/job.pb.go#L561>)

```go
func (x *JobRecord) GetDiskWriteIopsLimit() string
```



<a name="JobRecord.GetJobCommand"></a>
##### func \(\*JobRecord\) [GetJobCommand](<https://github.com/dmdavis/ijr/blob/main/pkg/api/job/job.pb.go#L533>)

```go
func (x *JobRecord) GetJobCommand() string
```



<a name="JobRecord.GetJobId"></a>
##### func \(\*JobRecord\) [GetJobId](<https://github.com/dmdavis/ijr/blob/main/pkg/api/job/job.pb.go#L519>)

```go
func (x *JobRecord) GetJobId() string
```



<a name="JobRecord.GetJobStart"></a>
##### func \(\*JobRecord\) [GetJobStart](<https://github.com/dmdavis/ijr/blob/main/pkg/api/job/job.pb.go#L526>)

```go
func (x *JobRecord) GetJobStart() *timestamppb.Timestamp
```



<a name="JobRecord.GetMemoryLimitInBytes"></a>
##### func \(\*JobRecord\) [GetMemoryLimitInBytes](<https://github.com/dmdavis/ijr/blob/main/pkg/api/job/job.pb.go#L547>)

```go
func (x *JobRecord) GetMemoryLimitInBytes() uint64
```



<a name="JobRecord.ProtoMessage"></a>
##### func \(\*JobRecord\) [ProtoMessage](<https://github.com/dmdavis/ijr/blob/main/pkg/api/job/job.pb.go#L500>)

```go
func (*JobRecord) ProtoMessage()
```



<a name="JobRecord.ProtoReflect"></a>
##### func \(\*JobRecord\) [ProtoReflect](<https://github.com/dmdavis/ijr/blob/main/pkg/api/job/job.pb.go#L502>)

```go
func (x *JobRecord) ProtoReflect() protoreflect.Message
```



<a name="JobRecord.Reset"></a>
##### func \(\*JobRecord\) [Reset](<https://github.com/dmdavis/ijr/blob/main/pkg/api/job/job.pb.go#L487>)

```go
func (x *JobRecord) Reset()
```



<a name="JobRecord.String"></a>
##### func \(\*JobRecord\) [String](<https://github.com/dmdavis/ijr/blob/main/pkg/api/job/job.pb.go#L496>)

```go
func (x *JobRecord) String() string
```



<a name="JobServiceClient"></a>
#### type [JobServiceClient](<https://github.com/dmdavis/ijr/blob/main/pkg/api/job/job_grpc.pb.go#L33-L42>)

JobServiceClient is the client API for JobService service.

For semantics around ctx use and closing/ending streaming RPCs, please refer to https://pkg.go.dev/google.golang.org/grpc/?tab=doc#ClientConn.NewStream.

```go
type JobServiceClient interface {
    // Starts the job and returns an identifier for the job.
    StartJob(ctx context.Context, in *StartRequest, opts ...grpc.CallOption) (*StartResponse, error)
    // Returns a list of running jobs with their jobId and jobStart timestamps.
    ListJobs(ctx context.Context, in *ListJobsRequest, opts ...grpc.CallOption) (*ListJobsResponse, error)
    // Stream the output of the job.
    StreamJobOutput(ctx context.Context, in *JobIdentifier, opts ...grpc.CallOption) (JobService_StreamJobOutputClient, error)
    // Stops a running job.
    StopJob(ctx context.Context, in *JobIdentifier, opts ...grpc.CallOption) (*StopResponse, error)
}
```

<a name="NewJobServiceClient"></a>
##### func [NewJobServiceClient](<https://github.com/dmdavis/ijr/blob/main/pkg/api/job/job_grpc.pb.go#L48>)

```go
func NewJobServiceClient(cc grpc.ClientConnInterface) JobServiceClient
```



<a name="JobServiceServer"></a>
#### type [JobServiceServer](<https://github.com/dmdavis/ijr/blob/main/pkg/api/job/job_grpc.pb.go#L114-L124>)

JobServiceServer is the server API for JobService service. All implementations must embed UnimplementedJobServiceServer for forward compatibility

```go
type JobServiceServer interface {
    // Starts the job and returns an identifier for the job.
    StartJob(context.Context, *StartRequest) (*StartResponse, error)
    // Returns a list of running jobs with their jobId and jobStart timestamps.
    ListJobs(context.Context, *ListJobsRequest) (*ListJobsResponse, error)
    // Stream the output of the job.
    StreamJobOutput(*JobIdentifier, JobService_StreamJobOutputServer) error
    // Stops a running job.
    StopJob(context.Context, *JobIdentifier) (*StopResponse, error)
    // contains filtered or unexported methods
}
```

<a name="JobService_StreamJobOutputClient"></a>
#### type [JobService\\\_StreamJobOutputClient](<https://github.com/dmdavis/ijr/blob/main/pkg/api/job/job_grpc.pb.go#L85-L88>)



```go
type JobService_StreamJobOutputClient interface {
    Recv() (*JobOutput, error)
    grpc.ClientStream
}
```

<a name="JobService_StreamJobOutputServer"></a>
#### type [JobService\\\_StreamJobOutputServer](<https://github.com/dmdavis/ijr/blob/main/pkg/api/job/job_grpc.pb.go#L199-L202>)



```go
type JobService_StreamJobOutputServer interface {
    Send(*JobOutput) error
    grpc.ServerStream
}
```

<a name="ListJobsRequest"></a>
#### type [ListJobsRequest](<https://github.com/dmdavis/ijr/blob/main/pkg/api/job/job.pb.go#L377-L381>)

ListJobsRequest contains no fields. Merely pass it to the ListJobs method to retrieve the list of running jobs.

```go
type ListJobsRequest struct {
    // contains filtered or unexported fields
}
```

<a name="ListJobsRequest.Descriptor"></a>
##### func \(\*ListJobsRequest\) [Descriptor](<https://github.com/dmdavis/ijr/blob/main/pkg/api/job/job.pb.go#L411>)

```go
func (*ListJobsRequest) Descriptor() ([]byte, []int)
```

Deprecated: Use ListJobsRequest.ProtoReflect.Descriptor instead.

<a name="ListJobsRequest.ProtoMessage"></a>
##### func \(\*ListJobsRequest\) [ProtoMessage](<https://github.com/dmdavis/ijr/blob/main/pkg/api/job/job.pb.go#L396>)

```go
func (*ListJobsRequest) ProtoMessage()
```



<a name="ListJobsRequest.ProtoReflect"></a>
##### func \(\*ListJobsRequest\) [ProtoReflect](<https://github.com/dmdavis/ijr/blob/main/pkg/api/job/job.pb.go#L398>)

```go
func (x *ListJobsRequest) ProtoReflect() protoreflect.Message
```



<a name="ListJobsRequest.Reset"></a>
##### func \(\*ListJobsRequest\) [Reset](<https://github.com/dmdavis/ijr/blob/main/pkg/api/job/job.pb.go#L383>)

```go
func (x *ListJobsRequest) Reset()
```



<a name="ListJobsRequest.String"></a>
##### func \(\*ListJobsRequest\) [String](<https://github.com/dmdavis/ijr/blob/main/pkg/api/job/job.pb.go#L392>)

```go
func (x *ListJobsRequest) String() string
```



<a name="ListJobsResponse"></a>
#### type [ListJobsResponse](<https://github.com/dmdavis/ijr/blob/main/pkg/api/job/job.pb.go#L416-L422>)

ListJobsResponse returns the JobInfo for each running job.

```go
type ListJobsResponse struct {
    JobRecords []*JobRecord `protobuf:"bytes,1,rep,name=job_records,json=jobRecords,proto3" json:"job_records,omitempty"`
    // contains filtered or unexported fields
}
```

<a name="ListJobsResponse.Descriptor"></a>
##### func \(\*ListJobsResponse\) [Descriptor](<https://github.com/dmdavis/ijr/blob/main/pkg/api/job/job.pb.go#L452>)

```go
func (*ListJobsResponse) Descriptor() ([]byte, []int)
```

Deprecated: Use ListJobsResponse.ProtoReflect.Descriptor instead.

<a name="ListJobsResponse.GetJobRecords"></a>
##### func \(\*ListJobsResponse\) [GetJobRecords](<https://github.com/dmdavis/ijr/blob/main/pkg/api/job/job.pb.go#L456>)

```go
func (x *ListJobsResponse) GetJobRecords() []*JobRecord
```



<a name="ListJobsResponse.ProtoMessage"></a>
##### func \(\*ListJobsResponse\) [ProtoMessage](<https://github.com/dmdavis/ijr/blob/main/pkg/api/job/job.pb.go#L437>)

```go
func (*ListJobsResponse) ProtoMessage()
```



<a name="ListJobsResponse.ProtoReflect"></a>
##### func \(\*ListJobsResponse\) [ProtoReflect](<https://github.com/dmdavis/ijr/blob/main/pkg/api/job/job.pb.go#L439>)

```go
func (x *ListJobsResponse) ProtoReflect() protoreflect.Message
```



<a name="ListJobsResponse.Reset"></a>
##### func \(\*ListJobsResponse\) [Reset](<https://github.com/dmdavis/ijr/blob/main/pkg/api/job/job.pb.go#L424>)

```go
func (x *ListJobsResponse) Reset()
```



<a name="ListJobsResponse.String"></a>
##### func \(\*ListJobsResponse\) [String](<https://github.com/dmdavis/ijr/blob/main/pkg/api/job/job.pb.go#L433>)

```go
func (x *ListJobsResponse) String() string
```



<a name="StartRequest"></a>
#### type [StartRequest](<https://github.com/dmdavis/ijr/blob/main/pkg/api/job/job.pb.go#L74-L93>)

StartRequest contains the job command, arguments, and resource constraints.

```go
type StartRequest struct {

    // The job command line to run.
    JobCommand string `protobuf:"bytes,1,opt,name=job_command,json=jobCommand,proto3" json:"job_command,omitempty"`
    // Arguments for the job command.
    JobArguments []string `protobuf:"bytes,2,rep,name=job_arguments,json=jobArguments,proto3" json:"job_arguments,omitempty"`
    // A number representing the proportion of CPU shares the job has.
    CpuShares uint32 `protobuf:"varint,3,opt,name=cpu_shares,json=cpuShares,proto3" json:"cpu_shares,omitempty"`
    // Maximum memory limit in bytes.
    MemoryLimitInBytes uint64 `protobuf:"varint,4,opt,name=memory_limit_in_bytes,json=memoryLimitInBytes,proto3" json:"memory_limit_in_bytes,omitempty"`
    // A string in the form <device>:<io/s limit> (ex. /dev/sdc:1200) use to limit
    // read I/O operations per second.
    DiskReadIopsLimit string `protobuf:"bytes,5,opt,name=disk_read_iops_limit,json=diskReadIopsLimit,proto3" json:"disk_read_iops_limit,omitempty"`
    // A string in the form <device>:<io/s limit> (ex. /dev/sdc:1200) use to limit
    // write I/O operations per second.
    DiskWriteIopsLimit string `protobuf:"bytes,6,opt,name=disk_write_iops_limit,json=diskWriteIopsLimit,proto3" json:"disk_write_iops_limit,omitempty"`
    // contains filtered or unexported fields
}
```

<a name="StartRequest.Descriptor"></a>
##### func \(\*StartRequest\) [Descriptor](<https://github.com/dmdavis/ijr/blob/main/pkg/api/job/job.pb.go#L123>)

```go
func (*StartRequest) Descriptor() ([]byte, []int)
```

Deprecated: Use StartRequest.ProtoReflect.Descriptor instead.

<a name="StartRequest.GetCpuShares"></a>
##### func \(\*StartRequest\) [GetCpuShares](<https://github.com/dmdavis/ijr/blob/main/pkg/api/job/job.pb.go#L141>)

```go
func (x *StartRequest) GetCpuShares() uint32
```



<a name="StartRequest.GetDiskReadIopsLimit"></a>
##### func \(\*StartRequest\) [GetDiskReadIopsLimit](<https://github.com/dmdavis/ijr/blob/main/pkg/api/job/job.pb.go#L155>)

```go
func (x *StartRequest) GetDiskReadIopsLimit() string
```



<a name="StartRequest.GetDiskWriteIopsLimit"></a>
##### func \(\*StartRequest\) [GetDiskWriteIopsLimit](<https://github.com/dmdavis/ijr/blob/main/pkg/api/job/job.pb.go#L162>)

```go
func (x *StartRequest) GetDiskWriteIopsLimit() string
```



<a name="StartRequest.GetJobArguments"></a>
##### func \(\*StartRequest\) [GetJobArguments](<https://github.com/dmdavis/ijr/blob/main/pkg/api/job/job.pb.go#L134>)

```go
func (x *StartRequest) GetJobArguments() []string
```



<a name="StartRequest.GetJobCommand"></a>
##### func \(\*StartRequest\) [GetJobCommand](<https://github.com/dmdavis/ijr/blob/main/pkg/api/job/job.pb.go#L127>)

```go
func (x *StartRequest) GetJobCommand() string
```



<a name="StartRequest.GetMemoryLimitInBytes"></a>
##### func \(\*StartRequest\) [GetMemoryLimitInBytes](<https://github.com/dmdavis/ijr/blob/main/pkg/api/job/job.pb.go#L148>)

```go
func (x *StartRequest) GetMemoryLimitInBytes() uint64
```



<a name="StartRequest.ProtoMessage"></a>
##### func \(\*StartRequest\) [ProtoMessage](<https://github.com/dmdavis/ijr/blob/main/pkg/api/job/job.pb.go#L108>)

```go
func (*StartRequest) ProtoMessage()
```



<a name="StartRequest.ProtoReflect"></a>
##### func \(\*StartRequest\) [ProtoReflect](<https://github.com/dmdavis/ijr/blob/main/pkg/api/job/job.pb.go#L110>)

```go
func (x *StartRequest) ProtoReflect() protoreflect.Message
```



<a name="StartRequest.Reset"></a>
##### func \(\*StartRequest\) [Reset](<https://github.com/dmdavis/ijr/blob/main/pkg/api/job/job.pb.go#L95>)

```go
func (x *StartRequest) Reset()
```



<a name="StartRequest.String"></a>
##### func \(\*StartRequest\) [String](<https://github.com/dmdavis/ijr/blob/main/pkg/api/job/job.pb.go#L104>)

```go
func (x *StartRequest) String() string
```



<a name="StartResponse"></a>
#### type [StartResponse](<https://github.com/dmdavis/ijr/blob/main/pkg/api/job/job.pb.go#L170-L179>)

StartResponse is returned by StartJob if there is no error.

```go
type StartResponse struct {

    // A unique string representing the running job.
    JobId string `protobuf:"bytes,1,opt,name=job_id,json=jobId,proto3" json:"job_id,omitempty"`
    // The host system timestamp for when the job started.
    JobStart *timestamppb.Timestamp `protobuf:"bytes,2,opt,name=job_start,json=jobStart,proto3" json:"job_start,omitempty"`
    // contains filtered or unexported fields
}
```

<a name="StartResponse.Descriptor"></a>
##### func \(\*StartResponse\) [Descriptor](<https://github.com/dmdavis/ijr/blob/main/pkg/api/job/job.pb.go#L209>)

```go
func (*StartResponse) Descriptor() ([]byte, []int)
```

Deprecated: Use StartResponse.ProtoReflect.Descriptor instead.

<a name="StartResponse.GetJobId"></a>
##### func \(\*StartResponse\) [GetJobId](<https://github.com/dmdavis/ijr/blob/main/pkg/api/job/job.pb.go#L213>)

```go
func (x *StartResponse) GetJobId() string
```



<a name="StartResponse.GetJobStart"></a>
##### func \(\*StartResponse\) [GetJobStart](<https://github.com/dmdavis/ijr/blob/main/pkg/api/job/job.pb.go#L220>)

```go
func (x *StartResponse) GetJobStart() *timestamppb.Timestamp
```



<a name="StartResponse.ProtoMessage"></a>
##### func \(\*StartResponse\) [ProtoMessage](<https://github.com/dmdavis/ijr/blob/main/pkg/api/job/job.pb.go#L194>)

```go
func (*StartResponse) ProtoMessage()
```



<a name="StartResponse.ProtoReflect"></a>
##### func \(\*StartResponse\) [ProtoReflect](<https://github.com/dmdavis/ijr/blob/main/pkg/api/job/job.pb.go#L196>)

```go
func (x *StartResponse) ProtoReflect() protoreflect.Message
```



<a name="StartResponse.Reset"></a>
##### func \(\*StartResponse\) [Reset](<https://github.com/dmdavis/ijr/blob/main/pkg/api/job/job.pb.go#L181>)

```go
func (x *StartResponse) Reset()
```



<a name="StartResponse.String"></a>
##### func \(\*StartResponse\) [String](<https://github.com/dmdavis/ijr/blob/main/pkg/api/job/job.pb.go#L190>)

```go
func (x *StartResponse) String() string
```



<a name="StopResponse"></a>
#### type [StopResponse](<https://github.com/dmdavis/ijr/blob/main/pkg/api/job/job.pb.go#L327-L334>)

StopResponse will return a status of STOPPED once the job command is stopped.

```go
type StopResponse struct {

    // JobStatus represents the final status of the job after stopping.
    Status StopResponse_JobStatus `protobuf:"varint,1,opt,name=status,proto3,enum=job.StopResponse_JobStatus" json:"status,omitempty"`
    // contains filtered or unexported fields
}
```

<a name="StopResponse.Descriptor"></a>
##### func \(\*StopResponse\) [Descriptor](<https://github.com/dmdavis/ijr/blob/main/pkg/api/job/job.pb.go#L364>)

```go
func (*StopResponse) Descriptor() ([]byte, []int)
```

Deprecated: Use StopResponse.ProtoReflect.Descriptor instead.

<a name="StopResponse.GetStatus"></a>
##### func \(\*StopResponse\) [GetStatus](<https://github.com/dmdavis/ijr/blob/main/pkg/api/job/job.pb.go#L368>)

```go
func (x *StopResponse) GetStatus() StopResponse_JobStatus
```



<a name="StopResponse.ProtoMessage"></a>
##### func \(\*StopResponse\) [ProtoMessage](<https://github.com/dmdavis/ijr/blob/main/pkg/api/job/job.pb.go#L349>)

```go
func (*StopResponse) ProtoMessage()
```



<a name="StopResponse.ProtoReflect"></a>
##### func \(\*StopResponse\) [ProtoReflect](<https://github.com/dmdavis/ijr/blob/main/pkg/api/job/job.pb.go#L351>)

```go
func (x *StopResponse) ProtoReflect() protoreflect.Message
```



<a name="StopResponse.Reset"></a>
##### func \(\*StopResponse\) [Reset](<https://github.com/dmdavis/ijr/blob/main/pkg/api/job/job.pb.go#L336>)

```go
func (x *StopResponse) Reset()
```



<a name="StopResponse.String"></a>
##### func \(\*StopResponse\) [String](<https://github.com/dmdavis/ijr/blob/main/pkg/api/job/job.pb.go#L345>)

```go
func (x *StopResponse) String() string
```



<a name="StopResponse_JobStatus"></a>
#### type [StopResponse\\\_JobStatus](<https://github.com/dmdavis/ijr/blob/main/pkg/api/job/job.pb.go#L27>)

The status of the job.

```go
type StopResponse_JobStatus int32
```

<a name="StopResponse_UNKNOWN"></a>

```go
const (
    StopResponse_UNKNOWN StopResponse_JobStatus = 0 // Placeholder for an unknown job status
    StopResponse_STOPPED StopResponse_JobStatus = 1 // The job was stopped successfully
)
```

<a name="StopResponse_JobStatus.Descriptor"></a>
##### func \(StopResponse\_JobStatus\) [Descriptor](<https://github.com/dmdavis/ijr/blob/main/pkg/api/job/job.pb.go#L56>)

```go
func (StopResponse_JobStatus) Descriptor() protoreflect.EnumDescriptor
```



<a name="StopResponse_JobStatus.Enum"></a>
##### func \(StopResponse\_JobStatus\) [Enum](<https://github.com/dmdavis/ijr/blob/main/pkg/api/job/job.pb.go#L46>)

```go
func (x StopResponse_JobStatus) Enum() *StopResponse_JobStatus
```



<a name="StopResponse_JobStatus.EnumDescriptor"></a>
##### func \(StopResponse\_JobStatus\) [EnumDescriptor](<https://github.com/dmdavis/ijr/blob/main/pkg/api/job/job.pb.go#L69>)

```go
func (StopResponse_JobStatus) EnumDescriptor() ([]byte, []int)
```

Deprecated: Use StopResponse\_JobStatus.Descriptor instead.

<a name="StopResponse_JobStatus.Number"></a>
##### func \(StopResponse\_JobStatus\) [Number](<https://github.com/dmdavis/ijr/blob/main/pkg/api/job/job.pb.go#L64>)

```go
func (x StopResponse_JobStatus) Number() protoreflect.EnumNumber
```



<a name="StopResponse_JobStatus.String"></a>
##### func \(StopResponse\_JobStatus\) [String](<https://github.com/dmdavis/ijr/blob/main/pkg/api/job/job.pb.go#L52>)

```go
func (x StopResponse_JobStatus) String() string
```



<a name="StopResponse_JobStatus.Type"></a>
##### func \(StopResponse\_JobStatus\) [Type](<https://github.com/dmdavis/ijr/blob/main/pkg/api/job/job.pb.go#L60>)

```go
func (StopResponse_JobStatus) Type() protoreflect.EnumType
```



<a name="StreamServiceOutputSender"></a>
#### type [StreamServiceOutputSender](<https://github.com/dmdavis/ijr/blob/main/pkg/api/job/output.go#L6-L8>)

StreamServiceOutputSender implements the api.OutputSender interface and adapts sending job.Job output back to the gRPC client. It contains a JobStream which is the interface that allows sending job outputs.

```go
type StreamServiceOutputSender struct {
    JobStream JobService_StreamJobOutputServer
}
```

<a name="StreamServiceOutputSender.Send"></a>
##### func \(StreamServiceOutputSender\) [Send](<https://github.com/dmdavis/ijr/blob/main/pkg/api/job/output.go#L14>)

```go
func (j StreamServiceOutputSender) Send(output []byte) error
```

Send sends the output of a job to the gRPC client. It takes a string parameter \`output\`, which represents the job output to be sent. It returns an error if there was a problem sending the output. The error value can be \`nil\` if the output was sent successfully.

<a name="UnimplementedJobServiceServer"></a>
#### type [UnimplementedJobServiceServer](<https://github.com/dmdavis/ijr/blob/main/pkg/api/job/job_grpc.pb.go#L127-L128>)

UnimplementedJobServiceServer must be embedded to have forward compatible implementations.

```go
type UnimplementedJobServiceServer struct {
}
```

<a name="UnimplementedJobServiceServer.ListJobs"></a>
##### func \(UnimplementedJobServiceServer\) [ListJobs](<https://github.com/dmdavis/ijr/blob/main/pkg/api/job/job_grpc.pb.go#L133>)

```go
func (UnimplementedJobServiceServer) ListJobs(context.Context, *ListJobsRequest) (*ListJobsResponse, error)
```



<a name="UnimplementedJobServiceServer.StartJob"></a>
##### func \(UnimplementedJobServiceServer\) [StartJob](<https://github.com/dmdavis/ijr/blob/main/pkg/api/job/job_grpc.pb.go#L130>)

```go
func (UnimplementedJobServiceServer) StartJob(context.Context, *StartRequest) (*StartResponse, error)
```



<a name="UnimplementedJobServiceServer.StopJob"></a>
##### func \(UnimplementedJobServiceServer\) [StopJob](<https://github.com/dmdavis/ijr/blob/main/pkg/api/job/job_grpc.pb.go#L139>)

```go
func (UnimplementedJobServiceServer) StopJob(context.Context, *JobIdentifier) (*StopResponse, error)
```



<a name="UnimplementedJobServiceServer.StreamJobOutput"></a>
##### func \(UnimplementedJobServiceServer\) [StreamJobOutput](<https://github.com/dmdavis/ijr/blob/main/pkg/api/job/job_grpc.pb.go#L136>)

```go
func (UnimplementedJobServiceServer) StreamJobOutput(*JobIdentifier, JobService_StreamJobOutputServer) error
```



<a name="UnsafeJobServiceServer"></a>
#### type [UnsafeJobServiceServer](<https://github.com/dmdavis/ijr/blob/main/pkg/api/job/job_grpc.pb.go#L147-L149>)

UnsafeJobServiceServer may be embedded to opt out of forward compatibility for this service. Use of this interface is not recommended, as added methods to JobServiceServer will result in compilation errors.

```go
type UnsafeJobServiceServer interface {
    // contains filtered or unexported methods
}
```
