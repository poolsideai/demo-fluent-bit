# flb_signv4.c

## Overview

The `flb_signv4.c` file implements AWS Signature Version 4 (SigV4) signing functionality for Fluent Bit. This module provides the capability to sign HTTP requests according to AWS SigV4 standards, which is required for authenticating requests to AWS services.

AWS Signature Version 4 is a protocol for authenticating HTTP requests to AWS services. It provides a way to authenticate requests using a cryptographic signature that includes the request content, headers, and other metadata. This implementation follows the official AWS SigV4 specification and is used by various AWS output plugins in Fluent Bit.

Key features:
- Complete AWS SigV4 signing implementation
- Support for different AWS services and regions
- Handling of various payload modes (signed, unsigned)
- Integration with AWS credentials providers
- Proper URI normalization and encoding
- Header sanitization and sorting

## Key Functions/Components

### Public Functions

#### `flb_signv4_uri_normalize_path(char *uri, size_t len)`
Normalizes a URI path according to AWS SigV4 requirements:
1. Removes redundant path segments (e.g., `/./` and `/../`)
2. Ensures proper path formatting
3. Maintains trailing slashes when present in original URI
4. Returns normalized URI as SDS string

#### `flb_signv4_do(struct flb_http_client *c, int normalize_uri, int amz_date, time_t t_now, char *region, char *service, int s3_mode, struct mk_list *unsigned_headers, struct flb_aws_provider *provider)`
Main function to sign an HTTP request using AWS SigV4:
1. Retrieves AWS credentials from the provider
2. Performs all four SigV4 tasks (canonical request, string to sign, calculate signature, add authorization)
3. Returns the Authorization header value

### Internal Functions

#### `flb_signv4_canonical_request()`
Creates the canonical request according to AWS SigV4 specification:
1. Forms HTTP method line
2. Processes and encodes URI path
3. Handles query string parameters
4. Processes POST payload parameters
5. Calculates payload hash
6. Sanitizes and sorts headers
7. Constructs canonical headers section
8. Builds signed headers string
9. Appends payload hash

#### `flb_signv4_string_to_sign()`
Generates the string to sign for the signature calculation:
1. Adds algorithm identifier (AWS4-HMAC-SHA256)
2. Includes timestamp
3. Constructs credential scope
4. Calculates hash of canonical request

#### `flb_signv4_calculate_signature()`
Calculates the cryptographic signature:
1. Derives signing key through HMAC operations
2. Applies HMAC-SHA256 to string to sign
3. Converts result to hexadecimal representation

#### `flb_signv4_add_authorization()`
Adds the Authorization header to the HTTP request:
1. Formats the complete authorization string
2. Adds header to HTTP client
3. Returns header value for verification

### Helper Functions

#### `sha256_to_hex()`
Converts SHA-256 binary digest to hexadecimal string representation

#### `hmac_sha256_sign()`
Performs HMAC-SHA256 signing operation using Fluent Bit's crypto library

#### `kv_key_cmp()`
Comparison function for sorting key-value pairs by key and value

#### `to_encode()` and `to_encode_path()`
Functions to determine if characters need URI encoding

#### `uri_encode()` and `uri_encode_params()`
URI encoding functions following RFC 3986 standards

#### `url_params_format()`
Formats URL parameters according to SigV4 requirements:
1. Parses query string into key-value pairs
2. URI encodes keys and values
3. Sorts parameters by key
4. Formats as canonical query string

#### `headers_sanitize()`
Sanitizes HTTP headers for SigV4:
1. Converts header keys to lowercase
2. Trims whitespace from header values
3. Merges duplicate headers
4. Maintains proper header formatting

## Important Constants and Definitions

### S3 Mode Constants
- `S3_MODE_NONE` (0): Standard mode, not Amazon S3 PutObject
- `S3_MODE_SIGNED_PAYLOAD` (1): Set x-amz-content-sha256 header with SHA value
- `S3_MODE_UNSIGNED_PAYLOAD` (2): Set x-amz-content-sha256 header to "UNSIGNED-PAYLOAD"

### Buffer Sizes
- Pre-allocated buffer sizes for various operations to optimize memory usage
- Conservative sizing to handle typical AWS request sizes

## Dependencies and Relationships

This module depends on:
- `flb_http_client`: HTTP client functionality for request construction
- `flb_aws_credentials`: AWS credentials management
- `flb_sds`: Simple Dynamic String library for string operations
- `flb_hmac`: HMAC cryptographic functions
- `flb_hash`: Hash functions for SHA-256
- `flb_kv`: Key-value pair management
- `flb_utils`: Utility functions for string operations
- Standard C library functions (strftime, etc.)

It integrates with:
- AWS output plugins (CloudWatch, S3, Kinesis, etc.)
- HTTP client for request signing
- Credentials providers for authentication
- Configuration system for region and service settings

## Implementation Details

