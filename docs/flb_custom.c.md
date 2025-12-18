# flb_custom.c

## Overview

The `flb_custom.c` file implements the Custom Plugin framework for Fluent Bit. This system allows developers to create specialized plugins that can be integrated into the Fluent Bit pipeline without following the standard input/filter/output plugin architecture.

Custom plugins are particularly useful for:
- Specialized data processing that doesn't fit standard plugin categories
- Integration with external systems or protocols
- Experimental features or proof-of-concepts
- Complex workflows that span multiple plugin types

The custom plugin system provides a flexible interface that can handle various types of operations while maintaining compatibility with Fluent Bit's core architecture.

## Key Functions

### `flb_custom_new`
Creates a new custom plugin instance:
- Looks up the plugin by name in the registered plugins list
- Allocates memory for the instance structure
- Initializes instance properties and configuration maps
- Sets up network configuration if required
- Returns initialized instance or NULL on failure

### `flb_custom_set_property`
Sets configuration properties for a custom plugin instance:
- Handles property validation and environment variable substitution
- Manages special properties like alias and log_level
- Stores network-related properties separately
- Returns 0 on success, -1 on failure

### `flb_custom_get_property`
Retrieves configuration property values:
- Searches instance properties for the requested key
- Returns property value or NULL if not found

### `flb_custom_init_all`
Initializes all registered custom plugin instances:
- Validates configuration properties against plugin config maps
- Sets up metrics collection for each instance
- Calls plugin initialization callbacks
- Handles cleanup on initialization failures

### `flb_custom_exit`
Cleans up all custom plugin instances:
- Calls exit callbacks for each plugin
- Destroys plugin instances
- Releases all associated resources

### `flb_custom_instance_destroy`
Destroys a single custom plugin instance:
- Cleans up configuration maps
- Releases property lists
- Destroys metrics context
- Frees instance memory

### `flb_custom_plugin_property_check`
Validates plugin configuration properties:
- Creates dynamic configuration maps for validation
- Checks properties against allowed configuration
- Sets up network configuration maps when needed
- Returns 0 on success, -1 on validation failure

### Utility Functions
- `flb_custom_name`: Returns instance name or alias
- `flb_custom_set_context`: Sets instance context pointer
- `flb_custom_log_check`: Checks if logging level is enabled

## Data Structures

### `struct flb_custom_plugin`
Represents a custom plugin definition with:
- `type`: Plugin type (core or proxy)
- `proxy`: Proxy handler for non-core plugins
- `flags`: Plugin capability flags
- `name`: Plugin identifier
- `description`: Human-readable description
- `config_map`: Configuration property definitions
- `cb_init`: Initialization callback
- `cb_run`: Main execution callback
- `cb_exit`: Cleanup callback
- `cb_destroy`: Plugin destruction callback

### `struct flb_custom_instance`
Represents a running custom plugin instance with:
- `id`: Unique instance identifier
- `log_level`: Instance-specific logging level
- `name`: Formatted instance name
- `alias`: User-defined alias
- `context`: Plugin-specific context data
- `data`: User data passed during creation
- `p`: Reference to plugin definition
- `properties`: Configuration properties
- `net_properties`: Network configuration properties
- `config_map`: Configuration validation map
- `net_config_map`: Network configuration map
- `cmt`: Metrics collection context
- `config`: Parent configuration reference

## Plugin Types

### Core Plugins
- `FLB_CUSTOM_PLUGIN_CORE`: Standard C-based plugins
- Direct integration with Fluent Bit core
- Full access to internal APIs

### Proxy Plugins
- `FLB_CUSTOM_PLUGIN_PROXY`: Plugins handled by specific proxies
- Language-specific implementations (Go, Python, etc.)
- Isolated execution environment

## Network Capabilities

Plugins can declare network capabilities:
- `FLB_CUSTOM_NET_CLIENT`: Can act as network client (upstream)
- `FLB_CUSTOM_NET_SERVER`: Can act as network server (downstream)

## Dependencies

