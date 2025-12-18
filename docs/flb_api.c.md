# flb_api.c

## Overview

This file implements the API interface for Fluent Bit plugins. It provides a standardized way for plugins to interact with the core Fluent Bit engine through function pointers.

The module serves as a bridge between the core engine and plugins, exposing essential functions that plugins need to access Fluent Bit's features such as property retrieval, logging, and metrics.

## Key Functions

### `flb_api_create()`
Creates a new API context structure and initializes function pointers to core engine functions. This context is passed to plugins to enable them to call core functions.

### `flb_api_destroy()`
Destroys the API context, freeing the allocated memory.

## Important Variables/Constants

### API Context Structure
The `struct flb_api` contains function pointers for:
- `output_get_property`: Function to retrieve output plugin properties
- `input_get_property`: Function to retrieve input plugin properties
- `custom_get_property`: Function to retrieve custom plugin properties
- `log_print`: Function for logging messages
- `input_log_check`: Function to check input plugin logging
- `output_log_check`: Function to check output plugin logging
- `custom_log_check`: Function to check custom plugin logging
- `output_get_cmt_instance`: Function to retrieve CMT (Continuous Metrics) instance for output plugins (when metrics are enabled)
- `input_get_cmt_instance`: Function to retrieve CMT instance for input plugins (when metrics are enabled)

## Dependencies

- `fluent-bit/flb_info.h`: Fluent Bit core information
- `fluent-bit/flb_api.h`: API interface headers
- `fluent-bit/flb_mem.h`: Memory management utilities
- `fluent-bit/flb_log.h`: Logging utilities
- `fluent-bit/flb_input.h`: Input plugin interface
- `fluent-bit/flb_output.h`: Output plugin interface
- `fluent-bit/flb_custom.h`: Custom plugin interface

## Implementation Details

1. **Function Pointer Interface**: The API uses function pointers to provide a stable interface that can be updated without breaking existing plugins.

2. **Conditional Compilation**: Metrics-related functions are only included when `FLB_HAVE_METRICS` is defined.

3. **Memory Management**: Uses Fluent Bit's memory allocation functions (`flb_malloc`, `flb_free`) for consistency.

4. **API Stability**: The API structure is designed to be extensible while maintaining backward compatibility.

## Usage Example

```c
// Create API context
struct flb_api *api_ctx = flb_api_create();

// Pass API context to plugin
my_plugin_init(api_ctx);

// Plugin can then use API functions like:
api_ctx->log_print(FLB_LOG_INFO, "Plugin initialized");

// Clean up
flb_api_destroy(api_ctx);
```