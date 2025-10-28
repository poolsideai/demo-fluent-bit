# flb_aws_error_reporter.c

## Overview

This file implements an error reporting mechanism for AWS-related operations in Fluent Bit. It provides functionality to log error messages to a file and manage them with time-to-live (TTL) expiration.

## Key Functions

### Error Reporter Management

- `flb_aws_error_reporter_create()`: Creates and initializes an error reporter instance
- `flb_aws_error_reporter_destroy()`: Cleans up and destroys an error reporter instance
- `is_error_reporting_enabled()`: Checks if error reporting is enabled via environment variables

### Error Reporting Functions

- `flb_aws_error_reporter_write()`: Writes an error message to the report file and memory cache
- `flb_aws_error_reporter_clean()`: Cleans up expired messages based on TTL settings

### Utility Functions

- `getenv_int()`: Helper function to parse integer environment variables

## Important Constants

### Environment Variables
- `STATUS_MESSAGE_FILE_PATH_ENV`: Environment variable for specifying the error report file path
- `STATUS_MESSAGE_TTL_ENV`: Environment variable for setting message TTL in seconds
- `STATUS_MESSAGE_MAX_BYTE_LENGTH_ENV`: Environment variable for setting maximum message size

### Default Values
- `STATUS_MESSAGE_TTL_DEFAULT`: Default TTL value for error messages
- `STATUS_MESSAGE_MAX_BYTE_LENGTH_DEFAULT`: Default maximum size for error messages

## Data Structures

### `struct flb_aws_error_reporter`
Represents the error reporter with:
- File path for error reports (`file_path`)
- Time-to-live setting for messages (`ttl`)
- Maximum message size (`max_size`)
- Current file size (`file_size`)
- Linked list of error messages (`messages`)

### `struct flb_error_message`
Represents an individual error message with:
- Message data (`data`)
- Message length (`len`)
- Timestamp when message was created (`timestamp`)
- Linked list entry for chaining messages (`_head`)

## Dependencies

- `<stdio.h>`: Standard I/O functions
- `<stdlib.h>`: Standard library functions
- `<time.h>`: Time functions
- `<monkey/mk_core/mk_list.h>`: Linked list implementation
- `<fluent-bit/flb_mem.h>`: Memory management functions
- `<fluent-bit/flb_log.h>`: Logging functions
- `<fluent-bit/flb_env.h>`: Environment variable functions
- `<fluent-bit/flb_sds.h>`: String data structures
- `<fluent-bit/aws/flb_aws_error_reporter.h>`: Header file for this module

## Implementation Details

The error reporter implements a circular buffer-like behavior for error messages:

1. **Message Storage**: Messages are stored both in memory (linked list) and on disk
2. **Duplicate Detection**: Prevents storing duplicate consecutive messages
3. **Size Management**: Automatically removes old messages when adding new ones would exceed the maximum size
4. **TTL Expiration**: Periodically cleans up messages that have exceeded their TTL
5. **File Operations**: Maintains a single file that gets rewritten when cleanup occurs

Key features:
- Thread-safe message handling
- Automatic file cleanup on initialization
- Configurable TTL and size limits
- Efficient memory management with SDS strings
- Proper resource cleanup on destruction

## Usage Example

```c
// Check if error reporting is enabled
if (is_error_reporting_enabled()) {
    // Create an error reporter
    struct flb_aws_error_reporter *reporter = flb_aws_error_reporter_create();
    
    if (reporter) {
        // Write error messages
        flb_aws_error_reporter_write(reporter, "AWS credentials retrieval failed\n");
        flb_aws_error_reporter_write(reporter, "Network timeout connecting to STS\n");
        
        // Clean up expired messages periodically
        flb_aws_error_reporter_clean(reporter);
        
        // Clean up when done
        flb_aws_error_reporter_destroy(reporter);
    }
}

// Environment setup for error reporting:
// export STATUS_MESSAGE_FILE_PATH=/var/log/fluent-bit/aws-errors.log
// export STATUS_MESSAGE_TTL=300
// export STATUS_MESSAGE_MAX_BYTE_LENGTH=1048576
```