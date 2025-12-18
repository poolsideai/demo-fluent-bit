# src/flb_io.c

## Overview

The `flb_io.c` file implements Fluent Bit's network I/O interface, providing a unified abstraction layer for network operations including TCP/UDP connections, TLS encryption, and asynchronous I/O. This module serves as the core networking foundation for Fluent Bit's output plugins and other components that need to communicate over the network.

## Included Headers

```c
#include <stdio.h>
#include <stdlib.h>
#include <limits.h>
#include <assert.h>
#include <monkey/mk_core.h>
#include <fluent-bit/flb_info.h>
#include <fluent-bit/flb_config.h>
#include <fluent-bit/flb_io.h>
#include <fluent-bit/tls/flb_tls.h>
#include <fluent-bit/flb_socket.h>
#include <fluent-bit/flb_upstream.h>
#include <fluent-bit/flb_downstream.h>
#include <fluent-bit/flb_utils.h>
#include <fluent-bit/flb_macros.h>
#include <fluent-bit/flb_network.h>
#include <fluent-bit/flb_engine.h>
#include <fluent-bit/flb_coro.h>
#include <fluent-bit/flb_http_client.h>
```

These headers provide essential Fluent Bit functionality and system interfaces:
- Standard C library headers for basic operations
- `mk_core.h`: Monkey core event loop and utilities
- `flb_info.h`: Basic types and version information
- `flb_config.h`: Configuration system
- `flb_io.h`: I/O interface definitions
- `flb_tls.h`: TLS/SSL support
- `flb_socket.h`: Socket utilities
- `flb_upstream.h`: Upstream connection management
- `flb_downstream.h`: Downstream connection management
- `flb_utils.h`: Utility functions
- `flb_macros.h`: Platform-specific macros
- `flb_network.h`: Network utilities
- `flb_engine.h`: Core engine functionality
- `flb_coro.h`: Coroutine support
- `flb_http_client.h`: HTTP client functionality

## Constants

### Coroutine Status

```c
#define FLB_IO_CONNECT     0  /* thread issue a connection request */
#define FLB_IO_WRITE       1  /* thread wants to write() data      */
```

Status codes for coroutine operations.

### Network Operation Modes

```c
#define FLB_IO_TCP         1  /* use plain TCP                          */
#define FLB_IO_TLS         2  /* use TLS/SSL layer                      */
#define FLB_IO_OPT_TLS     4  /* use TCP and optional TLS               */
#define FLB_IO_ASYNC       8  /* use async mode (depends on event loop) */
#define FLB_IO_TCP_KA     16  /* use async mode (depends on event loop) */
```

Bit flags for network operation modes.

### Other Features

```c
#define FLB_IO_IPV6       32  /* network I/O uses IPv6                  */
```

Feature flags for network operations.

## Helper Functions

### `net_io_propagate_critical_error`

```c
static void net_io_propagate_critical_error(struct flb_connection *connection)
```

Propagates critical network errors to the connection context.

### `fd_io_write`

```c
static int fd_io_write(int fd, struct sockaddr_storage *address,
                       const void *data, size_t len, size_t *out_len)
```

Writes data to a file descriptor, handling both TCP and UDP connections.

### `net_io_write`

```c
static int net_io_write(struct flb_connection *connection,
                        const void *data, size_t len, size_t *out_len)
```

Performs network write operations for a connection.

### `net_io_backup_event`

```c
static FLB_INLINE void net_io_backup_event(struct flb_connection *connection,
                                           struct mk_event *backup)
```

Backs up the current event registration for a connection.

### `net_io_restore_event`

```c
static FLB_INLINE void net_io_restore_event(struct flb_connection *connection,
                                            struct mk_event *backup)
```

Restores a previously backed-up event registration for a connection.

### `fd_io_read`

```c
static ssize_t fd_io_read(int fd, struct sockaddr_storage *address,
                          void *buf, size_t len)
```