### SigV4 Signing Process
The implementation follows the four-step AWS SigV4 process:

1. **Create a Canonical Request**: Standardizes the HTTP request
2. **Create a String to Sign**: Prepares the string for signature calculation
3. **Calculate the Signature**: Computes the cryptographic signature
4. **Add the Signature to the Request**: Adds Authorization header

### Memory Management
- Efficient memory allocation with pre-sizing where possible
- Proper cleanup of temporary buffers and structures
- Error handling with graceful resource deallocation
- Use of SDS strings for dynamic string operations

### Security Considerations
- Proper cryptographic implementation using HMAC-SHA256
- Secure handling of AWS credentials
- Prevention of buffer overflows through bounds checking
- Proper URI encoding to prevent injection attacks

### Performance Optimizations
- Minimized memory allocations through pre-sizing
- Efficient string operations using SDS library
- Caching opportunities noted in comments (TODO)
- Optimized sorting algorithms for headers and parameters

### Error Handling
- Comprehensive validation of input parameters
- Graceful degradation on memory allocation failures
- Detailed error logging for debugging
- Consistent return value conventions

## Usage Examples

### Basic SigV4 Signing
```c
// Sign an HTTP request for AWS service
struct flb_http_client *c = flb_http_client_create(host, port);
if (c) {
    // Configure request
    flb_http_client_set_method(c, FLB_HTTP_POST);
    flb_http_client_set_uri(c, "/logs");
    
    // Sign the request
    flb_sds_t auth_header = flb_signv4_do(c, FLB_TRUE, FLB_TRUE, time(NULL),
                                  "us-east-1", "logs", S3_MODE_NONE,
                                  NULL, aws_provider);
    
    if (auth_header) {
        // Request is now signed and ready to send
        flb_http_client_do(c);
        flb_sds_destroy(auth_header);
    }
    
    flb_http_client_destroy(c);
}
```

### URI Normalization
```c
// Normalize a URI path for SigV4
char *original_uri = "/path/./to/../resource/";
size_t uri_len = strlen(original_uri);

flb_sds_t normalized = flb_signv4_uri_normalize_path(original_uri, uri_len);
if (normalized) {
    printf("Normalized URI: %s\n", normalized);
    flb_sds_destroy(normalized);
}
```

### Configuration Example
```ini
[OUTPUT]
    name cloudwatch
    match *
    region us-east-1
    log_group_name fluent-bit-logs
    log_stream_prefix fluent-bit-
    # Uses SigV4 signing for AWS CloudWatch Logs
```

### Integration Pattern
```c
// Typical integration in an AWS output plugin
int aws_output_plugin_flush(struct flb_output_instance *ins,
                           struct flb_config *config,
                           struct flb_input_instance *i_ins,
                           void *out_context,
                           struct flb_time *out_time) {
    
    struct flb_http_client *c;
    flb_sds_t auth_header;
    
    // Create HTTP client
    c = flb_http_client(ins->host, ins->port, ins->uri);
    if (!c) {
        return -1;
    }
    
    // Set request body
    flb_http_client_set_body(c, payload, payload_len);
    
    // Sign the request
    auth_header = flb_signv4_do(c, FLB_TRUE, FLB_TRUE, time(NULL),
                               ins->region, "logs", S3_MODE_NONE,
                               NULL, ins->aws_provider);
    
    if (!auth_header) {
        flb_http_client_destroy(c);
        return -1;
    }
    
    // Send the request
    int ret = flb_http_client_do(c);
    
    // Cleanup
    flb_sds_destroy(auth_header);
    flb_http_client_destroy(c);
    
    return ret;
}
```

### Error Handling Pattern
```c
// Robust SigV4 signing with error handling
flb_sds_t safe_sign_request(struct flb_http_client *c,
                           struct flb_aws_provider *provider) {
    if (!c || !provider) {
        flb_error("Invalid parameters for SigV4 signing");
        return NULL;
    }
    
    // Validate HTTP client state
    if (!c->uri || !c->host) {
        flb_error("HTTP client not properly configured");
        return NULL;
    }
    
    // Perform SigV4 signing
    flb_sds_t auth_header = flb_signv4_do(c, FLB_TRUE, FLB_TRUE,
                                         time(NULL), "us-east-1", "logs",
                                         S3_MODE_NONE, NULL, provider);
    
    if (!auth_header) {
        flb_error("Failed to sign HTTP request with SigV4");
        return NULL;
    }
    
    return auth_header;
}

// Usage
struct flb_http_client *client = flb_http_client_create("logs.us-east-1.amazonaws.com", 443);
if (client) {
    flb_http_client_set_uri(client, "/");
    
    flb_sds_t auth = safe_sign_request(client, aws_provider);
    if (auth) {
        printf("Successfully signed request\n");
        flb_sds_destroy(auth);
    } else {
        printf("Failed to sign request\n");
    }
    
    flb_http_client_destroy(client);
}
```