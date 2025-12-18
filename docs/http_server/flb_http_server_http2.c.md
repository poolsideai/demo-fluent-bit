# http_server/flb_http_server_http2.c

## Overview

The `flb_http_server_http2.c` file contains the implementation of HTTP/2 protocol support for Fluent Bit's HTTP server. This file provides the core functionality for parsing and handling HTTP/2 requests using the nghttp2 library, including binary framing, header compression (HPACK), and multiplexed connections.

## Key Functions

### Session Management Functions

#### `flb_http2_server_session_init`

```c
int flb_http2_server_session_init(struct flb_http2_server_session *session, 
                       struct flb_http_server_session *parent)
```

Initializes an HTTP/2 server session for handling client connections.

**Parameters:**
- `session`: HTTP/2 server session context
- `parent`: Parent HTTP server session context

**Returns:**
- 0 on success
- Negative value on failure

**Implementation Details:**
1. Initializes session memory and data structures
2. Sets up nghttp2 session callbacks
3. Creates nghttp2 session for HTTP/2 protocol handling
4. Configures session settings (max concurrent streams)
5. Sends initial settings frame to client
6. Associates session with parent server session

#### `flb_http2_server_session_destroy`

```c
void flb_http2_server_session_destroy(struct flb_http2_server_session *session)
```
Determines an HTTP/2 server session and frees all associated resources.

**Parameters:**
- `session`: HTTP/2 server session context

**Implementation Details:**
1. Destroys all active HTTP streams
2. Cleans up nghttp2 session resources
3. Resets initialization flag

#### `flb_http2_server_session_ingest`

```c
int flb_http2_server_session_ingest(struct flb_http2_server_session *session, 
                         unsigned char *buffer, 
                         size_t length)
```

Processes incoming HTTP/2 data for a server session.

**Parameters:**
- `session`: HTTP/2 server session context
- `buffer`: Incoming data buffer
- `length`: Length of incoming data

**Returns:**
- `HTTP_SERVER_SUCCESS` on success
- `HTTP_SERVER_PROVIDER_ERROR` on failure

**Implementation Details:**
1. Processes incoming HTTP/2 frames using nghttp2
2. Sends any pending responses back to client
3. Handles protocol errors gracefully

### Response Generation Functions

#### `flb_http2_response_begin`

```c
struct flb_http_response *flb_http2_response_begin(
                                struct flb_http2_server_session *session, 
                                struct flb_http_stream *stream)
```

Begins creating an HTTP/2 response for a request.

**Parameters:**
- `session`: HTTP/2 server session context
- `stream`: HTTP stream context

**Returns:**
- Pointer to HTTP response structure on success
- NULL on failure

**Implementation Details:**
1. Initializes HTTP response structure
2. Associates response with the stream

#### `flb_http2_response_commit`

```c
int flb_http2_response_commit(struct flb_http_response *response)
```

Commits an HTTP/2 response by serializing it using nghttp2.

**Parameters:**
- `response`: HTTP response context

**Returns:**
- 0 on success
- Negative value on failure

**Implementation Details:**
1. Prepares response headers for nghttp2 submission
2. Includes status header (`:status`)
3. Serializes all headers using nghttp2 format
4. Prepares data provider for response body
5. Submits response to nghttp2 session
6. Sends trailers if present
7. Sends the response frames to client

#### `flb_http2_response_set_header`

```c
int flb_http2_response_set_header(struct flb_http_response *response, 
                              char *name, size_t name_length,
                              char *value, size_t value_length)
```

Sets an HTTP header in an HTTP/2 response.

**Parameters:**
- `response`: HTTP response context
- `name`: Header name
- `name_length`: Length of header name
- `value`: Header value
- `value_length`: Length of header value

**Returns:**
- 0 on success
- Negative value on failure

#### `flb_http2_response_set_status`

```c
int flb_http2_response_set_status(struct flb_http_response *response, 
                              int status)
```

