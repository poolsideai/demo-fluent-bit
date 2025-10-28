# flb_aws_util.c

## Overview

This file provides utility functions for AWS integration in Fluent Bit. It includes functionality for endpoint generation, file operations, HTTP client management, error parsing, and S3 key formatting.

## Key Functions

### Endpoint Management

- `flb_aws_endpoint()`: Generates AWS service endpoints with proper region and domain formatting
- `removeProtocol()`: Removes protocol prefixes from endpoint URLs

### File Operations

- `flb_read_file()`: Reads file contents into a buffer

### HTTP Client Utilities

- `flb_aws_client_request()`: Makes HTTP requests with AWS authentication
- `flb_aws_client_request_basic_auth()`: Makes HTTP requests with basic authentication headers
- `request_do()`: Core HTTP request implementation with signature handling
- `flb_aws_client_create()`: Creates a new AWS HTTP client
- `flb_aws_client_destroy()`: Destroys an AWS HTTP client and cleans up resources
- `flb_aws_client_generator()`: Returns a client generator for creating AWS clients

### Error Handling

- `flb_aws_is_auth_error()`: Detects authentication-related errors in HTTP responses
- `flb_aws_print_xml_error()`: Prints XML error responses from AWS APIs
- `flb_aws_xml_error()`: Extracts error codes from XML responses
- `flb_aws_xml_get_val()`: Extracts values from XML tags
- `flb_aws_print_error()`: Prints JSON error responses from AWS APIs
- `flb_aws_print_error_code()`: Prints error codes from JSON responses
- `flb_aws_error()`: Extracts error types from JSON responses
- `flb_json_get_val()`: Extracts values from JSON responses using jsmn parser

### String Utilities

- `replace_uri_tokens()`: Replaces tokens in strings with replacement values
- `strtok_concurrent()`: Cross-platform concurrent-safe string tokenizer

### S3 Key Formatting

- `flb_get_s3_blob_key()`: Generates S3 object keys for blob storage
- `flb_get_s3_key()`: Generates S3 object keys with timestamp formatting

### Time Formatting

- `flb_aws_strftime_precision()`: Extended strftime with millisecond/nanosecond support

## Important Constants

### Endpoint Constants
- `AWS_SERVICE_ENDPOINT_FORMAT`: "%s.%s.amazonaws.com" - Format for AWS service endpoints
- `AWS_SERVICE_ENDPOINT_BASE_LEN`: 15 - Base length for endpoint strings

### Tag Constants
- `TAG_PART_DESCRIPTOR`: "$TAG[%d]" - Format for tag part descriptors
- `TAG_DESCRIPTOR`: "$TAG" - Descriptor for entire tag
- `MAX_TAG_PARTS`: 10 - Maximum number of tag parts
- `S3_KEY_SIZE`: 1024 - Maximum S3 key size

### Special String Constants
- `RANDOM_STRING`: "$UUID" - Placeholder for random strings
- `INDEX_STRING`: "$INDEX" - Placeholder for index values

### User Agent Constants
- `AWS_USER_AGENT_NONE`: "none" - No special user agent
- `AWS_USER_AGENT_ECS`: "ecs" - ECS user agent
- `AWS_USER_AGENT_K8S`: "k8s" - Kubernetes user agent
- `AWS_ECS_METADATA_URI`: "ECS_CONTAINER_METADATA_URI_V4" - ECS metadata URI environment variable

### Time Formatting Constants
- `FLB_AWS_MILLISECOND_FORMATTER_LENGTH`: 3 - Length of millisecond formatter
- `FLB_AWS_NANOSECOND_FORMATTER_LENGTH`: 9 - Length of nanosecond formatter
- `FLB_AWS_MILLISECOND_FORMATTER`: "%3N" - Millisecond format specifier
- `FLB_AWS_NANOSECOND_FORMATTER_N`: "%9N" - Nanosecond format specifier (N)
- `FLB_AWS_NANOSECOND_FORMATTER_L`: "%L" - Nanosecond format specifier (L)

### Platform-Specific User Agent
- `FLB_AWS_BASE_USER_AGENT`: Base user agent string
- `FLB_AWS_BASE_USER_AGENT_FORMAT`: Format for extended user agent
- `FLB_AWS_BASE_USER_AGENT_LEN`: Length of base user agent

## Data Structures

