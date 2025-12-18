# flb_http_client_http2.c

## Overview

This file implements the HTTP/2 client functionality for Fluent Bit using the nghttp2 library. It provides low-level support for HTTP/2 protocol features including multiplexing, header compression, and binary protocol framing.

The module serves as the HTTP/2 implementation layer within Fluent Bit's HTTP client architecture, working alongside the main HTTP client and HTTP/1.x implementations to provide comprehensive HTTP protocol support.

## Key Functions

### `flb_http2_client_session_init()`
Initializes an HTTP/2 client session using the nghttp2 library for handling HTTP/2 requests and responses.

### `flb_http2_client_session_destroy()`
Destroys an HTTP/2 client session and frees associated resources including the nghttp2 session.

### `flb_http2_client_session_ingest()`
Processes incoming HTTP/2 response data by feeding it to the nghttp2 library for protocol parsing.

### `flb_http2_request_begin()`
Begins preparation of an HTTP/2 request.

### `flb_http2_request_commit()`
Commits and sends an HTTP/2 request by converting Fluent Bit request format to nghttp2 format.

### Callback Functions

#### `http2_send_callback()`
Handles outgoing HTTP/2 data by appending it to the session's outgoing buffer.

#### `http2_header_callback()`
Processes incoming HTTP/2 headers and populates the response structure.

#### `http2_frame_recv_callback()`
Handles received HTTP/2 frames and updates stream status accordingly.

#### `http2_stream_close_callback()`
Handles stream closure events and updates stream status.

#### `http2_begin_headers_callback()`
Handles the beginning of header frames.

#### `http2_data_chunk_recv_callback()`
Processes incoming HTTP/2 data chunks and appends them to the response body.

#### `http2_data_source_read_callback()`
Provides HTTP/2 request body data to the nghttp2 library for transmission.

## Important Variables/Constants

### Session Structure
- `struct flb_http2_client_session`: Contains the nghttp2 session pointer and references to parent HTTP client session

### Stream Status
- `HTTP_STREAM_STATUS_PROCESSING`: Stream is being processed
- `HTTP_STREAM_STATUS_RECEIVING_HEADERS`: Currently receiving response headers
- `HTTP_STREAM_STATUS_RECEIVING_DATA`: Currently receiving response body data
- `HTTP_STREAM_STATUS_RECEIVING_TRAILER`: Currently receiving trailer headers
- `HTTP_STREAM_STATUS_READY`: Response processing complete
- `HTTP_STREAM_STATUS_CLOSED`: Stream has been closed
- `HTTP_STREAM_STATUS_ERROR`: Error occurred during processing

## Dependencies

- `fluent-bit/flb_http_client_http2.h`: Header file defining the interface
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
- `nghttp2/nghttp2.h`: HTTP/2 library

## Implementation Details

1. **Protocol Implementation**: Full HTTP/2 protocol implementation using the nghttp2 C library.

2. **Multiplexing Support**: Handles multiple concurrent streams over a single connection.

3. **Header Compression**: Implements HPACK header compression as defined in HTTP/2 specification.

4. **Binary Framing**: Processes HTTP/2 binary frame format with proper parsing and serialization.

5. **Flow Control**: Implements HTTP/2 flow control mechanisms for efficient data transmission.

6. **Request Composition**: Converts Fluent Bit request format to nghttp2 format with proper pseudo-header handling.

7. **Response Processing**: Parses HTTP/2 responses and populates Fluent Bit response structures.

8. **Error Handling**: Comprehensive error detection and reporting for malformed HTTP/2 frames.

9. **Memory Management**: Efficient buffer management for both incoming and outgoing HTTP/2 data.

10. **Integration**: Seamlessly integrates with Fluent Bit's HTTP client architecture through session-based design.

## Usage Example

```c
// Create HTTP client session
struct flb_http_client_session *session = flb_http_client_session_create(
    client, HTTP_PROTOCOL_VERSION_2, connection);

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
        
        // Commit the request (HTTP/2 specific)
        int result = flb_http2_request_commit(request);
        
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
                // Ingest response data (HTTP/2 specific)
                flb_http2_client_session_ingest(&session->http2, response_buffer, bytes_read);
                
                // Check if response is complete
                if (session->http2.parent->streams.first->response.stream->status == HTTP_STREAM_STATUS_READY) {
                    break;
                }
            }
            
            // Access response data
            struct flb_http_response *response = &session->http2.parent->streams.first->response;
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