Sets the HTTP status code for an HTTP/2 response.

**Parameters:**
- `response`: HTTP response context
- `status`: HTTP status code

**Returns:**
- 0 (always succeeds)

#### `flb_http2_response_set_body`

```c
int flb_http2_response_set_body(struct flb_http_response *response, 
                            unsigned char *body, size_t body_length)
```

Sets the body content for an HTTP/2 response.

**Parameters:**
- `response`: HTTP response context
- `body`: Response body data
- `body_length`: Length of response body

**Returns:**
- 0 (always succeeds)

### Callback Functions

#### `http2_send_callback`

```c
static ssize_t http2_send_callback(nghttp2_session *inner_session, 
                                   const uint8_t *data,
                                   size_t length, 
                                   int flags, 
                                   void *user_data)
```

nghttp2 callback for sending HTTP/2 data to the client.

**Parameters:**
- `inner_session`: nghttp2 session
- `data`: Data to send
- `length`: Length of data
- `flags`: Send flags
- `user_data`: User data (HTTP/2 session)

**Returns:**
- Length of data sent on success
- `NGHTTP2_ERR_CALLBACK_FAILURE` on failure

**Implementation Details:**
1. Appends data to session's outgoing buffer
2. Updates buffer length

#### `http2_header_callback`

```c
static int http2_header_callback(nghttp2_session *inner_session,
                                 const nghttp2_frame *frame, 
                                 const uint8_t *name,
                                 size_t name_length, 
                                 const uint8_t *value,
                                 size_t value_length, 
                                 uint8_t flags, 
                                 void *user_data)
```

nghttp2 callback for processing HTTP/2 headers.

**Parameters:**
- `inner_session`: nghttp2 session
- `frame`: HTTP/2 frame
- `name`: Header name
- `name_length`: Length of header name
- `value`: Header value
- `value_length`: Length of header value
- `flags`: Header flags
- `user_data`: User data

**Returns:**
- 0 on success
- Negative value on failure

**Implementation Details:**
1. Maps pseudo-headers (`:method`, `:path`, `:authority`) to request fields
2. Handles `content-type` and `content-length` headers
3. Stores all headers in the request structure

#### `http2_frame_recv_callback`

```c
static int http2_frame_recv_callback(nghttp2_session *inner_session,
                                     const nghttp2_frame *frame, 
                                     void *user_data)
```

nghttp2 callback for processing received HTTP/2 frames.

**Parameters:**
- `inner_session`: nghttp2 session
- `frame`: Received HTTP/2 frame
- `user_data`: User data

**Returns:**
- 0 on success
- Negative value on failure

**Implementation Details:**
1. Updates stream status based on frame type
2. Queues complete requests for processing when END_STREAM flag is received

#### `http2_stream_close_callback`

```c
static int http2_stream_close_callback(nghttp2_session *session, 
                                       int32_t stream_id,
                                       uint32_t error_code, 
                                       void *user_data)
```

nghttp2 callback for handling stream closure.

**Parameters:**
- `session`: nghttp2 session
- `stream_id`: Stream identifier
- `error_code`: Error code
- `user_data`: User data

**Returns:**
- 0 on success
- Negative value on failure

**Implementation Details:**
1. Updates stream status to CLOSED

#### `http2_begin_headers_callback`

```c
static int http2_begin_headers_callback(nghttp2_session *inner_session,
                                        const nghttp2_frame *frame,
                                        void *inner_user_data)
```

nghttp2 callback for beginning header processing.

**Parameters:**
- `inner_session`: nghttp2 session
- `frame`: HTTP/2 frame
- `inner_user_data`: User data

**Returns:**
- 0 on success
- Negative value on failure

**Implementation Details:**
1. Creates new HTTP stream for incoming requests
2. Sets stream protocol version to HTTP/2
3. Associates stream with nghttp2 session

#### `http2_data_chunk_recv_callback`

