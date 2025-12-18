# flb_io.c

## Overview

This file contains the implementation for network I/O operations in Fluent Bit. It provides a unified interface for handling both synchronous and asynchronous network communication, including support for TCP, TLS, and Unix domain sockets.

The module abstracts the complexities of network programming by providing consistent APIs for connection establishment, data transmission, and error handling. It supports both blocking and non-blocking I/O operations, with automatic integration with Fluent Bit's event-driven architecture through coroutines.

Key features include connection pooling, timeout management, TLS session handling, and efficient data buffering for large transfers. The I/O layer serves as the foundation for all network-based input and output plugins in Fluent Bit.

## Key Functions

### Network Connection Management

#### `flb_io_net_accept()`
Accepts incoming network connections for server-side operations. Handles both plain TCP and TLS connections, performing SSL handshake when necessary.

#### `flb_io_net_connect()`
Establishes outgoing network connections to remote servers. Supports both plain TCP and TLS connections, with automatic proxy handling and TCP keepalive configuration.

### Data Transmission

#### `flb_io_net_write()`
Sends data over network connections. Automatically handles both synchronous and asynchronous modes, with TLS encryption when enabled. Manages large data transfers through chunked sending.

#### `flb_io_net_read()`
Receives data from network connections. Supports both blocking and non-blocking modes, with proper error handling and timeout management.

### File Descriptor Operations

#### `flb_io_fd_write()`
Writes data to file descriptors, primarily for Unix domain socket operations.

#### `flb_io_fd_read()`
Reads data from file descriptors, primarily for Unix domain socket operations.

### Internal Helper Functions

#### `net_io_write()`
Core implementation for network write operations, handling both TCP and UDP transports.

#### `net_io_read()`
Core implementation for network read operations, handling both TCP and UDP transports.

#### `net_io_write_async()`
Asynchronous write implementation using coroutines and event-driven I/O for non-blocking operations.

#### `net_io_read_async()`
Asynchronous read implementation using coroutines and event-driven I/O for non-blocking operations.

#### `fd_io_write()`
Low-level file descriptor write operations with retry logic for handling transient errors.

#### `fd_io_read()`
Low-level file descriptor read operations for direct socket communication.

### Event Management

#### `net_io_backup_event()`
Backs up event loop registration state for temporary modifications.

#### `net_io_restore_event()`
Restores event loop registration state after temporary modifications.

#### `net_io_propagate_critical_error()`
Propagates critical network errors to connection objects for proper error handling.

## Important Variables/Constants

### I/O Operation Modes
- `FLB_IO_TCP`: Use plain TCP communication (1)
- `FLB_IO_TLS`: Use TLS/SSL layer (2)
- `FLB_IO_OPT_TLS`: Use TCP with optional TLS (4)
- `FLB_IO_ASYNC`: Use asynchronous mode (8)
- `FLB_IO_TCP_KA`: Use TCP keepalive (16)
- `FLB_IO_IPV6`: Use IPv6 networking (32)

### Coroutine Status
- `FLB_IO_CONNECT`: Thread issuing connection request (0)
- `FLB_IO_WRITE`: Thread wanting to write data (1)

## Dependencies

- `fluent-bit/flb_info.h`: Core Fluent Bit information
- `fluent-bit/flb_config.h`: Configuration management
- `fluent-bit/flb_io.h`: Header file defining the interface
- `fluent-bit/tls/flb_tls.h`: TLS support
- `fluent-bit/flb_socket.h`: Socket utilities
- `fluent-bit/flb_upstream.h`: Upstream connection management
- `fluent-bit/flb_downstream.h`: Downstream connection management
- `fluent-bit/flb_utils.h`: Utility functions
- `fluent-bit/flb_macros.h`: Utility macros
- `fluent-bit/flb_network.h`: Network utilities
- `fluent-bit/flb_engine.h`: Engine interface
- `fluent-bit/flb_coro.h`: Coroutine interface
- `fluent-bit/flb_http_client.h`: HTTP client utilities
- `monkey/mk_core.h`: Monkey Core event loop

## Implementation Details

