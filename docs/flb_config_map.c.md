# flb_config_map.c

## Overview

The `flb_config_map.c` file implements a sophisticated configuration mapping system for Fluent Bit plugins. This system provides a standardized way for plugins to define, validate, and process configuration properties while ensuring type safety and proper resource management.

The configuration map system serves as an abstraction layer between raw configuration data (from files or command-line) and plugin-specific data structures. It handles property validation, type conversion, default value assignment, and memory management automatically.

## Key Functions

### `flb_config_map_create`
Creates a dynamic configuration map from a static plugin definition:
- Allocates memory for each configuration property
- Processes default values and converts them to appropriate data types
- Handles environment variable substitution in default values
- Initializes linked lists for multi-value properties
- Returns a heap-allocated linked list of configuration map entries

### `flb_config_map_destroy`
Performs comprehensive cleanup of a configuration map:
- Frees all allocated strings and linked lists
- Releases memory for multi-value property entries
- Cleans up all resources associated with the map

### `flb_config_map_set`
Populates a plugin context structure with configuration values:
- Maps configuration properties to context structure members using offsets
- Handles both default values and user-provided overrides
- Performs type conversion from string representations
- Supports complex data types including lists and variants
- Manages memory ownership and prevents leaks

### `flb_config_map_properties_check`
Validates that all provided configuration properties are supported:
- Checks each property against the plugin's allowed property list
- Reports unknown properties with helpful error messages
- Validates usage of multi-value properties
- Handles deprecated property warnings

### `flb_config_map_expected_values`
Returns the expected number of values for list-type properties:
- Determines minimum required entries for CLIST/SLIST properties
- Used for validation of multi-part configuration values

## Data Structures

### `struct flb_config_map`
Represents a single configuration property with:
- Type information (string, integer, boolean, etc.)
- Property name and description
- Default value (processed to appropriate type)
- Flags for special behaviors (multi-value support)
- Memory offset for direct context structure mapping
- Linked list head for map traversal

### `struct flb_config_map_val`
Stores the processed value of a configuration property:
- Union containing typed values (string, integer, boolean, etc.)
- Pointer to linked list for multi-value properties
- Linked list head for multi-value entry management

## Supported Data Types

The configuration map supports these data types:

| Type | Description | Example |
|------|-------------|---------|
| `FLB_CONFIG_MAP_STR` | String value | "localhost" |
| `FLB_CONFIG_MAP_STR_PREFIX` | String with prefix requirement | "prefix." |
| `FLB_CONFIG_MAP_INT` | Integer value | 42 |
| `FLB_CONFIG_MAP_BOOL` | Boolean value | true/false |
| `FLB_CONFIG_MAP_DOUBLE` | Double precision float | 3.14 |
| `FLB_CONFIG_MAP_SIZE` | Size specification | "2M", "100K" |
| `FLB_CONFIG_MAP_TIME` | Time duration | "2H", "30s" |
| `FLB_CONFIG_MAP_CLIST` | Comma-separated list | "a,b,c" |
| `FLB_CONFIG_MAP_SLIST` | Space-separated list | "a b c" |
| `FLB_CONFIG_MAP_VARIANT` | Complex variant type | JSON objects |

## Multi-Value Properties

Support for properties that can be specified multiple times:
- `FLB_CONFIG_MAP_MULT` flag enables multiple entries
- Automatically managed linked lists for storage
- Validation of minimum required entries
- Proper memory management for dynamic entries

## Dependencies

This module depends on:
- `flb_env`: Environment variable processing
- `flb_sds`: String data structure management
- `flb_slist`: String list utilities
- `monkey/mk_core`: Linked list and core utilities
- `cfl`: Variant data type handling

## Implementation Details

The configuration mapping process involves several key steps:

1. **Map Creation**: Static plugin definitions are converted to dynamic linked lists
2. **Default Processing**: Default values are parsed and converted to appropriate types
3. **Validation**: User-provided properties are checked against allowed properties
4. **Value Assignment**: Configuration values are mapped to plugin context structures
5. **Resource Management**: Automatic cleanup prevents memory leaks

The system handles complex scenarios like:
- Environment variable substitution in default values
- Type conversion with error handling
- Multi-value property validation
- Memory ownership transfer between components
- Support for deprecated property warnings

## Usage Example

```c
// Define plugin configuration map
static struct flb_config_map config_map[] = {
    {
        FLB_CONFIG_MAP_STR,
        "host",
        "localhost",
        0, FLB_TRUE,
        offsetof(struct my_plugin_config, host),
        "Server hostname"
    },
    {
        FLB_CONFIG_MAP_INT,
        "port",
        "24224",
        0, FLB_TRUE,
        offsetof(struct my_plugin_config, port),
        "Server port"
    },
    {
        FLB_CONFIG_MAP_BOOL,
        "tls",
        "false",
        0, FLB_TRUE,
        offsetof(struct my_plugin_config, tls),
        "Enable TLS"
    },
    {
        FLB_CONFIG_MAP_CLIST,
        "labels",
        NULL,
        FLB_CONFIG_MAP_MULT,
        FLB_TRUE,
        offsetof(struct my_plugin_config, labels),
        "Key-value labels"
    },
    {
        FLB_CONFIG_MAP_TIME,
        "flush_interval",
        "1s",
        0, FLB_TRUE,
        offsetof(struct my_plugin_config, flush_interval),
        "Flush interval"
    },
    {0}
};

// Plugin initialization function
int my_plugin_init(struct flb_output_instance *ins, struct flb_config *config,
                   void *data)
{
    struct my_plugin_config *ctx;
    struct mk_list *config_map;
    struct mk_list *properties;

    // Create configuration map
    config_map = flb_config_map_create(config, config_map);
    if (!config_map) {
        return -1;
    }

    // Get properties from configuration
    properties = flb_output_config_get(ins);

    // Validate properties
    if (flb_config_map_properties_check("my_plugin", properties, config_map) == -1) {
        flb_config_map_destroy(config_map);
        return -1;
    }

    // Allocate context
    ctx = flb_calloc(1, sizeof(struct my_plugin_config));
    if (!ctx) {
        flb_config_map_destroy(config_map);
        return -1;
    }

    // Populate context with configuration values
    if (flb_config_map_set(properties, config_map, ctx) == -1) {
        flb_free(ctx);
        flb_config_map_destroy(config_map);
        return -1;
    }

    // Store context in plugin instance
    flb_output_set_context(ins, ctx);

    // Cleanup configuration map (values are now in context)
    flb_config_map_destroy(config_map);

    return 0;
}
```