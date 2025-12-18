# flb_signv4_ng.c and flb_signv4_ng.h Documentation

## Overview

The `flb_signv4_ng` module implements the next-generation AWS Signature Version 4 (SigV4) authentication for HTTP requests. This implementation is designed to work with the newer HTTP request infrastructure in Fluent Bit and follows the official AWS SigV4 specification.

## Key Functions

### flb_signv4_ng_do()

```c
flb_sds_t flb_signv4_ng_do(struct flb_http_request *request,
                              int normalize_uri,
                              int amz_date,
                              time_t t_now,
                              char *region, char *service,
                              int s3_mode,
                              struct mk_list *unsigned_headers,
                              struct flb_aws_provider *provider);
```

Performs AWS Signature Version 4 signing of an HTTP request using the next-generation API.

**Parameters:**
- `request`: HTTP request context (newer API)
- `normalize_uri`: Flag to enable URI normalization
- `amz_date`: Flag to include x-amz-date header
- `t_now`: Current timestamp
- `region`: AWS region
- `service`: AWS service name
- `s3_mode`: S3-specific mode (S3_MODE_NONE, S3_MODE_SIGNED_PAYLOAD, or S3_MODE_UNSIGNED_PAYLOAD)
- `unsigned_headers`: List of headers to exclude from signing
- `provider`: AWS credentials provider

**Returns:**
- Authorization header value as SDS string
- `NULL` on error

## Implementation Details

The next-generation AWS SigV4 implementation follows the same four-step process as the original implementation but is adapted to work with the newer HTTP request infrastructure:

### Task 1: Create a Canonical Request

Constructs a canonical request by:
- Including the HTTP method
- Normalizing and encoding the URI path
- Formatting query string parameters
- Preparing canonical headers from the request's header hash table
- Calculating payload hash

### Task 2: Create a String to Sign

Generates the string to sign by:
- Including the algorithm identifier (AWS4-HMAC-SHA256)
- Adding the request date
- Specifying the credential scope
- Hashing the canonical request

### Task 3: Calculate the Signature

Computes the signature using HMAC-SHA256 with the derived signing key:
- Derives the key date from the secret key and date
- Derives the key region from the key date and region
- Derives the key service from the key region and service
- Derives the signing key from the key service
- Calculates the final signature

### Task 4: Add the Signature to the Request

Constructs the Authorization header by:
- Including the credential information
- Listing the signed headers
- Adding the calculated signature

## S3 Mode Options

The implementation supports three S3-specific modes:

- `S3_MODE_NONE` (0): Standard mode, no special S3 handling
- `S3_MODE_SIGNED_PAYLOAD` (1): Sets x-amz-content-sha256 header with the SHA256 hash of the payload
- `S3_MODE_UNSIGNED_PAYLOAD` (2): Sets x-amz-content-sha256 header with "UNSIGNED-PAYLOAD"

## Differences from flb_signv4

The next-generation implementation differs from the original in several key ways:

1. **HTTP Request Interface**: Uses `struct flb_http_request` instead of `struct flb_http_client`
2. **Header Management**: Works with the new header hash table implementation
3. **Body Handling**: Uses the newer body management APIs
4. **Header Sanitization**: Implements a new sanitization function for the new header structure

## Security Considerations

The implementation handles sensitive data securely:
- Uses proper memory management for credentials
- Implements constant-time comparisons where appropriate
- Follows AWS security best practices
- Properly sanitizes and encodes data

## Usage Example

```c
#include <fluent-bit/flb_signv4_ng.h>
#include <fluent-bit/flb_http_client.h>
#include <fluent-bit/flb_aws_credentials.h>

// Initialize HTTP request
struct flb_http_request *request = flb_http_request_create();

// Set request properties
flb_http_request_set_uri(request, "/path/to/resource");
flb_http_request_set_method(request, HTTP_METHOD_GET);

// Set up AWS credentials provider
struct flb_aws_provider *provider = flb_aws_provider_create_static(
    access_key_id, secret_access_key, session_token);

// Perform SigV4 signing
flb_sds_t auth_header = flb_signv4_ng_do(
    request, FLB_TRUE, FLB_TRUE, time(NULL),
    "us-east-1", "s3", S3_MODE_NONE, NULL, provider);

if (auth_header != NULL) {
    // Request is now signed and ready to send
    // Process the request...
    
    // Clean up
    flb_sds_destroy(auth_header);
    flb_http_request_destroy(request);
} else {
    // Signing failed
    flb_error("Failed to sign AWS request");
    flb_http_request_destroy(request);
}
```