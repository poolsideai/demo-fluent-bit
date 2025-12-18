# flb_upstream_ha.c

## Overview

This file implements High Availability (HA) upstream networking functionality for Fluent Bit, providing a load balancing and failover system for managing multiple upstream servers. The HA upstream system allows for distributing network connections across multiple backend servers with automatic failover capabilities.

Key features include:
- Load balancing across multiple upstream nodes
- Automatic failover when nodes become unavailable
- Configuration file parsing for defining upstream clusters
- Round-robin node selection for load distribution
- Support for TLS configuration per node
- Environment variable substitution in configurations
- Hash table storage for custom node properties
- Support for both Fluent Bit native and YAML configuration formats

The HA upstream system serves as a foundation for building resilient network architectures where multiple backend servers can be used interchangeably, providing improved reliability and performance.

## Key Functions

### `flb_upstream_ha_create()`
Creates a new High Availability upstream context with a specified name. Initializes the node list and tracking variables.

### `flb_upstream_ha_destroy()`
Destroys an HA upstream context and cleans up all associated resources, including all registered nodes.

### `flb_upstream_ha_node_add()`
Adds a new upstream node to the HA context's node list.

### `flb_upstream_ha_node_get()`
Retrieves the next upstream node to be used for I/O operations, implementing round-robin load balancing.

### `flb_upstream_ha_from_file()`
Parses an upstream configuration file and creates an HA upstream context with configured nodes.

### `create_node()`
Internal function that creates an upstream node from configuration properties, handling TLS settings and custom properties.

### `translate_environment_variables()`
Substitutes environment variables in configuration values, supporting dynamic configuration based on runtime environment.

## Important Variables/Constants

### Node Selection
- Round-robin algorithm for distributing load across nodes
- Last used node tracking for proper rotation

### Configuration Properties
- `name`: Node identifier
- `host`: Target host address
- `port`: Target port number
- `tls`: Enable/disable TLS encryption
- `tls.verify`: Enable/disable certificate verification
- `tls.verify_hostname`: Enable/disable hostname verification
- `tls.debug`: TLS debug level
- `tls.vhost`: TLS virtual host
- `tls.ca_path`: Certificate authority path
- `tls.ca_file`: Certificate authority file
- `tls.crt_file`: Client certificate file
- `tls.key_file`: Client key file
- `tls.key_passwd`: Client key password

### Data Structures
- `struct flb_upstream_ha`: Main HA upstream context containing node list and metadata
- `struct flb_upstream_node`: Individual upstream node with connection details and TLS configuration
- Hash tables for storing custom node properties

## Dependencies

- Standard C library headers:
  - `ctype.h`: Character type classification
  - `sys/types.h`: System type definitions
  - `sys/stat.h`: File status information

- Fluent Bit core components:
  - `flb_compat.h`: Compatibility layer
  - `flb_info.h`: Core information and logging
  - `flb_log.h`: Logging functionality
  - `flb_mem.h`: Memory allocation utilities
  - `flb_hash_table.h`: Hash table implementation
  - `flb_utils.h`: Utility functions
  - `flb_upstream_ha.h`: HA upstream interface definitions
  - `flb_upstream_node.h`: Upstream node interface
  - `flb_config_format.h`: Configuration format handling
  - `flb_kv.h`: Key-value utilities
  - `flb_env.h`: Environment variable handling

## Implementation Details

1. **Round-Robin Load Balancing**: Implements simple round-robin algorithm for distributing connections across available nodes.

2. **Configuration Parsing**: Supports both Fluent Bit native format and YAML format for defining upstream clusters.

3. **TLS Integration**: Comprehensive TLS configuration support per node, allowing for secure connections with various certificate options.

4. **Environment Variable Substitution**: Dynamic configuration values through environment variable substitution.

5. **Custom Properties**: Hash table storage for arbitrary node properties that can be used by calling plugins.

6. **File System Integration**: Proper handling of file paths and configuration file resolution.

7. **Memory Management**: Proper allocation and cleanup of all resources to prevent memory leaks.

8. **Error Handling**: Comprehensive error checking and reporting for configuration issues.

9. **Multi-Format Support**: Flexible configuration format support for different deployment scenarios.

## Usage Example

```c
// Create HA upstream from configuration file
struct flb_upstream_ha *ha_upstream = flb_upstream_ha_from_file(
    "upstream.conf",  // Configuration file
    config            // Fluent Bit configuration
);

if (!ha_upstream) {
    flb_error("Failed to create HA upstream");
    return -1;
}

// Get next node for connection
struct flb_upstream_node *node = flb_upstream_ha_node_get(ha_upstream);
if (!node) {
    flb_error("No available nodes");
    flb_upstream_ha_destroy(ha_upstream);
    return -1;
}

// Use the node to create an upstream connection
struct flb_upstream *upstream = flb_upstream_create(
    config,           // Fluent Bit configuration
    node->host,       // Host from node
    node->port,       // Port from node
    flags,            // Connection flags
    node->tls         // TLS context
);

// Use the upstream connection for I/O operations
// ... perform network operations ...

// Clean up
flb_upstream_destroy(upstream);
flb_upstream_ha_destroy(ha_upstream);

// Manual HA upstream creation
struct flb_upstream_ha *manual_ha = flb_upstream_ha_create("my_cluster");

// Add nodes manually
struct flb_upstream_node *node1 = flb_upstream_node_create(
    "primary",        // Node name
    "192.168.1.10",   // Host
    8080,             // Port
    FLB_FALSE,        // TLS disabled
    FLB_TRUE,         // TLS verify enabled
    FLB_FALSE,        // TLS hostname verify disabled
    1,                // TLS debug level
    NULL,             // TLS vhost
    NULL,             // TLS CA path
    NULL,             // TLS CA file
    NULL,             // TLS certificate file
    NULL,             // TLS key file
    NULL,             // TLS key password
    NULL,             // Custom properties hash table
    config            // Fluent Bit configuration
);

flb_upstream_ha_node_add(manual_ha, node1);

// Add more nodes as needed
// ... add additional nodes ...

// Use the HA upstream
// ... use manual_ha as needed ...

// Clean up
flb_upstream_ha_destroy(manual_ha);
```

## Sample Configuration File

```ini
[upstream]
    name example_cluster

[node]
    name primary
    host 192.168.1.10
    port 8080
    tls off

[node]
    name secondary
    host 192.168.1.11
    port 8080
    tls on
    tls.verify on
    tls.ca_file /path/to/ca.crt
    custom.property value
```

## YAML Configuration Example

```yaml
upstream:
  name: example_cluster
  nodes:
    - name: primary
      host: 192.168.1.10
      port: 8080
      tls: off
    - name: secondary
      host: 192.168.1.11
      port: 8080
      tls: on
      tls.verify: on
      tls.ca_file: /path/to/ca.crt
      custom.property: value
```

## Node Selection Algorithm

The HA upstream system implements a simple round-robin algorithm:

1. Track the last used node
2. On each `flb_upstream_ha_node_get()` call:
   - If no previous node, return the first node
   - Otherwise, return the next node in the list
   - Wrap around to the beginning when reaching the end
3. This ensures even distribution of connections across all available nodes