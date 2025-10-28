# src/aws/flb_aws_credentials_http.c Documentation

## Overview

This C file implements HTTP-based credential providers for Fluent Bit's AWS integration. It supports retrieving temporary AWS credentials from HTTP endpoints, including ECS task roles and custom credential servers. The implementation handles authentication, parsing of credential responses, and secure communication with credential endpoints.

## Key Data Structures

### `flb_aws_provider_http`

Structure representing an HTTP credential provider:

- `creds`: Cached AWS credentials
- `next_refresh`: Timestamp for when credentials should be refreshed
- `client`: HTTP client for communicating with credential endpoints
- `host`: Hostname of the credential endpoint
- `path`: Path to the credential endpoint

## Key Functions

### `get_credentials_fn_http`

Retrieves HTTP-based credentials:

- Checks if cached credentials are expired or missing
- Acquires mutex lock to prevent concurrent refreshes
- Calls `http_credentials_request` to fetch fresh credentials
- Returns a copy of cached credentials to the caller
- Handles concurrent access scenarios

### `refresh_fn_http`

Refreshes HTTP-based credentials:

- Acquires mutex lock to prevent concurrent refreshes
- Calls `http_credentials_request` to fetch fresh credentials
- Returns 0 on success, -1 on failure

### `init_fn_http`

Initializes the HTTP credential provider:

- Sets debug mode for initial connection
- Acquires mutex lock to prevent concurrent initialization
- Calls `http_credentials_request` to fetch initial credentials
- Resets debug mode after initialization
- Returns 0 on success, -1 on failure

### `sync_fn_http`

Switches the provider to synchronous mode:

- Disables async mode on the upstream connection
- Used when credentials are needed immediately

### `async_fn_http`

Switches the provider to asynchronous mode:

- Enables async mode on the upstream connection
- Used for normal operation to avoid blocking

### `upstream_set_fn_http`

Configures the upstream connection for the provider:

- Temporarily disables TLS for credential endpoint connection
- Sets up the upstream connection with proper timeouts

### `destroy_fn_http`

Destroys the HTTP credential provider:

- Cleans up cached credentials
- Destroys HTTP client
- Frees host and path strings
- Frees provider implementation

### `flb_endpoint_provider_create`

Creates a generic HTTP credential provider:

- Initializes provider structure with mutex
- Creates upstream connection to specified endpoint
- Configures proper timeouts and connection settings
- Creates HTTP client for credential communication
- Returns configured provider or NULL on failure

### `flb_http_provider_create`

Creates an ECS/EKS HTTP credential provider:

- Reads credential endpoint from environment variables
- Supports both relative URI (`AWS_CONTAINER_CREDENTIALS_RELATIVE_URI`) and full URI (`AWS_CONTAINER_CREDENTIALS_FULL_URI`)
- Validates endpoint URLs for security compliance
- Creates endpoint provider with appropriate settings
- Returns configured provider or NULL on failure

### `http_credentials_request`

Fetches credentials from HTTP endpoint:

- Handles authorization token authentication
- Reads tokens from environment variables or files
- Makes authenticated HTTP request to credential endpoint
- Parses JSON response using `flb_parse_http_credentials`
- Updates cached credentials and refresh time
- Returns 0 on success, -1 on failure

### `flb_parse_http_credentials`

Parses HTTP credential response:

- Wrapper function for JSON credential parsing
- Uses `AWS_HTTP_RESPONSE_TOKEN` field name for session tokens
- Returns parsed credentials or NULL on failure

### `flb_parse_json_credentials`

Parses JSON credential response:

- Uses jsmn JSON parser to tokenize response
- Extracts AccessKeyId, SecretAccessKey, and session token
- Parses expiration timestamp and validates it
- Creates credentials structure with extracted values
- Returns parsed credentials or NULL on failure

### `validate_http_credential_uri`

Validates HTTP credential endpoint URI for security:

- Allows HTTPS endpoints (any hostname)
- Allows loopback addresses (127.0.0.0/8, ::1/128)
- Allows ECS endpoint (169.254.170.2)
- Allows EKS endpoint (169.254.170.23)
- Returns 0 on valid URI, -1 on invalid URI

## Credential Providers

The implementation supports multiple HTTP-based credential providers:

1. **ECS Provider**: Retrieves credentials from ECS task metadata endpoint
2. **EKS Provider**: Retrieves credentials from EKS pod metadata endpoint
3. **Custom Endpoint Provider**: Retrieves credentials from custom HTTP endpoints

## Implementation Details

### Authentication

- Supports authorization token authentication
- Reads tokens from `AWS_CONTAINER_AUTHORIZATION_TOKEN` environment variable
- Reads tokens from file specified by `AWS_CONTAINER_AUTHORIZATION_TOKEN_FILE`
- Uses basic authentication headers for token transmission

### Credential Refresh

- Implements proactive credential refresh before expiration
- Uses `FLB_AWS_REFRESH_WINDOW` to refresh credentials early
- Thread-safe refresh mechanism with mutex protection
- Handles concurrent access scenarios gracefully

### Error Handling

- Comprehensive error checking with proper resource cleanup
- Detailed logging for debugging credential issues
- Graceful handling of JSON parsing errors
- Proper validation of credential response format

### Security Validation

- Validates credential endpoint URLs to prevent SSRF attacks
- Only allows connections to approved endpoints
- Enforces HTTPS for external endpoints
- Restricts connections to localhost and AWS metadata endpoints

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
- Utility functions (`flb_utils.h`)

## Usage

This file is part of the AWS library (`flb-aws`) and is used by the standard credential chain provider when running in containerized environments (ECS, EKS) or when custom credential endpoints are configured. The HTTP provider is automatically included in the standard chain and will be used when other providers (environment variables, profiles, EC2 IMDS) are not available.