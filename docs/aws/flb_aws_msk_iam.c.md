# flb_aws_msk_iam.c

## Overview

This file implements functionality for AWS Managed Streaming for Apache Kafka (MSK) IAM authentication. It provides a stateless OAuth bearer token refresh mechanism that generates signed URLs for authenticating with MSK clusters using IAM credentials.

## Key Functions

### Configuration Management

- `flb_aws_msk_iam_register_oauth_cb()`: Registers the OAuth bearer token refresh callback with Kafka configuration
- `flb_aws_msk_iam_destroy()`: Cleans up MSK IAM configuration resources

### Token Generation

- `build_msk_iam_payload()`: Generates a signed URL payload for MSK IAM authentication
- `oauthbearer_token_refresh_cb()`: Callback function that generates and sets OAuth bearer tokens

### Utility Functions

- `uri_encode_params()`: URI encodes parameters for AWS signature
- `sha256_to_hex()`: Converts SHA256 hash to hexadecimal string
- `hmac_sha256_sign()`: Signs data using HMAC-SHA256
- `extract_region()`: Extracts region from AWS ARN
- `to_encode()`: Checks if a character needs URI encoding

## Important Constants

### Action Parameters
- `ACTION_KAFKA_CLUSTER_CONNECT`: "kafka-cluster:Connect" - Required action for MSK IAM authentication

### Service Identifiers
- `SERVICE_KAFKA_CLUSTER`: "kafka-cluster" - AWS service identifier for Kafka

### Endpoint Patterns
- `MSK_SERVERLESS_SUFFIX`: "-s3" - Suffix identifying MSK Serverless clusters

## Data Structures

### `struct flb_aws_msk_iam`
Represents the MSK IAM configuration with:
- Fluent Bit configuration reference (`flb_config`)
- AWS region (`region`)
- Cluster ARN (`cluster_arn`)

### `struct flb_kafka_opaque`
Opaque structure passed to Kafka callbacks containing:
- MSK IAM context reference (`msk_iam_ctx`)

## Dependencies

- `<fluent-bit/flb_info.h>`: General information and utilities
- `<fluent-bit/flb_log.h>`: Logging functions
- `<fluent-bit/flb_sds.h>`: String data structures
- `<fluent-bit/flb_mem.h>`: Memory management functions
- `<fluent-bit/flb_utils.h>`: Utility functions
- `<fluent-bit/flb_base64.h>`: Base64 encoding functions
- `<fluent-bit/flb_hash.h>`: Hash functions
- `<fluent-bit/flb_hmac.h>`: HMAC functions
- `<fluent-bit/flb_kafka.h>`: Kafka integration functions
- `<fluent-bit/flb_aws_credentials.h>`: Core AWS credentials functionality
- `<fluent-bit/aws/flb_aws_msk_iam.h>`: Header file for this module
- `<fluent-bit/flb_signv4.h>`: AWS Signature Version 4 functionality
- `<rdkafka.h>`: librdkafka API
- `<stdio.h>`: Standard I/O functions
- `<stdlib.h>`: Standard library functions
- `<string.h>`: String manipulation functions
- `<time.h>`: Time functions

## Implementation Details

### Stateless Architecture

The implementation follows a stateless design:

1. **No Persistent Provider**: Creates AWS providers on-demand for each token refresh
2. **Immediate Cleanup**: Destroys all temporary resources after use
3. **Thread Safety**: Each callback execution is independent

### Token Generation Process

1. **Credential Acquisition**: Creates a temporary AWS provider to get current credentials
2. **Signature Generation**: Implements AWS Signature Version 4 to sign the request
3. **URL Construction**: Builds a presigned URL with required parameters
4. **Base64 Encoding**: Encodes the URL using URL-safe Base64 encoding
5. **Token Setting**: Sets the generated token in the Kafka client

### Security Features

- **Proper Signature Implementation**: Follows AWS Signature Version 4 specification
- **Secure Token Handling**: Generates tokens with appropriate expiration (900 seconds)
- **Resource Cleanup**: Ensures no memory leaks with comprehensive cleanup
- **Error Handling**: Graceful error handling with informative messages

### MSK Cluster Support

- **Regular MSK Clusters**: Uses standard kafka.{region}.amazonaws.com endpoints
- **MSK Serverless Clusters**: Detects and uses appropriate endpoints for serverless clusters
- **ARN Parsing**: Extracts region information from cluster ARNs

## Usage Example

```c
// Register MSK IAM OAuth callback
struct flb_aws_msk_iam *msk_iam_ctx = flb_aws_msk_iam_register_oauth_cb(
    flb_config,
    kafka_conf,
    "arn:aws:kafka:us-east-1:123456789012:cluster/MyCluster/abcd1234-ef56-gh78-ij90-abcd1234ef56",
    kafka_opaque
);

if (msk_iam_ctx) {
    // The OAuth callback will automatically handle token refresh
    // No additional setup needed - librdkafka will call the callback when needed
    
    // Clean up when done
    flb_aws_msk_iam_destroy(msk_iam_ctx);
} else {
    flb_error("Failed to register MSK IAM OAuth callback");
}

// In your Kafka producer/consumer configuration:
// Set security.protocol=SASL_SSL
// Set sasl.mechanism=OAUTHBEARER
// Set oauth_cb=oauthbearer_token_refresh_cb
```