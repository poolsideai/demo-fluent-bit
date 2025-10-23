# src/aws/CMakeLists.txt Documentation

## Overview

This CMakeLists.txt file is the build configuration for the AWS-specific components in Fluent Bit. It defines the source files, dependencies, and build targets for AWS integration functionality including credentials management, compression, and MSK IAM authentication.

## Key Components

### Source Files
The file defines the core AWS source files that provide AWS integration capabilities:
- `flb_aws_credentials.c`: Main AWS credentials management
- `flb_aws_credentials_sts.c`: STS (Security Token Service) credentials
- `flb_aws_credentials_ec2.c`: EC2 instance credentials
- `flb_aws_imds.c`: Instance Metadata Service (IMDS) client
- `flb_aws_credentials_http.c`: HTTP-based credentials
- `flb_aws_credentials_profile.c`: Profile-based credentials
- `flb_aws_compress.c`: AWS compression utilities
- `flb_aws_util.c`: General AWS utility functions

### Conditional Compilation
The file supports conditional compilation for additional AWS features:
- MSK IAM authentication (`FLB_HAVE_AWS_MSK_IAM`)
- Credential process support (`FLB_HAVE_AWS_CREDENTIAL_PROCESS`)

### Dependencies
The file manages dependencies for AWS functionality:
- Links to `flb-aws-compress` library
- Optional linking to Kafka libraries when MSK IAM is enabled
- Optional linking to jemalloc when enabled

### Subdirectories
The file includes the `compression` subdirectory which contains AWS compression functionality.

## Implementation Details

### Library Target
Creates a static library target `flb-aws` that contains all AWS-related functionality.

### Feature Detection
The CMakeLists.txt includes status messages to indicate which AWS features are enabled:
- MSK IAM authentication status
- Credential process status

### Platform Compatibility
The file handles platform-specific library linking requirements for AWS functionality.

## Usage Examples

To build with AWS support enabled:
```bash
cmake -DFLB_AWS=ON .
make
```

To build with MSK IAM support:
```bash
cmake -DFLB_AWS=ON -DFLB_HAVE_AWS_MSK_IAM=ON .
make
```

To build with credential process support:
```bash
cmake -DFLB_AWS=ON -DFLB_HAVE_AWS_CREDENTIAL_PROCESS=ON .
make
```