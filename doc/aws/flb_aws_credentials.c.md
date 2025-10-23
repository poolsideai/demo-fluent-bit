# src/aws/flb_aws_credentials.c Documentation

## Overview

This file implements the AWS credentials management system for Fluent Bit. It provides a comprehensive credential provider chain that automatically discovers and manages AWS credentials from multiple sources, including environment variables, IAM roles, EC2 instance metadata, ECS task roles, and EKS pod execution roles.

## Key Functions

### `flb_standard_chain_provider_create`
Creates the standard AWS credential provider chain.
- **Parameters**: 
  - `config`: Fluent Bit configuration
  - `tls`: TLS configuration for secure connections
  - `region`: AWS region
  - `sts_endpoint`: STS endpoint URL
  - `proxy`: Proxy configuration
  - `generator`: HTTP client generator
  - `profile`: AWS profile name
- **Return Value**: Pointer to AWS provider or NULL on failure
- **Description**: Creates a provider chain that tries multiple credential sources in order

### `flb_managed_chain_provider_create`
Creates a managed AWS credential provider chain for output plugins.
- **Parameters**: 
  - `ins`: Output instance
  - `config`: Fluent Bit configuration
  - `config_key_prefix`: Configuration key prefix
  - `proxy`: Proxy configuration
  - `generator`: HTTP client generator
- **Return Value**: Pointer to AWS provider or NULL on failure
- **Description**: Creates a provider chain with automatic configuration parsing

### `flb_aws_env_provider_create`
Creates an environment variable credential provider.
- **Return Value**: Pointer to AWS provider or NULL on failure
- **Description**: Provider that reads credentials from AWS environment variables

### `get_credentials_fn_environment`
Retrieves credentials from environment variables.
- **Parameters**: `provider`: AWS provider instance
- **Return Value**: Pointer to AWS credentials or NULL on failure
- **Description**: Reads AWS credentials from environment variables

### `flb_aws_credentials_destroy`
Destroys AWS credentials structure.
- **Parameters**: `creds`: AWS credentials to destroy
- **Description**: Frees all memory associated with credentials

### `flb_aws_provider_destroy`
Destroys AWS provider structure.
- **Parameters**: `provider`: AWS provider to destroy
- **Description**: Frees all memory associated with provider and dependencies

### `flb_aws_cred_expiration`
Parses and validates credential expiration timestamp.
- **Parameters**: `timestamp`: ISO8601 timestamp string
- **Return Value**: Unix timestamp or -1 on failure
- **Description**: Converts timestamp string to epoch time and validates range

### `try_lock_provider` and `unlock_provider`
Thread-safe locking functions for credential providers.
- **Parameters**: `provider`: AWS provider instance
- **Return Value**: Lock status or void
- **Description**: Prevents race conditions during credential refresh

## Important Variables

### `FIVE_MINUTES` and `TWELVE_HOURS`
Constants for credential expiration validation:
- `FIVE_MINUTES`: 300 seconds (minimum valid credential duration)
- `TWELVE_HOURS`: 43200 seconds (maximum valid credential duration)

### Environment Variable Names
- `AWS_ACCESS_KEY_ID`: Environment variable for access key ID
- `AWS_SECRET_ACCESS_KEY`: Environment variable for secret access key
- `AWS_SESSION_TOKEN`: Environment variable for session token
- `EKS_POD_EXECUTION_ROLE`: Environment variable for EKS pod execution role

### Provider Chain Structure
- `flb_aws_provider_chain`: Contains list of sub-providers in evaluation order
- `sub_provider`: Currently active provider in the chain

## Dependencies

- Fluent Bit core libraries (`flb_info.h`, `flb_sds.h`, `flb_http_client.h`)
- AWS-specific headers (`flb_aws_credentials.h`, `flb_aws_util.h`)
- JSON parsing (`flb_jsmn.h`)
- Output plugin interface (`flb_output_plugin.h`)
- Standard C library functions

## Implementation Details

### Provider Chain Evaluation Order
The standard chain evaluates providers in this order:
1. Environment variables
2. Shared credentials file (AWS Profile)
3. EKS OIDC (when applicable)
4. EC2 IMDS
5. ECS HTTP credentials endpoint

### Thread Safety
The implementation uses pthread mutexes to ensure thread safety:
- `try_lock_provider` prevents deadlocks during concurrent access
- `unlock_provider` releases locks after operations
- Provider refresh operations are serialized

### Credential Expiration Validation
The `flb_aws_cred_expiration` function validates timestamps:
- Checks that expiration is within 5 minutes to 12 hours in the future
- Warns about suspicious expiration times
- Returns Unix timestamp for easy comparison

### Memory Management
Comprehensive memory management with proper cleanup:
- Uses Fluent Bit's memory allocation functions (`flb_calloc`, `flb_free`)
- Properly destroys SDS strings (`flb_sds_destroy`)
- Cleans up TLS instances and provider dependencies

### Configuration Parsing
The `flb_managed_chain_provider_create` function automatically parses configuration:
- Builds configuration keys with prefixes
- Extracts region, STS endpoint, role ARN, and external ID
- Creates separate TLS instances for credential and STS providers

### EKS Fargate Support
Special handling for EKS Fargate environments:
- Detects `EKS_POD_EXECUTION_ROLE` environment variable
- Creates STS provider to assume the pod execution role
- Generates random session names for STS requests

## Usage Examples

To create a standard credential provider chain:
```c
#include <fluent-bit/aws/flb_aws_credentials.h>

struct flb_aws_provider *provider = flb_standard_chain_provider_create(
    config, tls, "us-east-1", NULL, NULL, flb_aws_client_generator(), "default");

if (provider) {
    // Provider chain created successfully
    // Use provider->provider_vtable->get_credentials(provider) to retrieve credentials
    
    // Clean up when done
    flb_aws_provider_destroy(provider);
} else {
    // Failed to create provider chain
}
```

To retrieve credentials from a provider:
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