Reads data from a file descriptor, handling both TCP and UDP connections.

### `net_io_read`

```c
static ssize_t net_io_read(struct flb_connection *connection,
                           void *buf, size_t len)
```

Performs network read operations for a connection.

## Core I/O Functions

### Connection Management

#### `flb_io_net_accept`

```c
int flb_io_net_accept(struct flb_connection *connection,
                       struct flb_coro *coro)
```

Accepts a new incoming network connection.

**Parameters:**
- `connection`: Connection context
- `coro`: Coroutine context

**Returns:**
- 0 on success
- -1 on failure

#### `flb_io_net_connect`

```c
int flb_io_net_connect(struct flb_connection *connection,
                       struct flb_coro *coro)
```

Establishes a new outgoing network connection.

**Parameters:**
- `connection`: Connection context
- `coro`: Coroutine context

**Returns:**
- 0 on success
- -1 on failure

### Data Transfer Functions

#### `flb_io_net_write`

```c
int flb_io_net_write(struct flb_connection *connection, const void *data,
                     size_t len, size_t *out_len)
```

Writes data to a network connection.

**Parameters:**
- `connection`: Connection context
- `data`: Data to write
- `len`: Length of data
- `out_len`: Output parameter for bytes written

**Returns:**
- Number of bytes written on success
- -1 on failure

#### `flb_io_net_read`

```c
size_t flb_io_net_read(struct flb_connection *connection, void *buf, size_t len)
```

Reads data from a network connection.

**Parameters:**
- `connection`: Connection context
- `buf`: Buffer to store read data
- `len`: Maximum bytes to read

**Returns:**
- Number of bytes read on success
- -1 on failure

#### `flb_io_fd_write`

```c
int flb_io_fd_write(int fd, const void *data, size_t len, size_t *out_len)
```

Writes data to a file descriptor.

**Parameters:**
- `fd`: File descriptor
- `data`: Data to write
- `len`: Length of data
- `out_len`: Output parameter for bytes written

**Returns:**
- Number of bytes written on success
- -1 on failure

#### `flb_io_fd_read`

```c
size_t flb_io_fd_read(int fd, void *buf, size_t len)
```

Reads data from a file descriptor.

**Parameters:**
- `fd`: File descriptor
- `buf`: Buffer to store read data
- `len`: Maximum bytes to read

**Returns:**
- Number of bytes read on success
- -1 on failure

### Asynchronous I/O Functions

#### `net_io_write_async`

```c
static FLB_INLINE int net_io_write_async(struct flb_coro *co,
                                         struct flb_connection *connection,
                                         const void *data, size_t len, size_t *out_len)
```

Performs asynchronous network write operations using coroutines and event loops.

#### `net_io_read_async`

```c
static FLB_INLINE ssize_t net_io_read_async(struct flb_coro *co,
                                            struct flb_connection *connection,
                                            void *buf, size_t len)
```

Performs asynchronous network read operations using coroutines and event loops.

## Dependencies

This module depends on:

1. **Fluent Bit Core**: For basic types, memory management, and system interfaces
2. **Monkey Core**: For event loop and coroutine support
3. **TLS Library**: For encrypted connections
4. **Socket Library**: For low-level network operations
5. **Upstream/Downstream**: For connection management

## Integration with Fluent Bit

The I/O interface integrates with Fluent Bit's core systems:

1. **Configuration**: Uses Fluent Bit's configuration system for network settings
2. **Threading**: Uses coroutines for non-blocking operations
3. **Memory Management**: Uses Fluent Bit's memory allocation functions
4. **Event Loop**: Integrates with Fluent Bit's event loop system
5. **Plugin Architecture**: Works with Fluent Bit's plugin system for network operations

## Asynchronous I/O Model

The I/O interface implements an asynchronous model using:

1. **Coroutines**: For cooperative multitasking
2. **Event Loop**: For I/O event notification
3. **Non-blocking Operations**: For efficient resource utilization
4. **Callback Mechanisms**: For operation completion notification

