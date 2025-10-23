# src/aws/flb_aws_credentials_http.c Documentation

## Overview

This file implements HTTP-based credential providers for Fluent Bit's AWS integration. It provides functionality to retrieve temporary AWS credentials from HTTP endpoints, including ECS task roles, EKS pod execution roles, and custom HTTP credential servers. The module handles secure communication, credential parsing, and automatic refresh based on expiration times.

## Key Functions

### `flb_http_provider_create`
Creates an HTTP credential provider for ECS/EKS environments.
- **Parameters**: 
  - `config`: Fluent Bit configuration
  - `generator`: HTTP client generator
- **Return Value**: Pointer to AWS provider or NULL on failure
- **Description**: Creates provider based on environment variables for ECS/EKS

### `flb_endpoint_provider_create`
Creates a generic HTTP credential provider for custom endpoints.
- **Parameters**: 
  - `config`: Fluent Bit configuration
  - `host`: Hostname for credential endpoint
  - `path`: Path for credential endpoint
  - `port`: Port for credential endpoint
  - `insecure`: Whether to use insecure connection
  - `generator`: HTTP client generator
- **Return Value**: Pointer to AWS provider or NULL on failure
- **Description**: Creates provider for arbitrary HTTP credential endpoints

### `get_credentials_fn_http`
Retrieves credentials from HTTP endpoint.
- **Parameters**: `provider`: AWS provider instance
- **Return Value**: Pointer to AWS credentials or NULL on failure
- **Description**: Gets credentials from cache or requests fresh ones if needed

### `refresh_fn_http`
Refreshes credentials from HTTP endpoint.
- **Parameters**: `provider`: AWS provider instance
- **Return Value**: 0 on success, -1 on failure
- **Description**: Forces a refresh of credentials from HTTP endpoint

### `init_fn_http`
Initializes the HTTP credential provider.
- **Parameters**: `provider`: AWS provider instance
- **Return Value**: 0 on success, -1 on failure
- **Description**: Performs initial credential retrieval

### `sync_fn_http` and `async_fn_http`
Control synchronous/asynchronous operation modes.
- **Parameters**: `provider`: AWS provider instance
- **Description**: Enable/disable async mode for the provider

### `upstream_set_fn_http`
Sets upstream connection for the provider.
- **Parameters**: 
  - `provider`: AWS provider instance
  - `ins`: Output instance
- **Description**: Configures upstream network settings for HTTP communication

### `destroy_fn_http`
Destroys the HTTP credential provider.
- **Parameters**: `provider`: AWS provider instance
- **Description**: Cleans up all resources associated with the provider

### `http_credentials_request`
Requests and parses credentials from HTTP endpoint.
- **Parameters**: `implementation`: HTTP provider implementation
- **Return Value**: 0 on success, -1 on failure
- **Description**: Makes HTTP request and parses credential response

### `flb_parse_http_credentials`
Parses HTTP credential response into credentials structure.
- **Parameters**: 
  - `response`: JSON response from HTTP endpoint
  - `response_len`: Length of response
  - `expiration`: Pointer to store expiration timestamp
- **Return Value**: Pointer to AWS credentials or NULL on failure
- **Description**: Parses standard AWS credential JSON format

### `flb_parse_json_credentials`
Generic JSON credential parser.
- **Parameters**: 
  - `response`: JSON response
  - `response_len`: Length of response
  - `session_token_field`: Name of session token field
  - `expiration`: Pointer to store expiration timestamp
- **Return Value**: Pointer to AWS credentials or NULL on failure
- **Description**: Parses JSON credentials with configurable field names

### `validate_http_credential_uri`
Validates HTTP credential endpoint URI.
- **Parameters**: 
  - `protocol`: Protocol (http/https)
  - `host`: Hostname
- **Return Value**: 0 on success, -1 on failure
- **Description**: Ensures endpoint is secure or uses allowed local addresses

## Important Variables

### Environment Variables
- `AWS_CREDENTIALS_RELATIVE_URI`: Relative URI for ECS credentials
- `AWS_CREDENTIALS_FULL_URI`: Full URI for custom credential endpoints
- `AUTH_TOKEN_ENV_VAR`: Authorization token environment variable
- `AUTH_TOKEN_FILE_ENV_VAR`: Authorization token file path environment variable