### `struct flb_aws_client`
Represents an AWS HTTP client with:
- Client virtual table (`client_vtable`)
- Retry flag (`retry_requests`)
- Debug mode flag (`debug_only`)
- Upstream connection (`upstream`)
- Host and port information (`host`, `port`)
- Proxy settings (`proxy`)
- HTTP flags (`flags`)
- Region and service identifiers (`region`, `service`)
- S3 mode settings (`s3_mode`)
- Authentication flag (`has_auth`)
- Provider reference (`provider`)
- Refresh limit (`refresh_limit`)
- Extra user agent (`extra_user_agent`)

### `struct flb_aws_client_vtable`
Virtual table for AWS client operations with:
- Request function pointer (`request`)

### `struct flb_aws_client_generator`
Generator structure for creating AWS clients with:
- Create function pointer (`create`)

### `struct flb_aws_header`
Header structure for HTTP requests with:
- Header key (`key`)
- Header key length (`key_len`)
- Header value (`val`)
- Header value length (`val_len`)

## Dependencies

- `<fluent-bit/flb_info.h>`: General information and utilities
- `<fluent-bit/flb_sds.h>`: String data structures
- `<fluent-bit/flb_http_client.h>`: HTTP client functionality
- `<fluent-bit/flb_signv4.h>`: AWS Signature Version 4 functionality
- `<fluent-bit/flb_aws_util.h>`: Header file for this module
- `<fluent-bit/flb_aws_credentials.h>`: Core AWS credentials functionality
- `<fluent-bit/flb_output_plugin.h>`: Output plugin functionality
- `<fluent-bit/flb_jsmn.h>`: JSON parsing (jsmn)
- `<fluent-bit/flb_env.h>`: Environment variable functions
- `<stdlib.h>`: Standard library functions
- `<sys/types.h>`: System type definitions
- `<sys/stat.h>`: File status functions
- `<fcntl.h>`: File control functions

## Implementation Details

### Endpoint Generation

The `flb_aws_endpoint()` function generates proper AWS service endpoints:
- Handles China regions by appending ".cn" to the domain
- Uses the standard format: `{service}.{region}.amazonaws.com`
- Properly allocates and formats endpoint strings

### HTTP Client Management

The AWS client implementation provides:
- Automatic retry logic for failed requests
- Authentication error detection and credential refresh
- Proper signature generation using AWS Signature Version 4
- User agent customization based on environment
- Support for both basic authentication and AWS signature authentication

### Error Parsing

Comprehensive error handling for AWS APIs:
- XML error parsing for services like STS
- JSON error parsing for most modern AWS services
- Authentication error detection for automatic credential refresh
- Detailed error reporting with codes and messages

### S3 Key Formatting

Advanced S3 key generation with:
- Tag-based key components ($TAG, $TAG[n])
- Random string generation ($UUID)
- Index-based components ($INDEX)
- Timestamp formatting with strftime extensions
- Proper delimiter handling and validation

### Cross-Platform Compatibility

- Uses `strtok_concurrent()` for thread-safe string tokenization
- Platform-specific user agent strings
- Proper memory management with SDS strings

## Usage Example

```c
// Create an AWS client
struct flb_aws_client *aws_client = flb_aws_client_create();
aws_client->region = "us-east-1";
aws_client->service = "s3";
aws_client->has_auth = FLB_TRUE;
aws_client->provider = my_aws_provider;

// Make an authenticated request
struct flb_http_client *http_client = flb_aws_client_request(
    aws_client,
    FLB_HTTP_GET,
    "/my-bucket/my-object",
    NULL, 0,
    NULL, 0
);

if (http_client && http_client->resp.status == 200) {
    printf("Response: %.*s\n", (int)http_client->resp.payload_size, 
           http_client->resp.payload);
}

// Clean up
flb_http_client_destroy(http_client);
flb_aws_client_destroy(aws_client);

// Generate an S3 key with timestamp formatting
time_t now = time(NULL);
char *tag = "my-tag";
char *delimiter = ".";
uint64_t index = 123;

flb_sds_t s3_key = flb_get_s3_key(
    "logs/$TAG/$UUID.json",
    now,
    tag,
    delimiter,
    index
);

if (s3_key) {
    printf("Generated S3 key: %s\n", s3_key);
    flb_sds_destroy(s3_key);
}
```