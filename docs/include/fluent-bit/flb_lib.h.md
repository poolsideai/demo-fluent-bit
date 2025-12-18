# include/fluent-bit/flb_lib.h

## Overview

The `flb_lib.h` header file defines the interface for Fluent Bit's library API. This header provides the necessary declarations for embedding Fluent Bit functionality into other applications, allowing programmatic control of data collection, processing, and routing.

## Header Guards

```c
#ifndef FLB_LIB_H
#define FLB_LIB_H

/* ... */

#endif
```

Standard header guards prevent multiple inclusion of the header file.

## Included Dependencies

### Core Fluent Bit Headers

```c
#include <fluent-bit/flb_macros.h>
#include <fluent-bit/flb_config.h>
```

These headers provide essential Fluent Bit functionality:
- `flb_macros.h`: Platform-specific macros and definitions
- `flb_config.h`: Configuration system

## Constants

### Library Status Codes

```c
#define FLB_LIB_ERROR     -1
#define FLB_LIB_NONE       0
#define FLB_LIB_OK         1
#define FLB_LIB_NO_CONFIG_MAP 2
```

Status codes used throughout the library interface:
- `FLB_LIB_ERROR`: General error condition
- `FLB_LIB_NONE`: No operation or initial state
- `FLB_LIB_OK`: Successful operation
- `FLB_LIB_NO_CONFIG_MAP`: No configuration map available

## Data Structures

### `struct flb_lib_ctx`

Library mode context data structure:

```c
struct flb_lib_ctx {
    int status;
    struct mk_event_loop *event_loop;
    struct mk_event *event_channel;
    struct flb_config *config;
};
```

**Fields:**
- `status`: Current library status (using FLB_LIB_* constants)
- `event_loop`: Event loop for handling asynchronous operations
- `event_channel`: Event channel for notifications
- `config`: Fluent Bit configuration context

### `struct flb_lib_out_cb`

Callback structure for output plugins:

```c
struct flb_lib_out_cb {
    int (*cb) (void *record, size_t size, void *data);
    void *data;
};
```

**Fields:**
- `cb`: Callback function pointer
- `data`: User data passed to callback

### Type Definitions

```c
typedef struct flb_lib_ctx         flb_ctx_t;
```

Type alias for library context.

## Function Prototypes

### Core Library Functions

#### `flb_init_env`

```c
FLB_EXPORT void flb_init_env();
```

Initializes the Fluent Bit environment.

#### `flb_create`

```c
FLB_EXPORT flb_ctx_t *flb_create();
```

Creates a new Fluent Bit library context.

**Returns:**
- Pointer to new context on success
- NULL on failure

#### `flb_destroy`

```c
FLB_EXPORT void flb_destroy(flb_ctx_t *ctx);
```

Determines a Fluent Bit library context and frees all associated resources.

**Parameters:**
- `ctx`: Context to destroy

#### `flb_start`

```c
FLB_EXPORT int flb_start(flb_ctx_t *ctx);
```

Starts the Fluent Bit engine.

**Parameters:**
- `ctx`: Library context

**Returns:**
- 0 on success
- -1 on failure

#### `flb_start_trace`

```c
FLB_EXPORT int flb_start_trace(flb_ctx_t *ctx);
```

Starts the Fluent Bit engine without setting the global context.

**Parameters:**
- `ctx`: Library context

**Returns:**
- 0 on success
- -1 on failure

#### `flb_stop`

```c
FLB_EXPORT int flb_stop(flb_ctx_t *ctx);
```

Stops the Fluent Bit engine.

**Parameters:**
- `ctx`: Library context

**Returns:**
- 0 on success
- -1 on failure

#### `flb_loop`

```c
FLB_EXPORT int flb_loop(flb_ctx_t *ctx);
```

Runs the Fluent Bit engine in a loop.

**Parameters:**
- `ctx`: Library context

**Returns:**
- 0 on success
- -1 on failure

### Component Registration Functions

#### `flb_input`

```c
FLB_EXPORT int flb_input(flb_ctx_t *ctx, const char *input, void *data);
```

Registers a new input plugin instance.

**Parameters:**
- `ctx`: Library context
- `input`: Name of input plugin
- `data`: Plugin-specific data

**Returns:**
- File descriptor of new input instance on success
- -1 on failure

#### `flb_output`

```c
FLB_EXPORT int flb_output(flb_ctx_t *ctx, const char *output, struct flb_lib_out_cb *cb);
```

Registers a new output plugin instance.

**Parameters:**
- `ctx`: Library context
- `output`: Name of output plugin
- `cb`: Output callback structure

**Returns:**
- File descriptor of new output instance on success
- -1 on failure

#### `flb_filter`

```c
FLB_EXPORT int flb_filter(flb_ctx_t *ctx, const char *filter, void *data);
```

Registers a new filter plugin instance.

