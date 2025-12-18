# nghttp2-1.65.0 Documentation

## Overview

nghttp2 is an implementation of the Hypertext Transfer Protocol version 2 (HTTP/2) in C. It provides a reusable C library for the HTTP/2 framing layer, along with implementations of an HTTP/2 client, server, and proxy. The library also includes load testing and benchmarking tools for HTTP/2.

The library supports:
- HTTP/2 framing layer implementation
- HTTP/2 client, server, and proxy functionality
- HPACK encoder and decoder for header compression
- HTTP/3 support through integration with ngtcp2 and nghttp3
- TLS support with various SSL/TLS libraries (OpenSSL, wolfSSL, LibreSSL, etc.)

## Key Methods/Functions

### Session Management
- `nghttp2_session_new()`: Creates a new HTTP/2 session
- `nghttp2_session_del()`: Deletes an HTTP/2 session
- `nghttp2_session_send()`: Sends pending frames
- `nghttp2_session_recv()`: Processes incoming frames
- `nghttp2_session_terminate_session()`: Terminates the session

### Stream Operations
- `nghttp2_submit_request()`: Submits an HTTP request
- `nghttp2_submit_response()`: Submits an HTTP response
- `nghttp2_submit_headers()`: Submits headers with optional data
- `nghttp2_submit_data()`: Submits data for a stream
- `nghttp2_submit_rst_stream()`: Sends a RST_STREAM frame

### Settings and Configuration
- `nghttp2_option_new()`: Creates a new option object
- `nghttp2_option_set_*()`: Various option setters for configuring behavior
- `nghttp2_submit_settings()`: Sends SETTINGS frame

### Callback Functions
- `nghttp2_on_data_chunk_recv_callback`: Called when a chunk of DATA frame is received
- `nghttp2_on_stream_close_callback`: Called when a stream is closed
- `nghttp2_on_header_callback`: Called when a header name/value pair is received
- `nghttp2_on_frame_recv_callback`: Called when a frame is received
- `nghttp2_on_frame_send_callback`: Called when a frame is sent

### Priority and Dependency
- `nghttp2_priority_spec_new()`: Initializes a priority specification
- `nghttp2_submit_priority()`: Submits PRIORITY frame
- `nghttp2_submit_dependency()`: Submits dependency for a stream

## Important Usage Notes

### Initialization
```c
nghttp2_session *session;
nghttp2_session_callbacks *callbacks;

nghttp2_session_callbacks_new(&callbacks);
// Set up callbacks...
nghttp2_session_client_new(&session, callbacks, user_data);
```

### Error Handling
The library uses error codes in the range [-999, -500]. Common error codes include:
- `NGHTTP2_ERR_INVALID_ARGUMENT`: Invalid argument passed
- `NGHTTP2_ERR_BUFFER_ERROR`: Out of buffer space
- `NGHTTP2_ERR_PROTO`: General protocol error
- `NGHTTP2_ERR_STREAM_CLOSED`: Stream is already closed

### Memory Management
The library provides reference counted buffer management:
- `nghttp2_rcbuf_incref()`: Increments reference count
- `nghttp2_rcbuf_decref()`: Decrements reference count
- `nghttp2_rcbuf_get_buf()`: Gets underlying buffer

### Flow Control
HTTP/2 implements flow control at both connection and stream levels:
- `NGHTTP2_INITIAL_WINDOW_SIZE`: Initial stream window size (64KB)
- `NGHTTP2_INITIAL_CONNECTION_WINDOW_SIZE`: Initial connection window size (64KB)
- `nghttp2_submit_window_update()`: Sends WINDOW_UPDATE frame

## Examples

### Simple Client
```c
#include <nghttp2/nghttp2.h>

int main() {
    nghttp2_session *session;
    nghttp2_session_callbacks *callbacks;
    
    // Initialize callbacks
    nghttp2_session_callbacks_new(&callbacks);
    nghttp2_session_client_new(&session, callbacks, NULL);
    
    // Submit request
    nghttp2_nv hdrs[] = {
        MAKE_NV(":method", "GET"),
        MAKE_NV(":path", "/"),
        MAKE_NV(":scheme", "https"),
        MAKE_NV(":authority", "example.com")
    };
    
    nghttp2_submit_request(session, NULL, hdrs, 4, NULL, NULL);
    
    // Send data
    nghttp2_session_send(session);
    
    // Cleanup
    nghttp2_session_del(session);
    nghttp2_session_callbacks_del(callbacks);
    
    return 0;
}
```

For more detailed examples and documentation, refer to the official nghttp2 documentation at https://nghttp2.org/documentation/