## TLS Support

The I/O interface provides comprehensive TLS support:

1. **Session Management**: Creation and management of TLS sessions
2. **Certificate Handling**: Support for client and server certificates
3. **Protocol Negotiation**: Support for various TLS protocols
4. **Encryption**: Strong encryption for data transmission

## Error Handling

The I/O interface follows robust error handling practices:

1. **Error Propagation**: Proper error codes and messages
2. **Resource Cleanup**: Automatic cleanup on error conditions
3. **Timeout Handling**: Configurable timeouts for operations
4. **Logging**: Comprehensive error logging

## Performance Characteristics

The I/O interface is optimized for performance:

1. **Asynchronous Operations**: Non-blocking I/O for efficiency
2. **Connection Pooling**: Reuse of connections where possible
3. **Buffer Management**: Efficient buffer allocation and reuse
4. **Event-Driven Architecture**: Minimal CPU usage when idle

## Thread Safety

The I/O interface is designed to be thread-safe:

1. **Reentrant Functions**: No static or global state
2. **Immutable Parameters**: Functions don't modify input parameters
3. **Session Isolation**: Each connection has isolated resources
4. **Thread Management**: Proper synchronization primitives

## Resource Management

The I/O interface carefully manages all resources:

1. **Memory**: Uses Fluent Bit's memory management
2. **File Descriptors**: Proper opening and closing
3. **Network Connections**: Proper establishment and termination
4. **TLS Sessions**: Proper creation and destruction

## Usage Example

The I/O interface is typically used as follows:

```c
#include <fluent-bit/flb_io.h>

// Create connection
struct flb_connection *conn = flb_upstream_conn_create(upstream);

if (conn != NULL) {
    // Connect to remote host
    if (flb_io_net_connect(conn, NULL) == 0) {
        // Send data
        const char *data = "Hello World";
        size_t out_len;
        
        if (flb_io_net_write(conn, data, strlen(data), &out_len) > 0) {
            // Data sent successfully
            printf("Sent %zu bytes\n", out_len);
        }
        
        // Read response
        char buffer[1024];
        ssize_t bytes_read = flb_io_net_read(conn, buffer, sizeof(buffer));
        if (bytes_read > 0) {
            buffer[bytes_read] = '\0';
            printf("Received: %s\n", buffer);
        }
    }
    
    // Close connection
    flb_upstream_conn_release(conn);
}
```

## Security Considerations

The I/O interface includes several security features:

1. **TLS Encryption**: Support for encrypted connections
2. **Certificate Validation**: Proper validation of certificates
3. **Buffer Bounds**: Prevention of buffer overflows
4. **Resource Limits**: Enforcement of reasonable size limits
5. **Memory Safety**: Proper cleanup of all resources

## Extensibility

The design allows for easy extension:

1. **New Protocols**: Support for additional network protocols
2. **Custom Transports**: Flexible transport layer implementation
3. **Authentication**: Extensible authentication mechanisms
4. **Compression**: Support for data compression

## Build Configuration

The I/O interface supports various build configurations:

1. **TLS Support**: Conditional compilation for TLS functionality
2. **IPv6 Support**: Support for IPv6 networking
3. **Proxy Support**: Support for HTTP proxy connections
4. **Cross-Platform**: Designed to work across different operating systems

## Related Components

This module works in conjunction with:

1. **Upstream/Downstream**: For connection management
2. **TLS Module**: For encrypted connections
3. **HTTP Client**: For HTTP-based communications
4. **Output Plugins**: Using this interface for network operations

## Performance Optimization

The I/O interface implements several performance optimizations:

1. **Connection Reuse**: Minimizes connection establishment overhead
2. **Buffer Pooling**: Reduces memory allocation overhead
3. **Asynchronous Operations**: Maximizes resource utilization
4. **Event-Driven Architecture**: Minimizes CPU usage during idle periods