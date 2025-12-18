# flb_plugin_proxy.c - Plugin Proxy System for External Language Support

## Overview

This file implements Fluent Bit's plugin proxy system, which enables support for plugins written in languages other than C. The proxy system acts as a bridge between Fluent Bit's core C engine and external language runtimes like Go, Python, and others.

The system provides a standardized interface for external plugins to interact with Fluent Bit's core functionality through exported C functions. It handles the complexity of cross-language communication, memory management, and callback routing.

## Key Components

### Plugin Proxy Definition (`struct flb_plugin_proxy_def`)
Defines the characteristics of a proxied plugin:
- `type`: Plugin category (input, output, or custom)
- `proxy`: Proxy language type (currently supporting Go)
- `flags`: Plugin-specific flags
- `name`: Short name of the plugin
- `description`: Human-readable description of the plugin

### Plugin Proxy Context (`struct flb_plugin_proxy`)
Manages the lifecycle and communication of a proxied plugin:
- `def`: Pointer to the plugin definition
- `api`: API context for exporting C functions to the plugin
- `instance`: Reference to the input/output/custom instance
- `dso_handler`: Shared object handler from `dlopen()`
- `data`: Opaque data for specific proxy handlers
- `_head`: Linked list node for organization in config

### Proxy Context Structures
- `struct flb_plugin_proxy_context`: Context for output/custom plugins
- `struct flb_plugin_input_proxy_context`: Context for input plugins with additional collector file descriptor

## Key Functions

### `flb_plugin_proxy_symbol(struct flb_plugin_proxy *proxy, const char *symbol)`
Retrieves a symbol from the proxied plugin's shared object:
- Uses `dlsym()` to find the specified symbol in the plugin's shared library
- Returns NULL if the symbol is not found
- Used to locate plugin registration and callback functions

### `flb_plugin_proxy_register(struct flb_plugin_proxy *proxy, struct flb_config *config)`
Registers a proxied plugin with Fluent Bit:
1. Locates and calls the plugin's `FLBPluginPreRegister` callback (if exists)
2. Locates and calls the plugin's `FLBPluginRegister` callback to populate plugin definition
3. Routes to language-specific registration handlers based on proxy type
4. Creates appropriate plugin instances (input, output, or custom) and links them to the core

### `flb_plugin_proxy_create(const char *dso_path, int type, struct flb_config *config)`
Creates and initializes a new proxied plugin:
1. Loads the shared object using `dlopen()`
2. Allocates and initializes proxy context structures
3. Links the proxy to the configuration's proxy list
4. Registers the plugin with Fluent Bit
5. Returns the created proxy context or NULL on failure

### `flb_plugin_proxy_destroy(struct flb_plugin_proxy *proxy)`
Cleans up a proxied plugin:
- Frees the plugin definition
- Destroys the API context
- Closes the shared object handler
- Removes the proxy from the configuration list
- Frees the proxy structure itself

### `flb_plugin_proxy_set(struct flb_plugin_proxy_def *def, int type, int proxy, char *name, char *description)`
Populates a plugin definition with metadata:
- Sets plugin type, proxy language, name, and description
- Allocates and copies string data
- Returns 0 on success, -1 on failure

## Plugin Registration Process

The proxy system follows a standardized registration process:

1. **Pre-Registration**: Plugins can define a `FLBPluginPreRegister` callback that runs before registration
2. **Registration**: Plugins define a `FLBPluginRegister` callback that populates the plugin definition
3. **Language-Specific Initialization**: Based on the proxy type, appropriate language handlers are invoked
4. **Core Integration**: The proxy system creates standard Fluent Bit plugin instances and links them to the core

## Callback Functions

### Output Plugin Callbacks
- `flb_proxy_output_cb_init()`: Initializes output plugins
- `proxy_cb_flush()`: Routes data to output plugins
- `flb_proxy_output_cb_pre_run()`: Runs pre-execution setup
- `flb_proxy_output_cb_exit()`: Cleans up output plugins
- `flb_proxy_output_cb_destroy()`: Destroys output plugin resources

### Input Plugin Callbacks
- `flb_proxy_input_cb_init()`: Initializes input plugins
- `flb_proxy_input_cb_collect()`: Collects data from input plugins
- `flb_proxy_input_cb_pre_run()`: Runs pre-execution setup
- `flb_proxy_input_cb_exit()`: Cleans up input plugins
- `flb_proxy_input_cb_destroy()`: Destroys input plugin resources
- `flb_proxy_input_cb_pause()`: Pauses input collection
- `flb_proxy_input_cb_resume()`: Resumes input collection

### Custom Plugin Callbacks
- `flb_proxy_custom_cb_init()`: Initializes custom plugins
- `flb_proxy_custom_cb_exit()`: Cleans up custom plugins
- `flb_proxy_custom_cb_destroy()`: Destroys custom plugin resources

## Language Support

Currently supports:
- **Go (Golang)**: Through the `FLB_PROXY_GOLANG` proxy type

The system is designed to be extensible for additional languages.

## Dependencies

- `<stdio.h>` - Standard I/O functions
- `<stdlib.h>` - Standard library functions
- `<sys/types.h>` - System type definitions
- `<sys/stat.h>` - File status utilities
- `<monkey/mk_core.h>` - Monkey core utilities
- `<fluent-bit/flb_compat.h>` - Compatibility layer
- `<fluent-bit/flb_info.h>` - Core information headers
- `<fluent-bit/flb_log.h>` - Logging utilities
- `<fluent-bit/flb_mem.h>` - Memory management utilities
- `<fluent-bit/flb_output.h>` - Output plugin interface
- `<fluent-bit/flb_api.h>` - API export utilities
- `<fluent-bit/flb_error.h>` - Error handling utilities
- `<fluent-bit/flb_utils.h>` - Utility functions
- `<fluent-bit/flb_plugin_proxy.h>` - Public interface header
- `<fluent-bit/flb_input_log.h>` - Input logging utilities
- `<fluent-bit/flb_custom.h>` - Custom plugin interface
- Proxy implementations (`proxy/go/go.h`)

## Notable Implementation Details

1. **Dynamic Loading**: Uses `dlopen()` and `dlsym()` for runtime plugin loading

2. **Cross-Language Communication**: Provides a standardized API for external languages to interact with Fluent Bit

3. **Memory Management**: Handles allocation and cleanup of proxy contexts and plugin definitions

4. **Error Handling**: Comprehensive error checking with detailed logging

5. **Resource Cleanup**: Ensures proper cleanup of all allocated resources including shared objects

6. **Thread Safety**: Designed to work with Fluent Bit's threading model

7. **Extensibility**: Architecture supports adding new language proxies

## Usage Examples

### Creating a Proxied Plugin
```c
struct flb_config *config; // Assume this is initialized

// Create a proxied plugin (e.g., Go plugin)
struct flb_plugin_proxy *proxy = flb_plugin_proxy_create(
    "/path/to/plugin.so", 
    FLB_PROXY_OUTPUT_PLUGIN, 
    config
);

if (proxy == NULL) {
    // Handle error
}

// The plugin is now registered and ready to use
```

### Plugin Registration Callback (in external plugin)
```c
// This would be implemented in the external plugin
int FLBPluginRegister(struct flb_plugin_proxy_def *def) {
    return flb_plugin_proxy_set(def,
                               FLB_PROXY_OUTPUT_PLUGIN,
                               FLB_PROXY_GOLANG,
                               "my_output_plugin",
                               "A custom output plugin");
}
```