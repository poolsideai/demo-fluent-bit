# flb_socket.c and flb_socket.h Documentation

## Overview

The `flb_socket` module provides cross-platform socket utilities for Fluent Bit. This implementation abstracts platform-specific socket operations and provides consistent interfaces for socket error handling across different operating systems (Unix-like systems and Windows).

## Key Functions

### flb_socket_error()

```c
int flb_socket_error(int fd);
```

Retrieves the error status for a socket file descriptor.

**Parameters:**
- `fd`: Socket file descriptor

**Returns:**
- `0` if no error occurred
- Error code if an error occurred
- `-1` if unable to check socket status

## Cross-Platform Abstractions

The module provides platform-independent definitions for common socket operations:

### Socket Types

- `flb_sockfd_t`: Platform-independent socket file descriptor type
- `FLB_INVALID_SOCKET`: Constant representing an invalid socket

### Socket Operations

- `flb_socket_close(fd)`: Closes a socket (maps to `close()` on Unix, `evutil_closesocket()` on Windows)
- `flb_socket_error(fd)`: Gets socket error status (custom implementation on Unix, `evutil_socket_geterror()` on Windows)

### Error Checking Macros

- `FLB_EINPROGRESS(e)`: Checks if error indicates operation in progress
- `FLB_WOULDBLOCK()`: Checks if last operation would block

## Implementation Details

### Unix-like Systems

On Unix-like systems, the implementation uses standard POSIX socket functions:
- `getsockopt()` to retrieve socket error status
- Standard error constants (`EINTR`, `EINPROGRESS`, `EAGAIN`, `EWOULDBLOCK`)
- Standard socket operations (`close()`)

### Windows Systems

On Windows systems, the implementation uses libevent utilities:
- `evutil_socket_t` for socket type
- `evutil_closesocket()` for closing sockets
- `evutil_socket_geterror()` for getting socket errors
- Windows-specific error constants (`WSAEWOULDBLOCK`)

## Error Handling

The `flb_socket_error()` function provides a consistent way to check socket status:

1. Uses `getsockopt()` with `SO_ERROR` to retrieve pending errors
2. Handles cases where `getsockopt()` itself fails
3. Returns appropriate error codes based on the platform
4. Provides debug logging for troubleshooting

## Usage Example

```c
#include <fluent-bit/flb_socket.h>
#include <fluent-bit/flb_log.h>

// Create a socket (platform-independent)
flb_sockfd_t socket_fd = socket(AF_INET, SOCK_STREAM, 0);
if (socket_fd == FLB_INVALID_SOCKET) {
    flb_error("Failed to create socket");
    return -1;
}

// Connect to a server
struct sockaddr_in server_addr;
server_addr.sin_family = AF_INET;
server_addr.sin_port = htons(80);
server_addr.sin_addr.s_addr = inet_addr("127.0.0.1");

int result = connect(socket_fd, (struct sockaddr*)&server_addr, sizeof(server_addr));
if (result == -1) {
    // Check for non-blocking connection
    if (FLB_EINPROGRESS(errno) || FLB_WOULDBLOCK()) {
        flb_debug("Connection in progress");
        // Handle non-blocking connection...
    } else {
        flb_error("Connection failed: %s", strerror(errno));
        flb_socket_close(socket_fd);
        return -1;
    }
}

// Check socket status
int socket_error = flb_socket_error(socket_fd);
if (socket_error != 0) {
    flb_error("Socket error: %s", strerror(socket_error));
    flb_socket_close(socket_fd);
    return -1;
}

// Use the socket...

// Close the socket
flb_socket_close(socket_fd);
```