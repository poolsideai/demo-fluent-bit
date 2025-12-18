# flb_upstream.c

## Overview

The `flb_upstream.c` file implements the upstream connection management system for Fluent Bit. This module handles network connections to upstream services, including connection pooling, keepalive management, proxy support, and various networking configurations. It provides a robust foundation for maintaining persistent connections to external services while efficiently managing resources.

The upstream system is designed to handle multiple connections concurrently, support TLS encryption, provide timeout handling, and integrate with Fluent Bit's event-driven architecture. It uses a sophisticated queuing system to manage available, busy, and pending destruction connections.

## Key Functions

### `flb_upstream_create(struct flb_config *config, const char *host, int port, int flags, struct flb_tls *tls)`
Creates a new upstream connection context to a specified host and port with optional TLS configuration.

**Parameters:**
- `config`: Fluent Bit configuration context
- `host`: Target host address
- `port`: Target port number
- `flags`: Connection flags (FLB_IO_TLS, FLB_IO_ASYNC, etc.)
- `tls`: TLS configuration context (optional)

**Returns:** Pointer to the created upstream context or NULL on error

### `flb_upstream_create_url(struct flb_config *config, const char *url, int flags, struct flb_tls *tls)`
Creates an upstream connection from a URL string, automatically parsing protocol, host, and port information.

**Parameters:**
- `config`: Fluent Bit configuration context
- `url`: Complete URL string (e.g., "https://api.example.com:443")
- `flags`: Connection flags
- `tls`: TLS configuration context (optional)

**Returns:** Pointer to the created upstream context or NULL on error

### `flb_upstream_destroy(struct flb_upstream *u)`
Destroys an upstream connection context and cleans up all associated resources.

**Parameters:**
- `u`: Upstream context to destroy

**Returns:** 0 on success, -1 on error

### `flb_upstream_conn_get(struct flb_upstream *u)`
Retrieves a connection from the upstream context, either reusing an existing keepalive connection or creating a new one.

**Parameters:**
- `u`: Upstream context

**Returns:** Pointer to the connection or NULL if unable to create/retrieve

### `flb_upstream_conn_release(struct flb_connection *conn)`
Releases a connection back to the upstream pool, either recycling it for keepalive use or destroying it.

**Parameters:**
- `conn`: Connection to release

**Returns:** 0 on success, -1 on error

### `flb_upstream_conn_recycle(struct flb_connection *conn, int val)`
Enables or disables the recycle flag for a connection, controlling whether it can be reused in keepalive mode.

**Parameters:**
- `conn`: Connection to modify
- `val`: FLB_TRUE to enable recycling, FLB_FALSE to disable

**Returns:** 0 on success, -1 on error

### `flb_upstream_conn_timeouts(struct mk_list *list)`
Processes timeout checks for all upstream connections, cleaning up stale or timed-out connections.

**Parameters:**
- `list`: List of upstream contexts

**Returns:** 0 on success, -1 on error

### `flb_upstream_needs_proxy(const char *host, const char *proxy, const char *no_proxy)`
Determines whether a connection to a host should use a proxy based on proxy configuration and no-proxy rules.

**Parameters:**
- `host`: Target host
- `proxy`: Proxy configuration
- `no_proxy`: No-proxy configuration

**Returns:** FLB_TRUE if proxy should be used, FLB_FALSE otherwise

### `flb_upstream_thread_safe(struct flb_upstream *u)`
Enables thread-safe mode for upstream connections, important for multi-worker environments.

**Parameters:**
- `u`: Upstream context

### `flb_upstream_queue_init(struct flb_upstream_queue *uq)`
Initializes the connection queues for an upstream context.

**Parameters:**
- `uq`: Upstream queue to initialize

### `flb_upstream_conn_pending_destroy(struct flb_upstream *u)`
Processes pending destruction of connections for a specific upstream context.

**Parameters:**
- `u`: Upstream context

**Returns:** 0 on success, -1 on error

