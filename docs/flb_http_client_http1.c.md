# flb_http_client_http1.c

## Overview

This file implements the HTTP/1.x client functionality for Fluent Bit, providing low-level support for HTTP/1.0 and HTTP/1.1 protocol versions. It handles request composition, response parsing, chunked transfer encoding, and various HTTP protocol features specific to the HTTP/1.x family.

The module serves as the HTTP/1.x implementation layer within Fluent Bit's HTTP client architecture, working alongside the main HTTP client and HTTP/2 implementations to provide comprehensive HTTP protocol support.

## Key Functions

### `flb_http1_client_session_init()`
Initializes an HTTP/1.x client session for handling HTTP requests and responses.

### `flb_http1_client_session_destroy()`
Destroys an HTTP/1.x client session and frees associated resources.

### `flb_http1_client_session_ingest()`
Processes incoming HTTP response data and handles protocol-specific parsing.

### `flb_http1_request_begin()`
Begins preparation of an HTTP/1.x request.

### `flb_http1_request_commit()`
Commits and sends an HTTP/1.x request with proper header composition.

### `flb_http1_client_session_process_headers()`
Parses HTTP response headers according to HTTP/1.x specifications.

### `flb_http1_client_session_process_data()`
Processes HTTP response body data, handling both regular and chunked transfer encoding.

## Important Variables/Constants

### Protocol Versions
- `HTTP_PROTOCOL_VERSION_09`: HTTP/0.9 protocol
- `HTTP_PROTOCOL_VERSION_10`: HTTP/1.0 protocol
- `HTTP_PROTOCOL_VERSION_11`: HTTP/1.1 protocol

### Session Structure
- `struct flb_http1_client_session`: Contains session state and references to parent HTTP client session

### Stream Status
- `HTTP_STREAM_STATUS_RECEIVING_HEADERS`: Currently receiving response headers
- `HTTP_STREAM_STATUS_RECEIVING_DATA`: Currently receiving response body data
- `HTTP_STREAM_STATUS_READY`: Response processing complete
- `HTTP_STREAM_STATUS_ERROR`: Error occurred during processing

## Dependencies

- `fluent-bit/flb_http_client_http1.h`: Header file defining the interface
- `fluent-bit/flb_info.h`: Core Fluent Bit information
- `fluent-bit/flb_kv.h`: Key-value storage
- `fluent-bit/flb_log.h`: Logging utilities
- `fluent-bit/flb_mem.h`: Memory management
- `fluent-bit/flb_http_common.h`: Common HTTP utilities
- `fluent-bit/flb_http_client.h`: Main HTTP client interface
- `fluent-bit/flb_http_client_debug.h`: HTTP debugging support
- `fluent-bit/flb_utils.h`: General utilities
- `fluent-bit/flb_base64.h`: Base64 encoding
- `fluent-bit/tls/flb_tls.h`: TLS support

## Implementation Details

1. **Protocol Version Support**: Implements full support for HTTP/0.9, HTTP/1.0, and HTTP/1.1 protocols.

2. **Header Parsing**: Robust parsing of HTTP response headers with proper handling of case-insensitive header names.

3. **Chunked Transfer Encoding**: Complete implementation of chunked transfer encoding as defined in HTTP/1.1 specification.

4. **Content Length Handling**: Proper handling of Content-Length headers for fixed-size response bodies.

5. **Request Composition**: Builds complete HTTP/1.x requests including request line, headers, and body data.

6. **Response Processing**: Parses HTTP status lines, headers, and body data with appropriate state management.

7. **Memory Management**: Efficient buffer management for both incoming and outgoing HTTP data.

8. **Error Handling**: Comprehensive error detection and reporting for malformed HTTP responses.

9. **Integration**: Seamlessly integrates with Fluent Bit's HTTP client architecture through session-based design.

## Usage Example

```c
// Create HTTP client session
struct flb_http_client_session *session = flb_http_client_session_create(
    client, HTTP_PROTOCOL_VERSION_11, connection);

if (session) {
    // Begin HTTP request
    struct flb_http_request *request = flb_http_client_request_begin(session);
    
    if (request) {
        // Configure request parameters
        flb_http_request_set_method(request, HTTP_METHOD_POST);
        flb_http_request_set_path(request, "/api/endpoint");
        flb_http_request_set_host(request, "example.com");
        flb_http_request_set_content_type(request, "application/json");
        
        // Add custom headers
        flb_http_request_set_header(request, "Authorization", "Bearer token123");
        
        // Set request body
        cfl_sds_t body = cfl_sds_create("{ \"key\": \"value\" }");
        flb_http_request_set_body(request, body);
        
        // Commit the request (HTTP/1.x specific)
        int result = flb_http1_request_commit(request);
        
        if (result == 0) {
            // Send request data
            size_t bytes_written;
            flb_connection_write(connection, 
                               session->outgoing_data,
                               cfl_sds_len(session->outgoing_data),
                               &bytes_written);
            
            // Process response data as it arrives
            unsigned char response_buffer[1024];
            size_t bytes_read;
            while (flb_connection_read(connection, response_buffer, sizeof(response_buffer), &bytes_read) > 0) {
                // Ingest response data (HTTP/1.x specific)
                flb_http1_client_session_ingest(&session->http1, response_buffer, bytes_read);
                
                // Check if response is complete
                if (session->http1.parent->streams.first->response.stream->status == HTTP_STREAM_STATUS_READY) {
                    break;
                }
            }
            
            // Access response data
            struct flb_http_response *response = &session->http1.parent->streams.first->response;
            printf("Status: %d\n", response->status);
            printf("Body: %.*s\n", 
                   (int)cfl_sds_len(response->body),
                   response->body);
        }
        
        // Clean up
        flb_http_client_request_destroy(request, FLB_FALSE);
    }
    
    flb_http_client_session_destroy(session);
}
```