**Parameters:**
- `ctx`: Library context
- `filter`: Name of filter plugin
- `data`: Plugin-specific data

**Returns:**
- File descriptor of new filter instance on success
- -1 on failure

### Configuration Functions

#### `flb_input_set`

```c
FLB_EXPORT int flb_input_set(flb_ctx_t *ctx, int ffd, ...);
```

Sets properties for an input instance.

**Parameters:**
- `ctx`: Library context
- `ffd`: File descriptor of input instance
- `...`: Variable arguments for key-value pairs

**Returns:**
- 0 on success
- -1 on failure

#### `flb_output_set`

```c
FLB_EXPORT int flb_output_set(flb_ctx_t *ctx, int ffd, ...);
```

Sets properties for an output instance.

**Parameters:**
- `ctx`: Library context
- `ffd`: File descriptor of output instance
- `...`: Variable arguments for key-value pairs

**Returns:**
- 0 on success
- -1 on failure

#### `flb_filter_set`

```c
FLB_EXPORT int flb_filter_set(flb_ctx_t *ctx, int ffd, ...);
```

Sets properties for a filter instance.

**Parameters:**
- `ctx`: Library context
- `ffd`: File descriptor of filter instance
- `...`: Variable arguments for key-value pairs

**Returns:**
- 0 on success
- -1 on failure

#### `flb_service_set`

```c
FLB_EXPORT int flb_service_set(flb_ctx_t *ctx, ...);
```

Sets service-level properties.

**Parameters:**
- `ctx`: Library context
- `...`: Variable arguments for key-value pairs

**Returns:**
- 0 on success
- -1 on failure

### Property Validation Functions

#### `flb_input_property_check`

```c
FLB_EXPORT int flb_input_property_check(flb_ctx_t *ctx, int ffd, char *key, char *val);
```

Validates if a key-value pair is a valid configuration directive for an input plugin.

#### `flb_output_property_check`

```c
FLB_EXPORT int flb_output_property_check(flb_ctx_t *ctx, int ffd, char *key, char *val);
```

Validates if a key-value pair is a valid configuration directive for an output plugin.

#### `flb_filter_property_check`

```c
FLB_EXPORT int flb_filter_property_check(flb_ctx_t *ctx, int ffd, char *key, char *val);
```

Validates if a key-value pair is a valid configuration directive for a filter plugin.

### Processor Functions

#### `flb_input_set_processor`

```c
FLB_EXPORT int flb_input_set_processor(flb_ctx_t *ctx, int ffd, struct flb_processor *proc);
```

Sets a processor for an input instance.

#### `flb_output_set_processor`

```c
FLB_EXPORT int flb_output_set_processor(flb_ctx_t *ctx, int ffd, struct flb_processor *proc);
```

Sets a processor for an output instance.

### Callback Functions

#### `flb_output_set_callback`

```c
FLB_EXPORT int flb_output_set_callback(flb_ctx_t *ctx, int ffd, char *name, void (*cb)(char *, void *, void *));
```

Sets a callback function for an output instance.

### Test Functions

#### `flb_input_set_test`

```c
FLB_EXPORT int flb_input_set_test(flb_ctx_t *ctx, int ffd, char *test_name, void (*in_callback) (void *, int, int, void *, size_t, void *), void *in_callback_data);
```

Enables test mode for an input instance.

#### `flb_output_set_http_test`

```c
FLB_EXPORT int flb_output_set_http_test(flb_ctx_t *ctx, int ffd, char *test_name, void (*out_response) (void *, int, int, void *, size_t, void *), void *out_callback_data);
```

Enables HTTP test mode for an output instance.

#### `flb_output_set_test`

```c
FLB_EXPORT int flb_output_set_test(flb_ctx_t *ctx, int ffd, char *test_name, void (*out_callback) (void *, int, int, void *, size_t, void *), void *out_callback_data, void *test_ctx);
```

Enables test mode for an output instance.

### Data Ingestion Functions

#### `flb_lib_push`

```c
FLB_EXPORT int flb_lib_push(flb_ctx_t *ctx, int ffd, const void *data, size_t len);
```

Pushes data into the Fluent Bit engine.

**Parameters:**
- `ctx`: Library context
- `ffd`: File descriptor of input instance
- `data`: Data to push
- `len`: Length of data

**Returns:**
- 0 on success
- -1 on failure

#### `flb_lib_response`

```c
FLB_EXPORT int flb_lib_response(flb_ctx_t *ctx, int ffd, int status, const void *data, size_t len);
```

Emulates an HTTP response for an output plugin.

#### `flb_lib_free`

```c
FLB_EXPORT int flb_lib_free(void *data);
```

Frees memory allocated by the library.

### Configuration Functions

#### `flb_lib_config_file`

```c
FLB_EXPORT int flb_lib_config_file(struct flb_lib_ctx *ctx, const char *path);
```

