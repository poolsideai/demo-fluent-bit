# http_server/flb_http_server.c

## Overview

The `flb_http_server.c` file contains the core implementation of Fluent Bit's HTTP server functionality. This file provides a comprehensive HTTP server implementation that supports both HTTP/1.1 and HTTP/2 protocols, along with features like TLS encryption, connection management, and request/response handling.

## Key Functions

### Server Lifecycle Functions

#### `flb_http_server_init`

```c
int flb_http_server_init(struct flb_http_server *session,
                         int protocol_version,
                         uint64_t flags,
                         flb_http_server_request_processor_callback
                             request_callback,
                         char *address,
                         unsigned short int port,
                         struct flb_tls *tls_provider,
                         int networking_flags,
                         struct flb_net_setup *networking_setup,
                         struct mk_event_loop *event_loop,
                         struct flb_config *system_context,
                         void *user_data)
```

Initializes a new HTTP server instance with the specified configuration.

**Parameters:**
- `session`: HTTP server context to initialize
- `protocol_version`: Protocol version to use (HTTP/1.1, HTTP/2, or autodetect)
- `flags`: Server flags for enabling features
- `request_callback`: Callback function for processing requests
- `address`: Network address to bind to
- `port`: Port number to listen on
- `tls_provider`: TLS provider for encrypted connections
- `networking_flags`: Networking configuration flags
- `networking_setup`: Networking setup configuration
- `event_loop`: Event loop for asynchronous operations
- `system_context`: Fluent Bit system context
- `user_data`: User-defined data to associate with the server

**Returns:**
- 0 on success
- Negative value on failure

**Implementation Details:**
1. Initializes server status to `HTTP_SERVER_UNINITIALIZED`
2. Sets protocol version, flags, and callback function
3. Configures network settings (address, port, TLS, etc.)
4. Initializes client list for connection tracking
5. Creates event for listener socket
6. Sets status to `HTTP_SERVER_INITIALIZED`

#### `flb_http_server_start`

```c
int flb_http_server_start(struct flb_http_server *session)
```

Starts the HTTP server to begin accepting connections.

**Parameters:**
- `session`: HTTP server context

**Returns:**
- 0 on success
- Negative value on failure

**Implementation Details:**
1. Configures ALPN for TLS connections if applicable
2. Creates downstream connection for listening
3. Registers listener event with the event loop
4. Sets server status to `HTTP_SERVER_RUNNING`

#### `flb_http_server_stop`

```c
int flb_http_server_stop(struct flb_http_server *server)
```

Stops the HTTP server and closes all connections.

**Parameters:**
- `server`: HTTP server context

**Returns:**
- 0 on success
- Negative value on failure

**Implementation Details:**
1. Removes listener event from event loop
2. Destroys all active client sessions
3. Sets server status to `HTTP_SERVER_STOPPED`

#### `flb_http_server_destroy`

```c
int flb_http_server_destroy(struct flb_http_server *server)
```

Completely destroys the HTTP server and frees all resources.

**Parameters:**
- `server`: HTTP server context

**Returns:**
- 0 on success
- Negative value on failure

**Implementation Details:**
1. Calls `flb_http_server_stop()` to stop the server
2. Destroys the downstream connection
3. Cleans up server resources

### Buffer Management Functions

#### `flb_http_server_set_buffer_max_size`

```c
void flb_http_server_set_buffer_max_size(struct flb_http_server *server,
                                         size_t size)
```

Sets the maximum buffer size for HTTP server sessions.

**Parameters:**
- `server`: HTTP server context
- `size`: Maximum buffer size in bytes

#### `flb_http_server_get_buffer_max_size`

```c
size_t flb_http_server_get_buffer_max_size(struct flb_http_server *server)
```

Gets the current maximum buffer size for HTTP server sessions.

**Parameters:**
- `server`: HTTP server context

**Returns:**
- Current maximum buffer size in bytes

### Session Management Functions

#### `flb_http_server_session_init`

```c
int flb_http_server_session_init(struct flb_http_server_session *session, int version)
```

Initializes an HTTP server session for handling client connections.

**Parameters:**
- `session`: HTTP server session context
- `version`: Protocol version for the session

**Returns:**
- 0 on success
- Negative value on failure

**Implementation Details:**
1. Initializes session memory and data structures
2. Creates incoming and outgoing data buffers
3. Initializes appropriate protocol handler (HTTP/1 or HTTP/2)

