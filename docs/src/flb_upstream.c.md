# flb_upstream.c

## Overview

The `flb_upstream.c` file implements the upstream connection management system for Fluent Bit. This module handles network connections to upstream services, including connection pooling, keepalive management, proxy support, and various networking configurations. It provides a robust foundation for maintaining persistent connections to external services while efficiently managing resources.

## Key Functions

### `flb_upstream_create(struct flb_config *config, const char *host, int port, int flags, struct flb_tls *tls)`
Creates a new upstream connection context to a specified host and port with optional TLS configuration.

### `flb_upstream_create_url(struct flb_config *config, const char *url, int flags, struct flb_tls *tls)`
Creates an upstream connection from a URL string, automatically parsing protocol, host, and port information.

### `flb_upstream_destroy(struct flb_upstream *u)`
Destroys an upstream connection context and cleans up all associated resources.

### `flb_upstream_conn_get(struct flb_upstream *u)`
Retrieves a connection from the upstream context, either reusing an existing keepalive connection or creating a new one.

### `flb_upstream_conn_release(struct flb_connection *conn)`
Releases a connection back to the upstream pool, either recycling it for keepalive use or destroying it.

### `flb_upstream_conn_recycle(struct flb_connection *conn, int val)`
Enables or disables the recycle flag for a connection, controlling whether it can be reused in keepalive mode.

### `flb_upstream_conn_timeouts(struct mk_list *list)`
Processes timeout checks for all upstream connections, cleaning up stale or timed-out connections.

### `flb_upstream_needs_proxy(const char *host, const char *proxy, const char *no_proxy)`
Determines whether a connection to a host should use a proxy based on proxy configuration and no-proxy rules.

### `flb_upstream_thread_safe(struct flb_upstream *u)`
Enables thread-safe mode for upstream connections, important for multi-worker environments.

### `flb_upstream_queue_init(struct flb_upstream_queue *uq)`
Initializes the connection queues for an upstream context.

## Important Variables and Constants

### Connection States
- `av_queue` - Available connections ready for reuse
- `busy_queue` - Connections currently in use
- `destroy_queue` - Connections pending destruction

### Configuration Options
- `net.dns.mode` - DNS connection type (TCP or UDP)
- `net.dns.resolver` - DNS resolver type (LEGACY or ASYNC)
- `net.keepalive` - Enable/disable keepalive support
- `net.connect_timeout` - Maximum time to establish a connection
- `net.io_timeout` - Maximum idle time for a connection
- `net.max_worker_connections` - Maximum concurrent connections per worker
- `net.keepalive_max_recycle` - Maximum reuse count for keepalive connections

### Connection Flags
- `FLB_IO_ASYNC` - Asynchronous I/O mode
- `FLB_IO_TLS` - TLS encryption enabled
- Various proxy and networking flags

## Dependencies

This module depends on:
- Monkey core library (`mk_core.h`)
- Fluent Bit core components (`flb_info.h`, `flb_mem.h`, `flb_config.h`)
- Key-value utilities (`flb_kv.h`)
- String utilities (`flb_str.h`, `flb_slist.h`)
- I/O operations (`flb_io.h`)
- TLS support (`tls/flb_tls.h`)
- Engine components (`flb_engine.h`)
- Configuration mapping (`flb_config_map.h`)
- Thread storage (`flb_thread_storage.h`)
- Connection management (`flb_connection.h`)
- Stream management (`flb_stream.h`)
- Coroutine support (`flb_coro.h`)

## Implementation Details

The upstream system implements several key features:

1. **Connection Pooling**: Maintains queues of available, busy, and destroy-pending connections to efficiently reuse resources.

2. **Keepalive Management**: Supports persistent connections that can be reused across multiple requests, reducing connection overhead.

3. **Proxy Support**: Automatically configures proxy connections when needed, with proper handling of proxy authentication and no-proxy rules.

4. **Timeout Handling**: Implements comprehensive timeout management for connection establishment, I/O operations, and keepalive idle periods.

5. **Thread Safety**: Provides mechanisms for safe concurrent access to upstream connections in multi-worker environments.

6. **Metrics Integration**: Exposes connection metrics through gauges for monitoring total and busy connection counts.

7. **Error Recovery**: Gracefully handles connection failures and implements automatic cleanup of stale connections.

The system uses a three-queue model:
- **Available Queue**: Connections ready for immediate reuse
- **Busy Queue**: Connections currently in active use
- **Destroy Queue**: Connections awaiting final cleanup

Connections flow through these queues as they are created, used, recycled, and destroyed. The keepalive feature allows connections to persist between requests, significantly improving performance for services that support persistent connections.

## Usage Examples

Creating an upstream connection:
```c
struct flb_upstream *upstream;

// Create upstream connection to a service
upstream = flb_upstream_create(config, "example.com", 80, FLB_IO_ASYNC, NULL);

if (upstream) {
    // Use the upstream connection
    struct flb_connection *conn = flb_upstream_conn_get(upstream);
    
    if (conn) {
        // Perform network operations
        // ...
        
        // Release the connection back to the pool
        flb_upstream_conn_release(conn);
    }
    
    // Clean up when done
    flb_upstream_destroy(upstream);
}
```

Creating from a URL:
```c
struct flb_upstream *upstream;

// Create upstream from URL
upstream = flb_upstream_create_url(config, "https://api.example.com:443", FLB_IO_TLS, tls_config);

if (upstream) {
    // Use the connection as above
}
```

Handling timeouts:
```c
// Process timeouts for all upstream connections
flb_upstream_conn_timeouts(&config->upstreams);
```