# flb_pipe.c - Cross-platform Pipe Abstraction

## Overview

This file provides a cross-platform abstraction layer for Unix pipes and Windows sockets. Fluent Bit core uses unnamed Unix pipes for signaling and general communication across components. However, when building on Windows, this becomes problematic because Windows pipes are not selectable and only sockets are.

The file wraps around the required backend calls depending on the operating system, providing a consistent interface for pipe operations across different platforms.

## Key Functions

### `flb_pipe_create(flb_pipefd_t pipefd[2])`
Creates a pair of connected file descriptors or sockets depending on the platform:
- On Unix/Linux: Creates a standard Unix pipe using `pipe()`
- On Windows: Creates a socket pair using `evutil_socketpair()` from the libevent library

Returns 0 on success, -1 on failure.

### `flb_pipe_destroy(flb_pipefd_t pipefd[2])`
Destroys a pair of connected file descriptors or sockets:
- On Unix/Linux: Closes both ends of the pipe using `close()`
- On Windows: Closes both sockets using `evutil_closesocket()`

### `flb_pipe_close(flb_pipefd_t fd)`
Closes an individual end of a pipe or socket:
- On Unix/Linux: Uses `close()`
- On Windows: Uses `evutil_closesocket()`

Includes a safety check to prevent closing invalid file descriptors.

### `flb_pipe_set_nonblocking(flb_pipefd_t fd)`
Makes a socket or file descriptor non-blocking:
- On Unix/Linux: Uses `fcntl()` to set the `O_NONBLOCK` flag
- On Windows: Uses `evutil_make_socket_nonblocking()`

Returns 0 on success, -1 on failure.

### `flb_pipe_read_all(int fd, void *buf, size_t count)`
Blocking read operation that continues until `count` bytes have been read:
- Continuously reads from the pipe/socket until all requested bytes are received
- Handles `EAGAIN`/`EWOULDBLOCK` errors by sleeping briefly and retrying
- Returns the total number of bytes read on success, -1 on failure

### `flb_pipe_write_all(int fd, const void *buf, size_t count)`
Blocking write operation that continues until `count` bytes have been written:
- Continuously writes to the pipe/socket until all requested bytes are sent
- Handles `EAGAIN`/`EWOULDBLOCK` errors by sleeping briefly and retrying
- Returns the total number of bytes written on success, -1 on failure

## Platform-Specific Implementations

### Unix/Linux Implementation
Uses standard POSIX functions:
- `pipe()` for creating pipes
- `close()` for closing file descriptors
- `fcntl()` for setting non-blocking mode
- `read()`/`write()` for I/O operations

### Windows Implementation
Uses libevent abstractions:
- `evutil_socketpair()` for creating socket pairs
- `evutil_closesocket()` for closing sockets
- `evutil_make_socket_nonblocking()` for non-blocking mode
- `send()`/`recv()` for I/O operations

## Dependencies

- `<fluent-bit/flb_compat.h>` - Compatibility layer
- `<fluent-bit/flb_pipe.h>` - Public interface header
- `<fluent-bit/flb_log.h>` - Logging utilities
- `<fluent-bit/flb_time.h>` - Time utilities
- Platform-specific headers (`fcntl.h`, `event.h`)

## Notable Implementation Details

1. **Cross-platform abstraction**: The implementation uses preprocessor directives to provide different implementations for Unix and Windows platforms.

2. **Error handling**: Both implementations handle platform-specific error conditions appropriately.

3. **Socket linger options**: On Windows, socket linger options are set to ensure clean closure of connections.

4. **Blocking I/O helpers**: The `_all` variants of read/write functions provide convenience methods for ensuring complete data transfer.

5. **Safety checks**: Includes validation to prevent operations on invalid file descriptors.

## Usage Examples

```c
// Create a pipe pair
flb_pipefd_t pipefd[2];
if (flb_pipe_create(pipefd) == -1) {
    // Handle error
}

// Make one end non-blocking
if (flb_pipe_set_nonblocking(pipefd[0]) == -1) {
    // Handle error
}

// Write data
char data[] = "Hello, World!";
ssize_t bytes_written = flb_pipe_write_all(pipefd[1], data, sizeof(data));

// Read data
char buffer[1024];
ssize_t bytes_read = flb_pipe_read_all(pipefd[0], buffer, sizeof(data));

// Clean up
flb_pipe_destroy(pipefd);
```