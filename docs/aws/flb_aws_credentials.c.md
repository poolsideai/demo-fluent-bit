# src/aws/flb_aws_credentials.c Documentation

## Overview

This C file implements AWS credential management functionality for Fluent Bit. It provides a comprehensive credential provider system that supports multiple authentication methods for AWS services, including environment variables, shared credentials files, EC2 Instance Metadata Service (IMDS), ECS task roles, and EKS pod roles.

## Key Data Structures

### `flb_aws_provider_chain`

Structure representing a chain of credential providers:

- `sub_providers`: Linked list of credential providers in the chain
- `sub_provider`: Currently active provider from the chain

### `compression_option`

Structure that defines a credential provider option:

- `compression_type`: Integer identifier for the credential provider type
- `compression_keyword`: String keyword used to identify the provider type
- `compress`: Function pointer to the credential retrieval function

## Key Functions

### `get_from_chain`

Retrieves credentials from the first successful provider in the chain:

- Iterates through all providers in the chain
- Returns credentials from the first provider that successfully returns valid credentials
- Caches the successful provider for subsequent requests

### `get_credentials_fn_standard_chain`

Main entry point for retrieving credentials from the standard chain:

- Uses cached provider if available
- Falls back to trying all providers in the chain if no cached provider
- Handles concurrent access with mutex locking

### `init_fn_standard_chain`

Initializes the standard credential provider chain:

- Initializes all providers in the chain
- Sets the first successful provider as the cached provider
- Handles concurrent access with mutex locking

### `refresh_fn_standard_chain`

Refreshes credentials from the standard chain:

- Attempts to refresh credentials from all providers in the chain
- Updates the cached provider to the first successful one
- Handles concurrent access with mutex locking

### `flb_standard_chain_provider_create`

Creates a standard credential provider chain:

- Supports special handling for EKS Fargate environments
- Creates a base standard chain and wraps it with STS provider for EKS pod roles
- Sets up proper session names for role assumption

### `flb_managed_chain_provider_create`

Creates a managed credential provider chain for output plugins:

- Reads configuration from output plugin properties
- Creates TLS instances for secure credential retrieval
- Handles role assumption with STS provider when role_arn is configured
- Manages dependencies for proper cleanup

### `standard_chain_create`

Creates the standard credential provider chain:

- Initializes environment variable provider
- Initializes profile provider (if profile specified)
- Initializes EKS provider (if EKS IRSA enabled)
- Initializes ECS HTTP provider
- Initializes EC2 IMDS provider

### `get_credentials_fn_environment`

Retrieves credentials from environment variables:

- Reads `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, and `AWS_SESSION_TOKEN`
- Returns credentials structure or NULL if required variables missing

### `refresh_fn_environment`

Refreshes environment variable credentials:

- Checks if required environment variables are still present
- Returns 0 on success, -1 on failure

### `flb_aws_env_provider_create`

Creates an environment variable credential provider:

- Initializes provider with environment-specific vtable
- Sets up proper function pointers for credential operations

### `flb_aws_credentials_destroy`

Destroys an AWS credentials structure:

- Frees all allocated strings (access key, secret key, session token)
- Frees the credentials structure itself

### `flb_aws_provider_destroy`

Destroys an AWS credential provider:

- Calls provider-specific destroy function
- Destroys mutex lock
- Cleans up managed dependencies (TLS instances, base providers)
- Frees the provider structure

### `timestamp_to_epoch`

Converts AWS timestamp string to epoch time:

- Parses ISO 8601 timestamp format (YYYY-MM-DDTHH:MM:SSZ)
- Converts to Unix epoch time
- Returns -1 on parsing failure

### `flb_aws_cred_expiration`

Processes AWS credential expiration timestamp:

- Converts timestamp to epoch time
- Validates expiration time is reasonable (5 minutes to 12 hours in future)
- Returns expiration time or -1 on error

### `try_lock_provider` and `unlock_provider`

Thread-safe locking functions:

- `try_lock_provider`: Non-blocking attempt to acquire provider mutex
- `unlock_provider`: Releases provider mutex

## Credential Providers

The implementation supports multiple credential providers in a chain:

1. **Environment Variables**: Reads credentials from `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_SESSION_TOKEN`
2. **Shared Credentials File**: Uses AWS profile from `~/.aws/credentials`
3. **EKS IRSA**: Kubernetes service account token for IAM role assumption
4. **ECS HTTP**: Retrieves credentials from ECS task metadata endpoint
5. **EC2 IMDS**: Retrieves credentials from EC2 Instance Metadata Service

## Implementation Details

### Thread Safety

- Uses pthread mutexes to protect concurrent access to providers
- Implements non-blocking lock acquisition to prevent deadlocks
- Caches successful providers to minimize repeated lookups

### Error Handling

- Comprehensive error checking with proper resource cleanup
- Detailed logging for debugging credential issues
- Graceful fallback between providers in the chain

### Memory Management

- Uses Fluent Bit's memory allocation functions (`flb_calloc`, `flb_free`)
- Proper cleanup of all allocated resources
- Reference counting for shared dependencies

## Usage

This file is part of the AWS library (`flb-aws`) and is used by AWS output plugins to authenticate with AWS services. The standard chain provider is typically used by default, automatically selecting the most appropriate credential source based on the execution environment.