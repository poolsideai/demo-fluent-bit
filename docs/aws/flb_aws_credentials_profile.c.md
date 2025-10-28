# flb_aws_credentials_profile.c

## Overview

This file implements functionality for retrieving AWS credentials from shared configuration files and credentials files. It supports reading from `~/.aws/config` and `~/.aws/credentials` files, parsing profile-specific credentials, and handling credential processes as defined in AWS configuration.

## Key Functions

### Provider Interface Functions

- `get_credentials_fn_profile()`: Retrieves AWS credentials for the profile provider
- `refresh_fn_profile()`: Refreshes credentials for the profile provider
- `init_fn_profile()`: Initializes the profile provider
- `destroy_fn_profile()`: Destroys the profile provider and cleans up resources
- `sync_fn_profile()` / `async_fn_profile()`: No-op functions for profile provider (no network I/O)
- `upstream_set_fn_profile()`: No-op function for setting upstream connections

### File Path Resolution

- `get_aws_shared_file_path()`: Determines the path to AWS configuration files based on environment variables

### File Parsing Functions

- `parse_config_file()`: Parses AWS configuration file for credential process definitions
- `parse_credentials_file()`: Parses AWS credentials file for static credentials
- `get_shared_config_credentials()`: Retrieves credentials from shared config file
- `get_shared_credentials()`: Retrieves credentials from shared credentials file

### Utility Functions

- `refresh_credentials()`: Main function to refresh credentials from files
- `is_profile_line()`: Checks if a line is a profile header
- `has_profile()`: Checks if a line matches the requested profile
- `parse_property_line()`: Parses property name and value from a line
- `parse_property_value()`: Parses property values with whitespace handling
- `config_file_profile_matches()`: Checks if a config file line matches the requested profile

## Important Constants

- `ACCESS_KEY_PROPERTY_NAME`: "aws_access_key_id" - Property name for access key
- `SECRET_KEY_PROPERTY_NAME`: "aws_secret_access_key" - Property name for secret key
- `SESSION_TOKEN_PROPERTY_NAME`: "aws_session_token" - Property name for session token
- `CREDENTIAL_PROCESS_PROPERTY_NAME`: "credential_process" - Property name for credential process
- `AWS_PROFILE`: "AWS_PROFILE" - Environment variable for AWS profile
- `AWS_DEFAULT_PROFILE`: "AWS_DEFAULT_PROFILE" - Environment variable for default AWS profile
- `AWS_CONFIG_FILE`: "AWS_CONFIG_FILE" - Environment variable for config file path
- `AWS_SHARED_CREDENTIALS_FILE`: "AWS_SHARED_CREDENTIALS_FILE" - Environment variable for credentials file path
- `DEFAULT_PROFILE`: "default" - Default profile name
- `CONFIG_PROFILE_PREFIX`: "profile " - Prefix for profile names in config files
- `CONFIG_PROFILE_PREFIX_LEN`: Length of CONFIG_PROFILE_PREFIX

## Data Structures

### `struct flb_aws_provider_profile`
Represents the profile provider implementation with:
- Current credentials (`creds`)
- Next refresh time (`next_refresh`)
- Profile name (`profile`)
- Config file path (`config_path`)
- Credentials file path (`credentials_path`)

### `struct flb_aws_provider_vtable profile_provider_vtable`
Virtual table implementing the provider interface functions.

## Dependencies

- `<fluent-bit/flb_aws_credentials.h>`: Core AWS credentials functionality
- `<fluent-bit/flb_aws_credentials_log.h>`: Logging macros for AWS credentials
- `<fluent-bit/flb_aws_util.h>`: AWS utility functions
- `<fluent-bit/flb_http_client.h>`: HTTP client functionality
- `<fluent-bit/flb_info.h>`: General information and utilities
- `<fluent-bit/flb_sds.h>`: String data structures
- `<stdlib.h>`: Standard library functions
- `<string.h>`: String manipulation functions
- `<time.h>`: Time functions
- `<sys/types.h>`: System type definitions
- `<sys/stat.h>`: File status functions
- `<ctype.h>`: Character type functions

## Implementation Details

The implementation follows these steps:

1. Determine the AWS profile to use (from parameter, AWS_PROFILE env var, AWS_DEFAULT_PROFILE env var, or "default")
2. Locate the shared config file (~/.aws/config) and shared credentials file (~/.aws/credentials)
3. Attempt to retrieve credentials from the config file first (supports credential processes)
4. Fall back to the credentials file if no credential process is found
5. Parse the appropriate file format:
   - Config files use `[profile name]` or `[default]` sections
   - Credentials files use `[name]` sections
6. Handle credential processes by executing external commands and parsing JSON output
7. Manage credential expiration and refresh timing

The code handles various edge cases including:
- Proper file path resolution using environment variables
- Profile name matching for both config and credentials files
- Property parsing with whitespace handling
- Credential process execution and JSON parsing
- Resource cleanup in all code paths
- Thread safety with mutex locks

## Usage Example

```c
// Create a profile provider for the "production" profile
struct flb_aws_provider *provider = flb_profile_provider_create("production");

if (provider) {
    // Initialize the provider
    if (init_fn_profile(provider) == 0) {
        // Retrieve credentials
        struct flb_aws_credentials *creds = get_credentials_fn_profile(provider);
        
        if (creds) {
            printf("Access Key: %s\n", creds->access_key_id);
            printf("Secret Key: %s\n", creds->secret_access_key);
            if (creds->session_token) {
                printf("Session Token: %s\n", creds->session_token);
            }
            
            // Clean up credentials
            flb_aws_credentials_destroy(creds);
        }
    }
    
    // Clean up provider
    destroy_fn_profile(provider);
}
```