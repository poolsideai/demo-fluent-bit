# include/fluent-bit/http_server/flb_http_server.h

## Overview

The `flb_http_server.h` file contains the main header definitions for Fluent Bit's HTTP server functionality. This header defines the core data structures, constants, and function prototypes for the HTTP server implementation.

## Header Guards

```c
#ifndef FLB_HTTP_SERVER
#define FLB_HTTP_SERVER

/* ... */

#endif
```

Standard header guards prevent multiple inclusion of the header file.

## Included Dependencies

### Core Fluent Bit Headers

```c
#include <fluent-bit/flb_downstream.h>
#include <fluent-bit/flb_hash_table.h>
#include <fluent-bit/tls/flb_tls.h>
#include <fluent-bit/flb_network.h>
#include <fluent-bit/flb_config.h>
#include <fluent-bit/flb_engine.h>
```

These headers provide essential Fluent Bit functionality for networking, TLS, configuration, and event loop integration.

### External Libraries

```c
#include <monkey/mk_core.h>
#include <cfl/cfl_list.h>
#include <cfl/cfl_sds.h>
```

These headers provide the Monkey HTTP server core and CFL (Common Fluent Library) data structures.

### HTTP Server Components

```c
#include <fluent-bit/flb_http_common.h>
#include <fluent-bit/http_server/flb_http_server_http1.h>
#include <fluent-bit/http_server/flb_http_server_http2.h>
```

These headers provide common HTTP functionality and protocol-specific implementations.

## Constants

### Buffer Sizes

```c
#define HTTP_SERVER_INITIAL_BUFFER_SIZE        (10 * 1024)
#define HTTP_SERVER_MAXIMUM_BUFFER_SIZE        (10 * (1000 * 1024))
```

- `HTTP_SERVER_INITIAL_BUFFER_SIZE`: Initial buffer size for HTTP sessions (10KB)
- `HTTP_SERVER_MAXIMUM_BUFFER_SIZE`: Maximum buffer size for HTTP sessions (10MB)

### Server Flags

```c
#define FLB_HTTP_SERVER_FLAG_KEEPALIVE         (((uint64_t) 1) << 0)
#define FLB_HTTP_SERVER_FLAG_AUTO_DEFLATE      (((uint64_t) 1) << 1)
#define FLB_HTTP_SERVER_FLAG_AUTO_INFLATE      (((uint64_t) 1) << 2)
```

- `FLB_HTTP_SERVER_FLAG_KEEPALIVE`: Enable HTTP keep-alive connections
- `FLB_HTTP_SERVER_FLAG_AUTO_DEFLATE`: Automatically compress outgoing data
- `FLB_HTTP_SERVER_FLAG_AUTO_INFLATE`: Automatically decompress incoming data

### Status Codes

```c
#define HTTP_SERVER_SUCCESS                    0
#define HTTP_SERVER_PROVIDER_ERROR            -1
#define HTTP_SERVER_ALLOCATION_ERROR          -2
#define HTTP_SERVER_BUFFER_LIMIT_EXCEEDED     -3
```

- `HTTP_SERVER_SUCCESS`: Successful operation
- `HTTP_SERVER_PROVIDER_ERROR`: Provider-level error
- `HTTP_SERVER_ALLOCATION_ERROR`: Memory allocation failure
- `HTTP_SERVER_BUFFER_LIMIT_EXCEEDED`: Buffer size limit exceeded

### Server Status

```c
#define HTTP_SERVER_UNINITIALIZED              0
#define HTTP_SERVER_INITIALIZED                1
#define HTTP_SERVER_RUNNING                    2
#define HTTP_SERVER_STOPPED                    3
```

- `HTTP_SERVER_UNINITIALIZED`: Server not yet initialized
- `HTTP_SERVER_INITIALIZED`: Server initialized but not running
- `HTTP_SERVER_RUNNING`: Server actively accepting connections
- `HTTP_SERVER_STOPPED`: Server stopped but not destroyed

## Data Structures

### `struct flb_http_server`

