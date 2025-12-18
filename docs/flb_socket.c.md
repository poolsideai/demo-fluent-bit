# flb_socket.c

## Overview

The `flb_socket.c` file implements platform-independent socket error handling functionality for Fluent Bit. This module provides a wrapper around system socket error checking that works consistently across different operating systems, particularly addressing differences between Unix-like systems and Windows.

This implementation focuses on providing a unified interface for checking socket errors, which is essential for network operations in Fluent Bit's input and output plugins. The module handles platform-specific details such as different error checking mechanisms and socket types.

Key features:
- Cross-platform socket error checking
- Unified interface for socket operations
- Platform-specific implementations for Unix and Windows
- Consistent error reporting across operating systems

## Key Functions/Components

### Platform-Specific Implementations

#### Unix Implementation (`flb_socket_error(int fd)`)
Checks the error status of a socket file descriptor on Unix-like systems:
1. Uses `getsockopt()` with `SO_ERROR` to retrieve socket error status
2. Handles potential errors in the `getsockopt()` call itself
3. Returns the actual socket error if one exists, or 0 if no error
4. Provides debug logging for socket status validation issues

#### Windows Implementation
Uses libevent's socket utilities for Windows compatibility:
1. `flb_socket_error(fd)` maps to `evutil_socket_geterror(fd)`
2. Uses `evutil_closesocket(fd)` for socket closure
3. Provides Windows-specific error checking macros

### Helper Macros

#### `FLB_EINPROGRESS(e)`
Checks if an error code indicates an operation is in progress:
- Unix: Checks for `EINTR` or `EINPROGRESS`
- Windows: Checks for `WSAEWOULDBLOCK`

#### `FLB_WOULDBLOCK()`
Checks if a blocking operation would block:
- Unix: Checks for `EAGAIN` or `EWOULDBLOCK`
- Windows: Checks for `WSAEWOULDBLOCK`

#### `flb_socket_close(fd)`
Closes a socket in a platform-appropriate manner:
- Unix: Uses standard `close()` function
- Windows: Uses `evutil_closesocket()` from libevent

#### Type Definitions
- `flb_sockfd_t`: Platform-appropriate socket descriptor type
- `FLB_INVALID_SOCKET`: Constant representing an invalid socket descriptor

## Important Constants and Definitions

### Socket Descriptor Types
- `flb_sockfd_t`: Platform-specific socket descriptor type
- `FLB_INVALID_SOCKET`: Constant representing an invalid socket descriptor

### Platform Detection
- `_WIN32`: Preprocessor definition for Windows platform detection

## Dependencies and Relationships

This module depends on:
- `flb_compat`: Compatibility layer for cross-platform functionality
- `flb_log`: Logging functions for error reporting
- System socket libraries (Unix: `sys/socket.h`, Windows: libevent)
- Standard C library functions

It integrates with:
- Network input plugins (TCP, UDP, HTTP)
- Network output plugins (TCP, UDP, HTTP)
- HTTP client and server implementations
- Connection management modules
- TLS/SSL socket wrappers

## Implementation Details

### Error Checking Mechanism
The Unix implementation uses `getsockopt()` with `SO_ERROR` to retrieve deferred socket errors:
1. Calls `getsockopt()` to get the socket's error status
2. Handles potential errors in the `getsockopt()` call itself
3. Returns the actual socket error if one exists
4. Provides informative debug logging for edge cases

### Cross-Platform Compatibility
The module provides consistent interfaces across platforms:
1. Unified function signatures and return values
2. Platform-specific implementations hidden behind common interfaces
3. Proper handling of platform-specific error codes
4. Consistent behavior for socket operations

### Memory Management
- No dynamic memory allocation in this module
- Relies on system socket APIs for resource management
- Proper error handling without memory leaks

### Error Handling
- Comprehensive validation of input parameters
- Graceful handling of system call failures
- Consistent return value conventions
- Appropriate logging for debugging purposes

## Usage Examples