### `flb_upstream_conn_active_destroy(struct flb_upstream *u)`
Destroys active connections for a specific upstream context.

**Parameters:**
- `u`: Upstream context

**Returns:** 0 on success, -1 on error

### `flb_upstream_is_async(struct flb_upstream *u)`
Checks if the upstream connection is configured for asynchronous I/O.

**Parameters:**
- `u`: Upstream context

**Returns:** FLB_TRUE if async, FLB_FALSE otherwise

### `flb_upstream_get_config_map(struct flb_config *config)`
Retrieves the configuration map for upstream networking setup.

**Parameters:**
- `config`: Fluent Bit configuration context

**Returns:** Pointer to the configuration map

### `flb_upstream_set_total_connections_gauge(struct flb_upstream *stream, struct cmt_gauge *gauge_instance)`
Sets the gauge for tracking total connections.

**Parameters:**
- `stream`: Upstream context
- `gauge_instance`: Gauge instance for metrics

### `flb_upstream_set_busy_connections_gauge(struct flb_upstream *stream, struct cmt_gauge *gauge_instance)`
Sets the gauge for tracking busy connections.

**Parameters:**
- `stream`: Upstream context
- `gauge_instance`: Gauge instance for metrics

## Important Variables and Constants

### Connection States
- `av_queue` - Available connections ready for reuse
- `busy_queue` - Connections currently in use
- `destroy_queue` - Connections pending destruction

### Configuration Options
- `net.dns.mode` - DNS connection type (TCP or UDP)
- `net.dns.resolver` - DNS resolver type (LEGACY or ASYNC)
- `net.dns.prefer_ipv4` - Prioritize IPv4 DNS results
- `net.dns.prefer_ipv6` - Prioritize IPv6 DNS results
- `net.keepalive` - Enable/disable Keepalive support
- `net.keepalive_idle_timeout` - Maximum time allowed for an idle Keepalive connection
- `net.tcp_keepalive` - Enable/disable TCP keepalive probes
- `net.tcp_keepalive_time` - Interval between last data packet and first TCP keepalive probe
- `net.tcp_keepalive_interval` - Interval between TCP keepalive probes
- `net.tcp_keepalive_probes` - Number of unacknowledged probes to consider connection dead
- `net.io_timeout` - Maximum idle time for a connection
- `net.connect_timeout` - Maximum time to establish a connection
- `net.connect_timeout_log_error` - Log connection timeout as error or debug
- `net.source_address` - Network address to bind for data traffic
- `net.keepalive_max_recycle` - Maximum reuse count for keepalive connections
- `net.max_worker_connections` - Maximum concurrent connections per worker
- `net.proxy_env_ignore` - Ignore HTTP_PROXY, HTTPS_PROXY, and NO_PROXY environment variables

### Connection Flags
- `FLB_IO_TCP` - TCP connection
- `FLB_IO_TLS` - TLS encryption enabled
- `FLB_IO_ASYNC` - Asynchronous I/O mode
- `FLB_IO_TCP_KA` - TCP keepalive

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
- Metrics (`cmetrics/cmetrics.h`)
- Queue management (`flb_upstream_queue.h`)

## Implementation Details

The upstream system implements several key features:

1. **Connection Pooling**: Maintains queues of available, busy, and destroy-pending connections to efficiently reuse resources.

2. **Keepalive Management**: Supports persistent connections that can be reused across multiple requests, reducing connection overhead.

3. **Proxy Support**: Automatically configures proxy connections when needed, with proper handling of proxy authentication and no-proxy rules.

4. **Timeout Handling**: Implements comprehensive timeout management for connection establishment, I/O operations, and keepalive idle periods.

5. **Thread Safety**: Provides mechanisms for safe concurrent access to upstream connections in multi-worker environments.

6. **Metrics Integration**: Exposes connection metrics through gauges for monitoring total and busy connection counts.

7. **Error Recovery**: Gracefully handles connection failures and implements automatic cleanup of stale connections.

