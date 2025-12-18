# go.c

## Overview

This file implements the Go language proxy for Fluent Bit, providing the bridge between Fluent Bit's C core and Go-based plugins. It handles the registration, initialization, and execution of Go plugins for different plugin types (input, output, and custom). The implementation manages the lifecycle of Go plugins and provides the necessary callbacks for communication between Fluent Bit and Go code.

## Key Functions

### `proxy_go_output_register`

Registers an output plugin written in Go with Fluent Bit's plugin system.

**Parameters:**
- `proxy`: Proxy interface structure
- `def`: Plugin definition containing name and metadata

**Returns:**
- 0 on success
- -1 on failure

### `proxy_go_output_init`

Initializes an output Go plugin by calling its initialization callback.

### `proxy_go_output_flush`

Handles the flushing of data from Fluent Bit to a Go output plugin.

### `proxy_go_output_destroy`

Destroys an output Go plugin by calling its cleanup callback.

### `proxy_go_input_register`

Registers an input plugin written in Go with Fluent Bit's plugin system.

### `proxy_go_input_init`

Initializes an input Go plugin by calling its initialization callback.

### `proxy_go_input_collect`

Handles data collection from a Go input plugin.

### `proxy_go_input_cleanup`

Cleans up allocated data from a Go input plugin.

### `proxy_go_input_destroy`

Destroys an input Go plugin by calling its cleanup callback.

### `proxy_go_custom_register`

Registers a custom plugin written in Go with Fluent Bit's plugin system.

### `proxy_go_custom_init`

Initializes a custom Go plugin by calling its initialization callback.

### `proxy_go_custom_destroy`

Destroys a custom Go plugin by calling its cleanup callback.

## Important Variables/Constants

- `flbgo_output_plugin`: Structure for Go output plugin data
- `flbgo_input_plugin`: Structure for Go input plugin data
- `flbgo_custom_plugin`: Structure for Go custom plugin data

## Dependencies

- `flb_info.h`: Fluent Bit core information
- `flb_config.h`: Configuration utilities
- `flb_plugin_proxy.h`: Proxy interface definitions
- `flb_output.h`: Output plugin interface
- `flb_custom.h`: Custom plugin interface
- `go.h`: Go proxy header definitions

## Implementation Details

### Plugin Registration

The Go proxy handles registration for three plugin types:

1. **Output Plugins**: Handle sending data to external destinations
2. **Input Plugins**: Handle receiving data from external sources
3. **Custom Plugins**: Handle custom functionality not fitting other categories

Each registration function:
- Allocates plugin-specific data structures
- Resolves required callback symbols from the Go plugin
- Sets up the plugin context for communication

### Callback Management

The proxy supports both context-aware and context-free callbacks:

- **Context-Aware**: Pass additional context data to callbacks
- **Context-Free**: Traditional callback signatures without context

Examples:
- `FLBPluginFlush` vs `FLBPluginFlushCtx`
- `FLBPluginInputCallback` vs `FLBPluginInputCallbackCtx`

### Memory Management

Handles memory allocation and cleanup:

- **Plugin Data**: Allocates and frees plugin-specific structures
- **String Data**: Manages string duplication for plugin names
- **Callback Results**: Properly handles return values from Go callbacks

### Symbol Resolution

Uses `flb_plugin_proxy_symbol()` to resolve required function symbols:

- **Initialization**: `FLBPluginInit`
- **Execution**: Type-specific callbacks (flush, collect, etc.)
- **Cleanup**: `FLBPluginExit`

### Error Handling

Comprehensive error handling with detailed logging:

- **Symbol Resolution Failures**: Logs specific missing symbols
- **Initialization Failures**: Reports plugin initialization errors
- **Memory Allocation Failures**: Handles allocation failures gracefully

## Plugin Lifecycle

The Go proxy manages the complete plugin lifecycle:

1. **Registration**: Plugin is discovered and registered
2. **Initialization**: Plugin is initialized with configuration
3. **Execution**: Plugin processes data according to its type
4. **Cleanup**: Plugin resources are properly released

### Output Plugin Lifecycle

1. Register → Initialize → Flush (repeated) → Destroy
2. Each flush operation passes data to the Go plugin

### Input Plugin Lifecycle

1. Register → Initialize → Collect (repeated) → Cleanup → Destroy
2. Each collect operation retrieves data from the Go plugin

### Custom Plugin Lifecycle

1. Register → Initialize → Execute → Destroy
2. Custom execution pattern defined by the plugin

## Usage

Go plugins integrate with Fluent Bit through this proxy:

```c
// Go plugin must export these functions:
// extern "C" int FLBPluginInit(void *plugin);
// extern "C" int FLBPluginFlush(const void *data, size_t size, const char *tag);
// extern "C" int FLBPluginExit(void);

// Fluent Bit automatically discovers and loads Go plugins
// through the proxy system when FLB_PROXY_GO is enabled
```

The proxy enables developers to write Fluent Bit plugins in Go while maintaining compatibility with the C-based core. It handles the complexity of cross-language communication and provides a clean interface for Go developers to implement Fluent Bit plugins.