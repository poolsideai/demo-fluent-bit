# http_server/flb_http_server_http1.c

## Overview

The `flb_http_server_http1.c` file contains the implementation of HTTP/1.x protocol support for Fluent Bit's HTTP server. This file provides the core functionality for parsing and handling HTTP/1.0 and HTTP/1.1 requests, including request parsing, chunked transfer encoding support, and response generation.

## Key Functions

### Session Management Functions

#### `flb_http1_server_session_init`

```c
int flb_http1_server_session_init(struct flb_http1_server_session *session,
                       struct flb_http_server_session *parent)
```

Initializes an HTTP/1.x server session for handling client connections.

**Parameters:**
- `session`: HTTP/1.x server session context
- `parent`: Parent HTTP server session context

**Returns:**
- 0 on success
- Negative value on failure

**Implementation Details:**
1. Initializes session memory and data structures
2. Sets up internal Monkey HTTP session and request structures
3. Initializes HTTP parser for request processing
4. Creates HTTP stream for request/response handling
5. Associates session with parent server session

#### `flb_http1_server_session_destroy`

```c
void flb_http1_server_session_destroy(struct flb_http1_server_session *session)
```
Determines an HTTP/1.x server session and frees all associated resources.

**Parameters:**
- `session`: HTTP/1.x server session context

**Implementation Details:**
1. Releases Monkey HTTP channel resources
2. Destroys HTTP stream resources
3. Resets initialization flag

#### `flb_http1_server_session_ingest`

```c
int flb_http1_server_session_ingest(struct flb_http1_server_session *session,
                                    unsigned char *buffer,
                                    size_t length)
```

Processes incoming HTTP/1.x data for a server session.

**Parameters:**
- `session`: HTTP/1.x server session context
- `buffer`: Incoming data buffer
- `length`: Length of incoming data

**Returns:**
- `HTTP_SERVER_SUCCESS` on success
- `HTTP_SERVER_PROVIDER_ERROR` on failure
- `MK_HTTP_PARSER_PENDING` when more data is needed

**Implementation Details:**
1. Parses incoming HTTP data using Monkey HTTP parser
2. Processes complete requests through `http1_session_process_request()`
3. Handles incomplete requests by waiting for more data
4. Evicts processed requests from the buffer
5. Resets parser state for subsequent requests

### Request Processing Functions

#### `http1_session_process_request`

```c
static int http1_session_process_request(struct flb_http1_server_session *session)
```

Processes a complete HTTP/1.x request and prepares it for handling.

**Parameters:**
- `session`: HTTP/1.x server session context

**Returns:**
- 0 on success
- Negative value on failure

**Implementation Details:**
1. Initializes HTTP request structure
2. Extracts request path from URI
3. Maps Monkey HTTP methods to Fluent Bit methods
4. Maps Monkey HTTP protocol versions to Fluent Bit versions
5. Processes request headers and stores them in the request
6. Handles chunked transfer encoding for request bodies
7. Queues the request for processing by the main HTTP server

#### `http1_evict_request`

```c
static int http1_evict_request(struct flb_http1_server_session *session)
```

Removes processed HTTP request data from the session buffer.

**Parameters:**
- `session`: HTTP/1.x server session context

**Returns:**
- 0 on success
- Negative value on failure

**Implementation Details:**
1. Calculates the size of the processed request
2. Moves remaining data to the beginning of the buffer
3. Updates buffer length accordingly

### Response Generation Functions

#### `flb_http1_response_begin`

```c
struct flb_http_response *flb_http1_response_begin(
                                struct flb_http1_server_session *session,
                                struct flb_http_stream *stream)
```

Begins creating an HTTP/1.x response for a request.

**Parameters:**
- `session`: HTTP/1.x server session context
- `stream`: HTTP stream context

**Returns:**
- Pointer to HTTP response structure on success
- NULL on failure

**Implementation Details:**
1. Initializes HTTP response structure
2. Associates response with the stream

#### `flb_http1_response_commit`

