# flb_aws_credentials_process.c

## Overview

This file implements functionality for executing external credential processes as defined in AWS configuration files. It handles parsing credential process commands, executing them in child processes, capturing their output, and parsing the resulting credentials.

## Key Functions

### Credential Process Parsing

- `parse_credential_process(char* input)`: Parses a credential process string into an array of arguments for execution. Handles both quoted and unquoted tokens.
- `credential_process_token_count(char* process)`: Counts the number of tokens in a credential process string.
- `parse_credential_process_token(char** input, char** out_token)`: Parses individual tokens from a credential process string.

### Process Management

- `exec_credential_process(char* process, struct flb_aws_credentials** creds, time_t* expiration)`: Main entry point that executes a credential process and returns parsed credentials.
- `new_process(struct process* p, char** args)`: Initializes a new process structure.
- `exec_process(struct process* p)`: Forks and executes the credential process.
- `read_from_process(struct process* p, struct readbuf* buf)`: Reads the process output with timeout handling.
- `wait_process(struct process* p)`: Waits for the process to complete with timeout.
- `destroy_process(struct process* p)`: Cleans up process resources.

### Utility Functions

- `get_monotonic_time(struct flb_time* tm)`: Gets the current monotonic time for timeout calculations.
- `read_until_block(char* name, flb_pipefd_t fd, struct readbuf* buf)`: Reads from a pipe until blocking or buffer full.
- `waitpid_timeout(char* name, pid_t pid, int* wstatus)`: Waits for a process with timeout.

## Important Constants

- `CREDENTIAL_PROCESS_TIMEOUT_MS`: 60000 (60 seconds) - Maximum time to wait for credential process execution
- `CREDENTIAL_PROCESS_BUFFER_SIZE`: 8 * 1024 (8KB) - Maximum size of credential process output buffer
- `WAITPID_POLL_FREQUENCY_MS`: 20 - Polling frequency when waiting for process completion
- `WAITPID_TIMEOUT_MS`: 10 * WAITPID_POLL_FREQUENCY_MS - Timeout for waitpid operations
- `CREDENTIAL_PROCESS_RESPONSE_SESSION_TOKEN`: "SessionToken" - Expected JSON field name for session tokens

## Data Structures

### `struct token_array`
Manages an array of parsed credential process tokens.

### `struct readbuf`
Buffer for reading credential process output.

### `struct process`
Represents a credential process with file descriptors and process ID.

## Dependencies

- `<fluent-bit/flb_aws_credentials.h>`: Core AWS credentials functionality
- `<fluent-bit/flb_aws_credentials_log.h>`: Logging macros for AWS credentials
- `<fluent-bit/flb_compat.h>`: Compatibility layer
- `<fluent-bit/flb_info.h>`: General information and utilities
- `<fluent-bit/flb_pipe.h>`: Pipe operations
- `<fluent-bit/flb_time.h>`: Time operations
- `<fcntl.h>`: File control operations
- `<poll.h>`: Poll operations
- `<stdlib.h>`: Standard library functions
- `<sys/wait.h>`: Process waiting functions

## Implementation Details

The implementation follows these steps:

1. Parse the credential process string into executable arguments
2. Create a new process structure with proper file descriptor setup
3. Fork and execute the credential process in a child process
4. Read the process output with timeout handling
5. Wait for the process to complete
6. Parse the JSON credentials from the process output
7. Clean up all resources

The code handles various edge cases including:
- Proper timeout management for all operations
- Error handling for process execution failures
- Resource cleanup in all code paths
- Quoted vs unquoted token parsing
- Buffer overflow protection

## Usage Example

```c
// Execute a credential process and retrieve credentials
struct flb_aws_credentials* creds = NULL;
time_t expiration = 0;

if (exec_credential_process("aws sts get-session-token", &creds, &expiration) == 0) {
    // Use the retrieved credentials
    printf("Access Key: %s\n", creds->access_key_id);
    printf("Secret Key: %s\n", creds->secret_access_key);
    printf("Session Token: %s\n", creds->session_token);
    printf("Expiration: %ld\n", expiration);
    
    // Clean up
    flb_aws_credentials_destroy(creds);
} else {
    // Handle error
    fprintf(stderr, "Failed to execute credential process\n");
}
```