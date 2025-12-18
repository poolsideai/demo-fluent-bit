# flb_upstream_node.c

## Overview

The `flb_upstream_node.c` file implements individual upstream node management for Fluent Bit. This module provides functionality for creating, configuring, and managing individual nodes that can be used as part of high availability upstream configurations. Each node represents a single endpoint that can be connected to, with support for various networking options including TLS encryption.

The upstream node system serves as a bridge between high-level configuration and low-level networking operations, providing a clean interface for plugins to manage individual upstream endpoints. It integrates seamlessly with the standard upstream module and the HA upstream system.

## Key Functions

### `flb_upstream_node_create(flb_sds_t name, flb_sds_t host, flb_sds_t port, int tls, int tls_verify, int tls_verify_hostname, int tls_debug, const char *tls_vhost, const char *tls_ca_path, const char *tls_ca_file, const char *tls_crt_file, const char *tls_key_file, const char *tls_key_passwd, struct flb_hash_table *ht, struct flb_config *config)`
Creates a new upstream node with the specified configuration parameters including networking and TLS settings.

**Parameters:**
- `name`: Identifier for the node (optional, auto-generated if not provided)
- `host`: Target host address (required)
- `port`: Target port number as string (required)
- `tls`: Enable/disable TLS encryption
- `tls_verify`: Verify TLS certificates (default: true)
- `tls_verify_hostname`: Verify hostname in TLS certificates (default: false)
- `tls_debug`: TLS debugging level
- `tls_vhost`: TLS virtual host
- `tls_ca_path`: Path to CA certificates
- `tls_ca_file`: CA certificate file
- `tls_crt_file`: Client certificate file
- `tls_key_file`: Client key file
- `tls_key_passwd`: Client key password
- `ht`: Hash table for custom properties (optional)
- `config`: Fluent Bit configuration context

**Returns:** Pointer to the created upstream node or NULL on error

### `flb_upstream_node_get_property(const char *prop, struct flb_upstream_node *node)`
Retrieves a custom property value from the node's hash table by property name.

**Parameters:**
- `prop`: Property name to retrieve
- `node`: Upstream node context

**Returns:** Pointer to the property value or NULL if not found

### `flb_upstream_node_destroy(struct flb_upstream_node *node)`
Destroys an upstream node and frees all associated resources including TLS contexts and hash tables.

**Parameters:**
- `node`: Upstream node to destroy

### `flb_upstream_node_set_data(void *data, struct flb_upstream_node *node)`
Sets custom data associated with the node.

**Parameters:**
- `data`: Custom data pointer
- `node`: Upstream node context

### `flb_upstream_node_get_data(struct flb_upstream_node *node)`
Retrieves custom data associated with the node.

**Parameters:**
- `node`: Upstream node context

**Returns:** Pointer to custom data or NULL if not set

## Important Variables and Constants

### Node Structure Fields
- `name` - Identifier for the node
- `host` - Target host address
- `port` - Target port number
- `u` - Underlying upstream connection context
- `ht` - Hash table for custom properties
- `tls` - TLS context when TLS is enabled
- `tls_*` - Various TLS configuration parameters
- `tls_enabled` - Flag indicating if TLS is active

### TLS Configuration Parameters
- `tls` - Enable/disable TLS encryption
- `tls_verify` - Verify TLS certificates
- `tls_verify_hostname` - Verify hostname in TLS certificates
- `tls_debug` - TLS debugging level
- `tls_vhost` - TLS virtual host
- `tls_ca_path` - Path to CA certificates
- `tls_ca_file` - CA certificate file
- `tls_crt_file` - Client certificate file
- `tls_key_file` - Client key file
- `tls_key_passwd` - Client key password

## Dependencies

This module depends on:
- Fluent Bit information header (`flb_info.h`)
- I/O operations (`flb_io.h`)
- Fluent Bit logging system (`flb_log.h`)
- Fluent Bit memory management (`flb_mem.h`)
- String data structures (`flb_sds.h`)
- TLS support (`tls/flb_tls.h`)
- Hash table utilities (`flb_hash_table.h`)
- Upstream node interface (`flb_upstream_node.h`)
- Upstream connection management (`flb_upstream.h`)

## Implementation Details

The upstream node system provides:

1. **Node Creation**: Creates individual endpoints with comprehensive networking configuration including TLS settings.

