# flb_task.c

## Overview

This file implements the task management system for Fluent Bit, which is responsible for handling data processing workflows between input and output plugins. Tasks represent units of work that need to be processed, including routing data to appropriate output plugins and managing retry mechanisms for failed deliveries.

The task system provides:
- Task creation and lifecycle management
- Routing of data to appropriate output plugins
- Retry handling for failed output operations
- Task queuing and scheduling
- Resource tracking and cleanup

Each task encapsulates a data chunk along with metadata about its source, destination routes, and processing status. The system ensures reliable data delivery through retry mechanisms and proper resource management.

## Key Functions

### `flb_task_create()`
Creates a new task for processing data from an input plugin to output plugins. Establishes routing paths based on configuration and initializes task metadata.

### `flb_task_destroy()`
Destroys a task and releases all associated resources, including routes, retries, and data chunks. Ensures proper cleanup to prevent memory leaks.

### `flb_task_retry_create()`
Creates or reuses a retry context for a task when an output operation fails. Manages retry limits and tracks attempt counts.

### `flb_task_retry_reschedule()`
Reschedules a failed task retry for future execution, typically after a delay based on retry policies.

### `flb_task_retry_clean()`
Removes retry contexts associated with a specific output plugin, useful when output plugins are removed or reconfigured.

### `flb_task_running_count()`
Returns the count of currently active tasks, which helps in monitoring system load and resource usage.

### `flb_task_running_print()`
Prints diagnostic information about currently running tasks, useful for debugging and monitoring.

## Important Variables/Constants

### Task States
- `FLB_TASK_NEW`: Task has been created but not yet processed
- `FLB_TASK_RUNNING`: Task is actively being processed
- `FLB_TASK_PENDING`: Task is waiting for resources or scheduling

### Task Structures
- `struct flb_task`: Main task structure containing metadata, routes, and data references
- `struct flb_task_route`: Represents a routing path to an output plugin
- `struct flb_task_retry`: Manages retry attempts for failed output operations
- `struct flb_task_queue`: Queue for managing task execution order

### Task Management
- Task ID mapping system for quick lookup
- Reference counting for tracking active users of tasks
- Route lists for managing multiple output destinations
- Retry lists for tracking failed delivery attempts

## Dependencies

- Standard C library headers for memory management and data structures
- Fluent Bit core components:
  - `flb_config.h`: Configuration management
  - `flb_input.h`: Input plugin interface
  - `flb_input_chunk.h`: Input chunk management
  - `flb_output.h`: Output plugin interface
  - `flb_router.h`: Routing functionality
  - `flb_mem.h`: Memory allocation utilities
  - `flb_str.h`: String manipulation utilities
  - `flb_scheduler.h`: Task scheduling system
  - `flb_task.h`: Task interface definitions

## Implementation Details

1. **Task Lifecycle**: Tasks progress through creation, routing, processing, and destruction phases with proper state management.

2. **Routing System**: Implements flexible routing where tasks can be sent to multiple output plugins based on configuration rules and event types.

3. **Retry Mechanism**: Provides sophisticated retry handling with configurable limits, exponential backoff, and automatic rescheduling.

4. **Resource Management**: Careful tracking of memory usage and proper cleanup to prevent leaks, especially important for long-running processes.

5. **Thread Safety**: Uses mutex locks to ensure thread-safe access to task structures in multi-threaded environments.

6. **Direct Connections**: Supports direct input-to-output connections for optimized data flow in simple configurations.

7. **Metrics Integration**: Tracks task-related metrics for monitoring and performance analysis.

## Usage Example

```c
// Create a task for processing input data
struct flb_task *task = flb_task_create(
    ref_id,
    buf,
    size,
    i_ins,
    ic,
    tag_buf,
    tag_len,
    config,
    &err
);

if (task && !err) {
    // Task created successfully, will be processed by the engine
    flb_debug("[task] created task=%p id=%i OK", task, task->id);
}

// Later, when task processing completes or fails
if (need_retry) {
    struct flb_task_retry *retry = flb_task_retry_create(task, o_ins);
    if (retry) {
        flb_task_retry_reschedule(retry, config);
    }
}

// Clean up task when no longer needed
flb_task_destroy(task, FLB_TRUE);
```