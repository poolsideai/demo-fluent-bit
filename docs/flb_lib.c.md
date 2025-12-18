# flb_lib.c

## Overview

The `flb_lib.c` file implements the core library interface for Fluent Bit. It provides the foundation for embedding Fluent Bit functionality into other applications by exposing a clean API for creating, configuring, and managing Fluent Bit instances programmatically.

This file contains the main library functions that allow external applications to:
- Create and destroy Fluent Bit contexts
- Configure input, output, and filter plugins
- Start and stop the Fluent Bit engine
- Push data into the system
- Handle responses from output plugins

## Key Functions

### `flb_create`
Creates a new Fluent Bit context and initializes its internal structures including configuration, event loop, and communication channels.

### `flb_destroy`
Releases all resources associated with a Fluent Bit context, including the event loop, configuration, and communication channels.

### `flb_input`
Creates a new input instance of the specified type within the Fluent Bit context.

### `flb_output`
Creates a new output instance of the specified type within the Fluent Bit context.

### `flb_filter`
Creates a new filter instance of the specified type within the Fluent Bit context.

### `flb_start`
Starts the Fluent Bit engine in a separate worker thread, allowing the calling application to continue execution.

### `flb_stop`
Stops the Fluent Bit engine and cleans up associated resources.

### `flb_lib_push`
Pushes data into the Fluent Bit pipeline through a specified input instance.

### `flb_lib_response`
Emulates HTTP responses for testing output plugins.

## Data Structures

### `struct flb_lib_ctx`
Represents the Fluent Bit library context with the following fields:
- `status`: Current status of the context (error, none, ok)
- `event_loop`: Pointer to the event loop structure
- `event_channel`: Pointer to the event channel structure
- `config`: Pointer to the configuration structure

### `struct flb_lib_out_cb`
Used to define callbacks for output plugins with the following fields:
- `cb`: Function pointer to the callback function
- `data`: Opaque data pointer for the callback

## Dependencies

- `<fluent-bit/flb_lib.h>`: Header file with declarations
- `<fluent-bit/flb_mem.h>`: Memory management functions
- `<fluent-bit/flb_pipe.h>`: Pipe communication utilities
- `<fluent-bit/flb_engine.h>`: Engine management functions
- `<fluent-bit/flb_input.h>`: Input plugin interface
- `<fluent-bit/flb_output.h>`: Output plugin interface
- `<fluent-bit/flb_filter.h>`: Filter plugin interface
- `<fluent-bit/flb_utils.h>`: Utility functions
- `<fluent-bit/flb_time.h>`: Time handling functions
- `<fluent-bit/flb_coro.h>`: Coroutine support
- `<fluent-bit/flb_callback.h>`: Callback management
- `<fluent-bit/flb_kv.h>`: Key-value pair management
- `<fluent-bit/flb_metrics.h>`: Metrics collection
- `<fluent-bit/flb_upstream.h>`: Upstream connection management
- `<fluent-bit/flb_downstream.h>`: Downstream connection management
- `<fluent-bit/tls/flb_tls.h>`: TLS support
- `<signal.h>`: Signal handling
- `<stdarg.h>`: Variable argument lists
- System-specific headers for Windows socket initialization

## Implementation Details

The library implementation follows a thread-safe design using TLS (Thread Local Storage) for context management. It creates a separate worker thread for the Fluent Bit engine to avoid blocking the calling application.

Key architectural features:
- Uses pipes for communication between the main thread and worker thread
- Implements proper resource cleanup in case of errors
- Supports both normal operation and test modes for plugins
- Handles platform-specific differences (Windows vs Unix-like systems)
- Integrates with the Monkey framework's event loop system

## Usage Examples

```c
// Create a Fluent Bit context
flb_ctx_t *ctx = flb_create();
if (!ctx) {
    fprintf(stderr, "Failed to create Fluent Bit context\n");
    return -1;
}

// Configure service settings
flb_service_set(ctx, "Flush", "1", "Log_Level", "info", NULL);

// Add an input plugin
int in_ffd = flb_input(ctx, "lib", NULL);
if (in_ffd == -1) {
    fprintf(stderr, "Failed to create input plugin\n");
    flb_destroy(ctx);
    return -1;
}

// Set input properties
flb_input_set(ctx, in_ffd, "tag", "test", NULL);

// Add an output plugin
struct flb_lib_out_cb out_cb = { .cb = my_output_callback, .data = NULL };
int out_ffd = flb_output(ctx, "stdout", &out_cb);
if (out_ffd == -1) {
    fprintf(stderr, "Failed to create output plugin\n");
    flb_destroy(ctx);
    return -1;
}

// Start the engine
int ret = flb_start(ctx);
if (ret == -1) {
    fprintf(stderr, "Failed to start engine\n");
    flb_destroy(ctx);
    return -1;
}

// Push some data
const char *data = "some log data";
flb_lib_push(ctx, in_ffd, data, strlen(data));

// Clean up
flb_stop(ctx);
flb_destroy(ctx);
```