#### `flb_http_server_session_create`

```c
struct flb_http_server_session *flb_http_server_session_create(int version)
```

Creates a new HTTP server session with the specified protocol version.

**Parameters:**
- `version`: Protocol version for the session

**Returns:**
- Pointer to new session on success
- NULL on failure

#### `flb_http_server_session_destroy`

```c
void flb_http_server_session_destroy(struct flb_http_server_session *session)
```

Determines an HTTP server session and frees all associated resources.

**Parameters:**
- `session`: HTTP server session context

**Implementation Details:**
1. Releases the underlying network connection
2. Removes session from client list
3. Destroys data buffers
4. Cleans up protocol-specific resources
5. Frees session memory if marked as releasable

#### `flb_http_server_session_ingest`

```c
int flb_http_server_session_ingest(struct flb_http_server_session *session,
                            unsigned char *buffer,
                            size_t length)
```

Processes incoming data for an HTTP server session.

**Parameters:**
- `session`: HTTP server session context
- `buffer`: Incoming data buffer
- `length`: Length of incoming data

**Returns:**
- 0 on success
- Negative value on failure
- `HTTP_SERVER_BUFFER_LIMIT_EXCEEDED` if buffer limit is exceeded

**Implementation Details:**
1. Checks buffer size limits
2. Appends data to incoming buffer
3. Performs protocol version detection if needed
4. Initializes appropriate protocol handler
5. Delegates to protocol-specific ingestion function

### Data Transfer Functions

#### `flb_http_server_session_read`

```c
static int flb_http_server_session_read(struct flb_http_server_session *session)
```

Reads incoming data from a client connection.

**Parameters:**
- `session`: HTTP server session context

**Returns:**
- 0 on success
- Negative value on failure

**Implementation Details:**
1. Reads data from network connection
2. Processes incoming data through `flb_http_server_session_ingest()`
3. Handles buffer overflow by sending 413 response

#### `flb_http_server_session_write`

```c
static int flb_http_server_session_write(struct flb_http_server_session *session)
```

Sends outgoing data to a client connection.

**Parameters:**
- `session`: HTTP server session context

**Returns:**
- 0 on success
- Negative value on failure

**Implementation Details:**
1. Sends data from outgoing buffer
2. Handles partial writes by moving remaining data
3. Updates buffer length accordingly

### Event Handler Functions

#### `flb_http_server_client_activity_event_handler`

```c
static int flb_http_server_client_activity_event_handler(void *data)
```

Handles client activity events (read/write operations).

**Parameters:**
- `data`: Connection context

**Returns:**
- 0 on success
- Negative value on failure

**Implementation Details:**
1. Processes incoming data if readable
2. Processes queued requests
3. Handles compression if enabled
4. Calls request callback for processing
5. Determines connection closure behavior
6. Sends outgoing data
7. Cleans up session if needed

#### `flb_http_server_client_connection_event_handler`

```c
static int flb_http_server_client_connection_event_handler(void *data)
```

Handles new client connection events.

**Parameters:**
- `data`: Server context

**Returns:**
- 0 on success
- Negative value on failure

**Implementation Details:**
1. Accepts new client connection
2. Creates new session for the connection
3. Sets up event handling for the connection
4. Adds session to client list
5. Initializes session write operations

### Connection Management Functions

#### `flb_http_server_should_connection_be_closed`

```c
static int flb_http_server_should_connection_be_closed(
    struct flb_http_request *request)
```

Determines whether an HTTP connection should be closed after a request.

**Parameters:**
- `request`: HTTP request context

**Returns:**
- `FLB_TRUE` if connection should be closed
- `FLB_FALSE` if connection should remain open

**Implementation Details:**
1. Handles HTTP/2 connections (always keep alive)
2. Respects user configuration for keep-alive
3. Implements protocol-specific defaults:
   - HTTP/0.9: Keep-alive is opt-in
   - HTTP/1.0: Keep-alive is opt-in
   - HTTP/1.1: Keep-alive is opt-out
4. Checks Connection header for explicit control

## Data Structures

### `struct flb_http_server`

Main HTTP server context structure that holds all server-wide configuration and state.

