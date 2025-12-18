# flb_upstream.c

## Overview

This file implements the upstream networking functionality for Fluent Bit, providing a robust connection management system for client-side TCP connections. The upstream system handles connection pooling, keepalive support, proxy configurations, and various network protocols including TLS.

Key features include:
- Connection pooling with keepalive support for efficient resource utilization
- Proxy configuration handling (HTTP/SOCKS proxies)
- TLS/SSL encryption support
- Configurable timeouts and connection limits
- Thread-safe connection management
- DNS resolution with configurable modes
- Connection lifecycle management (creation, reuse, destruction)
- Metrics collection for monitoring connection states

The upstream system serves as the foundation for all client-side network communications in Fluent Bit, particularly for output plugins that need to send data to remote services.

## Key Functions

### `flb_upstream_create()`
Creates a new upstream context for establishing TCP connections to a remote host. Handles proxy configuration and TLS setup.

### `flb_upstream_create_url()`
Creates an upstream context from a URL string, automatically parsing protocol, host, and port information.

### `flb_upstream_destroy()`
Destroys an upstream context and cleans up all associated resources, including active connections.

### `flb_upstream_conn_get()`
Acquires a connection from the upstream pool, either reusing an existing keepalive connection or creating a new one.

### `flb_upstream_conn_release()`
Releases a connection back to the pool, either recycling it for keepalive reuse or destroying it based on configuration.

### `flb_upstream_conn_timeouts()`
Processes connection timeouts, closing stale connections and enforcing timeout policies.

### `flb_upstream_conn_pending_destroy()`
Cleans up pending connection destruction queues.

### `flb_upstream_conn_active_destroy()`
Destroys active connections in the available queue.

### `flb_upstream_thread_safe()`
Enables thread-safe mode for upstream connections in multi-worker environments.

### `flb_upstream_needs_proxy()`
Determines if a connection should use a proxy based on configuration and NO_PROXY rules.

### `flb_upstream_queue_init()`
Initializes the connection queues (available, busy, destroy) for an upstream context.

### `flb_upstream_queue_get()`
Retrieves the appropriate connection queue for the current threading context.

## Important Variables/Constants

### Connection States
- Available connections (ready for reuse)
- Busy connections (currently in use)
- Destroy connections (pending cleanup)

### Configuration Options
- `net.dns.mode`: DNS resolution mode (TCP/UDP)
- `net.dns.resolver`: DNS resolver type (LEGACY/ASYNC)
- `net.keepalive`: Enable/disable keepalive connections
- `net.connect_timeout`: Maximum time to establish a connection
- `net.io_timeout`: Maximum time for I/O operations
- `net.max_worker_connections`: Maximum connections per worker
- `net.keepalive_max_recycle`: Maximum reuse count for keepalive connections

### Connection Structures
- `struct flb_upstream`: Main upstream context containing connection pools and configuration
- `struct flb_connection`: Individual connection context with socket and state information
- `struct flb_upstream_queue`: Connection queues for managing connection lifecycle

### Metrics
- Total connections gauge
- Busy connections gauge
- Connection labels for categorization

## Dependencies

- External libraries:
  - `monkey/mk_core.h`: Monkey HTTP server core
  - `cmetrics`: Metrics collection library

- Fluent Bit core components:
  - `flb_info.h`: Core information and logging
  - `flb_mem.h`: Memory allocation utilities
  - `flb_kv.h`: Key-value utilities
  - `flb_slist.h`: Simple list utilities
  - `flb_str.h`: String utilities
  - `flb_upstream.h`: Upstream interface definitions
  - `flb_io.h`: I/O operations
  - `tls/flb_tls.h`: TLS/SSL support
  - `flb_utils.h`: Utility functions
  - `flb_engine.h`: Engine interface
  - `flb_config_map.h`: Configuration mapping
  - `flb_thread_storage.h`: Thread storage utilities

## Implementation Details

1. **Connection Pooling**: Implements efficient connection reuse through keepalive support, reducing connection establishment overhead.

2. **Proxy Support**: Comprehensive proxy configuration handling including HTTP/SOCKS proxies and NO_PROXY exclusion rules.

3. **Thread Safety**: Full support for multi-worker environments with thread-local storage for connection queues.

4. **TLS Integration**: Seamless integration with Fluent Bit's TLS subsystem for secure connections.

5. **Timeout Management**: Sophisticated timeout handling for connection establishment, I/O operations, and keepalive idle periods.

6. **Metrics Collection**: Built-in metrics for monitoring connection states and performance.

7. **DNS Configuration**: Flexible DNS resolution options with configurable modes and resolvers.

8. **Resource Management**: Proper cleanup of connections and resources to prevent memory leaks.

9. **Error Handling**: Comprehensive error detection and recovery mechanisms.

10. **Connection Limits**: Configurable limits to prevent resource exhaustion.

## Usage Example

```c
// Create upstream from URL
struct flb_upstream *upstream = flb_upstream_create_url(
    config,                    // Fluent Bit configuration
    "https://example.com:443", // Target URL
    FLB_IO_TLS,               // Flags (enable TLS)
    tls_context               // TLS context (if needed)
);

if (!upstream) {
    flb_error("Failed to create upstream");
    return -1;
}

// Get a connection from the pool
struct flb_connection *connection = flb_upstream_conn_get(upstream);
if (!connection) {
    flb_error("Failed to get connection");
    flb_upstream_destroy(upstream);
    return -1;
}

// Use the connection for I/O operations
// ... perform network operations ...

// Release the connection back to the pool
flb_upstream_conn_release(connection);

// Later, when shutting down
flb_upstream_destroy(upstream);

// Configure upstream with custom settings
struct flb_upstream *custom_upstream = flb_upstream_create(
    config,     // Fluent Bit configuration
    "192.168.1.100",  // Host
    8080,       // Port
    0,          // Flags
    NULL        // TLS context
);

// Set custom timeouts
custom_upstream->base.net.connect_timeout = 30;  // 30 seconds
custom_upstream->base.net.io_timeout = 60;         // 60 seconds

// Enable keepalive
custom_upstream->base.net.keepalive = FLB_TRUE;
custom_upstream->base.net.keepalive_idle_timeout = 300;  // 5 minutes

// Use the upstream for connections
// ... use custom_upstream as needed ...

// Clean up
flb_upstream_destroy(custom_upstream);
```

## Connection Lifecycle

1. **Creation**: New connections are created on demand when no available keepalive connections exist.
2. **Usage**: Connections are marked as busy when acquired and used for I/O operations.
3. **Release**: Connections are either recycled to the available pool (keepalive) or destroyed.
4. **Timeout**: Stale connections are automatically cleaned up based on timeout configurations.
5. **Destruction**: Connections are properly closed and resources freed when no longer needed.