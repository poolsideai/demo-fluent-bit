# flb_network.c

## Overview

This file implements the network utilities for Fluent Bit. It provides low-level networking functions for socket creation, connection management, DNS resolution, and various TCP/UDP socket operations. The module handles both IPv4 and IPv6 connections and includes platform-specific implementations for different operating systems.

## Key Functions

### flb_net_host_set

Parses and sets network host information from a connection string.

**Parameters:**
- `plugin_name`: Name of the plugin using this function
- `host`: Structure to store parsed host information
- `address`: Connection string (e.g., "127.0.0.1:24224")

**Returns:** 0 on success, -1 on failure

### flb_net_socket_reset

Sets the SO_REUSEADDR option on a socket to allow immediate reuse of addresses.

**Parameters:**
- `fd`: Socket file descriptor

**Returns:** 0 on success, -1 on failure

### flb_net_socket_share_port

Sets the SO_REUSEPORT option on a socket to allow sharing of port bindings (Linux only).

**Parameters:**
- `fd`: Socket file descriptor

**Returns:** 0 on success, -1 on failure

### flb_net_socket_tcp_nodelay

Enables TCP_NODELAY option to disable Nagle's algorithm for low-latency connections.

**Parameters:**
- `fd`: Socket file descriptor

**Returns:** 0 on success, -1 on failure

### flb_net_socket_nonblocking

Sets a socket to non-blocking mode for asynchronous operations.

**Parameters:**
- `fd`: Socket file descriptor

**Returns:** 0 on success, -1 on failure

### flb_net_socket_blocking

Sets a socket to blocking mode.

**Parameters:**
- `fd`: Socket file descriptor

**Returns:** 0 on success, -1 on failure

### flb_net_socket_set_rcvtimeout

Sets the receive timeout for a socket.

**Parameters:**
- `fd`: Socket file descriptor
- `timeout_in_seconds`: Timeout in seconds

**Returns:** 0 on success, -1 on failure

### flb_net_socket_tcp_fastopen

Enables TCP Fast Open feature for faster connection establishment (Linux kernel >= 3.7).

**Parameters:**
- `fd`: Socket file descriptor

**Returns:** 0 on success, -1 on failure

### flb_net_socket_tcp_keepalive

Configures TCP keepalive options for a socket.

**Parameters:**
- `fd`: Socket file descriptor
- `net`: Network setup configuration

**Returns:** 0 on success, -1 on failure

### flb_net_socket_create

Creates a TCP socket with optional non-blocking mode.

**Parameters:**
- `family`: Address family (AF_INET, AF_INET6, etc.)
- `nonblock`: Non-blocking flag

**Returns:** Socket file descriptor, or -1 on failure

### flb_net_socket_create_udp

Creates a UDP socket with optional non-blocking mode.

**Parameters:**
- `family`: Address family (AF_INET, AF_INET6, etc.)
- `nonblock`: Non-blocking flag

**Returns:** Socket file descriptor, or -1 on failure

### net_connect_sync

Performs a synchronous TCP connection with timeout support.

**Parameters:**
- `fd`: Socket file descriptor
- `addr`: Address structure
- `addrlen`: Address length
- `host`: Host name for logging
- `port`: Port number for logging
- `connect_timeout`: Connection timeout in seconds

**Returns:** 0 on success, -1 on failure

## Dependencies

- `<stdio.h>`: Standard I/O functions
- `<stdlib.h>`: Standard library functions
- `<string.h>`: String manipulation functions
- `<sys/types.h>`: System types
- `<fcntl.h>`: File control functions
- `<errno.h>`: Error numbers
- `<ctype.h>`: Character type functions
- `<winsock2.h>`: Windows socket API (Windows only)
- `<sys/poll.h>`: Poll function (Unix only)
- `<fluent-bit/flb_info.h>`: Core Fluent Bit header
- `<fluent-bit/flb_compat.h>`: Compatibility layer
- `<fluent-bit/flb_socket.h>`: Socket utilities
- `<fluent-bit/flb_mem.h>`: Memory management utilities
- `<fluent-bit/flb_str.h>`: String utilities
- `<fluent-bit/flb_sds.h>`: String data structure utilities
- `<fluent-bit/flb_network.h>`: Network utilities header
- `<fluent-bit/flb_utils.h>`: Utility functions
- `<fluent-bit/flb_macros.h>`: Macro definitions
- `<fluent-bit/flb_upstream.h>`: Upstream connection management
- `<fluent-bit/flb_scheduler.h>`: Scheduler utilities
- `<monkey/mk_core.h>`: Monkey core library
- `<ares.h>`: Asynchronous DNS resolver library

## Important Constants

### SOL_TCP

Defines the TCP protocol level for socket options.

### FLB_DNS_LOOKUP_CONTEXT_FOR_EVENT

Macro for converting event pointers to DNS lookup context pointers.

## Implementation Details

The network module provides a cross-platform abstraction layer for networking operations:

1. **Socket Operations**: Unified interface for TCP/UDP socket creation, configuration, and management across different platforms (Linux, macOS, Windows)

2. **Connection Management**: Synchronous connection establishment with timeout support using poll() for non-blocking operations

3. **DNS Resolution**: Thread-local storage for DNS contexts with c-ares integration for asynchronous DNS lookups

4. **TCP Optimizations**: Support for TCP Fast Open, keepalive, and Nagle's algorithm control

5. **Platform Abstraction**: Conditional compilation for platform-specific features like SO_REUSEPORT (Linux) and different error handling

The module handles IPv6 addresses in RFC 3986 format (bracketed addresses) and provides utilities for parsing complex connection strings.

## Usage Examples

```c
// Create a TCP socket
flb_sockfd_t sock = flb_net_socket_create(AF_INET, FLB_TRUE);
if (sock == -1) {
    flb_error("Failed to create socket");
    return -1;
}

// Parse host information
struct flb_net_host host;
if (flb_net_host_set("tcp", &host, "127.0.0.1:24224") == -1) {
    flb_error("Invalid host address");
    return -1;
}

// Configure socket options
flb_net_socket_tcp_nodelay(sock);
flb_net_socket_nonblocking(sock);

// Set up network configuration
struct flb_net_setup net;
flb_net_setup_init(&net);
net.connect_timeout = 5;
net.io_timeout = 10;

// Use in connection logic...

// Clean up
flb_sds_destroy(host.name);
flb_sds_destroy(host.address);
```