# go.h

## Overview

This header file defines the interface for Fluent Bit's Go language proxy implementation. It provides the data structures and function declarations needed to bridge Fluent Bit's C core with Go-based plugins. The header defines plugin-specific structures for different plugin types (input, output, and custom) and declares the functions that manage their lifecycle.

## Data Structures

### `flbgo_output_plugin`

Structure for Go output plugin data, containing:

- `name`: Plugin name string
- `api`: Pointer to plugin API interface
- `o_ins`: Output instance pointer
- `context`: Plugin context pointer
- `cb_init`: Initialization callback function
- `cb_flush`: Flush callback function (context-free)
- `cb_flush_ctx`: Flush callback function (context-aware)
- `cb_exit`: Exit callback function (context-free)
- `cb_exit_ctx`: Exit callback function (context-aware)

### `flbgo_input_plugin`

Structure for Go input plugin data, containing:

- `name`: Plugin name string
- `api`: Pointer to plugin API interface
- `i_ins`: Input instance pointer
- `context`: Plugin context pointer
- `cb_init`: Initialization callback function
- `cb_collect`: Data collection callback function (context-free)
- `cb_collect_ctx`: Data collection callback function (context-aware)
- `cb_cleanup`: Cleanup callback function (context-free)
- `cb_cleanup_ctx`: Cleanup callback function (context-aware)
- `cb_exit`: Exit callback function

### `flbgo_custom_plugin`

Structure for Go custom plugin data, containing:

- `name`: Plugin name string
- `api`: Pointer to plugin API interface
- `i_ins`: Custom instance pointer
- `context`: Plugin context pointer
- `cb_init`: Initialization callback function
- `cb_exit`: Exit callback function

## Function Declarations

### Output Plugin Functions

#### `proxy_go_output_register`

Registers an output plugin written in Go with Fluent Bit's plugin system.

#### `proxy_go_output_init`

Initializes an output Go plugin by calling its initialization callback.

#### `proxy_go_output_flush`

Handles the flushing of data from Fluent Bit to a Go output plugin.

#### `proxy_go_output_destroy`

Destroys an output Go plugin by calling its cleanup callback.

#### `proxy_go_output_unregister`

Unregisters an output Go plugin and frees associated resources.

### Input Plugin Functions

#### `proxy_go_input_register`

Registers an input plugin written in Go with Fluent Bit's plugin system.

#### `proxy_go_input_init`

Initializes an input Go plugin by calling its initialization callback.

#### `proxy_go_input_collect`

Handles data collection from a Go input plugin.

#### `proxy_go_input_cleanup`

Cleans up allocated data from a Go input plugin.

#### `proxy_go_input_destroy`

Destroys an input Go plugin by calling its cleanup callback.

#### `proxy_go_input_unregister`

Unregisters an input Go plugin and frees associated resources.

### Custom Plugin Functions

#### `proxy_go_custom_register`

Registers a custom plugin written in Go with Fluent Bit's plugin system.

#### `proxy_go_custom_init`

Initializes a custom Go plugin by calling its initialization callback.

#### `proxy_go_custom_destroy`

Destroys a custom Go plugin by calling its cleanup callback.

#### `proxy_go_custom_unregister`

Unregisters a custom Go plugin and frees associated resources.

## Dependencies

- `flb_config.h`: Fluent Bit configuration utilities
- `flb_plugin_proxy.h`: Proxy interface definitions

## Implementation Details

### Plugin Type Support

The header supports three distinct plugin types:

1. **Output Plugins**: Handle sending data to external destinations
2. **Input Plugins**: Handle receiving data from external sources
3. **Custom Plugins**: Handle custom functionality not fitting other categories

### Callback Variants

Each plugin type supports both context-aware and context-free callback variants:

- **Context-Free**: Traditional callback signatures without additional context
- **Context-Aware**: Enhanced callbacks that receive additional context data

This dual approach provides flexibility for Go plugin developers while maintaining backward compatibility.

### Memory Management

The structures are designed for efficient memory management:

- **String Duplication**: Plugin names are duplicated for safe ownership
- **Pointer Management**: Clear separation of API, instance, and context pointers
- **Resource Cleanup**: Dedicated unregister functions for proper cleanup

### ABI Stability

The structures avoid embedding complex objects directly:

- **Opaque Pointers**: Use void pointers for API and instance references
- **Context Separation**: Copy context pointers rather than embedding entire instances
- **Interface Compatibility**: Maintain stable interfaces across versions

## Usage

This header is included by the Go proxy implementation and provides the interface contract between Fluent Bit's C core and Go plugins:

```c
#include "go.h"

// Go plugin implementations use these structures and functions
// to integrate with Fluent Bit's plugin system

// Example usage in plugin registration:
struct flbgo_output_plugin *plugin = flb_malloc(sizeof(struct flbgo_output_plugin));
plugin->cb_init = flb_plugin_proxy_symbol(proxy, "FLBPluginInit");
plugin->cb_flush = flb_plugin_proxy_symbol(proxy, "FLBPluginFlush");
```

The header enables Go developers to write Fluent Bit plugins by providing clear interfaces for plugin registration, initialization, execution, and cleanup. It abstracts the complexity of cross-language communication and provides a stable foundation for Go-based Fluent Bit plugins.