# src/flb_lib.c

## Overview

The `flb_lib.c` file implements Fluent Bit's library interface, providing a programmatic API for embedding Fluent Bit functionality into other applications. This module serves as the core interface between Fluent Bit and external applications that want to use its data processing capabilities.

## Included Headers

```c
#include <fluent-bit/flb_lib.h>
#include <fluent-bit/flb_mem.h>
#include <fluent-bit/flb_pipe.h>
#include <fluent-bit/flb_engine.h>
#include <fluent-bit/flb_input.h>
#include <fluent-bit/flb_output.h>
#include <fluent-bit/flb_filter.h>
#include <fluent-bit/flb_utils.h>
#include <fluent-bit/flb_time.h>
#include <fluent-bit/flb_coro.h>
#include <fluent-bit/flb_callback.h>
#include <fluent-bit/flb_kv.h>
#include <fluent-bit/flb_metrics.h>
#include <fluent-bit/flb_upstream.h>
#include <fluent-bit/flb_downstream.h>
#include <fluent-bit/tls/flb_tls.h>
#include <signal.h>
#include <stdarg.h>
```

These headers provide essential Fluent Bit functionality and system interfaces:
- `flb_lib.h`: Library interface definitions
- `flb_mem.h`: Memory management functions
- `flb_pipe.h`: Inter-process communication pipes
- `flb_engine.h`: Core engine functionality
- `flb_input.h`: Input plugin interface
- `flb_output.h`: Output plugin interface
- `flb_filter.h`: Filter plugin interface
- `flb_utils.h`: Utility functions
- `flb_time.h`: Time handling functions
- `flb_coro.h`: Coroutine support
- `flb_callback.h`: Callback management
- `flb_kv.h`: Key-value pair handling
- `flb_metrics.h`: Metrics collection
- `flb_upstream.h`: Upstream connection management
- `flb_downstream.h`: Downstream connection management
- `flb_tls.h`: TLS/SSL support
- `signal.h`: Signal handling
- `stdarg.h`: Variable argument lists

## Thread Local Storage Definitions

```c
FLB_TLS_DEFINE(flb_ctx_t, flb_lib_active_context);
FLB_TLS_DEFINE(struct flb_cf, flb_lib_active_cf_context);
```

Thread-local storage variables for maintaining context information across threads.

## Helper Functions

### Instance Retrieval Functions

#### `in_instance_get`

```c
static inline struct flb_input_instance *in_instance_get(flb_ctx_t *ctx, int ffd)
```

Retrieves an input instance by its file descriptor.

#### `out_instance_get`

```c
static inline struct flb_output_instance *out_instance_get(flb_ctx_t *ctx, int ffd)
```

Retrieves an output instance by its file descriptor.

#### `filter_instance_get`

```c
static inline struct flb_filter_instance *filter_instance_get(flb_ctx_t *ctx, int ffd)
```

Retrieves a filter instance by its file descriptor.

### Configuration Validation Functions

#### `flb_config_map_property_check`

Helper function to validate configuration properties against a config map.

## Core Library Functions

### Environment Initialization

#### `flb_init_env`

```c
void flb_init_env()
```

Initializes the Fluent Bit environment, including TLS, coroutines, upstream connections, and downstream connections.

### Context Management

#### `flb_create`

```c
flb_ctx_t *flb_create()
```

Creates a new Fluent Bit library context.

**Returns:**
- Pointer to new context on success
- NULL on failure

#### `flb_destroy`

```c
void flb_destroy(flb_ctx_t *ctx)
```

Determines a Fluent Bit library context and frees all associated resources.

**Parameters:**
- `ctx`: Context to destroy

### Component Registration

#### `flb_input`

```c
int flb_input(flb_ctx_t *ctx, const char *input, void *data)
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
int flb_output(flb_ctx_t *ctx, const char *output, struct flb_lib_out_cb *cb)
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
int flb_filter(flb_ctx_t *ctx, const char *filter, void *data)
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
int flb_input_set(flb_ctx_t *ctx, int ffd, ...)
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
int flb_output_set(flb_ctx_t *ctx, int ffd, ...)
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
int flb_filter_set(flb_ctx_t *ctx, int ffd, ...)
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
int flb_service_set(flb_ctx_t *ctx, ...)
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
int flb_input_property_check(flb_ctx_t *ctx, int ffd, char *key, char *val)
```

Validates if a key-value pair is a valid configuration directive for an input plugin.

#### `flb_output_property_check`

```c
int flb_output_property_check(flb_ctx_t *ctx, int ffd, char *key, char *val)
```

