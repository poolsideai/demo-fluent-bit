# flb_aws_imds.c

## Overview

This file implements functionality for interacting with the AWS Instance Metadata Service (IMDS). It provides support for both IMDSv1 and IMDSv2 protocols, automatically detecting which version is available and handling token management for IMDSv2.

## Key Functions

### Context Management

- `flb_aws_imds_create()`: Creates and initializes an IMDS context
- `flb_aws_imds_destroy()`: Cleans up and destroys an IMDS context

### Metadata Retrieval

- `flb_aws_imds_request()`: Retrieves metadata from IMDS at a given path
- `flb_aws_imds_request_by_key()`: Retrieves specific JSON key values from metadata responses
- `flb_aws_imds_get_vpc_id()`: Helper function to retrieve the VPC ID of the EC2 instance

### Version Management

- `get_imds_version()`: Detects which IMDS version is available (IMDSv1 or IMDSv2)
- `refresh_imds_v2_token()`: Obtains or refreshes an IMDSv2 token

## Important Constants

### IMDS Paths
- `FLB_AWS_IMDS_ROOT`: "/" - Root path for IMDS requests
- `FLB_AWS_IMDS_V2_TOKEN_PATH`: "/latest/api/token" - Path for IMDSv2 token requests
- `FLB_AWS_IMDS_MAC_PATH`: "/latest/meta-data/mac" - Path for retrieving MAC address

### IMDS Host and Port
- `FLB_AWS_IMDS_HOST`: "169.254.169.254" - Default IMDS host
- `FLB_AWS_IMDS_HOST_LEN`: Length of FLB_AWS_IMDS_HOST
- `FLB_AWS_IMDS_PORT`: 80 - Default IMDS port

### IMDS Versions
- `FLB_AWS_IMDS_VERSION_EVALUATE`: -1 - Indicates version needs to be evaluated
- `FLB_AWS_IMDS_VERSION_1`: 1 - IMDS version 1
- `FLB_AWS_IMDS_VERSION_2`: 2 - IMDS version 2

### Token TTL
- `IMDS_V2_TOKEN_TTL_SECONDS`: "21600" - 6 hours (maximum TTL for IMDSv2 tokens)

## Data Structures

### `struct flb_aws_imds`
Represents the IMDS context with:
- IMDS version (`imds_version`)
- IMDSv2 token (`imds_v2_token`)
- IMDSv2 token length (`imds_v2_token_len`)
- EC2 IMDS client (`ec2_imds_client`)

### `struct flb_aws_imds_config`
Configuration structure for IMDS with:
- Preferred IMDS version (`use_imds_version`)

### `struct flb_aws_header`
Header structure for HTTP requests with:
- Header key (`key`)
- Header key length (`key_len`)
- Header value (`val`)
- Header value length (`val_len`)

## Dependencies

- `<fluent-bit/aws/flb_aws_imds.h>`: Header file for this module
- `<fluent-bit/flb_aws_credentials.h>`: Core AWS credentials functionality
- `<fluent-bit/flb_aws_util.h>`: AWS utility functions
- `<fluent-bit/flb_http_client.h>`: HTTP client functionality
- `<fluent-bit/flb_info.h>`: General information and utilities
- `<fluent-bit/flb_jsmn.h>`: JSON parsing functions

## Implementation Details

### IMDS Version Detection

The implementation automatically detects which IMDS version is available:

1. **IMDSv2 Detection**: Sends a request with an invalid token to determine if IMDSv2 is enabled
2. **Fallback to IMDSv1**: If IMDSv2 is not available or token refresh fails, falls back to IMDSv1
3. **Token Management**: Automatically manages IMDSv2 tokens with appropriate TTL values

### Request Handling

1. **Version-Aware Requests**: Uses appropriate authentication method based on detected IMDS version
2. **Token Refresh**: Automatically refreshes IMDSv2 tokens when they expire or become invalid
3. **Error Handling**: Gracefully handles various error conditions including network issues and invalid responses
4. **JSON Parsing**: Supports extracting specific key values from JSON metadata responses

### Security Considerations

- Implements proper token lifecycle management for IMDSv2
- Handles authentication failures gracefully
- Provides informative error messages for debugging
- Follows AWS best practices for IMDS interaction

## Usage Example

```c
// Create an IMDS context
struct flb_aws_imds_config config = {FLB_AWS_IMDS_VERSION_EVALUATE};
struct flb_aws_imds *imds_ctx = flb_aws_imds_create(&config, ec2_imds_client);

if (imds_ctx) {
    // Retrieve instance metadata
    flb_sds_t instance_id = NULL;
    size_t instance_id_len = 0;
    
    if (flb_aws_imds_request(imds_ctx, "/latest/meta-data/instance-id", 
                            &instance_id, &instance_id_len) == 0) {
        printf("Instance ID: %s\n", instance_id);
        flb_sds_destroy(instance_id);
    }
    
    // Retrieve VPC ID
    flb_sds_t vpc_id = flb_aws_imds_get_vpc_id(imds_ctx);
    if (vpc_id) {
        printf("VPC ID: %s\n", vpc_id);
        flb_sds_destroy(vpc_id);
    }
    
    // Retrieve specific JSON key from metadata
    flb_sds_t region = NULL;
    size_t region_len = 0;
    
    if (flb_aws_imds_request_by_key(imds_ctx, "/latest/dynamic/instance-identity/document",
                                   &region, &region_len, "region") == 0) {
        printf("Region: %s\n", region);
        flb_sds_destroy(region);
    }
    
    // Clean up
    flb_aws_imds_destroy(imds_ctx);
}
```