Loads a configuration file for the library context.

### Time Functions

#### `flb_time_now`

```c
FLB_EXPORT double flb_time_now();
```

Returns the current time as a double.

### Context Management Functions

#### `flb_context_set`

```c
FLB_EXPORT void flb_context_set(flb_ctx_t *ctx);
```

Sets the active library context.

#### `flb_context_get`

```c
FLB_EXPORT flb_ctx_t *flb_context_get();
```

Gets the active library context.

#### `flb_cf_context_set`

```c
FLB_EXPORT void flb_cf_context_set(struct flb_cf *cf);
```

Sets the active configuration context.

#### `flb_cf_context_get`

```c
FLB_EXPORT struct flb_cf *flb_cf_context_get();
```

Gets the active configuration context.

## Dependencies

This header depends on:

1. **Fluent Bit Core**: For basic types and configuration system
2. **Export Macros**: For symbol visibility control
3. **Forward Declarations**: For processor and configuration structures

## Integration with Fluent Bit

The library interface integrates with Fluent Bit's core systems:

1. **Configuration**: Uses Fluent Bit's configuration system
2. **Threading**: Designed for thread-safe operation
3. **Memory Management**: Uses Fluent Bit's memory allocation functions
4. **Event Loop**: Integrates with Fluent Bit's event loop system
5. **Plugin Architecture**: Works with Fluent Bit's plugin system

## Thread Safety

The library interface is designed to be thread-safe:

1. **Reentrant Functions**: No static or global state
2. **Immutable Parameters**: Functions don't modify input parameters
3. **Session Isolation**: Each context has isolated resources
4. **Thread Management**: Proper thread creation and cleanup

## Performance Characteristics

The library interface is optimized for performance:

1. **Asynchronous Processing**: Non-blocking operations through event loops
2. **Efficient Memory**: Proper memory management with minimal overhead
3. **Thread Management**: Efficient worker thread usage
4. **Event-Driven**: Minimal CPU usage when idle

## Resource Management

The library carefully manages all resources:

1. **Memory**: Uses Fluent Bit's memory management
2. **Threads**: Proper thread creation and joining
3. **Network Resources**: Proper cleanup of network connections
4. **Event Loop**: Proper cleanup of event loop resources

## Security Considerations

The library implementation includes several security features:

1. **Input Validation**: Validates all function parameters
2. **Buffer Bounds**: Prevents buffer overflows
3. **Resource Limits**: Enforces reasonable size limits
4. **Memory Safety**: Proper cleanup of all resources

## Usage Example

The library interface is typically used as follows:

```c
#include <fluent-bit/flb_lib.h>

// Create context
flb_ctx_t *ctx = flb_create();

if (ctx != NULL) {
    // Configure input
    int in_ffd = flb_input(ctx, "lib", NULL);
    flb_input_set(ctx, in_ffd, "tag", "my.tag", NULL);

    // Configure output
    struct flb_lib_out_cb cb;
    cb.cb = my_output_callback;
    cb.data = NULL;
    int out_ffd = flb_output(ctx, "stdout", &cb);

    // Start engine
    flb_start(ctx);

    // Push data
    const char *data = "{\"message\": \"Hello World\"}";
    flb_lib_push(ctx, in_ffd, data, strlen(data));

    // Stop engine
    flb_stop(ctx);

    // Destroy context
    flb_destroy(ctx);
}
```

## Error Handling

The library interface follows robust error handling practices:

1. **Null Pointer Checks**: Validates all input parameters
2. **Resource Cleanup**: Proper cleanup on error conditions
3. **Return Value Conventions**: Uses standard Fluent Bit return value conventions
4. **Logging**: Appropriate error logging

## Extensibility

The design allows for easy extension:

1. **New Plugins**: Can add support for additional input/output/filter plugins
2. **Custom Processors**: Flexible processor mechanism for data transformation
3. **Callback System**: Extensible callback mechanism for custom behavior
4. **Test Framework**: Built-in testing capabilities for plugins

## Build Configuration

The library interface supports various build configurations:

1. **Windows Support**: Conditional compilation for Windows sockets
2. **Memory Tracing**: Optional memory tracing support
3. **AWS Error Reporting**: Optional AWS error reporting integration
4. **Cross-Platform**: Designed to work across different operating systems

## Related Components

This header works in conjunction with:

1. **src/flb_lib.c**: Implementation of the library functions
2. **Input Plugins**: Use the library interface for data collection
3. **Output Plugins**: Use the library interface for data routing
4. **Filter Plugins**: Use the library interface for data transformation

## Export Control

All functions are marked with `FLB_EXPORT` to control symbol visibility:

1. **Shared Libraries**: Ensures proper symbol export for shared libraries
2. **Static Linking**: Works correctly with static linking
3. **Cross-Platform**: Consistent behavior across different platforms