**Key Fields:**
- `status`: Current server status
- `protocol_version`: Configured protocol version
- `flags`: Server feature flags
- `request_callback`: Request processing callback
- `address`: Network address to bind to
- `port`: Port number to listen on
- `tls_provider`: TLS configuration
- `downstream`: Network connection for listening
- `clients`: List of active client sessions
- `listener_event`: Event for listener socket
- `buffer_max_size`: Maximum buffer size for sessions

### `struct flb_http_server_session`

Represents a single client connection and its associated state.

**Key Fields:**
- `version`: Protocol version for this session
- `incoming_data`: Buffer for incoming data
- `outgoing_data`: Buffer for outgoing data
- `request_queue`: Queue of pending requests
- `connection`: Underlying network connection
- `http1`: HTTP/1.1 protocol handler
- `http2`: HTTP/2 protocol handler
- `parent`: Reference to parent server

## Protocol Support

The HTTP server supports multiple protocols:

### HTTP/1.1 Support

- Full HTTP/1.1 specification compliance
- Chunked transfer encoding
- Keep-alive connections
- Request pipelining
- Compression support (gzip, deflate)

### HTTP/2 Support

- Full HTTP/2 specification compliance
- Multiplexed connections
- Header compression (HPACK)
- Server push capabilities
- Binary framing layer

### Protocol Autodetection

The server can automatically detect the protocol version based on the initial bytes of the connection:

1. Looks for HTTP/2 magic sequence: `PRI * HTTP/2.0\r\n\r\nSM\r\n\r\n`
2. Falls back to HTTP/1.1 for other connections

## TLS Support

The server supports encrypted connections through TLS:

### ALPN Configuration

When TLS is enabled, the server configures Application-Layer Protocol Negotiation (ALPN) with the following priorities:
1. `h2` (HTTP/2)
2. `http/1.0`
3. `http/1.1`

### TLS Provider Integration

The server integrates with Fluent Bit's TLS infrastructure:

1. Accepts a `struct flb_tls *` provider
2. Configures TLS settings during initialization
3. Uses TLS for encrypted connections

## Event Loop Integration

The HTTP server integrates with Fluent Bit's event loop system:

### Event Types

1. **Listener Events**: Handle new incoming connections
2. **Client Activity Events**: Handle read/write operations on client connections

### Event Registration

1. Registers listener event during server startup
2. Registers client events during connection establishment
3. Properly cleans up events during shutdown

## Connection Management

### Client Session Lifecycle

1. **Creation**: New sessions created for each client connection
2. **Tracking**: Sessions maintained in server's client list
3. **Processing**: Requests processed through event handlers
4. **Cleanup**: Sessions destroyed when connections close

### Keep-Alive Handling

The server implements intelligent keep-alive management:

1. Protocol-specific defaults
2. Header-based overrides
3. Configuration-based overrides
4. Resource cleanup when connections close

## Data Flow

### Incoming Data Flow

1. Client connects to server
2. New session created
3. Data read from connection
4. Data ingested into session
5. Protocol handler processes data
6. Requests queued for processing
7. Callback function processes requests
8. Responses generated and queued
9. Data sent back to client

### Outgoing Data Flow

1. Response data prepared in session buffer
2. Data written to client connection
3. Partial writes handled by moving remaining data
4. Connection closed when appropriate

## Error Handling

The server implements comprehensive error handling:

### Buffer Limits

- Enforces maximum buffer sizes
- Returns `HTTP_SERVER_BUFFER_LIMIT_EXCEEDED` when limits exceeded
- Sends 413 response to clients exceeding limits

### Memory Allocation

- Checks for allocation failures
- Cleans up resources on allocation errors
- Returns appropriate error codes

### Protocol Errors

- Handles malformed requests gracefully
- Sends appropriate HTTP error responses
- Logs errors for debugging

## Performance Features

### Buffer Management

1. Configurable maximum buffer sizes
2. Efficient buffer resizing using SDS
3. Memory pooling for frequent allocations

### Asynchronous I/O

1. Non-blocking network operations
2. Event-driven architecture
3. Efficient resource utilization

### Protocol Optimization

1. HTTP/2 multiplexing reduces connection overhead
2. Header compression reduces bandwidth usage
3. Binary framing improves parsing efficiency

## Security Features

### TLS Encryption

1. Full support for encrypted connections
2. Certificate validation
3. Cipher suite configuration

### Input Validation

1. Buffer size limits prevent DoS attacks
2. Protocol compliance checking
3. Malformed request rejection

