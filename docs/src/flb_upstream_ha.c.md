# flb_upstream_ha.c

## Overview

The `flb_upstream_ha.c` file implements high availability (HA) upstream connection management for Fluent Bit. This module provides functionality for managing multiple upstream nodes in a round-robin fashion, enabling load balancing and failover capabilities for connections to external services.

## Key Functions

### `flb_upstream_ha_create(const char *name)`
Creates a new high availability upstream context with the specified name.

### `flb_upstream_ha_destroy(struct flb_upstream_ha *ctx)`
Destroys an HA upstream context and cleans up all associated resources, including nodes.

### `flb_upstream_ha_node_add(struct flb_upstream_ha *ctx, struct flb_upstream_node *node)`
Adds a new upstream node to the HA context.

### `flb_upstream_ha_node_get(struct flb_upstream_ha *ctx)`
Retrieves the next available upstream node using round-robin scheduling.

### `flb_upstream_ha_from_file(const char *file, struct flb_config *config)`
Creates an HA upstream context from a configuration file, supporting both Fluent Bit and YAML formats.

## Important Variables and Constants

### Context Fields
- `name` - Name identifier for the HA upstream
- `nodes` - List of upstream nodes managed by this HA context
- `last_used_node` - Reference to the last node used for round-robin scheduling

### Configuration Keys
- `name` - Node identifier
- `host` - Target host address
- `port` - Target port number
- `tls` - Enable/disable TLS encryption
- `tls.verify` - Verify TLS certificates
- `tls.verify_hostname` - Verify hostname in TLS certificates
- `tls.debug` - TLS debugging level
- `tls.vhost` - TLS virtual host
- `tls.ca_path` - Path to CA certificates
- `tls.ca_file` - CA certificate file
- `tls.crt_file` - Client certificate file
- `tls.key_file` - Client key file
- `tls.key_passwd` - Client key password

## Dependencies

This module depends on:
- Fluent Bit compatibility layer (`flb_compat.h`)
- Fluent Bit information header (`flb_info.h`)
- Fluent Bit logging system (`flb_log.h`)
- Fluent Bit memory management (`flb_mem.h`)
- Hash table utilities (`flb_hash_table.h`)
- General utilities (`flb_utils.h`)
- Upstream HA interface (`flb_upstream_ha.h`)
- Upstream node management (`flb_upstream_node.h`)
- Configuration format handling (`flb_config_format.h`)
- Key-value utilities (`flb_kv.h`)
- Environment variable handling (`flb_env.h`)
- Standard C library functions (`ctype.h`, `sys/types.h`, `sys/stat.h`)

## Implementation Details

The HA upstream system works by:

1. **Node Management**: Maintains a list of upstream nodes that can be used for load balancing.

2. **Round-Robin Scheduling**: Distributes connections across nodes using a simple round-robin algorithm to ensure even load distribution.

3. **Configuration Parsing**: Supports loading upstream configurations from files in both Fluent Bit native format and YAML format.

4. **Environment Variable Substitution**: Automatically translates environment variables in configuration values.

5. **TLS Configuration**: Provides comprehensive TLS settings for secure connections to upstream nodes.

6. **Custom Properties**: Allows plugins to store additional key-value pairs with nodes for custom configuration.

The system maintains a `last_used_node` pointer to track the last node that was assigned, ensuring proper round-robin behavior. When all nodes have been used, it wraps back to the first node in the list.

Configuration files can define multiple upstream sections, each containing one or more node definitions with various networking and security settings.

## Usage Examples

Creating an HA upstream context:
```c
struct flb_upstream_ha *ha_ctx;

// Create HA context
ha_ctx = flb_upstream_ha_create("my_upstream");

if (ha_ctx) {
    // Add nodes to the HA context
    struct flb_upstream_node *node1 = flb_upstream_node_create(
        "node1", "server1.example.com", "80", FLB_FALSE, FLB_TRUE,
        FLB_FALSE, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, config);
    
    struct flb_upstream_node *node2 = flb_upstream_node_create(
        "node2", "server2.example.com", "80", FLB_FALSE, FLB_TRUE,
        FLB_FALSE, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, config);
    
    if (node1 && node2) {
        flb_upstream_ha_node_add(ha_ctx, node1);
        flb_upstream_ha_node_add(ha_ctx, node2);
        
        // Get nodes in round-robin fashion
        struct flb_upstream_node *node = flb_upstream_ha_node_get(ha_ctx);
        // Use the node for connections
    }
    
    // Clean up
    flb_upstream_ha_destroy(ha_ctx);
}
```

Loading from configuration file:
```c
struct flb_upstream_ha *ha_ctx;

// Load HA configuration from file
ha_ctx = flb_upstream_ha_from_file("/path/to/upstream.conf", config);

if (ha_ctx) {
    // Get nodes for load balancing
    struct flb_upstream_node *node1 = flb_upstream_ha_node_get(ha_ctx);
    struct flb_upstream_node *node2 = flb_upstream_ha_node_get(ha_ctx);
    // ...
    
    flb_upstream_ha_destroy(ha_ctx);
}
```