Main HTTP server context structure that holds all server-wide configuration and state.

**Fields:**

```c
struct flb_http_server {
    /* Internal */
    struct mk_event        listener_event;
    char                  *address;
    unsigned short int     port;
    struct flb_tls        *tls_provider;
    int                    networking_flags;
    struct flb_net_setup  *networking_setup;
    struct mk_event_loop  *event_loop;
    struct flb_config     *system_context;
    /* Internal */

    uint64_t               flags;
    int                    status;
    int                    protocol_version;
    struct flb_downstream *downstream;
    struct cfl_list        clients;
    flb_http_server_request_processor_callback
                           request_callback;
    void                  *user_data;
    size_t                 buffer_max_size;
};
```

**Key Fields:**
- `listener_event`: Event for listener socket
- `address`: Network address to bind to
- `port`: Port number to listen on
- `tls_provider`: TLS configuration for encrypted connections
- `flags`: Server feature flags
- `status`: Current server status
- `protocol_version`: Configured protocol version
- `downstream`: Network connection for listening
- `clients`: List of active client sessions
- `request_callback`: Callback function for processing requests
- `user_data`: User-defined data to associate with the server
- `buffer_max_size`: Maximum buffer size for sessions

### `struct flb_http_server_session`

Represents a single client connection and its associated state.

**Fields:**

```c
struct flb_http_server_session {
    struct flb_http1_server_session http1;
    struct flb_http2_server_session http2;

    int                             version;
    struct cfl_list                 request_queue;

    cfl_sds_t                       incoming_data;
    cfl_sds_t                       outgoing_data;

    int                             releasable;

    struct flb_connection          *connection;
    struct flb_http_server         *parent;
    struct cfl_list                 _head;
};
```

**Key Fields:**
- `http1`: HTTP/1.x protocol handler
- `http2`: HTTP/2 protocol handler
- `version`: Protocol version for this session
- `request_queue`: Queue of pending requests
- `incoming_data`: Buffer for incoming data
- `outgoing_data`: Buffer for outgoing data
- `releasable`: Flag indicating if session can be freed
- `connection`: Underlying network connection
- `parent`: Reference to parent HTTP server

## Callback Function Types

### `flb_http_server_request_processor_callback`

```c
typedef int (*flb_http_server_request_processor_callback)(
                struct flb_http_request *request,
                struct flb_http_response *response);
```

Function pointer type for processing HTTP requests.

**Parameters:**
- `request`: HTTP request structure
- `response`: HTTP response structure

**Returns:**
- 0 on success
- Negative value on failure

## Function Prototypes

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
                         void *user_data);
```

Initializes a new HTTP server instance with the specified configuration.

#### `flb_http_server_start`

```c
int flb_http_server_start(struct flb_http_server *session);
```

Starts the HTTP server to begin accepting connections.

#### `flb_http_server_stop`

```c
int flb_http_server_stop(struct flb_http_server *session);
```

Stops the HTTP server and closes all connections.

#### `flb_http_server_destroy`

```c
int flb_http_server_destroy(struct flb_http_server *session);
```

Completely destroys the HTTP server and frees all resources.

### Buffer Management Functions

#### `flb_http_server_set_buffer_max_size`

```c
void flb_http_server_set_buffer_max_size(struct flb_http_server *server, size_t size);
```

Sets the maximum buffer size for HTTP server sessions.

#### `flb_http_server_get_buffer_max_size`

```c
size_t flb_http_server_get_buffer_max_size(struct flb_http_server *server);
```

Gets the current maximum buffer size for HTTP server sessions.

### Session Management Functions

#### `flb_http_server_session_init`

```c
int flb_http_server_session_init(struct flb_http_server_session *session, int version);
```

Initializes an HTTP server session for handling client connections.

#### `flb_http_server_session_create`

```c
struct flb_http_server_session *flb_http_server_session_create(int version);
```

Creates a new HTTP server session with the specified protocol version.

#### `flb_http_server_session_destroy`

```c
void flb_http_server_session_destroy(struct flb_http_server_session *session);
```

Determines an HTTP server session and frees all associated resources.

#### `flb_http_server_session_ingest`

```c
int flb_http_server_session_ingest(struct flb_http_server_session *session,
                            unsigned char *buffer,
                            size_t length);
