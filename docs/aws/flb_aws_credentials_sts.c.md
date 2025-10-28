# flb_aws_credentials_sts.c

## Overview

This file implements functionality for retrieving AWS credentials using Security Token Service (STS) operations. It supports two main use cases:

1. **STS AssumeRole Provider**: Uses existing credentials to assume an IAM role via STS
2. **EKS Provider**: Uses OIDC tokens from Kubernetes to obtain AWS credentials via `AssumeRoleWithWebIdentity`

Both providers handle credential caching, expiration management, and automatic refresh.

## Key Functions

### STS Provider Interface Functions

- `get_credentials_fn_sts()`: Retrieves cached or refreshed STS credentials
- `refresh_fn_sts()`: Forces refresh of STS credentials
- `init_fn_sts()`: Initializes the STS provider and retrieves initial credentials
- `sync_fn_sts()` / `async_fn_sts()`: Controls async mode for the STS client
- `upstream_set_fn_sts()`: Associates upstream connections with the provider
- `destroy_fn_sts()`: Cleans up STS provider resources

### EKS Provider Interface Functions

- `get_credentials_fn_eks()`: Retrieves cached or refreshed EKS credentials
- `refresh_fn_eks()`: Forces refresh of EKS credentials
- `init_fn_eks()`: Initializes the EKS provider and retrieves initial credentials
- `sync_fn_eks()` / `async_fn_eks()`: Controls async mode for the EKS client
- `upstream_set_fn_eks()`: Associates upstream connections with the EKS provider
- `destroy_fn_eks()`: Cleans up EKS provider resources

### Provider Creation Functions

- `flb_sts_provider_create()`: Creates an STS AssumeRole provider
- `flb_eks_provider_create()`: Creates an EKS/OIDC provider

### Credential Management Functions

- `sts_assume_role_request()`: Makes STS API calls to assume roles
- `assume_with_web_identity()`: Handles OIDC token-based role assumption
- `flb_parse_sts_resp()`: Parses XML responses from STS API calls
- `flb_sts_uri()`: Constructs STS request URIs with proper parameters
- `get_node()`: Extracts XML node values from STS responses

### Utility Functions

- `flb_sts_session_name()`: Generates unique session names for role assumptions
- `bytes_to_string()`: Converts random bytes to safe URL strings

## Important Constants

### URI Format Constants
- `STS_ASSUME_ROLE_URI_FORMAT`: Base URI format for STS requests
- `STS_ASSUME_ROLE_URI_BASE_LEN`: Length of base URI format

### XML Node Constants
- `CREDENTIALS_NODE`: "<Credentials>" - Root credentials node
- `ACCESS_KEY_NODE`: "<AccessKeyId>" - Access key ID node
- `SECRET_KEY_NODE`: "<SecretAccessKey>" - Secret access key node
- `SESSION_TOKEN_NODE`: "<SessionToken>" - Session token node
- `EXPIRATION_NODE`: "<Expiration>" - Expiration timestamp node

### Environment Variable Constants
- `TOKEN_FILE_ENV_VAR`: "AWS_WEB_IDENTITY_TOKEN_FILE" - Path to OIDC token file
- `ROLE_ARN_ENV_VAR`: "AWS_ROLE_ARN" - Role ARN for EKS provider
- `SESSION_NAME_ENV_VAR`: "AWS_ROLE_SESSION_NAME" - Session name for role assumption

### Session Name Constants
- `SESSION_NAME_RANDOM_BYTE_LEN`: 32 - Length of random bytes for session names

## Data Structures

### `struct flb_aws_provider_sts`
Represents the STS AssumeRole provider with:
- Custom endpoint flag (`custom_endpoint`)
- Base provider reference (`base_provider`)
- Cached credentials (`creds`)
- Next refresh time (`next_refresh`)
- STS client (`sts_client`)
- Endpoint URL (`endpoint`)
- Request URI (`uri`)

### `struct flb_aws_provider_eks`
Represents the EKS/OIDC provider with:
- Custom endpoint flag (`custom_endpoint`)
- Cached credentials (`creds`)
- Next refresh time (`next_refresh`)
- STS client (`sts_client`)
- Endpoint URL (`endpoint`)
- Session name (`session_name`)
- Role ARN (`role_arn`)
- Token file path (`token_file`)
- Session name cleanup flag (`free_session_name`)

### Provider Virtual Tables
- `sts_provider_vtable`: Virtual table for STS provider interface
- `eks_provider_vtable`: Virtual table for EKS provider interface

## Dependencies

- `<fluent-bit/flb_info.h>`: General information and utilities
- `<fluent-bit/flb_sds.h>`: String data structures
- `<fluent-bit/flb_http_client.h>`: HTTP client functionality
- `<fluent-bit/flb_aws_credentials.h>`: Core AWS credentials functionality
- `<fluent-bit/flb_aws_util.h>`: AWS utility functions
- `<fluent-bit/flb_random.h>`: Random number generation
- `<fluent-bit/flb_jsmn.h>`: JSON parsing (for error handling)
- `<stdlib.h>`: Standard library functions
- `<time.h>`: Time functions
- `<string.h>`: String manipulation functions

## Implementation Details

### STS AssumeRole Provider

1. Uses a base provider to obtain initial credentials
2. Makes HTTP requests to STS endpoints to assume roles
3. Parses XML responses to extract credentials and expiration times
4. Manages credential caching with automatic refresh before expiration
5. Supports both synchronous and asynchronous operation modes

### EKS Provider

1. Reads OIDC tokens from files specified by environment variables
2. Uses `AssumeRoleWithWebIdentity` to exchange tokens for AWS credentials
3. Generates unique session names when not provided by environment
4. Handles token file reading and error conditions
5. Manages credential lifecycle similar to STS provider

### Common Features

- Thread-safe credential access with mutex locks
- Automatic credential refresh with configurable windows
- Proper resource cleanup in all code paths
- Debug/error logging with appropriate verbosity levels
- Support for custom STS endpoints
- TLS configuration support
- Proxy configuration support

## Usage Example

```c
// Create an STS AssumeRole provider
struct flb_aws_provider *sts_provider = flb_sts_provider_create(
    config,
    tls,
    base_provider,
    NULL,  // external_id
    "arn:aws:iam::123456789012:role/MyRole",
    "MySession",
    "us-east-1",
    NULL,  // sts_endpoint
    NULL,  // proxy
    &generator
);

// Create an EKS provider (requires environment variables)
struct flb_aws_provider *eks_provider = flb_eks_provider_create(
    config,
    tls,
    "us-east-1",
    NULL,  // sts_endpoint
    NULL,  // proxy
    &generator
);

// Use either provider to get credentials
struct flb_aws_credentials *creds = sts_provider->provider_vtable->
    get_credentials(sts_provider);

if (creds) {
    printf("Access Key: %s\n", creds->access_key_id);
    printf("Secret Key: %s\n", creds->secret_access_key);
    if (creds->session_token) {
        printf("Session Token: %s\n", creds->session_token);
    }
    
    // Clean up credentials
    flb_aws_credentials_destroy(creds);
}

// Clean up providers
sts_provider->provider_vtable->destroy(sts_provider);
```