```c
static int http2_data_chunk_recv_callback(nghttp2_session *inner_session, 
                                          uint8_t flags, 
                                          int32_t stream_id, 
                                          const uint8_t *data, 
                                          size_t len, 
                                          void *user_data)
```

nghttp2 callback for receiving data chunks.

**Parameters:**
- `inner_session`: nghttp2 session
- `flags`: Data flags
- `stream_id`: Stream identifier
- `data`: Data chunk
- `len`: Length of data chunk
- `user_data`: User data

**Returns:**
- 0 on success
- Negative value on failure

**Implementation Details:**
1. Appends data chunks to request body
2. Manages body buffer resizing
3. Updates stream status
4. Queues complete requests when all data is received

#### `http2_data_source_read_callback`

```c
static ssize_t http2_data_source_read_callback(nghttp2_session *session, 
                                               int32_t stream_id, 
                                               uint8_t *buf, 
                                               size_t length, 
                                               uint32_t *data_flags, 
                                               nghttp2_data_source *source, 
                                               void *user_data)
```

nghttp2 callback for reading response data.

**Parameters:**
- `session`: nghttp2 session
- `stream_id`: Stream identifier
- `buf`: Buffer to fill with data
- `length`: Maximum length to read
- `data_flags`: Data flags
- `source`: Data source
- `user_data`: User data

**Returns:**
- Number of bytes read on success
- `NGHTTP2_ERR_CALLBACK_FAILURE` on failure

**Implementation Details:**
1. Reads response body data in chunks
2. Sets appropriate data flags (EOF, NO_END_STREAM)

## Data Structures

### `struct flb_http2_server_session`

Represents an HTTP/2 server session for handling client connections.

**Key Fields:**
- `parent`: Reference to parent HTTP server session
- `initialized`: Flag indicating if session is initialized
- `inner_session`: nghttp2 session for HTTP/2 protocol handling
- `streams`: List of active HTTP streams

## Protocol Features

### HTTP/2 Support

- Full HTTP/2 specification compliance
- Binary framing layer
- Header compression (HPACK)
- Multiplexed connections
- Server push capabilities
- Flow control

### nghttp2 Integration

The implementation uses the nghttp2 library for HTTP/2 protocol handling:

1. **Session Management**: Creates and manages nghttp2 sessions
2. **Frame Processing**: Handles HTTP/2 frame parsing and generation
3. **Callback System**: Implements nghttp2 callbacks for protocol events
4. **Stream Management**: Manages multiple concurrent streams

### Header Compression (HPACK)

The implementation leverages nghttp2's HPACK support:

1. Automatic header compression for outgoing responses
2. Decompression of incoming request headers
3. Header table management

### Multiplexed Connections

HTTP/2 supports multiple concurrent streams over a single connection:

1. Each stream handles one request/response cycle
2. Streams can be processed concurrently
3. Independent flow control per stream
4. Stream prioritization support

## Error Handling

The implementation implements comprehensive error handling:

### Protocol Errors

- Handles HTTP/2 protocol violations gracefully
- Reports errors through nghttp2 error codes
- Cleans up resources on protocol errors

### Memory Allocation

- Checks for allocation failures
- Cleans up resources on allocation errors
- Returns appropriate error codes

### Stream Management

- Properly cleans up stream resources
- Handles stream closure events
- Manages stream lifecycle

## Integration with HTTP Server

The HTTP/2 implementation integrates with the main HTTP server as follows:

1. **Session Creation**: Called during HTTP server session initialization
2. **Data Ingestion**: Processes incoming data through the main server
3. **Request Processing**: Converts nghttp2 requests to Fluent Bit requests
4. **Response Generation**: Serializes Fluent Bit responses to HTTP/2 format
5. **Resource Cleanup**: Properly cleans up resources during session destruction

## Performance Features

### Binary Framing