```

Processes incoming HTTP data for an HTTP server session.

## Dependencies

This header depends on:

1. **Fluent Bit Core**: For memory management, networking, and configuration
2. **Monkey HTTP Server**: For HTTP server core functionality
3. **CFL Library**: For data structures and string handling
4. **TLS Support**: For encrypted connections

## Integration with Fluent Bit

The HTTP server integrates with Fluent Bit's core systems:

1. **Event Loop**: Uses Fluent Bit's event loop for asynchronous operations
2. **Networking**: Integrates with Fluent Bit's networking stack
3. **TLS**: Uses Fluent Bit's TLS infrastructure
4. **Configuration**: Reads settings from Fluent Bit's configuration system
5. **Memory Management**: Uses Fluent Bit's memory allocation functions

## Protocol Support

The HTTP server supports multiple protocols:

### Protocol Versions

- `HTTP_PROTOCOL_VERSION_AUTODETECT`: Automatically detect protocol
- `HTTP_PROTOCOL_VERSION_09`: HTTP/0.9
- `HTTP_PROTOCOL_VERSION_10`: HTTP/1.0
- `HTTP_PROTOCOL_VERSION_11`: HTTP/1.1
- `HTTP_PROTOCOL_VERSION_20`: HTTP/2

### Protocol Implementation

- **HTTP/1.x**: Full HTTP/1.0 and HTTP/1.1 support
- **HTTP/2**: Full HTTP/2 specification compliance
- **Autodetection**: Automatic protocol version detection

## TLS Support

The header defines structures and functions for TLS-enabled connections:

1. **TLS Provider**: `struct flb_tls *tls_provider` for TLS configuration
2. **Certificate Support**: Integration with Fluent Bit's certificate handling
3. **Encrypted Connections**: Support for HTTPS and TLS-enabled HTTP/2

## Error Handling

The header defines standard error codes for HTTP server operations:

1. **Success**: `HTTP_SERVER_SUCCESS` (0)
2. **Provider Errors**: `HTTP_SERVER_PROVIDER_ERROR` (-1)
3. **Allocation Errors**: `HTTP_SERVER_ALLOCATION_ERROR` (-2)
4. **Buffer Limits**: `HTTP_SERVER_BUFFER_LIMIT_EXCEEDED` (-3)

## Thread Safety

The HTTP server implementation is designed to be thread-safe:

1. **Reentrant Functions**: No static or global state
2. **Immutable Parameters**: Functions don't modify input parameters
3. **Session Isolation**: Each connection has isolated resources
4. **Event Loop Integration**: Uses Fluent Bit's thread-safe event system

## Performance Considerations

The HTTP server is optimized for performance:

1. **Asynchronous I/O**: Non-blocking operations
2. **Efficient Memory**: Reuses buffers where possible
3. **Protocol Optimization**: HTTP/2 multiplexing
4. **Event-Driven**: Minimal CPU usage when idle

## Resource Management

The HTTP server carefully manages all resources:

1. **Memory**: Uses Fluent Bit's memory management
2. **File Descriptors**: Proper cleanup of network connections
3. **Event Resources**: Cleans up event registrations
4. **Protocol Resources**: Frees protocol-specific data

## Extensibility

The design allows for easy extension:

1. **New Protocols**: Can add support for additional HTTP versions
2. **Custom Handlers**: Request callback allows custom processing
3. **Feature Flags**: Server flags enable optional features
4. **Buffer Management**: Configurable buffer sizes

## Security Considerations

The HTTP server implementation includes several security features:

1. **Buffer Limits**: Prevents resource exhaustion attacks
2. **Input Validation**: Validates all HTTP input
3. **Resource Limits**: Enforces reasonable size limits
4. **Memory Safety**: Proper cleanup of all resources