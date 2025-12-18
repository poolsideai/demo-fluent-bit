# flb_http_client.c

## Overview

This file implements a simple HTTP client interface for Fluent Bit that provides an easy way to issue HTTP requests and handle responses from input/output plugins. The implementation supports various HTTP methods, handles retries, and manages connection keepalive.

The module serves as a core networking component that enables Fluent Bit plugins to communicate with HTTP servers. It handles request composition, response parsing, chunked transfer encoding, and various authentication mechanisms.

## Key Functions

### `flb_http_client()`
Creates a new HTTP client instance for making requests to a specific URI with optional body data.

### `flb_http_dummy_client()`
Creates a dummy HTTP client for testing purposes without making actual HTTP requests.

### `flb_http_do()`
Performs a complete HTTP request cycle including sending the request and receiving the response.

### `flb_http_do_request()`
Sends an HTTP request without waiting for the complete response, useful for processing chunked responses.

### `flb_http_get_response_data()`
Processes incoming HTTP response data and handles chunked transfer encoding.

### `flb_http_add_header()`
Adds custom HTTP headers to the request.

### `flb_http_basic_auth()`
Sets basic authentication credentials for the request.

### `flb_http_proxy_auth()`
Sets proxy authentication credentials for the request.

### `flb_http_bearer_auth()`
Sets bearer token authentication for the request.

### `flb_http_set_keepalive()`
Enables HTTP keepalive for persistent connections.

### `flb_http_set_content_encoding_*()`
Sets content encoding headers for gzip, zstd, or snappy compression.

### `flb_http_buffer_size()`
Configures the maximum buffer size for HTTP response data.

### `flb_http_strip_port_from_host()`
Removes the port from the Host header for certain proxy configurations.

## Important Variables/Constants

### HTTP Methods
- `FLB_HTTP_GET`: GET method
- `FLB_HTTP_POST`: POST method
- `FLB_HTTP_PUT`: PUT method
- `FLB_HTTP_HEAD`: HEAD method
- `FLB_HTTP_CONNECT`: CONNECT method
- `FLB_HTTP_PATCH`: PATCH method
- `FLB_HTTP_DELETE`: DELETE method

### HTTP Flags
- `FLB_HTTP_10`: HTTP/1.0 protocol
- `FLB_HTTP_11`: HTTP/1.1 protocol
- `FLB_HTTP_KA`: Keep-alive connections

### Proxy Types
- `FLB_HTTP_PROXY_NONE`: No proxy
- `FLB_HTTP_PROXY_HTTP`: HTTP proxy
- `FLB_HTTP_PROXY_HTTPS`: HTTPS proxy

### Return Codes
- `FLB_HTTP_ERROR`: Error occurred
- `FLB_HTTP_MORE`: More data needed
- `FLB_HTTP_OK`: Success
- `FLB_HTTP_NOT_FOUND`: Header not found
- `FLB_HTTP_CHUNK_AVAILABLE`: Chunked data available

### Buffer Sizes
- `FLB_HTTP_BUF_SIZE`: Header buffer size (2048 bytes)
- `FLB_HTTP_DATA_SIZE_MAX`: Maximum response data size (4096 bytes)
- `FLB_HTTP_DATA_CHUNK`: Chunk size for data processing (32768 bytes)

### Key Headers
- `FLB_HTTP_HEADER_AUTH`: Authorization header
- `FLB_HTTP_HEADER_PROXY_AUTH`: Proxy-Authorization header
- `FLB_HTTP_HEADER_CONTENT_TYPE`: Content-Type header
- `FLB_HTTP_HEADER_CONTENT_ENCODING`: Content-Encoding header
- `FLB_HTTP_HEADER_CONNECTION`: Connection header
- `FLB_HTTP_HEADER_KA`: Keep-alive header value

## Dependencies

- `fluent-bit/flb_http_client.h`: Header file defining the interface
- `fluent-bit/flb_io.h`: I/O operations
- `fluent-bit/flb_lock.h`: Thread locking utilities
- `fluent-bit/flb_upstream.h`: Upstream connection management
- `fluent-bit/flb_callback.h`: Callback system
- `fluent-bit/flb_http_common.h`: Common HTTP utilities
- `fluent-bit/flb_http_client_http1.h`: HTTP/1.x client implementation
- `fluent-bit/flb_http_client_http2.h`: HTTP/2 client implementation
- `fluent-bit/flb_kv.h`: Key-value storage
- `fluent-bit/flb_log.h`: Logging utilities
- `fluent-bit/flb_mem.h`: Memory management
- `fluent-bit/flb_utils.h`: General utilities
- `fluent-bit/flb_base64.h`: Base64 encoding
- `fluent-bit/tls/flb_tls.h`: TLS support
- `fluent-bit/flb_signv4_ng.h`: AWS Signature V4

## Implementation Details

1. **HTTP Protocol Support**: Implements both HTTP/1.0 and HTTP/1.1 protocols with full support for chunked transfer encoding.

2. **Connection Management**: Integrates with Fluent Bit's upstream connection system for connection pooling and keepalive.

3. **Authentication**: Supports basic authentication, bearer tokens, and proxy authentication.

4. **Proxy Support**: Handles HTTP and HTTPS proxy configurations with proper CONNECT method support.

5. **Response Handling**: Automatically parses response headers, handles content length, and processes chunked encoding.

6. **Buffer Management**: Dynamic buffer resizing to handle responses larger than initial buffer allocation.

7. **Timeout Handling**: Configurable read idle timeouts and response timeouts.

8. **Testing Support**: Built-in test mode for mocking HTTP responses during development.

9. **Thread Safety**: Uses Fluent Bit's locking mechanisms for thread-safe operations.

## Usage Example

```c
// Create an HTTP client for a POST request
struct flb_connection *u_conn = flb_upstream_conn_get(upstream);
struct flb_http_client *c = flb_http_client(u_conn,
                                            FLB_HTTP_POST, "/api/data",
                                            "Hello World", 11,
                                            "example.com", 80,
                                            NULL, FLB_HTTP_11);

if (c) {
    // Add custom headers
    flb_http_add_header(c, "User-Agent", 10, "Fluent-Bit", 10);
    flb_http_add_header(c, "Content-Type", 12, "text/plain", 10);
    
    // Set basic authentication
    flb_http_basic_auth(c, "username", "password");
    
    // Perform the request
    size_t bytes;
    int ret = flb_http_do(c, &bytes);
    
    if (ret == FLB_HTTP_OK) {
        // Process the response
        printf("Status: %d\n", c->resp.status);
        printf("Response: %.*s\n", 
               (int)c->resp.payload_size, 
               c->resp.payload);
    }
    
    // Clean up
    flb_http_client_destroy(c);
    flb_upstream_conn_release(u_conn);
}
```