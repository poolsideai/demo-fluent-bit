# flb_input_thread.c

## Overview

This file contains the implementation for managing threaded input plugins in Fluent Bit. It provides functionality for creating and managing separate threads for input plugins, handling inter-thread communication, and coordinating event loops between the main engine and plugin threads.

The module implements a complete threading system that allows input plugins to run in isolated threads with their own event loops, schedulers, and connection management. This enables non-blocking operations and better resource utilization for I/O-intensive input plugins.

Threaded input plugins operate independently from the main Fluent Bit engine thread, communicating through pipe-based messaging systems and maintaining their own coroutine contexts for cooperative multitasking.

## Key Functions

### Thread Instance Management

#### `flb_input_thread_instance_init()`
Initializes a threaded input plugin instance, creating the necessary thread context, event loops, communication channels, and spawning the worker thread.

#### `flb_input_thread_instance_pre_run()`
Handles pre-run initialization for threaded input plugins, ensuring proper synchronization between threads.

#### `flb_input_thread_instance_pause()`
Signals a threaded input plugin to pause its operations.

#### `flb_input_thread_instance_resume()`
Signals a threaded input plugin to resume its operations.

#### `flb_input_thread_instance_exit()`
Signals a threaded input plugin to exit and waits for thread termination.

### Collector Management

#### `flb_input_thread_collectors_signal_start()`
Sends a signal to start collectors in a threaded input plugin.

#### `flb_input_thread_collectors_signal_wait()`
Waits for a signal indicating that collectors have started in a threaded input plugin.

#### `flb_input_thread_collectors_start()`
Actually starts all collectors for a threaded input plugin.

### Internal Thread Functions

#### `input_thread()`
The main function executed by the worker thread, containing the event loop and processing logic.

#### `input_thread_instance_create()`
Creates a new threaded input instance with all necessary resources.

#### `input_thread_instance_destroy()`
Destroys a threaded input instance and frees all associated resources.

### Event Handling

#### `engine_handle_event()`
Handles events received by the threaded input plugin's event loop.

#### `handle_input_event()`
Handles specific input events from the parent thread.

#### `handle_input_thread_event()`
Handles events within the threaded input plugin's own event loop.

### Status Management

#### `input_thread_instance_set_status()`
Sets the initialization status of a threaded input plugin.

#### `input_thread_instance_get_status()`
Waits for and retrieves the initialization status of a threaded input plugin.

### Utility Functions

#### `cb_thread_sched_timer()`
Scheduler callback that runs periodically to handle timeouts and cleanup tasks.

#### `input_collector_fd()`
Handles file descriptor events for input collectors.

#### `flb_input_thread_wait_until_is_ready()`
Waits for a threaded input plugin to become ready for operation.

#### `flb_input_thread_init_fail()`
Handles initialization failure for threaded input plugins.

#### `flb_input_thread_is_ready()`
Checks if a threaded input plugin is ready for operation.

## Important Variables/Constants

### Message Types
- `FLB_INPUT_THREAD_TO_PARENT`: Messages from child thread to parent thread (1)
- `FLB_INPUT_THREAD_TO_THREAD`: Messages within the child thread (2)

### Operation Codes
- `FLB_INPUT_THREAD_PAUSE`: Pause operation code (1)
- `FLB_INPUT_THREAD_RESUME`: Resume operation code (2)
- `FLB_INPUT_THREAD_EXIT`: Exit operation code (3)
- `FLB_INPUT_THREAD_START_COLLECTORS`: Start collectors operation code (4)
- `FLB_INPUT_THREAD_OK`: Initialization success status (5)
- `FLB_INPUT_THREAD_ERROR`: Initialization error status (6)
- `FLB_INPUT_THREAD_NOT_READY`: Not ready status (7)

### Buffer Size
- `BUFFER_SIZE`: Size of temporary buffer for MessagePack data (65535 bytes)

### Data Structures
- `struct flb_input_thread`: Represents a threaded input plugin with mutex, exit flag, file descriptors, callback, and buffer management
- `struct flb_input_thread_instance`: Main threaded input instance structure containing event loops, communication channels, and synchronization primitives

## Dependencies

