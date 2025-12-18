# flb_plugin.c - Dynamic Plugin Management System

## Overview

This file implements Fluent Bit's dynamic plugin management system, responsible for loading, managing, and unloading external plugins at runtime. Plugins are compiled as shared objects (.so files) and dynamically loaded into the Fluent Bit process.

The system supports four types of plugins:
1. Input plugins (`in_*`)
2. Filter plugins (`filter_*`)
3. Output plugins (`out_*`)
4. Processor plugins (`processor_*`)

## Key Components

### Plugin Structure (`struct flb_plugin`)
Represents a loaded plugin with metadata:
- `type`: Plugin type (input, filter, output, or processor)
- `path`: File system path to the shared object file
- `dso_handle`: Handle returned by `dlopen()` for managing the shared object
- `_head`: Linked list node for organizing plugins by type

### Plugin Collections (`struct flb_plugins`)
Organizes loaded plugins into separate lists by type:
- `input`: List of input plugins
- `processor`: List of processor plugins
- `filter`: List of filter plugins
- `output`: List of output plugins

## Key Functions

### `flb_plugin_create()`
Creates a new plugin context for managing dynamic plugins:
- Allocates memory for the `flb_plugins` structure
- Initializes linked lists for each plugin type
- Returns a pointer to the new context or NULL on failure

### `flb_plugin_load(char *path, struct flb_plugins *ctx, struct flb_config *config)`
Loads a plugin from a shared object file:
1. Opens the shared object using `dlopen()`
2. Extracts the expected plugin structure name from the filename
3. Retrieves the plugin registration structure using `dlsym()`
4. Determines the plugin type based on naming conventions
5. Creates appropriate plugin instance and links it to the configuration
6. Creates internal plugin reference and links to plugin collections

Returns 0 on success, -1 on failure.

### `flb_plugin_load_router(char *path, struct flb_config *config)`
Routes plugin loading based on file type:
- For C plugins (prefixed with "flb-"): Uses `flb_plugin_load()`
- For proxy plugins (Go, Python, etc.): Uses `flb_plugin_proxy_create()`
- Returns 0 on success, -1 on failure

### `flb_plugin_load_config_file(const char *file, struct flb_config *config)`
Loads plugins from a configuration file:
1. Parses the configuration file using appropriate format parser
2. Extracts plugin paths from configuration sections
3. Routes each plugin path to `flb_plugin_load_router()`
4. Returns 0 on success, -1 on failure

### `flb_plugin_load_config_format(struct flb_cf *cf, struct flb_config *config)`
Loads plugins from a parsed configuration format:
1. Iterates through plugin sections in the configuration
2. Extracts plugin paths from key-value pairs
3. Routes each plugin path to `flb_plugin_load_router()`
4. Returns 0 on success, -1 on failure

### `flb_plugin_destroy(struct flb_plugins *ctx)`
Cleans up all loaded plugins:
1. Iterates through all plugin lists (input, processor, filter, output)
2. Closes shared object handles using `dlclose()`
3. Frees plugin paths using `flb_sds_destroy()`
4. Removes plugin entries from linked lists
5. Frees plugin structures
6. Frees the plugin context itself

## Plugin Naming Convention

Plugins must follow specific naming patterns:
- Input plugins: `flb-in_*.so`
- Filter plugins: `flb-filter_*.so`
- Output plugins: `flb-out_*.so`
- Processor plugins: `flb-processor_*.so`

The system extracts the plugin structure name by:
1. Removing the "flb-" prefix
2. Removing the ".so" extension
3. Appending "_plugin" suffix

For example, `flb-in_tail.so` becomes `in_tail_plugin`.

## Plugin Type Detection

The system determines plugin types by examining the structure name:
- Starts with "in_" → Input plugin
- Starts with "filter_" → Filter plugin
- Starts with "processor_" → Processor plugin
- Starts with "out_" → Output plugin

## Dependencies

- `<fluent-bit/flb_compat.h>` - Compatibility layer
- `<fluent-bit/flb_info.h>` - Core information headers
- `<fluent-bit/flb_mem.h>` - Memory management utilities
- `<fluent-bit/flb_log.h>` - Logging utilities
- `<fluent-bit/flb_error.h>` - Error handling utilities
- `<fluent-bit/flb_kv.h>` - Key-value utilities
- `<fluent-bit/flb_config_format.h>` - Configuration format utilities
- `<fluent-bit/flb_utils.h>` - Utility functions
- `<fluent-bit/flb_plugin.h>` - Public interface header
- `<fluent-bit/flb_plugin_proxy.h>` - Proxy plugin interface
- `<cfl/cfl_sds.h>` - String data structure utilities
- `<cfl/cfl_variant.h>` - Variant data type utilities
- `<cfl/cfl_kvlist.h>` - Key-value list utilities
- `<sys/types.h>` - System type definitions
- `<sys/stat.h>` - File status utilities
- `<monkey/mk_core.h>` - Monkey core utilities

## Notable Implementation Details

1. **Dynamic Loading**: Uses `dlopen()` and `dlsym()` for runtime plugin loading

2. **Cross-platform Compatibility**: Handles platform-specific dynamic loading mechanisms

3. **Memory Management**: Properly manages shared object handles and plugin metadata

4. **Error Handling**: Comprehensive error checking with detailed logging

5. **Resource Cleanup**: Ensures proper cleanup of all allocated resources

6. **Plugin Validation**: Validates plugin names and types before loading

7. **Configuration Integration**: Seamlessly integrates with Fluent Bit's configuration system

## Usage Examples

### Loading a Plugin Directly
```c
struct flb_config *config; // Assume this is initialized
struct flb_plugins *plugins = flb_plugin_create();

if (plugins == NULL) {
    // Handle error
}

// Load a plugin
if (flb_plugin_load("/path/to/flb-in_tail.so", plugins, config) == -1) {
    // Handle error
}

// Clean up when done
flb_plugin_destroy(plugins);
```

### Loading Plugins from Configuration
```c
struct flb_config *config; // Assume this is initialized

// Load plugins from a configuration file
if (flb_plugin_load_config_file("plugins.conf", config) == -1) {
    // Handle error
}
```