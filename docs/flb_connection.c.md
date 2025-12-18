# flb_connection.c

## Overview

The `flb_connection.c` file implements a connection management system for Fluent Bit's networking layer. This module provides a unified interface for handling both upstream (client) and downstream (server) connections, abstracting the underlying socket operations and providing consistent connection lifecycle management.

The connection system is designed to work with Fluent Bit's coroutine-based concurrency model, allowing connections to be managed asynchronously while maintaining proper resource tracking and timeout handling.

## Key Functions

### `flb_connection_setup`
Initializes an existing connection structure:
- Sets up socket file descriptor and connection type
- Associates with parent stream (upstream/downstream)
- Configures event loop and coroutine references
- Initializes timeout tracking variables
- Sets up TLS session support
- Returns 0 on success, non-zero on failure

### `flb_connection_create`
Allocates and initializes a new connection:
- Dynamically allocates memory for the connection structure
- Calls `flb_connection_setup` for initialization
- Sets the `dynamically_allocated` flag for proper cleanup
- Returns a pointer to the initialized connection or NULL on failure

### `flb_connection_destroy`
Cleans up a connection structure:
- Frees memory if the connection was dynamically allocated
- Does not close the underlying socket (handled by stream layer)
- Clears all connection state

### `flb_connection_set_remote_host`
Sets the remote host address information:
- Stores raw socket address information
- Used for connection tracking and logging
- Handles different address families (IPv4, IPv6, Unix domain)

### `flb_connection_get_remote_address`
Retrieves a human-readable remote address string:
- Constructs user-friendly address representation
- Handles different transport protocols (TCP, UDP, Unix)
- Caches result for performance
- Returns formatted string like "tcp://192.168.1.1:24224"

### `flb_connection_get_flags`
Retrieves connection flags from the parent stream:
- Delegates to stream layer for flag information
- Provides access to connection properties

### Timeout Management Functions
- `flb_connection_reset_connection_timeout`: Sets connection timeout based on stream configuration
- `flb_connection_unset_connection_timeout`: Clears connection timeout tracking
- `flb_connection_reset_io_timeout`: Sets I/O timeout based on stream configuration
- `flb_connection_unset_io_timeout`: Clears I/O timeout tracking

## Data Structures

### `struct flb_connection`
Represents a network connection with:
- Socket file descriptor (`fd`)
- Remote host information (raw address, hostname, port)
- User-friendly address string for logging
- Network setup configuration (`net`)
- Custom network error code (`net_error`)
- Busy/shutdown flags for connection state tracking
- Recycle flag for connection reuse
- Keepalive counter (`ka_count`)
- Timestamps for connection lifecycle tracking
- Event loop and coroutine references
- Parent stream reference (upstream/downstream)
- TLS session for secure connections
- Linked list head for queue management

## Connection Types

The system supports two connection types:
- `FLB_UPSTREAM_CONNECTION`: Client connections to remote servers
- `FLB_DOWNSTREAM_CONNECTION`: Server connections from clients

## Dependencies

This module depends on:
- `flb_upstream`: Upstream connection management
- `flb_downstream`: Downstream connection management
- `flb_socket`: Low-level socket operations
- `flb_net_setup`: Network configuration
- `flb_coro`: Coroutine management
- `monkey/mk_core`: Event loop and core utilities

## Implementation Details

The connection system provides several key features:

1. **Unified Interface**: Same API for upstream and downstream connections
2. **Resource Tracking**: Proper memory management with dynamic allocation flag
3. **Timeout Handling**: Automatic timeout calculation and tracking
4. **Address Resolution**: Human-readable address formatting for logging
5. **TLS Support**: Integration with TLS session management
6. **Coroutine Integration**: Seamless operation with Fluent Bit's coroutine model
7. **State Management**: Busy/shutdown flags for safe connection handling

Connection lifecycle:
1. Creation/Setup: Initialize connection structure
2. Assignment: Associate with stream and coroutine
3. Usage: Handle I/O operations with timeout tracking
4. Recycling: Reuse connection when possible
5. Destruction: Cleanup resources when no longer needed

## Usage Example

```c
// Creating a connection in an upstream context
struct flb_connection *connection;
struct flb_upstream *upstream;  // Assume already created

// Create connection for established socket
connection = flb_connection_create(socket_fd,
                                   FLB_UPSTREAM_CONNECTION,
                                   upstream,
                                   config->evl,
                                   coroutine);
if (!connection) {
    flb_error("Failed to create connection");
    return -1;
}

// Set remote host information
struct sockaddr_storage addr;
// ... populate addr ...

flb_connection_set_remote_host(connection, (struct sockaddr *) &addr);

// Get human-readable address for logging
char *remote_addr = flb_connection_get_remote_address(connection);
flb_info("Connection established to %s", remote_addr);

// Reset connection timeout based on stream configuration
flb_connection_reset_connection_timeout(connection);

// Use connection for I/O operations...
// ...

// Destroy connection when done
flb_connection_destroy(connection);
```