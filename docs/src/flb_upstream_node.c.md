# flb_upstream_node.c

## Overview

The `flb_upstream_node.c` file implements individual upstream node management for Fluent Bit. This module provides functionality for creating, configuring, and managing individual nodes that can be used as part of high availability upstream configurations. Each node represents a single endpoint that can be connected to, with support for various networking options including TLS encryption.

## Key Functions

### `flb_upstream_node_create(flb_sds_t name, flb_sds_t host, flb_sds_t port, int tls, int tls_verify, int tls_verify_hostname, int tls_debug, const char *tls_vhost, const char *tls_ca_path, const char *tls_ca_file, const char *tls_crt_file, const char *tls_key_file, const char *tls_key_passwd, struct flb_hash_table *ht, struct flb_config *config)`
Creates a new upstream node with the specified configuration parameters including networking and TLS settings.

### `flb_upstream_node_get_property(const char *prop, struct flb_upstream_node *node)`
Retrieves a custom property value from the node's hash table by property name.

### `flb_upstream_node_destroy(struct flb_upstream_node *node)`
Destroys an upstream node and frees all associated resources including TLS contexts and hash tables.

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

Accessing node properties:
```c
struct flb_upstream_node *node = /* ... get node ... */;

// Retrieve custom configuration values
const char *api_key = flb_upstream_node_get_property("api_key", node);
const char *timeout = flb_upstream_node_get_property("timeout", node);

if (api_key) {
    // Use API key for authentication
}
```