- `fluent-bit/flb_info.h`: Core Fluent Bit information
- `fluent-bit/flb_pipe.h`: Pipe communication utilities
- `fluent-bit/flb_engine.h`: Engine interface
- `fluent-bit/flb_mem.h`: Memory management utilities
- `fluent-bit/flb_mp.h`: MessagePack utilities
- `fluent-bit/flb_log.h`: Logging utilities
- `fluent-bit/flb_event_loop.h`: Event loop interface
- `fluent-bit/flb_utils.h`: Utility functions
- `fluent-bit/flb_scheduler.h`: Task scheduling
- `fluent-bit/flb_downstream.h`: Downstream connection management
- `fluent-bit/flb_input.h`: Input plugin interface
- `fluent-bit/flb_input_plugin.h`: Plugin interface definitions
- `fluent-bit/flb_input_thread.h`: Header file defining the interface
- `fluent-bit/flb_notification.h`: Notification system
- `fluent-bit/flb_thread_pool.h`: Thread pool management
- `mpack/mpack.h`: MessagePack serialization library

## Implementation Details

1. **Thread Isolation**: Complete isolation of threaded input plugins with separate event loops, schedulers, and connection management.

2. **Inter-Thread Communication**: Robust pipe-based messaging system for communication between main engine and plugin threads.

3. **Synchronization Primitives**: Proper use of mutexes, condition variables, and atomic operations for thread safety.

4. **Event Loop Integration**: Full integration with Monkey Core event loop for efficient event handling in threaded contexts.

5. **Coroutine Support**: Dedicated coroutine management within threaded contexts for cooperative multitasking.

6. **Resource Management**: Comprehensive resource allocation and cleanup with proper error handling.

7. **Timeout Handling**: Built-in timeout management for network connections and other time-sensitive operations.

8. **Scheduler Integration**: Integration with Fluent Bit's scheduler for periodic task execution.

9. **DNS Context Management**: Thread-local DNS context for network operations.

10. **Notification System**: Integration with Fluent Bit's notification system for async event handling.

## Usage Example

```c
// Initialize a threaded input plugin instance
struct flb_config *config;
struct flb_input_instance *instance;
// ... initialize config and instance ...

// Initialize the threaded input instance
int ret = flb_input_thread_instance_init(config, instance);
if (ret == 0) {
    printf("Threaded input instance initialized successfully\n");
} else {
    printf("Failed to initialize threaded input instance\n");
}

// Example of controlling a threaded input plugin
struct flb_input_instance *instance;
// ... initialize instance ...

// Pause the threaded input plugin
int ret = flb_input_thread_instance_pause(instance);
if (ret == 0) {
    printf("Threaded input plugin paused\n");
} else {
    printf("Failed to pause threaded input plugin\n");
}

// Resume the threaded input plugin
ret = flb_input_thread_instance_resume(instance);
if (ret == 0) {
    printf("Threaded input plugin resumed\n");
} else {
    printf("Failed to resume threaded input plugin\n");
}

// Gracefully exit the threaded input plugin
ret = flb_input_thread_instance_exit(instance);
if (ret == 0) {
    printf("Threaded input plugin exited successfully\n");
} else {
    printf("Failed to exit threaded input plugin\n");
}

// Example of collector management
struct flb_input_instance *instance;
// ... initialize instance ...

// Signal collectors to start
int ret = flb_input_thread_collectors_signal_start(instance);
if (ret == 0) {
    printf("Collectors signaled to start\n");
} else {
    printf("Failed to signal collectors start\n");
}

// Wait for collectors signal
ret = flb_input_thread_collectors_signal_wait(instance);
if (ret == 0) {
    printf("Collectors signal received\n");
} else {
    printf("Failed to receive collectors signal\n");
}

// Actually start collectors
ret = flb_input_thread_collectors_start(instance);
if (ret == 0) {
    printf("Collectors started successfully\n");
} else {
    printf("Failed to start collectors\n");
}

// Example of status checking
struct flb_input_instance *instance;
// ... initialize instance ...

// Wait until the threaded input is ready
int ret = flb_input_thread_wait_until_is_ready(instance);
if (ret == 0) {
    printf("Threaded input is ready\n");
} else {
    printf("Threaded input is not ready\n");
}

// Check if threaded input is ready (non-blocking)
ret = flb_input_thread_is_ready(instance);
if (ret == 0) {
    printf("Threaded input is ready\n");
} else {
    printf("Threaded input is not ready\n");
}
```