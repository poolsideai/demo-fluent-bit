# flb_http_common.c

## Overview

This file contains common HTTP functionality shared between HTTP client and server implementations in Fluent Bit. It provides core structures and utilities for handling HTTP requests, responses, streams, and compression/decompression operations.

The module serves as the foundational layer for both HTTP client and server functionality, implementing shared data structures, utility functions, and compression algorithms used across the HTTP stack.

## Key Functions

### Request Functions

#### `flb_http_request_init()`
Initializes an HTTP request structure with default values and allocates necessary resources.

#### `flb_http_request_create()`
Creates a new HTTP request instance with proper memory allocation.

#### `flb_http_request_destroy()`
Destroys an HTTP request and frees all associated resources.

#### `flb_http_request_commit()`
Commits an HTTP request by delegating to the appropriate protocol implementation (HTTP/1.x or HTTP/2).

#### `flb_http_request_get_header()`
Retrieves a header value from an HTTP request by name.

#### `flb_http_request_set_header()`
Sets or updates a header in an HTTP request.

#### `flb_http_request_unset_header()`
Removes a header from an HTTP request.

#### `flb_http_request_compress_body()`
Compresses the request body using various algorithms (gzip, zlib, zstd, snappy, deflate).

#### `flb_http_request_uncompress_body()`
Decompresses the request body if it was compressed.

#### `flb_http_request_set_method()`
Sets the HTTP method for the request.

#### `flb_http_request_set_host()`
Sets the target host for the request.

#### `flb_http_request_set_port()`
Sets the target port for the request.

#### `flb_http_request_set_url()`
Parses and sets the complete URL for the request.

#### `flb_http_request_set_uri()`
Sets the URI path for the request.

#### `flb_http_request_set_query_string()`
Sets the query string portion of the request.

#### `flb_http_request_set_content_type()`
Sets the Content-Type header for the request.

#### `flb_http_request_set_user_agent()`
Sets the User-Agent header for the request.

#### `flb_http_request_set_content_length()`
Sets the Content-Length header for the request.

#### `flb_http_request_set_content_encoding()`
Sets the Content-Encoding header for the request.

#### `flb_http_request_set_body()`
Sets the request body data.

#### `flb_http_request_perform_signv4_signature()`
Performs AWS Signature Version 4 signing on the request.

### Response Functions

#### `flb_http_response_init()`
Initializes an HTTP response structure with default values.

#### `flb_http_response_create()`
Creates a new HTTP response instance.

#### `flb_http_response_destroy()`
Destroys an HTTP response and frees all associated resources.

#### `flb_http_response_begin()`
Begins an HTTP response by delegating to the appropriate protocol implementation.

#### `flb_http_response_commit()`
Commits an HTTP response by delegating to the appropriate protocol implementation.

#### `flb_http_response_get_header()`
Retrieves a header value from an HTTP response by name.

#### `flb_http_response_set_header()`
Sets or updates a header in an HTTP response.

#### `flb_http_response_unset_header()`
Removes a header from an HTTP response.

#### `flb_http_response_set_trailer_header()`
Sets a trailer header in an HTTP response.

#### `flb_http_response_set_status()`
Sets the HTTP status code for the response.

#### `flb_http_response_set_message()`
Sets the status message for the response.

#### `flb_http_response_set_body()`
Sets the response body data.

#### `flb_http_response_append_to_body()`
Appends data to the existing response body.

#### `flb_http_response_compress_body()`
Compresses the response body using various algorithms.

#### `flb_http_response_uncompress_body()`
Decompresses the response body if it was compressed.

### Stream Functions

#### `flb_http_stream_init()`
Initializes an HTTP stream with request and response structures.

#### `flb_http_stream_create()`
Creates a new HTTP stream instance.

#### `flb_http_stream_destroy()`
Destroys an HTTP stream and frees associated resources.

### Utility Functions

#### `flb_http_get_method_string_from_id()`
Converts an HTTP method ID to its string representation.

#### `flb_http_server_convert_string_to_lowercase()`
Converts a string to lowercase.

#### `flb_http_server_strncasecmp()`
Performs case-insensitive string comparison.

## Important Variables/Constants

### HTTP Methods
- `HTTP_METHOD_GET`: GET method
- `HTTP_METHOD_POST`: POST method
- `HTTP_METHOD_HEAD`: HEAD method
- `HTTP_METHOD_PUT`: PUT method
- `HTTP_METHOD_DELETE`: DELETE method
- `HTTP_METHOD_OPTIONS`: OPTIONS method
- `HTTP_METHOD_CONNECT`: CONNECT method

