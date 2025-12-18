# flb_engine.c

## Overview

This file implements the core Fluent Bit engine, which serves as the central coordination point for all Fluent Bit operations. It manages the event loop, handles input/output plugin interactions, schedules tasks, and coordinates the overall data processing pipeline.

The engine is responsible for orchestrating data flow from input plugins through filters to output plugins, managing connections, handling retries, and maintaining system health through periodic cleanup operations.

## Key Functions

### `flb_engine_start()`
Initializes and starts the Fluent Bit engine, setting up the event loop and beginning data processing.

### `flb_engine_flush()`
Triggers a flush operation for input plugins, dispatching data to be processed by the engine.

### `flb_engine_destroy_tasks()`
Cleans up and destroys multiple task structures, freeing associated resources.

### `flb_engine_reschedule_retries()`
Reschedules all pending retry tasks to be executed immediately, useful for recovery scenarios.

### `handle_input_event()`
Processes events from input plugins, typically coroutine completion notifications.

### `handle_output_event()`
Handles completion events from output plugins, updating metrics and managing task lifecycle.

### `cb_engine_sched_timer()`
Periodic cleanup function that handles connection timeouts for upstream and downstream connections.

## Important Variables/Constants

### Engine Configuration (`struct flb_config`)
The main configuration structure contains:
- `inputs`: List of input plugin instances
- `outputs`: List of output plugin instances
- `upstreams`: List of upstream connections
- `downstreams`: List of downstream connections
- `event_loop`: Event loop for asynchronous operations
- `task_map`: Array mapping task IDs to task structures
- `scheduler`: Task scheduling subsystem

### Task Management
- `task_map`: Hash table for quick task lookup by ID
- `task_counter`: Global counter for task identification
- Various task-related counters and metrics

### Event Loop Management
- Thread-local event loop storage for multi-threaded environments
- Event handling callbacks for different event types

## Dependencies

- `monkey/mk_core.h`: Monkey HTTP server core
- `fluent-bit/flb_bucket_queue.h`: Bucket queue implementation
- `fluent-bit/flb_event_loop.h`: Event loop management
- `fluent-bit/flb_time.h`: Time utilities
- `fluent-bit/flb_lib.h`: Library interface
- `fluent-bit/flb_info.h`: Core information
- `fluent-bit/flb_bits.h`: Bit manipulation utilities
- `fluent-bit/flb_macros.h`: Macro definitions
- `fluent-bit/flb_pipe.h`: Pipe communication
- `fluent-bit/flb_custom.h`: Custom plugin interface
- `fluent-bit/flb_input.h`: Input plugin interface
- `fluent-bit/flb_output.h`: Output plugin interface
- `fluent-bit/flb_error.h`: Error handling
- `fluent-bit/flb_utils.h`: Utility functions
- `fluent-bit/flb_config.h`: Configuration management
- `fluent-bit/flb_engine.h`: Engine interface
- `fluent-bit/flb_engine_dispatch.h`: Dispatch functionality
- `fluent-bit/flb_network.h`: Network operations
- `fluent-bit/flb_task.h`: Task management
- `fluent-bit/flb_router.h`: Routing functionality
- `fluent-bit/flb_http_server.h`: HTTP server
- `fluent-bit/flb_scheduler.h`: Task scheduling
- `fluent-bit/flb_parser.h`: Parser interface
- `fluent-bit/flb_sosreport.h`: System state reporting
- `fluent-bit/flb_storage.h`: Storage layer
- `fluent-bit/flb_pack.h`: Data packing
- `fluent-bit/flb_metrics.h`: Metrics collection
- `fluent-bit/flb_version.h`: Version information
- `fluent-bit/flb_upstream.h`: Upstream connections
- `fluent-bit/flb_downstream.h`: Downstream connections
- `fluent-bit/flb_ring_buffer.h`: Ring buffer implementation
- `fluent-bit/flb_notification.h`: Notification system
- `fluent-bit/flb_simd.h`: SIMD optimizations

## Implementation Details

1. **Event-Driven Architecture**: The engine uses an event-driven model with a central event loop to handle asynchronous operations efficiently.

2. **Thread-Local Storage**: Uses thread-local storage for the event loop to support multi-threaded environments.

3. **Task Lifecycle Management**: Implements comprehensive task lifecycle management including creation, scheduling, execution, and cleanup.

4. **Retry Handling**: Provides sophisticated retry mechanisms for failed output operations with exponential backoff and immediate rescheduling capabilities.

5. **Metrics Collection**: Integrates with Fluent Bit's metrics system to track performance and operational statistics.

6. **Connection Management**: Handles both upstream (client) and downstream (server) connection timeouts and cleanup.

7. **Conditional Compilation**: Supports various optional features through conditional compilation flags.

## Usage Example

```c
// Initialize Fluent Bit configuration
struct flb_config *config = flb_config_init();

// Load configuration from file
int ret = flb_config_load_file(config, "fluent-bit.conf");
if (ret != 0) {
    flb_error("Failed to load configuration");
    return -1;
}

// Start the Fluent Bit engine
ret = flb_engine_start(config);
if (ret != 0) {
    flb_error("Failed to start Fluent Bit engine");
    return -1;
}

// Run the event loop
while (1) {
    // The engine handles all plugin interactions automatically
    // through the event loop
}

// On shutdown
flb_engine_stop(config);
flb_config_exit(config);
```