### Basic Socket Error Checking
```c
// Check socket error status
int socket_fd = socket(AF_INET, SOCK_STREAM, 0);
if (socket_fd != FLB_INVALID_SOCKET) {
    // Perform some socket operation
    int result = connect(socket_fd, (struct sockaddr *) &addr, sizeof(addr));
    
    if (result == -1) {
        // Check for specific error conditions
        if (FLB_EINPROGRESS(errno)) {
            printf("Connection in progress\n");
        } else {
            // Check for actual socket errors
            int error = flb_socket_error(socket_fd);
            if (error != 0) {
                printf("Socket error: %s\n", strerror(error));
            }
        }
    }
    
    // Close the socket
    flb_socket_close(socket_fd);
}
```

### Configuration Example
```ini
[INPUT]
    name tcp
    listen 0.0.0.0
    port 5170
    # Uses socket error handling for connection management
    
[OUTPUT]
    name tcp
    host 127.0.0.1
    port 5170
    # Uses socket error handling for network operations
```

### Integration Pattern
```c
// Typical integration in a network plugin
int network_plugin_connect(struct flb_network_instance *net) {
    int result = connect(net->fd, (struct sockaddr *) &net->addr, net->addr_len);
    
    if (result == -1) {
        // Handle non-blocking connection
        if (FLB_EINPROGRESS(errno)) {
            net->state = FLB_NET_CONNECTING;
            return 0; // Connection in progress
        }
        
        // Check for actual socket errors
        int error = flb_socket_error(net->fd);
        if (error != 0) {
            flb_error("Connection failed: %s", strerror(error));
            return -1;
        }
    }
    
    // Connection successful
    net->state = FLB_NET_CONNECTED;
    return 0;
}

// Usage in event loop
void network_plugin_event_handler(int fd, short events, void *data) {
    struct flb_network_instance *net = (struct flb_network_instance *) data;
    
    if (events & EV_WRITE) {
        // Check connection completion
        int error = flb_socket_error(fd);
        if (error != 0) {
            flb_error("Connection failed: %s", strerror(error));
            network_plugin_disconnect(net);
        } else {
            // Connection successful
            net->state = FLB_NET_CONNECTED;
            flb_info("Connection established to %s:%d", net->host, net->port);
        }
    }
}
```

### Error Handling Pattern
```c
// Robust socket error handling
int safe_socket_operation(int socket_fd, int (*operation)(int)) {
    int result = operation(socket_fd);
    
    if (result == -1) {
        // Check for recoverable errors
        if (FLB_WOULDBLOCK()) {
            return FLB_RETRY; // Operation would block
        }
        
        // Check for actual socket errors
        int error = flb_socket_error(socket_fd);
        if (error != 0) {
            flb_error("Socket operation failed: %s", strerror(error));
            return FLB_ERROR;
        }
        
        // Handle other system errors
        flb_error("System error: %s", strerror(errno));
        return FLB_ERROR;
    }
    
    return FLB_OK;
}

// Usage
int result = safe_socket_operation(socket_fd, send_data);
switch (result) {
    case FLB_OK:
        printf("Operation completed successfully\n");
        break;
    case FLB_RETRY:
        printf("Operation would block, retry later\n");
        break;
    case FLB_ERROR:
        printf("Operation failed\n");
        break;
}
```

### Cross-Platform Socket Management
```c
// Platform-independent socket management
void manage_socket_lifecycle(flb_sockfd_t fd) {
    // Use platform-appropriate socket operations
    if (fd != FLB_INVALID_SOCKET) {
        // Check for errors
        int error = flb_socket_error(fd);
        if (error != 0) {
            flb_warn("Socket error detected: %s", strerror(error));
        }
        
        // Close socket appropriately for platform
        flb_socket_close(fd);
    }
}

// Socket creation with error checking
flb_sockfd_t create_socket_with_error_handling(int domain, int type, int protocol) {
    flb_sockfd_t fd = socket(domain, type, protocol);
    
    if (fd == FLB_INVALID_SOCKET) {
        flb_error("Failed to create socket: %s", strerror(errno));
        return FLB_INVALID_SOCKET;
    }
    
    return fd;
}
```