1. **Unified I/O Interface**: Single interface for both synchronous and asynchronous network operations, abstracting the underlying complexity.

2. **TLS Integration**: Seamless integration with TLS/SSL for secure communications, including session management and certificate validation.

3. **Coroutine Support**: Full integration with Fluent Bit's coroutine system for non-blocking I/O operations that yield control during waits.

4. **Event Loop Integration**: Proper registration and management of file descriptors with the Monkey Core event loop for efficient I/O multiplexing.

5. **Error Handling**: Comprehensive error detection and propagation, including network-specific error codes and connection state management.

6. **Timeout Management**: Built-in timeout handling for connection attempts and data transfers to prevent indefinite blocking.

7. **Large Data Transfer**: Efficient handling of large data transfers through chunked sending and proper buffer management.

8. **Connection Pooling**: Support for connection reuse and pooling to minimize connection establishment overhead.

9. **Proxy Support**: Automatic handling of HTTP proxy connections for outbound requests.

10. **UDP Support**: Special handling for UDP transport including proper address management for datagram operations.

11. **Unix Domain Sockets**: Support for Unix domain socket operations through file descriptor I/O functions.

12. **TCP Keepalive**: Configurable TCP keepalive settings for maintaining persistent connections.

## Usage Example

```c
// Example of network connection and data transfer
struct flb_connection *connection;
struct flb_coro *coro;
// ... initialize connection and coro ...

// Establish network connection
int ret = flb_io_net_connect(connection, coro);
if (ret == 0) {
    printf("Network connection established successfully\n");
} else {
    printf("Failed to establish network connection\n");
}

// Send data over the connection
const char *data = "Hello, World!";
size_t data_len = strlen(data);
size_t bytes_sent;

ret = flb_io_net_write(connection, data, data_len, &bytes_sent);
if (ret > 0) {
    printf("Sent %zu bytes successfully\n", bytes_sent);
} else {
    printf("Failed to send data\n");
}

// Receive response data
char buffer[1024];
size_t bytes_received = flb_io_net_read(connection, buffer, sizeof(buffer));
if (bytes_received > 0) {
    buffer[bytes_received] = '\0';
    printf("Received: %s\n", buffer);
} else {
    printf("Failed to receive data\n");
}

// Example of accepting incoming connections (server mode)
struct flb_connection *server_connection;
struct flb_coro *server_coro;
// ... initialize server connection and coro ...

// Accept incoming connection
ret = flb_io_net_accept(server_connection, server_coro);
if (ret == 0) {
    printf("Incoming connection accepted\n");
} else {
    printf("Failed to accept incoming connection\n");
}

// Example of file descriptor operations (Unix domain sockets)
int fd;
const char *unix_data = "Unix socket data";
size_t unix_data_len = strlen(unix_data);
size_t bytes_written;

// Write to Unix domain socket
int ret = flb_io_fd_write(fd, unix_data, unix_data_len, &bytes_written);
if (ret == 0) {
    printf("Wrote %zu bytes to Unix socket\n", bytes_written);
} else {
    printf("Failed to write to Unix socket\n");
}

// Read from Unix domain socket
char unix_buffer[1024];
size_t bytes_read = flb_io_fd_read(fd, unix_buffer, sizeof(unix_buffer));
if (bytes_read > 0) {
    unix_buffer[bytes_read] = '\0';
    printf("Read from Unix socket: %s\n", unix_buffer);
} else {
    printf("Failed to read from Unix socket\n");
}

// Example with asynchronous operations
struct flb_connection *async_connection;
struct flb_coro *async_coro;
// ... initialize connection and coro ...

// Note: Async operations automatically use coroutines when available
// The same flb_io_net_write() and flb_io_net_read() functions work
// in async mode when the connection is configured appropriately

const char *async_data = "Async data transfer";
size_t async_data_len = strlen(async_data);
size_t async_bytes_sent;

// This will automatically use async mode if configured
ret = flb_io_net_write(async_connection, async_data, async_data_len, &async_bytes_sent);
if (ret > 0) {
    printf("Async write completed, sent %zu bytes\n", async_bytes_sent);
} else {
    printf("Async write failed\n");
}
```