# flb_downstream.c

## Overview

This file implements the downstream networking functionality for Fluent Bit. It handles incoming connections from clients and manages the server-side socket operations for various transport protocols.

The module provides a framework for creating server sockets that can accept connections from clients using different transport mechanisms (TCP, UDP, Unix domain sockets) and supports TLS encryption when configured.

## Key Functions

### `flb_downstream_setup()`
Initializes a downstream connection structure with the specified transport protocol, host, port, and TLS configuration. This function creates the appropriate server socket based on the transport type.

### `flb_downstream_destroy()`
Cleans up and destroys a downstream connection structure, closing any open sockets and freeing allocated resources.

### `flb_downstream_create_connection()`
Creates a new connection structure for an incoming client connection, handling the accept operation and setting up the connection for data transfer.

### `flb_downstream_thread_safe()`
Enables thread-safe mode for a downstream connection, allowing it to be used in multi-threaded environments.

## Important Variables/Constants

### Downstream Structure (`struct flb_downstream`)
The main structure that represents a downstream connection:
- `server_fd`: Server socket file descriptor
- `host`: Host address for binding
- `port`: Port number for binding
- `transport`: Transport protocol type (TCP, UDP, etc.)
- `tls`: TLS configuration structure
- `net_setup`: Network setup configuration
- `busy_queue`: Queue of busy connections
- `destroy_queue`: Queue of connections pending destruction

### Network Setup Configuration (`struct flb_net_setup`)
Configuration parameters for network operations:
- `backlog`: Socket listen backlog size
- `share_port`: Allow multiple plugins to share the same port
- `io_timeout`: Maximum time a connection can stay idle
- `accept_timeout`: Maximum time allowed to establish an incoming connection
- `accept_timeout_log_error`: Whether to log accept timeouts as errors
- `keepalive`: Enable/disable Keepalive support

## Dependencies

- `fluent-bit/flb_info.h`: Fluent Bit core information
- `fluent-bit/flb_mem.h`: Memory management utilities
- `fluent-bit/flb_kv.h`: Key-value pair utilities
- `fluent-bit/flb_io.h`: I/O operations
- `fluent-bit/flb_str.h`: String utilities
- `fluent-bit/flb_slist.h`: Simple list utilities
- `fluent-bit/flb_utils.h`: General utilities
- `fluent-bit/flb_engine.h`: Core engine functionality
- `fluent-bit/tls/flb_tls.h`: TLS support
- `fluent-bit/flb_connection.h`: Connection management
- `fluent-bit/flb_config_map.h`: Configuration mapping
- `fluent-bit/flb_thread_storage.h`: Thread storage utilities

## Implementation Details

1. **Transport Protocol Support**: The implementation supports multiple transport protocols including TCP, UDP, Unix stream sockets, and Unix datagram sockets.

2. **TLS Integration**: When TLS is enabled, the module integrates with Fluent Bit's TLS subsystem to provide encrypted connections.

3. **Connection Queue Management**: Uses separate queues for busy connections and connections pending destruction to manage resource cleanup efficiently.

4. **Thread Safety**: Provides thread-safe operation modes for multi-threaded environments.

5. **Configuration Mapping**: Uses Fluent Bit's config map system to handle network configuration parameters.

## Usage Example

```c
// Create downstream connection
struct flb_downstream *stream = flb_downstream_create(FLB_TRANSPORT_TCP, 
                                                       FLB_IO_TCP_NATIVE, 
                                                       "0.0.0.0", 
                                                       24224, 
                                                       NULL, 
                                                       config, 
                                                       net_setup);

// Handle incoming connections
struct flb_connection *conn = flb_downstream_create_connection(stream);
if (conn) {
    // Process connection data
    flb_connection_destroy(conn);
}

// Clean up
flb_downstream_destroy(stream);
```