1. Efficient binary protocol reduces parsing overhead
2. Pre-defined frame types optimize processing
3. Header compression reduces bandwidth usage

### Multiplexing

1. Multiple requests over single connection reduce latency
2. Eliminates head-of-line blocking
3. Better resource utilization

### Callback System

1. Asynchronous event handling
2. Minimal CPU usage when idle
3. Efficient resource management

## Security Features

### Protocol Security

1. Full HTTP/2 specification compliance
2. Proper error handling prevents protocol attacks
3. Resource limits prevent DoS attacks

### nghttp2 Security

1. Uses battle-tested nghttp2 library
2. Automatic security updates through library
3. Proper input validation

## Thread Safety

The HTTP/2 implementation is designed to be thread-safe:

1. **Reentrant Functions**: No static or global state
2. **Immutable Parameters**: Functions don't modify input parameters
3. **Session Isolation**: Each connection has isolated resources
4. **Event Loop Integration**: Uses Fluent Bit's thread-safe event system

## Protocol Compliance

The implementation follows HTTP/2 specifications:

### RFC 7540 (HTTP/2)

- Proper frame format and handling
- Correct HPACK implementation
- Valid stream management
- Appropriate connection management

### RFC 7230-7235 (HTTP/1.1 - Updated)

- Compatibility with HTTP/1.x semantics
- Proper mapping of HTTP/1.x concepts to HTTP/2

## Usage Example

The HTTP/2 functionality is used internally by the HTTP server:

```c
// During session initialization
result = flb_http2_server_session_init(&session->http2, session);

// During data ingestion
result = flb_http2_server_session_ingest(&session->http2, buffer, length);

// During response generation
response = flb_http2_response_begin(&session->http2, &stream);

if (response != NULL) {
    flb_http2_response_set_status(response, 200);
    flb_http2_response_set_header(response, "content-type", 12, "text/plain", 10);
    flb_http2_response_set_body(response, body_data, body_length);
    flb_http2_response_commit(response);
}

// During session cleanup
flb_http2_server_session_destroy(&session->http2);
```

## Configuration Options

The HTTP/2 implementation respects the following configuration:

### Protocol Version

- `HTTP_PROTOCOL_VERSION_20`: HTTP/2 support

### Session Settings

- Maximum concurrent streams: 1 (configurable)
- Buffer sizes: Uses parent session configuration

## Error Codes

### Standard Return Values

- 0: Success
- Negative values: Various error conditions
- `HTTP_SERVER_SUCCESS`: Successful operation
- `HTTP_SERVER_PROVIDER_ERROR`: Provider-level error

### nghttp2 Error Codes

- `NGHTTP2_ERR_CALLBACK_FAILURE`: Callback failure
- Various protocol error codes

## Extensibility

The design allows for easy extension:

1. **New Frame Types**: Can add support for additional HTTP/2 frames
2. **Custom Headers**: Easy to add custom header processing
3. **Protocol Extensions**: Can extend with new HTTP/2 features
4. **Performance Tuning**: Configurable session settings

## Performance Characteristics

The HTTP/2 implementation is optimized for high performance:

1. **Binary Protocol**: Efficient binary framing reduces parsing overhead
2. **Header Compression**: HPACK reduces bandwidth usage
3. **Multiplexing**: Multiple requests over single connection
4. **Asynchronous I/O**: Non-blocking operations

## Security Considerations

The implementation includes several security measures:

1. **Input Validation**: Validates all HTTP/2 input
2. **Buffer Bounds**: Prevents buffer overflows
3. **Resource Limits**: Enforces reasonable size limits
4. **Memory Safety**: Proper cleanup of all resources

## Resource Management

The HTTP/2 implementation carefully manages all resources:

1. **Memory**: Uses Fluent Bit's memory management
2. **Buffers**: Properly manages buffer lifecycles
3. **Streams**: Manages stream lifecycle
4. **Sessions**: Thorough session cleanup