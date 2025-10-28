# src/aws/CMakeLists.txt Documentation

## Overview

This CMakeLists.txt file is the build configuration for the AWS-specific components of Fluent Bit. It defines the source files, dependencies, and build targets for AWS integration features.

## Key Components

### Source Files

The file defines the following AWS-related source files:

- `flb_aws_credentials_log.h`: Header file for AWS credentials logging
- `flb_aws_compress.c`: AWS compression utilities
- `flb_aws_util.c`: General AWS utility functions
- `flb_aws_credentials.c`: Core AWS credentials management
- `flb_aws_credentials_sts.c`: AWS Security Token Service (STS) credentials
- `flb_aws_credentials_ec2.c`: EC2 instance credentials
- `flb_aws_imds.c`: AWS Instance Metadata Service (IMDS) utilities
- `flb_aws_credentials_http.c`: HTTP-based AWS credentials
- `flb_aws_credentials_profile.c`: AWS credentials profile management
- `flb_aws_credentials_process.c`: Credential process support (conditional)
- `flb_aws_msk_iam.c`: AWS Managed Streaming for Apache Kafka (MSK) IAM authentication (conditional)

### Subdirectories

The file includes the `compression` subdirectory which contains AWS-specific compression components.

### Conditional Features

The CMakeLists.txt includes conditional compilation for optional features:

1. **AWS MSK IAM Authentication** (`FLB_HAVE_AWS_MSK_IAM`):
   - Enables MSK IAM authentication support
   - Adds `flb_aws_msk_iam.c` to the build
   - Links against Kafka libraries when available

2. **AWS Credential Process** (`FLB_HAVE_AWS_CREDENTIAL_PROCESS`):
   - Enables credential process support
   - Adds `flb_aws_credentials_process.c` to the build

### Build Target

The file creates a static library target `flb-aws` that contains all AWS-related functionality.

### Dependencies

The AWS library depends on:

- `flb-aws-compress`: AWS compression library
- `KAFKA_LIBRARIES`: Kafka client libraries (when MSK IAM is enabled)
- `JEMALLOC_LIBRARIES`: Jemalloc memory allocator (when enabled)

## Usage

This CMakeLists.txt is included from the main src/CMakeLists.txt when the `FLB_AWS` flag is set. It builds the AWS integration components that can be used by other parts of Fluent Bit for AWS service integration.