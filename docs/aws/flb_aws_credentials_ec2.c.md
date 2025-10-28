# src/aws/flb_aws_credentials_ec2.c Documentation

## Overview

This C file implements the EC2 Instance Metadata Service (IMDS) credential provider for Fluent Bit's AWS integration. It retrieves temporary AWS credentials from EC2 instances using the Instance Metadata Service, which is the standard way for EC2 instances to access their assigned IAM roles.

## Key Data Structures

### `flb_aws_provider_ec2`

Structure representing the EC2 IMDS credential provider:

- `creds`: Cached AWS credentials
- `next_refresh`: Timestamp for when credentials should be refreshed
- `client`: HTTP client for communicating with IMDS
- `imds_interface`: IMDS interface abstraction

## Key Functions

### `get_credentials_fn_ec2`

Retrieves EC2 IMDS credentials:

- Checks if cached credentials are expired or missing
- Acquires mutex lock to prevent concurrent refreshes
- Calls `get_creds_ec2` to fetch fresh credentials
- Returns a copy of cached credentials to the caller
- Handles concurrent access scenarios

### `refresh_fn_ec2`

Refreshes EC2 IMDS credentials:

- Acquires mutex lock to prevent concurrent refreshes
- Calls `get_creds_ec2` to fetch fresh credentials
- Returns 0 on success, -1 on failure

### `init_fn_ec2`

Initializes the EC2 IMDS provider:

- Sets debug mode for initial connection
- Acquires mutex lock to prevent concurrent initialization
- Calls `get_creds_ec2` to fetch initial credentials
- Resets debug mode after initialization
- Returns 0 on success, -1 on failure

### `sync_fn_ec2`

Switches the provider to synchronous mode:

- Disables async mode on the upstream connection
- Used when credentials are needed immediately

### `async_fn_ec2`

Switches the provider to asynchronous mode:

- Enables async mode on the upstream connection
- Used for normal operation to avoid blocking

### `upstream_set_fn_ec2`

Configures the upstream connection for the provider:

- Temporarily disables TLS for IMDS connection
- Sets up the upstream connection with proper timeouts
- Restores IMDS-specific timeout configurations

### `destroy_fn_ec2`

Destroys the EC2 IMDS provider:

- Cleans up cached credentials
- Destroys IMDS interface
- Destroys HTTP client
- Frees provider implementation

### `flb_ec2_provider_create`

Creates an EC2 IMDS credential provider:

- Initializes provider structure with mutex
- Creates upstream connection to IMDS endpoint
- Configures proper timeouts and connection settings
- Creates HTTP client for IMDS communication
- Initializes IMDS interface
- Returns configured provider or NULL on failure

### `get_creds_ec2`

Fetches credentials from EC2 IMDS:

- Requests the instance role name from IMDS
- Constructs the credentials path using the role name
- Calls `ec2_credentials_request` to retrieve credentials
- Returns 0 on success, -1 on failure

### `ec2_credentials_request`

Requests credentials from IMDS and parses the response:

- Makes HTTP request to IMDS for credentials
- Parses the JSON response into credentials structure
- Extracts expiration timestamp
- Updates cached credentials
- Sets refresh time based on expiration
- Returns 0 on success, -1 on failure

## Implementation Details

### IMDS Communication

- Uses HTTP client to communicate with IMDS at `169.254.169.254:80`
- Implements proper timeout handling (5 seconds)
- Supports both IMDSv1 and IMDSv2 protocols
- Handles connection retries and error recovery

### Credential Refresh

- Implements proactive credential refresh before expiration
- Uses `FLB_AWS_REFRESH_WINDOW` to refresh credentials early
- Thread-safe refresh mechanism with mutex protection
- Handles concurrent access scenarios gracefully

### Error Handling

- Comprehensive error checking with proper resource cleanup
- Detailed logging for debugging credential issues
- Graceful fallback when IMDS is unavailable
- Proper handling of JSON parsing errors

### Memory Management

- Uses Fluent Bit's memory allocation functions (`flb_calloc`, `flb_free`)
- Proper cleanup of all allocated resources
- Reference counting for shared dependencies
- Safe handling of SDS strings

## Dependencies

The implementation depends on:

- Fluent Bit core libraries (`flb_info.h`, `flb_sds.h`, `flb_http_client.h`)
- AWS credentials library (`flb_aws_credentials.h`)
- AWS utilities (`flb_aws_util.h`)
- JSON parser (`flb_jsmn.h`)
- EC2 IMDS interface (`flb_aws_imds.h`)

## Usage

This file is part of the AWS library (`flb-aws`) and is used by the standard credential chain provider when running on EC2 instances. The EC2 provider is automatically included in the standard chain and will be used when other providers (environment variables, profiles) are not available.