### Constants
- `ECS_CREDENTIALS_HOST`: "169.254.170.2" (ECS credential endpoint)
- `EKS_CREDENTIALS_HOST`: "169.254.170.23" (EKS credential endpoint)
- `AWS_HTTP_RESPONSE_TOKEN`: "Token" (session token field name)
- `AWS_CREDENTIAL_RESPONSE_ACCESS_KEY`: "AccessKeyId"
- `AWS_CREDENTIAL_RESPONSE_SECRET_KEY`: "SecretAccessKey"
- `AWS_CREDENTIAL_RESPONSE_EXPIRATION`: "Expiration"

### Provider Structure
- `flb_aws_provider_http`: Contains cached credentials, refresh timing, HTTP client, and endpoint configuration
- `creds`: Cached AWS credentials
- `next_refresh`: Timestamp for next automatic credential refresh
- `client`: HTTP client for credential endpoint communication
- `host`, `path`: Endpoint configuration

## Dependencies

- Fluent Bit core libraries (`flb_info.h`, `flb_sds.h`, `flb_http_client.h`)
- AWS-specific headers (`flb_aws_credentials.h`, `flb_aws_util.h`)
- Utility functions (`flb_utils.h`)
- JSON parsing (`flb_jsmn.h`)
- Standard C library functions

## Implementation Details

### ECS/EKS Environment Detection
The provider automatically detects ECS/EKS environments by checking environment variables:
- `AWS_CREDENTIALS_RELATIVE_URI`: For ECS tasks
- `AWS_CREDENTIALS_FULL_URI`: For EKS pods or custom endpoints

### Security Validation
The `validate_http_credential_uri` function ensures secure communication:
- Allows HTTPS endpoints unconditionally
- Restricts HTTP endpoints to loopback addresses, ECS host, and EKS host
- Prevents credential leakage to external endpoints

### Credential Lifecycle Management
The provider manages credentials through:
- Automatic refresh based on expiration minus refresh window
- Thread-safe operations using provider locking
- Proper cleanup of expired credentials
- Caching of current credentials for performance

### Authorization Token Support
Supports authorization tokens for secure credential endpoints:
- Reads tokens from environment variables
- Reads tokens from files specified in environment
- Handles token formatting (removes newlines)
- Adds Authorization header to HTTP requests

### JSON Credential Parsing
The `flb_parse_json_credentials` function handles standard AWS credential JSON format:
```json
{
  "AccessKeyId": "ACCESS_KEY_ID",
  "Expiration": "2019-12-18T21:27:58Z",
  "SecretAccessKey": "SECRET_ACCESS_KEY",
  "Token": "SECURITY_TOKEN_STRING"
}
```

### Network Configuration
Specialized network settings for HTTP credential communication:
- Configurable timeouts for reliable operation
- Support for both HTTP and HTTPS endpoints
- Proper upstream configuration for output plugins

### Thread Safety
The implementation ensures thread safety:
- Uses provider locking to prevent concurrent credential updates
- Non-blocking lock attempts to avoid deadlocks
- Proper synchronization between coroutines

## Usage Examples

To create an HTTP credential provider for ECS/EKS:
```c
#include <fluent-bit/aws/flb_aws_credentials_http.h>

struct flb_aws_provider *provider = flb_http_provider_create(config, flb_aws_client_generator());

if (provider) {
    // Provider created successfully
    // Use provider->provider_vtable->get_credentials(provider) to retrieve credentials
    
    // Clean up when done
    flb_aws_provider_destroy(provider);
} else {
    // Failed to create provider
}
```

To create a provider for a custom HTTP endpoint:
```c
#include <fluent-bit/aws/flb_aws_credentials_http.h>

flb_sds_t host = flb_sds_create("169.254.170.2");
flb_sds_t path = flb_sds_create("/credentials");

struct flb_aws_provider *provider = flb_endpoint_provider_create(
    config, host, path, 80, FLB_TRUE, flb_aws_client_generator());

if (provider) {
    // Provider created successfully
    // Use provider->provider_vtable->get_credentials(provider) to retrieve credentials
    
    // Clean up when done
    flb_aws_provider_destroy(provider);
} else {
    // Failed to create provider
}
```

To retrieve credentials from the provider:
```c
struct flb_aws_credentials *creds = provider->provider_vtable->get_credentials(provider);

if (creds) {
    // Successfully retrieved credentials
    printf("Access Key: %s\n", creds->access_key_id);
    printf("Secret Key: %s\n", creds->secret_access_key);
    if (creds->session_token) {
        printf("Session Token: %s\n", creds->session_token);
    }
    
    // Clean up credentials when done
    flb_aws_credentials_destroy(creds);
} else {
    // Failed to retrieve credentials
}
```