### Stream Roles
- `HTTP_STREAM_ROLE_SERVER`: Server-side stream
- `HTTP_STREAM_ROLE_CLIENT`: Client-side stream

### Stream Status
- `HTTP_STREAM_STATUS_SENDING_HEADERS`: Sending headers
- `HTTP_STREAM_STATUS_RECEIVING_HEADERS`: Receiving headers
- `HTTP_STREAM_STATUS_RECEIVING_DATA`: Receiving data
- `HTTP_STREAM_STATUS_RECEIVING_TRAILER`: Receiving trailer headers
- `HTTP_STREAM_STATUS_READY`: Stream processing complete
- `HTTP_STREAM_STATUS_CLOSED`: Stream has been closed
- `HTTP_STREAM_STATUS_ERROR`: Error occurred during processing

### Protocol Versions
- `HTTP_PROTOCOL_VERSION_09`: HTTP/0.9
- `HTTP_PROTOCOL_VERSION_10`: HTTP/1.0
- `HTTP_PROTOCOL_VERSION_11`: HTTP/1.1
- `HTTP_PROTOCOL_VERSION_20`: HTTP/2

## Dependencies

- `fluent-bit/flb_mem.h`: Memory management utilities
- `fluent-bit/http_server/flb_http_server.h`: HTTP server functionality
- `fluent-bit/flb_http_common.h`: Header file defining the interface
- `fluent-bit/flb_signv4_ng.h`: AWS Signature Version 4 signing
- `fluent-bit/flb_snappy.h`: Snappy compression support
- `fluent-bit/flb_gzip.h`: GZIP compression support
- `fluent-bit/flb_zstd.h`: Zstandard compression support

## Implementation Details

1. **Request/Response Management**: Provides comprehensive structures and functions for managing HTTP requests and responses with proper memory handling.

2. **Compression Support**: Implements multiple compression algorithms (gzip, zlib, zstd, snappy, deflate) for efficient data transmission.

3. **Header Management**: Robust header handling with case-insensitive lookup and storage.

4. **URL Parsing**: Complete URL parsing functionality that extracts host, port, path, query string, and authentication information.

5. **Stream Abstraction**: Unified stream management that works with both HTTP client and server implementations.

6. **Protocol Agnostic Design**: Abstract interfaces that delegate to protocol-specific implementations (HTTP/1.x vs HTTP/2).

7. **Memory Efficiency**: Uses SDS (Simple Dynamic Strings) for efficient string handling and automatic memory management.

8. **Error Handling**: Comprehensive error detection and reporting throughout all operations.

9. **AWS Integration**: Built-in support for AWS Signature Version 4 signing.

10. **Extensibility**: Modular design that allows easy addition of new compression algorithms or protocol features.

## Usage Example

```c
// Create HTTP request
struct flb_http_request *request = flb_http_request_create();

if (request) {
    // Configure request
    flb_http_request_set_method(request, HTTP_METHOD_POST);
    flb_http_request_set_host(request, "api.example.com");
    flb_http_request_set_url(request, "https://api.example.com/v1/data");
    flb_http_request_set_content_type(request, "application/json");
    
    // Set request body
    const char *json_body = "{\"key\": \"value\"}";
    flb_http_request_set_body(request, (unsigned char *) json_body, strlen(json_body), NULL);
    
    // Add custom headers
    flb_http_request_set_header(request, "X-Custom-Header", 0, "custom-value", 0);
    
    // Commit the request (protocol agnostic)
    int result = flb_http_request_commit(request);
    
    if (result == 0) {
        // Request successfully prepared
        printf("Request prepared successfully\n");
    }
    
    // Clean up
    flb_http_request_destroy(request);
}

// Create HTTP response
struct flb_http_response *response = flb_http_response_create();

if (response) {
    // Configure response
    flb_http_response_set_status(response, 200);
    flb_http_response_set_message(response, "OK");
    flb_http_response_set_content_type(response, "application/json");
    
    // Set response body
    const char *json_response = "{\"status\": \"success\"}";
    flb_http_response_set_body(response, (unsigned char *) json_response, strlen(json_response));
    
    // Commit the response (protocol agnostic)
    int result = flb_http_response_commit(response);
    
    if (result == 0) {
        // Response successfully prepared
        printf("Response prepared successfully\n");
    }
    
    // Clean up
    flb_http_response_destroy(response);
}
```