```c
int flb_http1_response_commit(struct flb_http_response *response)
```

Commits an HTTP/1.x response by serializing it to the outgoing buffer.

**Parameters:**
- `response`: HTTP response context

**Returns:**
- 0 on success
- Negative value on failure

**Implementation Details:**
1. Creates response buffer with appropriate size
2. Formats HTTP status line
3. Serializes response headers
4. Appends response body if present
5. Adds final CRLF terminator
6. Appends response to session's outgoing buffer

#### `flb_http1_response_set_header`

```c
int flb_http1_response_set_header(struct flb_http_response *response,
                              char *name, size_t name_length,
                              char *value, size_t value_length)
```

Sets an HTTP header in an HTTP/1.x response.

**Parameters:**
- `response`: HTTP response context
- `name`: Header name
- `name_length`: Length of header name
- `value`: Header value
- `value_length`: Length of header value

**Returns:**
- 0 on success
- Negative value on failure

#### `flb_http1_response_set_status`

```c
int flb_http1_response_set_status(struct flb_http_response *response,
                              int status)
```

Sets the HTTP status code for an HTTP/1.x response.

**Parameters:**
- `response`: HTTP response context
- `status`: HTTP status code

**Returns:**
- 0 (always succeeds)

#### `flb_http1_response_set_body`

```c
int flb_http1_response_set_body(struct flb_http_response *response,
                            unsigned char *body, size_t body_length)
```

Sets the body content for an HTTP/1.x response.

**Parameters:**
- `response`: HTTP response context
- `body`: Response body data
- `body_length`: Length of response body

**Returns:**
- 0 (always succeeds)

### Helper Functions

#### `dummy_mk_http_session_init`

```c
static void dummy_mk_http_session_init(struct mk_http_session *session,
                                       struct mk_server *server)
```

Initializes a Monkey HTTP session structure with default values.

#### `dummy_mk_http_request_init`

```c
static void dummy_mk_http_request_init(struct mk_http_session *session,
                                       struct mk_http_request *request)
```

Initializes a Monkey HTTP request structure with default values.

## Data Structures

### `struct flb_http1_server_session`

Represents an HTTP/1.x server session for handling client connections.

**Key Fields:**
- `initialized`: Flag indicating if session is initialized
- `inner_session`: Monkey HTTP session structure
- `inner_request`: Monkey HTTP request structure
- `inner_parser`: Monkey HTTP parser structure
- `stream`: HTTP stream for request/response handling
- `parent`: Reference to parent HTTP server session

## Protocol Features

### HTTP/1.0 Support

- Basic HTTP/1.0 request parsing
- Simple request/response cycle
- No persistent connections by default

### HTTP/1.1 Support

- Full HTTP/1.1 specification compliance
- Persistent connections (keep-alive)
- Chunked transfer encoding
- Request pipelining
- Compression support

### Chunked Transfer Encoding

The implementation supports chunked transfer encoding:

1. Detects chunked requests through Transfer-Encoding header
2. Decodes chunked data using Monkey HTTP parser
3. Assembles complete request body from chunks
4. Validates chunk integrity

## Error Handling

The implementation implements comprehensive error handling:

### Parser Errors

- Handles incomplete requests gracefully
- Resets parser state between requests
- Reports parsing errors to parent session

### Memory Allocation

- Checks for allocation failures
- Cleans up resources on allocation errors
- Returns appropriate error codes

### Buffer Management

- Validates request sizes
- Handles buffer overflow conditions
- Properly manages buffer resizing

## Integration with HTTP Server

The HTTP/1.x implementation integrates with the main HTTP server as follows:

1. **Session Creation**: Called during HTTP server session initialization
2. **Data Ingestion**: Processes incoming data through the main server
3. **Request Processing**: Converts Monkey HTTP requests to Fluent Bit requests
4. **Response Generation**: Serializes Fluent Bit responses to HTTP/1.x format
5. **Resource Cleanup**: Properly cleans up resources during session destruction

## Performance Features

### Buffer Management