This module depends on:
- `flb_config_map`: Configuration property management
- `flb_router`: Plugin routing and integration
- `flb_metrics`: Metrics collection framework
- `flb_upstream/flb_downstream`: Network connection handling
- `flb_kv`: Key-value property storage
- Standard C library and Fluent Bit core utilities

## Implementation Details

The custom plugin system provides several key features:

1. **Flexible Plugin Architecture**: Support for both core and proxy-based plugins
2. **Configuration Management**: Integration with Fluent Bit's config map system
3. **Network Integration**: Seamless connection handling for network-capable plugins
4. **Metrics Support**: Built-in metrics collection for monitoring
5. **Resource Management**: Proper cleanup and memory management
6. **Error Handling**: Comprehensive error reporting and recovery

### Instance Lifecycle
1. **Creation**: `flb_custom_new()` allocates and initializes instance
2. **Configuration**: Properties set via `flb_custom_set_property()`
3. **Validation**: `flb_custom_plugin_property_check()` validates config
4. **Initialization**: `flb_custom_init_all()` calls plugin init callbacks
5. **Execution**: Plugin runs via `cb_run` callback
6. **Cleanup**: `flb_custom_exit()` destroys all instances

### Configuration Handling
- Standard properties stored in `properties` list
- Network properties stored in `net_properties` list
- Environment variable substitution for all values
- Special handling for alias and log_level properties

### Metrics Integration
- Each instance gets its own CMetrics context
- Automatic cleanup during instance destruction
- Integration with Fluent Bit's metrics export system

## Usage Example

```c
// Plugin definition
struct flb_custom_plugin my_custom_plugin = {
    .type = FLB_CUSTOM_PLUGIN_CORE,
    .name = "my_custom",
    .description = "My custom plugin",
    .config_map = my_config_map,
    .cb_init = my_init,
    .cb_run = my_run,
    .cb_exit = my_exit
};

// Configuration map
struct flb_config_map my_config_map[] = {
    {
        FLB_CONFIG_MAP_STR,
        "endpoint",
        NULL,
        0, FLB_TRUE,
        offsetof(struct my_context, endpoint),
        "API endpoint URL"
    },
    {
        FLB_CONFIG_MAP_INT,
        "timeout",
        "30",
        0, FLB_TRUE,
        offsetof(struct my_context, timeout),
        "Request timeout in seconds"
    },
    {0}
};

// Context structure
struct my_context {
    char *endpoint;
    int timeout;
    void *connection;
};

// Initialization callback
int my_init(struct flb_custom_instance *ins, struct flb_config *config, void *data)
{
    struct my_context *ctx;
    
    // Create context
    ctx = flb_calloc(1, sizeof(struct my_context));
    if (!ctx) {
        return -1;
    }
    
    // Set context in instance
    flb_custom_set_context(ins, ctx);
    
    // Initialize configuration
    if (flb_custom_config_map_set(ins, ctx) != 0) {
        flb_free(ctx);
        return -1;
    }
    
    // Validate required properties
    if (!ctx->endpoint) {
        flb_error("[custom] endpoint is required");
        flb_free(ctx);
        return -1;
    }
    
    return 0;
}

// Main execution callback
int my_run(const void *data, size_t size, const char *tag, int tag_len,
           void **out_buf, size_t *out_size,
           struct flb_custom_instance *ins,
           void *context, struct flb_config *config)
{
    struct my_context *ctx = (struct my_context *) context;
    
    // Process data...
    
    // Set output buffer if needed
    *out_buf = NULL;
    *out_size = 0;
    
    return 0;
}

// Cleanup callback
int my_exit(void *context, struct flb_config *config)
{
    struct my_context *ctx = (struct my_context *) context;
    
    // Cleanup resources
    if (ctx->connection) {
        // Close connection
    }
    
    flb_free(ctx);
    return 0;
}

// Registration
void register_my_custom_plugin(struct flb_config *config)
{
    struct flb_custom_plugin *p;
    
    p = flb_calloc(1, sizeof(struct flb_custom_plugin));
    memcpy(p, &my_custom_plugin, sizeof(my_custom_plugin));
    
    mk_list_add(&p->_head, &config->custom_plugins);
}
```