# flb_signv4_ng.c

## Overview

The `flb_signv4_ng.c` file implements the Next Generation (NG) AWS Signature Version 4 (SigV4) signing functionality for Fluent Bit. This module provides an updated implementation of AWS SigV4 signing that works with the newer HTTP request structure (`flb_http_request`) rather than the legacy HTTP client structure.

This implementation is designed to work with the modern Fluent Bit HTTP stack and provides the same AWS SigV4 signing capabilities as the original `flb_signv4.c` but with improved integration with the newer HTTP infrastructure. It follows the official AWS SigV4 specification for authenticating HTTP requests to AWS services.

Key features:
- Updated AWS SigV4 signing implementation for modern HTTP requests
- Support for different AWS services and regions
- Handling of various payload modes (signed, unsigned)
- Integration with AWS credentials providers
- Proper URI normalization and encoding
- Header sanitization and sorting
- Compatibility with the newer Fluent Bit HTTP infrastructure

## Key Functions/Components

### Public Functions

#### `flb_signv4_ng_do(struct flb_http_request *request, int normalize_uri, int amz_date, time_t t_now, char *region, char *service, int s3_mode, struct mk_list *unsigned_headers, struct flb_aws_provider *provider)`
Main function to sign an HTTP request using AWS SigV4 with the new HTTP request structure:
1. Retrieves AWS credentials from the provider
2. Performs all four SigV4 tasks (canonical request, string to sign, calculate signature, add authorization)
3. Returns the Authorization header value

### Internal Functions

#### `flb_signv4_ng_canonical_request()`
Creates the canonical request according to AWS SigV4 specification for new HTTP requests:
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
Generates the string to sign for the signature calculation (shared with legacy implementation):
1. Adds algorithm identifier (AWS4-HMAC-SHA256)
2. Includes timestamp
3. Constructs credential scope
4. Calculates hash of canonical request

#### `flb_signv4_calculate_signature()`
Calculates the cryptographic signature (shared with legacy implementation):
1. Derives signing key through HMAC operations
2. Applies HMAC-SHA256 to string to sign
3. Converts result to hexadecimal representation

#### `flb_signv4_add_authorization()`
Adds the Authorization header to the HTTP request (shared with legacy implementation):
1. Formats the complete authorization string
2. Adds header to HTTP request
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

#### `headers_sanitize_ng()`
Sanitizes HTTP headers for SigV4 with new HTTP request structure:
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
- `flb_http_request`: Modern HTTP request structure
- `flb_aws_credentials`: AWS credentials management
- `flb_sds`: Simple Dynamic String library for string operations
- `flb_hmac`: HMAC cryptographic functions
- `flb_hash`: Hash functions for SHA-256
- `flb_kv`: Key-value pair management
- `flb_utils`: Utility functions for string operations
- Standard C library functions (strftime, etc.)

It integrates with:
- Modern AWS output plugins
- HTTP request infrastructure for request signing
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

### Basic SigV4 Signing with New HTTP Request
```c
// Sign an HTTP request for AWS service using new HTTP infrastructure
struct flb_http_request *request = flb_http_request_new();
if (request) {
    // Configure request
    flb_http_request_set_method(request, FLB_HTTP_POST);
    flb_http_request_set_path(request, "/logs");
    
    // Set request body
    flb_http_request_set_body(request, payload, payload_len);
    
    // Sign the request
    flb_sds_t auth_header = flb_signv4_ng_do(request, FLB_TRUE, FLB_TRUE, time(NULL),
                                          "us-east-1", "logs", S3_MODE_NONE,
                                          NULL, aws_provider);
    
    if (auth_header) {
        // Request is now signed and ready to send
        // Send the request using new HTTP infrastructure
        flb_sds_destroy(auth_header);
    }
    
    flb_http_request_destroy(request);
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
    # Uses SigV4 NG signing for AWS CloudWatch Logs with modern HTTP stack
```

### Integration Pattern
```c
// Typical integration in a modern AWS output plugin
int aws_output_plugin_flush(struct flb_output_instance *ins,
                           struct flb_config *config,
                           struct flb_input_instance *i_ins,
                           void *out_context,
                           struct flb_time *out_time) {
    
    struct flb_http_request *request;
    flb_sds_t auth_header;
    
    // Create HTTP request using new infrastructure
    request = flb_http_request_new();
    if (!request) {
        return -1;
    }
    
    // Configure request
    flb_http_request_set_method(request, FLB_HTTP_POST);
    flb_http_request_set_path(request, ins->uri);
    flb_http_request_set_body(request, payload, payload_len);
    
    // Sign the request
    auth_header = flb_signv4_ng_do(request, FLB_TRUE, FLB_TRUE,
                                  time(NULL), ins->region, "logs",
                                  S3_MODE_NONE, NULL, ins->aws_provider);
    
    if (!auth_header) {
        flb_http_request_destroy(request);
        return -1;
    }
    
    // Send the request using new HTTP infrastructure
    int ret = flb_http_request_do(request);
    
    // Cleanup
    flb_sds_destroy(auth_header);
    flb_http_request_destroy(request);
    
    return ret;
}
```

### Error Handling Pattern
```c
// Robust SigV4 NG signing with error handling
flb_sds_t safe_sign_request_ng(struct flb_http_request *request,
                              struct flb_aws_provider *provider) {
    if (!request || !provider) {
        flb_error("Invalid parameters for SigV4 NG signing");
        return NULL;
    }
    
    // Validate HTTP request state
    if (!request->path) {
        flb_error("HTTP request not properly configured");
        return NULL;
    }
    
    // Perform SigV4 NG signing
    flb_sds_t auth_header = flb_signv4_ng_do(request, FLB_TRUE, FLB_TRUE,
                                           time(NULL), "us-east-1", "logs",
                                           S3_MODE_NONE, NULL, provider);
    
    if (!auth_header) {
        flb_error("Failed to sign HTTP request with SigV4 NG");
        return NULL;
    }
    
    return auth_header;
}

// Usage
struct flb_http_request *request = flb_http_request_new();
if (request) {
    flb_http_request_set_path(request, "/");
    
    flb_sds_t auth = safe_sign_request_ng(request, aws_provider);
    if (auth) {
        printf("Successfully signed request with SigV4 NG\n");
        flb_sds_destroy(auth);
    } else {
        printf("Failed to sign request with SigV4 NG\n");
    }
    
    flb_http_request_destroy(request);
}
```