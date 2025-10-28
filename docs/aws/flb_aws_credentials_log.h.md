# flb_aws_credentials_log.h

## Overview

This header file defines logging macros for AWS credentials functionality in Fluent Bit. It provides standardized logging functions with appropriate prefixes for AWS credentials operations.

## Key Components

### Logging Macros

- `AWS_CREDS_ERROR(format, ...)`: Logs error messages with "[aws_credentials]" prefix
- `AWS_CREDS_WARN(format, ...)`: Logs warning messages with "[aws_credentials]" prefix
- `AWS_CREDS_DEBUG(format, ...)`: Logs debug messages with "[aws_credentials]" prefix
- `AWS_CREDS_ERROR_OR_DEBUG(debug_only, format, ...)`: Conditionally logs either as error or debug based on the debug_only parameter

## Dependencies

- `<fluent-bit/flb_log.h>`: Provides the underlying logging functionality

## Implementation Details

This file uses preprocessor macros to wrap the standard Fluent Bit logging functions with AWS-specific prefixes. The macros are designed to be lightweight and provide consistent logging throughout the AWS credentials subsystem.

## Usage Example

```c
#include "flb_aws_credentials_log.h"

// Log an error
AWS_CREDS_ERROR("Failed to retrieve credentials from %s", source);

// Log a warning
AWS_CREDS_WARN("Using fallback credentials method");

// Log debug information
AWS_CREDS_DEBUG("Successfully retrieved credentials with expiration: %ld", expiration_time);
```