2. **TLS Integration**: Full support for TLS encryption with certificate verification, hostname checking, and client authentication.

3. **Property Management**: Uses hash tables to store custom key-value pairs that can be accessed by plugins for additional configuration.

4. **Resource Management**: Proper allocation and cleanup of all resources including TLS contexts, strings, and hash tables.

5. **Integration with Upstream System**: Each node internally creates an upstream connection context for actual network operations.

6. **Automatic Name Generation**: If no name is provided, the system automatically generates one using the host and port.

When creating a node, the system:
- Validates required parameters (host and port)
- Automatically generates a name if not provided
- Sets up TLS contexts when TLS is enabled
- Creates the underlying upstream connection context
- Stores custom properties in a hash table for plugin access

The node structure serves as a bridge between high-level configuration and low-level networking operations, providing a clean interface for plugins to manage individual upstream endpoints.

## Usage Examples

Creating an upstream node:
```c
struct flb_upstream_node *node;
struct flb_hash_table *custom_props;

// Create hash table for custom properties (optional)
custom_props = flb_hash_table_create(FLB_HASH_TABLE_EVICT_NONE, 32, 256);

// Add custom properties
flb_hash_table_add(custom_props, "custom_key", 10, "custom_value", 12);

// Create node with TLS
node = flb_upstream_node_create(
    "my_node",                    // name
    "server.example.com",         // host
    "443",                        // port
    FLB_TRUE,                     // tls
    FLB_TRUE,                     // tls_verify
    FLB_TRUE,                     // tls_verify_hostname
    1,                            // tls_debug
    "server.example.com",         // tls_vhost
    "/etc/ssl/certs",             // tls_ca_path
    "/etc/ssl/certs/ca.pem",      // tls_ca_file
    "/etc/ssl/certs/client.pem",  // tls_crt_file
    "/etc/ssl/private/client.key", // tls_key_file
    "mypassword",                 // tls_key_passwd
    custom_props,                 // custom properties
    config                        // Fluent Bit config
);

if (node) {
    // Access custom properties
    const char *prop = flb_upstream_node_get_property("custom_key", node);
    
    // Get connection from node
    struct flb_connection *conn = flb_upstream_conn_get(node->u);
    
    // Use connection for network operations
    // ...
    
    // Clean up
    flb_upstream_node_destroy(node);
}
```

Creating a node without TLS:
```c
struct flb_upstream_node *node;
struct flb_hash_table *custom_props;

// Create hash table for custom properties
custom_props = flb_hash_table_create(FLB_HASH_TABLE_EVICT_NONE, 32, 256);

// Add custom properties
flb_hash_table_add(custom_props, "api_key", 7, "my_secret_key", 13);

// Create node without TLS
node = flb_upstream_node_create(
    "simple_node",               // name
    "api.example.com",           // host
    "80",                        // port
    FLB_FALSE,                   // tls
    FLB_TRUE,                    // tls_verify (ignored when TLS disabled)
    FLB_FALSE,                   // tls_verify_hostname (ignored when TLS disabled)
    1,                           // tls_debug (ignored when TLS disabled)
    NULL,                        // tls_vhost (ignored when TLS disabled)
    NULL,                        // tls_ca_path (ignored when TLS disabled)
    NULL,                        // tls_ca_file (ignored when TLS disabled)
    NULL,                        // tls_crt_file (ignored when TLS disabled)
    NULL,                        // tls_key_file (ignored when TLS disabled)
    NULL,                        // tls_key_passwd (ignored when TLS disabled)
    custom_props,                // custom properties
    config                       // Fluent Bit config
);

if (node) {
    // Access custom properties
    const char *api_key = flb_upstream_node_get_property("api_key", node);
    
    // Get connection from node
    struct flb_connection *conn = flb_upstream_conn_get(node->u);
    
    // Use connection for network operations
    // ...
    
    // Clean up
    flb_upstream_node_destroy(node);
}
```

Accessing node properties:
```c
struct flb_upstream_node *node = /* ... get node ... */;

// Retrieve custom configuration values
const char *api_key = flb_upstream_node_get_property("api_key", node);
const char *timeout = flb_upstream_node_get_property("timeout", node);
const char *retry_count = flb_upstream_node_get_property("retry_count", node);

if (api_key) {
    // Use API key for authentication
}

if (timeout) {
    // Convert timeout string to integer
    int timeout_value = atoi(timeout);
}

if (retry_count) {
    // Convert retry count string to integer
    int retries = atoi(retry_count);
}
```