### Resource Management

1. Proper cleanup of connections and sessions
2. Memory leak prevention
3. File descriptor management

## Integration with Fluent Bit

### Event Loop Integration

The HTTP server integrates with Fluent Bit's core event loop:

1. Uses `mk_event_loop` for asynchronous operations
2. Registers custom event handlers
3. Complies with Fluent Bit's event handling patterns

### Configuration Integration

The server respects Fluent Bit's configuration system:

1. Reads network settings from configuration
2. Integrates with TLS configuration
3. Follows Fluent Bit's memory management patterns

### Logging Integration

The server uses Fluent Bit's logging infrastructure:

1. Consistent log message formatting
2. Appropriate log levels
3. Context-aware error reporting

## Usage Example

The HTTP server is typically used as follows:

```c
struct flb_http_server server;

// Initialize server
result = flb_http_server_init(&server,
                              HTTP_PROTOCOL_VERSION_AUTODETECT,
                              FLB_HTTP_SERVER_FLAG_AUTO_INFLATE,
                              my_request_callback,
                              "0.0.0.0",
                              2020,
                              tls_provider,
                              0,
                              net_setup,
                              event_loop,
                              config,
                              user_data);

if (result != 0) {
    // Handle initialization error
    return -1;
}

// Start server
result = flb_http_server_start(&server);

if (result != 0) {
    // Handle startup error
    flb_http_server_destroy(&server);
    return -1;
}

// Server is now running and accepting connections

// Later, during shutdown:
result = flb_http_server_stop(&server);
if (result != 0) {
    // Handle shutdown error
}

result = flb_http_server_destroy(&server);
if (result != 0) {
    // Handle destruction error
}
```

## Configuration Options

### Protocol Versions

- `HTTP_PROTOCOL_VERSION_AUTODETECT`: Automatically detect protocol
- `HTTP_PROTOCOL_VERSION_09`: HTTP/0.9
- `HTTP_PROTOCOL_VERSION_10`: HTTP/1.0
- `HTTP_PROTOCOL_VERSION_11`: HTTP/1.1
- `HTTP_PROTOCOL_VERSION_20`: HTTP/2

### Server Flags

- `FLB_HTTP_SERVER_FLAG_AUTO_INFLATE`: Automatically decompress request bodies

### Buffer Sizes

- Default maximum buffer size: `HTTP_SERVER_MAXIMUM_BUFFER_SIZE`
- Initial buffer size: `HTTP_SERVER_INITIAL_BUFFER_SIZE`

## Error Codes

### Standard Return Values

- 0: Success
- -1: General error
- -2: Memory allocation error
- -3: Protocol initialization error
- -4: Session creation error

### Special Error Codes

- `HTTP_SERVER_BUFFER_LIMIT_EXCEEDED`: Buffer size limit exceeded
- `HTTP_SERVER_ALLOCATION_ERROR`: Memory allocation failure

## Thread Safety

The HTTP server implementation is designed to be thread-safe:

1. **Reentrant Functions**: No static or global state
2. **Immutable Parameters**: Functions don't modify input parameters
3. **Event Loop Integration**: Uses Fluent Bit's thread-safe event system
4. **Resource Isolation**: Each connection has isolated resources

## Extensibility

The design allows for easy extension:

1. **New Protocols**: Can add support for additional HTTP versions
2. **Custom Handlers**: Request callback allows custom processing
3. **Feature Flags**: Server flags enable optional features
4. **Buffer Management**: Configurable buffer sizes

## Performance Characteristics

The HTTP server is optimized for high performance:

1. **Asynchronous I/O**: Non-blocking operations
2. **Efficient Memory**: SDS buffers for dynamic sizing
3. **Protocol Optimization**: HTTP/2 multiplexing
4. **Event-Driven**: Minimal CPU usage when idle

## Security Considerations

The implementation includes several security measures:

1. **Buffer Limits**: Prevents resource exhaustion attacks
2. **Input Validation**: Rejects malformed requests
3. **TLS Support**: Encrypts sensitive data
4. **Proper Cleanup**: Prevents resource leaks

## Resource Management

The server carefully manages all resources:

1. **Memory**: Uses Fluent Bit's memory management
2. **File Descriptors**: Properly closes connections
3. **Event Resources**: Cleans up event registrations
4. **Protocol Resources**: Frees protocol-specific data