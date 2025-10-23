# src/aws/flb_aws_credentials_ec2.c Documentation

## Overview

This file implements the EC2 Instance Metadata Service (IMDS) credential provider for Fluent Bit's AWS integration. It provides functionality to automatically retrieve temporary AWS credentials assigned to EC2 instances through IAM roles. The provider handles communication with the IMDS endpoint, credential parsing, and automatic refresh based on expiration times.

## Key Functions

### `flb_ec2_provider_create`
Creates an EC2 IMDS credential provider.
- **Parameters**: 
  - `config`: Fluent Bit configuration
  - `generator`: HTTP client generator
- **Return Value**: Pointer to AWS provider or NULL on failure
- **Description**: Initializes the EC2 provider with upstream connection and IMDS interface

### `get_credentials_fn_ec2`
Retrieves credentials from EC2 IMDS.
- **Parameters**: `provider`: AWS provider instance
- **Return Value**: Pointer to AWS credentials or NULL on failure
- **Description**: Gets credentials from cache or requests fresh ones if needed

### `refresh_fn_ec2`
Refreshes credentials from EC2 IMDS.
- **Parameters**: `provider`: AWS provider instance
- **Return Value**: 0 on success, -1 on failure
- **Description**: Forces a refresh of credentials from IMDS

### `init_fn_ec2`
Initializes the EC2 credential provider.
- **Parameters**: `provider`: AWS provider instance
- **Return Value**: 0 on success, -1 on failure
- **Description**: Performs initial credential retrieval

### `sync_fn_ec2` and `async_fn_ec2`
Control synchronous/asynchronous operation modes.
- **Parameters**: `provider`: AWS provider instance
- **Description**: Enable/disable async mode for the provider

### `upstream_set_fn_ec2`
Sets upstream connection for the provider.
- **Parameters**: 
  - `provider`: AWS provider instance
  - `ins`: Output instance
- **Description**: Configures upstream network settings for IMDS communication

### `destroy_fn_ec2`
Destroys the EC2 credential provider.
- **Parameters**: `provider`: AWS provider instance
- **Description**: Cleans up all resources associated with the provider

### `get_creds_ec2`
Internal function to retrieve credentials from IMDS.
- **Parameters**: `implementation`: EC2 provider implementation
- **Return Value**: 0 on success, -1 on failure
- **Description**: Orchestrates the credential retrieval process

### `ec2_credentials_request`
Requests and parses credentials from IMDS.
- **Parameters**: 
  - `implementation`: EC2 provider implementation
  - `cred_path`: Path to credentials on IMDS
- **Return Value**: 0 on success, -1 on failure
- **Description**: Makes HTTP request to IMDS and parses response

## Important Variables

### `AWS_IMDS_ROLE_PATH`
IMDS endpoint path for retrieving instance role name: "/latest/meta-data/iam/security-credentials/"

### Provider Structure
- `flb_aws_provider_ec2`: Contains cached credentials, refresh timing, HTTP client, and IMDS interface
- `creds`: Cached AWS credentials
- `next_refresh`: Timestamp for next automatic credential refresh
- `client`: HTTP client for IMDS communication
- `imds_interface`: IMDS interface abstraction

## Dependencies

- Fluent Bit core libraries (`flb_info.h`, `flb_sds.h`, `flb_http_client.h`)
- AWS-specific headers (`flb_aws_credentials.h`, `flb_aws_util.h`)
- JSON parsing (`flb_jsmn.h`)
- IMDS interface (`flb_aws_imds.h`)
- Standard C library functions

## Implementation Details

### IMDS Communication
The provider communicates with EC2 IMDS using:
- HTTP client for making requests to IMDS endpoint
- IMDS interface abstraction for handling protocol details
- Configurable timeouts for reliable operation

### Credential Lifecycle Management
The provider manages credentials through:
- Automatic refresh based on expiration minus refresh window
- Thread-safe operations using provider locking
- Proper cleanup of expired credentials
- Caching of current credentials for performance

### Role Discovery Process
The credential retrieval follows these steps:
1. Query IMDS for instance role name
2. Construct credentials path using role name
3. Request credentials from IMDS
4. Parse JSON response into credentials structure
5. Set refresh time based on expiration

### Network Configuration
Specialized network settings for IMDS communication:
- Fixed timeout values for reliable operation
- Disabled keepalive to handle connection breaks
- Special handling for upstream configuration

### Thread Safety
The implementation ensures thread safety:
- Uses provider locking to prevent concurrent credential updates
- Non-blocking lock attempts to avoid deadlocks
- Proper synchronization between coroutines

## Usage Examples

To create an EC2 credential provider:
```c
#include <fluent-bit/aws/flb_aws_credentials_ec2.h>

struct flb_aws_provider *provider = flb_ec2_provider_create(config, flb_aws_client_generator());

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