8. **TLS Support**: Full integration with Fluent Bit's TLS subsystem for secure connections.

9. **DNS Resolution**: Configurable DNS resolution with support for both legacy and async resolvers.

10. **IPv4/IPv6 Preference**: Ability to prioritize IPv4 or IPv6 DNS results.

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

Using with metrics:
```c
struct cmt_gauge *total_connections_gauge;
struct cmt_gauge *busy_connections_gauge;

// Create gauges for metrics
total_connections_gauge = cmt_gauge_create(metrics_context, "upstream_total_connections", "Total upstream connections");
busy_connections_gauge = cmt_gauge_create(metrics_context, "upstream_busy_connections", "Busy upstream connections");

// Associate gauges with upstream
flb_upstream_set_total_connections_gauge(upstream, total_connections_gauge);
flb_upstream_set_busy_connections_gauge(upstream, busy_connections_gauge);
```

## Configuration Impact

The upstream module supports extensive configuration through the Fluent Bit configuration system:

- **DNS Configuration**: Controls how domain names are resolved
- **Keepalive Settings**: Optimizes connection reuse and resource utilization
- **Timeout Values**: Balances between responsiveness and connection efficiency
- **Proxy Configuration**: Enables routing through proxy servers
- **TLS Configuration**: Controls certificate validation and cipher suites
- **Connection Limits**: Prevents resource exhaustion in high-load scenarios

## Error Handling

The upstream module implements comprehensive error handling:

- Connection timeouts are properly detected and handled
- TLS handshake failures are gracefully managed
- DNS resolution errors are reported appropriately
- Resource exhaustion is handled with appropriate logging
- Connection failures trigger automatic cleanup
- Thread safety violations are prevented through proper locking

## Performance Considerations

- Keepalive connections significantly reduce connection overhead
- Connection pooling minimizes resource allocation/deallocation
- Asynchronous I/O prevents blocking operations
- Configurable timeouts prevent resource leaks
- Thread-local storage optimizes multi-worker scenarios
- Metrics collection provides visibility into performance characteristics

## Thread Safety

The upstream module is designed to be thread-safe:

- Mutex protection for shared data structures
- Thread-local storage for per-thread connection queues
- Atomic operations for connection counting
- Proper synchronization for multi-worker environments

## Memory Management

The upstream module follows Fluent Bit's memory management patterns:

- Centralized allocation/deallocation through flb_malloc/flb_free
- Automatic cleanup of connection resources
- Proper reference counting for shared resources
- Memory leak prevention through systematic cleanup

## Debugging Aids

The upstream module includes several debugging features:

- Detailed logging at trace level
- Connection state tracking
- Timeout monitoring and reporting
- Metrics exposure for monitoring
- Error code propagation for troubleshooting

## Integration with Fluent Bit Pipeline

The upstream module integrates seamlessly with Fluent Bit's data pipeline:

- Works with input plugins to send data to upstream services
- Supports output plugins that require upstream connections
- Integrates with the event loop for asynchronous operations
- Compatible with Fluent Bit's coroutine system
- Supports Fluent Bit's configuration mapping system

## Testing Strategy

The upstream module is tested through:

- Unit tests for individual functions
- Integration tests with TLS connections
- Stress tests for connection pooling
- Timeout scenario testing
- Multi-threading scenario validation

## Future Enhancements

Potential future enhancements include:

- Support for additional protocols beyond TCP
- Enhanced connection health checking
- More sophisticated load balancing algorithms
- Improved metrics and monitoring capabilities
- Better integration with service discovery systems
- Enhanced proxy authentication support

## Related Components

- `flb_upstream_ha.c`: High availability upstream connection handling
- `flb_upstream_node.c`: Individual upstream node management
- `flb_connection.c`: Base connection management
- `flb_stream.c`: Stream-based connection handling
- `flb_io.c`: I/O operations interface
- `flb_tls.c`: TLS support implementation