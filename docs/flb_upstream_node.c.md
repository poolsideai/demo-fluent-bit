# flb_upstream_node.c

## Overview

This file implements upstream node functionality for Fluent Bit, providing a representation of individual backend servers within a high availability cluster. Each upstream node encapsulates connection details, TLS configuration, and custom properties for a specific backend server.

Key features include:
- Encapsulation of server connection details (host, port, name)
- Comprehensive TLS configuration support
- Custom property storage via hash tables
- Integration with Fluent Bit's upstream connection system
- Proper resource management and cleanup
- Property retrieval interface for custom configurations

The upstream node system serves as the building block for HA upstream clusters, allowing for flexible configuration of individual backend servers within a load-balanced architecture.

## Key Functions

### `flb_upstream_node_create()`
Creates a new upstream node with specified connection details, TLS configuration, and custom properties. Initializes the underlying upstream connection context.

### `flb_upstream_node_get_property()`
Retrieves a custom property value from the node's hash table by property name.

### `flb_upstream_node_destroy()`
Destroys an upstream node and cleans up all associated resources, including TLS contexts and upstream connections.

## Important Variables/Constants

### Node Properties
- `name`: Node identifier
- `host`: Target host address
- `port`: Target port number
- `tls_enabled`: Flag indicating TLS is enabled
- Custom properties stored in hash table

### TLS Configuration
- `tls_ca_path`: Certificate authority path
- `tls_ca_file`: Certificate authority file
- `tls_crt_file`: Client certificate file
- `tls_key_file`: Client key file
- `tls_key_passwd`: Client key password
- `tls_verify`: Enable/disable certificate verification
- `tls_verify_hostname`: Enable/disable hostname verification
- `tls_debug`: TLS debug level
- `tls_vhost`: TLS virtual host

### Data Structures
- `struct flb_upstream_node`: Main node context containing connection details, TLS configuration, and custom properties
- Hash table for storing arbitrary node properties
- Integration with Fluent Bit's upstream connection system

## Dependencies

- Fluent Bit core components:
  - `flb_info.h`: Core information and logging
  - `flb_io.h`: I/O operations
  - `flb_log.h`: Logging functionality
  - `flb_mem.h`: Memory allocation utilities
  - `flb_sds.h`: String data structures
  - `tls/flb_tls.h`: TLS/SSL support
  - `flb_hash_table.h`: Hash table implementation
  - `flb_upstream_node.h`: Upstream node interface definitions

## Implementation Details

1. **Resource Encapsulation**: Bundles all connection-related information into a single node context for easy management.

2. **TLS Integration**: Comprehensive TLS configuration support with proper initialization and cleanup of TLS contexts.

3. **Custom Properties**: Hash table-based storage for arbitrary node properties that can be accessed by calling plugins.

4. **Automatic Naming**: Generates node names from host and port when no explicit name is provided.

5. **Memory Safety**: Proper allocation and cleanup of all resources to prevent memory leaks.

6. **Error Handling**: Comprehensive error checking with appropriate cleanup on failure scenarios.

7. **Conditional Compilation**: TLS features are only compiled when TLS support is available in the build.

8. **Integration Ready**: Seamless integration with Fluent Bit's upstream connection system.

## Usage Example

```c
// Create an upstream node
struct flb_upstream_node *node = flb_upstream_node_create(
    flb_sds_create("primary_server"),  // Node name
    flb_sds_create("192.168.1.10"),     // Host
    flb_sds_create("8080"),             // Port
    FLB_TRUE,                           // TLS enabled
    FLB_TRUE,                           // TLS verify enabled
    FLB_TRUE,                           // TLS verify hostname
    1,                                  // TLS debug level
    "example.com",                      // TLS virtual host
    "/path/to/ca",                     // TLS CA path
    "/path/to/ca.crt",                 // TLS CA file
    "/path/to/client.crt",             // TLS certificate file
    "/path/to/client.key",             // TLS key file
    "password123",                     // TLS key password
    NULL,                               // Custom properties hash table
    config                              // Fluent Bit configuration
);

if (!node) {
    flb_error("Failed to create upstream node");
    return -1;
}

// Use the node's upstream connection
struct flb_connection *connection = flb_upstream_conn_get(node->u);
if (connection) {
    // Perform I/O operations using the connection
    // ... network operations ...
    
    // Release the connection back to the pool
    flb_upstream_conn_release(connection);
}

// Retrieve custom properties
const char *custom_prop = flb_upstream_node_get_property("custom.property", node);
if (custom_prop) {
    flb_info("Custom property value: %s", custom_prop);
}

// Clean up
flb_upstream_node_destroy(node);

// Create node with custom properties
struct flb_hash_table *custom_props = flb_hash_table_create(FLB_HASH_TABLE_EVICT_NONE, 32, 256);
if (custom_props) {
    flb_hash_table_add(custom_props, "timeout", 7, "30s", 3);
    flb_hash_table_add(custom_props, "retries", 7, "3", 1);
    
    struct flb_upstream_node *node_with_props = flb_upstream_node_create(
        flb_sds_create("server_with_props"),
        flb_sds_create("192.168.1.11"),
        flb_sds_create("8080"),
        FLB_FALSE,  // No TLS
        FLB_TRUE,
        FLB_FALSE,
        1,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        custom_props,
        config
    );
    
    if (node_with_props) {
        const char *timeout = flb_upstream_node_get_property("timeout", node_with_props);
        const char *retries = flb_upstream_node_get_property("retries", node_with_props);
        
        flb_info("Server timeout: %s, retries: %s", timeout, retries);
        
        flb_upstream_node_destroy(node_with_props);
    }
}
```