Setting and getting custom data:
```c
struct flb_upstream_node *node = /* ... get node ... */;

// Set custom data (e.g., plugin-specific context)
struct my_plugin_context *ctx = flb_malloc(sizeof(struct my_plugin_context));
// Initialize ctx...

flb_upstream_node_set_data(ctx, node);

// Later, retrieve the custom data
struct my_plugin_context *retrieved_ctx = flb_upstream_node_get_data(node);

// Use the context for plugin operations
// ...

// When cleaning up, don't forget to free the data
flb_free(retrieved_ctx);
```

## Configuration Options

The upstream node module supports extensive configuration options:

### Basic Networking
- `host`: Target host address (required)
- `port`: Target port number (required)
- `name`: Node identifier (optional, auto-generated)

### TLS Configuration
- `tls`: Enable/disable TLS encryption
- `tls_verify`: Verify TLS certificates (default: true)
- `tls_verify_hostname`: Verify hostname in TLS certificates (default: false)
- `tls_debug`: TLS debugging level
- `tls_vhost`: TLS virtual host
- `tls_ca_path`: Path to CA certificates
- `tls_ca_file`: CA certificate file
- `tls_crt_file`: Client certificate file
- `tls_key_file`: Client key file
- `tls_key_passwd`: Client key password

### Custom Properties
- Any additional key-value pairs can be stored in the hash table for plugin-specific configuration

## TLS Support

The upstream node module provides comprehensive TLS support:

- **Certificate Verification**: Full support for certificate chain validation
- **Hostname Verification**: Optional hostname checking in certificates
- **Client Authentication**: Support for client certificates and keys
- **Custom CA Stores**: Ability to specify custom CA certificate paths and files
- **Debugging Support**: Configurable TLS debugging levels for troubleshooting

## Custom Property Management

Plugins can store additional key-value pairs with nodes using the hash table mechanism:

- Properties are stored as key-value pairs in a hash table associated with each node
- Values are stored as strings and can be retrieved using `flb_upstream_node_get_property()`
- Plugins can store any configuration data needed for their specific use cases
- Common use cases include API keys, timeouts, retry counts, and custom headers

## Error Handling

The upstream node module implements comprehensive error handling:

- Parameter validation for required fields (host and port)
- Resource allocation failure detection and cleanup
- TLS context initialization error reporting
- Upstream connection creation error handling
- Memory allocation failure recovery

## Memory Management

The upstream node module follows Fluent Bit's memory management patterns:

- Centralized allocation/deallocation through flb_malloc/flb_free
- Automatic cleanup of all resources including TLS contexts, strings, and hash tables
- Proper reference counting for shared resources
- Memory leak prevention through systematic cleanup

## Thread Safety

The upstream node module is designed to be thread-safe:

- Mutex protection for shared data structures
- Atomic operations for node access
- Proper synchronization for multi-worker environments

## Integration with Fluent Bit Pipeline

The upstream node module integrates seamlessly with Fluent Bit's data pipeline:

- Works with input plugins to send data to upstream services
- Supports output plugins that require upstream connections
- Integrates with the event loop for asynchronous operations
- Compatible with Fluent Bit's configuration mapping system

## Testing Strategy

The upstream node module is tested through:

- Unit tests for individual functions
- Integration tests with TLS connections
- Stress tests for memory management
- Multi-threading scenario validation
- TLS configuration validation

## Related Components

- `flb_upstream.c`: Standard upstream connection management
- `flb_upstream_ha.c`: High availability upstream connection handling
- `flb_upstream_queue.c`: Upstream connection queuing system
- `flb_connection.c`: Base connection management
- `flb_stream.c`: Stream-based connection handling
- `flb_io.c`: I/O operations interface
- `flb_tls.c`: TLS support implementation

## Future Enhancements

Potential future enhancements include:

- Support for additional protocols beyond TCP
- Enhanced connection health checking
- Automatic failover capabilities
- Enhanced metrics and monitoring capabilities
- Better integration with service discovery systems
- Enhanced proxy authentication support
- Connection pooling at the node level