Validates if a key-value pair is a valid configuration directive for an output plugin.

#### `flb_filter_property_check`

```c
int flb_filter_property_check(flb_ctx_t *ctx, int ffd, char *key, char *val)
```

Validates if a key-value pair is a valid configuration directive for a filter plugin.

### Processor Functions

#### `flb_input_set_processor`

```c
int flb_input_set_processor(flb_ctx_t *ctx, int ffd, struct flb_processor *proc)
```

Sets a processor for an input instance.

#### `flb_output_set_processor`

```c
int flb_output_set_processor(flb_ctx_t *ctx, int ffd, struct flb_processor *proc)
```

Sets a processor for an output instance.

### Callback Functions

#### `flb_output_set_callback`

```c
int flb_output_set_callback(flb_ctx_t *ctx, int ffd, char *name, void (*cb)(char *, void *, void *))
```

Sets a callback function for an output instance.

### Test Functions

#### `flb_input_set_test`

```c
int flb_input_set_test(flb_ctx_t *ctx, int ffd, char *test_name, void (*in_callback) (void *, int, int, void *, size_t, void *), void *in_callback_data)
```

Enables test mode for an input instance.

#### `flb_output_set_http_test`

```c
int flb_output_set_http_test(flb_ctx_t *ctx, int ffd, char *test_name, void (*out_response) (void *, int, int, void *, size_t, void *), void *out_callback_data)
```

Enables HTTP test mode for an output instance.

#### `flb_output_set_test`

```c
int flb_output_set_test(flb_ctx_t *ctx, int ffd, char *test_name, void (*out_callback) (void *, int, int, void *, size_t, void *), void *out_callback_data, void *test_ctx)
```

Enables test mode for an output instance.

### Data Ingestion Functions

#### `flb_lib_push`

```c
int flb_lib_push(flb_ctx_t *ctx, int ffd, const void *data, size_t len)
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
int flb_lib_response(flb_ctx_t *ctx, int ffd, int status, const void *data, size_t len)
```

Emulates an HTTP response for an output plugin.

#### `flb_lib_free`

```c
int flb_lib_free(void* data)
```

Frees memory allocated by the library.

### Engine Control Functions

#### `flb_start`

```c
int flb_start(flb_ctx_t *ctx)
```

Starts the Fluent Bit engine.

**Parameters:**
- `ctx`: Library context

**Returns:**
- 0 on success
- -1 on failure

#### `flb_start_trace`

```c
int flb_start_trace(flb_ctx_t *ctx)
```

Starts the Fluent Bit engine without setting the global context.

#### `flb_stop`

```c
int flb_stop(flb_ctx_t *ctx)
```

Stops the Fluent Bit engine.

#### `flb_loop`

```c
int flb_loop(flb_ctx_t *ctx)
```

Runs the Fluent Bit engine in a loop.

### Configuration Functions

#### `flb_lib_config_file`

```c
int flb_lib_config_file(struct flb_lib_ctx *ctx, const char *path)
```

Loads a configuration file for the library context.

### Time Functions

#### `flb_time_now`

```c
double flb_time_now()
```

Returns the current time as a double.

### Context Management Functions

#### `flb_context_set`

```c
void flb_context_set(flb_ctx_t *ctx)
```

Sets the active library context.

#### `flb_context_get`

```c
flb_ctx_t *flb_context_get()
```

Gets the active library context.

#### `flb_cf_context_set`

```c
void flb_cf_context_set(struct flb_cf *cf)
```

Sets the active configuration context.

#### `flb_cf_context_get`

```c
struct flb_cf *flb_cf_context_get()
```

Gets the active configuration context.

### Worker Functions

#### `flb_lib_worker`

```c
static void flb_lib_worker(void *data)
```

Worker thread function that runs the Fluent Bit engine.

## Dependencies

This module depends on:

1. **Fluent Bit Core**: For basic types, memory management, and system interfaces
2. **Thread-Local Storage**: For maintaining context information
3. **Event Loop**: For asynchronous event handling
4. **Plugin Systems**: For input, output, and filter plugin interfaces

## Integration with Fluent Bit

The library interface integrates with Fluent Bit's core systems:

1. **Configuration**: Uses Fluent Bit's configuration system
2. **Threading**: Uses pthreads for worker thread management
3. **Memory Management**: Uses Fluent Bit's memory allocation functions
4. **Event Loop**: Integrates with Fluent Bit's event loop system
5. **Plugin Architecture**: Works with Fluent Bit's plugin system

## Thread Safety

The library implementation is designed to be thread-safe:

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

The library implementation follows robust error handling practices:

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