1. Efficient buffer reuse for requests
2. Minimal memory allocations
3. Safe buffer resizing operations

### Parser Optimization

1. Direct integration with Monkey HTTP parser
2. Efficient request parsing
3. Minimal overhead for common operations

### Response Serialization

1. Optimized response formatting
2. Efficient header serialization
3. Streamlined body transmission

## Security Features

### Input Validation

1. Validates HTTP method and protocol versions
2. Sanitizes header values
3. Validates request sizes

### Buffer Safety

1. Bounds checking for all buffer operations
2. Safe memory movement operations
3. Proper cleanup of temporary buffers

## Thread Safety

The HTTP/1.x implementation is designed to be thread-safe:

1. **Reentrant Functions**: No static or global state
2. **Immutable Parameters**: Functions don't modify input parameters
3. **Session Isolation**: Each connection has isolated resources
4. **Event Loop Integration**: Uses Fluent Bit's thread-safe event system

## Protocol Compliance

The implementation follows HTTP/1.x specifications:

### RFC 2616 (HTTP/1.1)

- Proper status line formatting
- Correct header field syntax
- Valid chunked encoding format
- Appropriate connection management

### RFC 7230-7235 (HTTP/1.1 - Updated)

- Modern header handling
- Updated transfer coding rules
- Improved connection semantics

## Usage Example

The HTTP/1.x functionality is used internally by the HTTP server:

```c
// During session initialization
result = flb_http1_server_session_init(&session->http1, session);

// During data ingestion
result = flb_http1_server_session_ingest(&session->http1, buffer, length);

// During response generation
response = flb_http1_response_begin(&session->http1, &stream);

if (response != NULL) {
    flb_http1_response_set_status(response, 200);
    flb_http1_response_set_header(response, "Content-Type", 12, "text/plain", 10);
    flb_http1_response_set_body(response, body_data, body_length);
    flb_http1_response_commit(response);
}

// During session cleanup
flb_http1_server_session_destroy(&session->http1);
```

## Configuration Options

The HTTP/1.x implementation respects the following configuration:

### Protocol Versions

- `HTTP_PROTOCOL_VERSION_09`: HTTP/0.9 support
- `HTTP_PROTOCOL_VERSION_10`: HTTP/1.0 support
- `HTTP_PROTOCOL_VERSION_11`: HTTP/1.1 support

### Buffer Sizes

- Uses parent session buffer configuration
- Respects maximum buffer size limits

## Error Codes

### Standard Return Values

- 0: Success
- Negative values: Various error conditions
- `HTTP_SERVER_SUCCESS`: Successful operation
- `HTTP_SERVER_PROVIDER_ERROR`: Provider-level error

### Parser Status Codes

- `MK_HTTP_PARSER_OK`: Complete request parsed
- `MK_HTTP_PARSER_PENDING`: More data needed

## Extensibility

The design allows for easy extension:

1. **New HTTP Methods**: Can add support for additional methods
2. **Custom Headers**: Easy to add custom header processing
3. **Protocol Extensions**: Can extend with new HTTP features
4. **Performance Tuning**: Configurable buffer sizes and limits

## Performance Characteristics

The HTTP/1.x implementation is optimized for high performance:

1. **Minimal Allocations**: Reuses buffers where possible
2. **Efficient Parsing**: Direct integration with optimized parser
3. **Streamlined Responses**: Fast response serialization
4. **Event-Driven**: Non-blocking operations

## Security Considerations

The implementation includes several security measures:

1. **Input Validation**: Validates all HTTP input
2. **Buffer Bounds**: Prevents buffer overflows
3. **Resource Limits**: Enforces reasonable size limits
4. **Memory Safety**: Proper cleanup of all resources

## Resource Management

The HTTP/1.x implementation carefully manages all resources:

1. **Memory**: Uses Fluent Bit's memory management
2. **Buffers**: Properly manages buffer lifecycles
3. **Parser State**: Resets parser between requests
4. **Session Cleanup**: Thorough resource cleanup