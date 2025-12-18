# flb_task.c

## Overview

The `flb_task.c` file implements the task management system for Fluent Bit. Tasks represent units of work that need to be processed by output plugins. Each task encapsulates data, routing information, and state management for efficient processing of log events through the Fluent Bit pipeline.

## Key Functions

### `flb_task_create()`
Creates a new task with the provided data buffer, input instance, chunk, tag, and configuration. This function handles routing logic to determine which output plugins should receive the task.

### `flb_task_destroy()`
Destroys a task and frees all associated resources including routes, retries, and the underlying chunk.

### `flb_task_retry_*()`
A family of functions for managing task retries when output plugins fail to process data:
- `flb_task_retry_create()` - Creates a retry context for a failed task
- `flb_task_retry_reschedule()` - Reschedules a retry attempt
- `flb_task_retry_destroy()` - Cleans up a retry context
- `flb_task_retry_clean()` - Removes retry contexts for specific output instances
- `flb_task_retry_count()` - Gets the retry count for a specific output instance

### `flb_task_running_count()`
Returns the number of currently active tasks (tasks with users or retries).

### `flb_task_running_print()`
Prints information about currently running tasks for debugging purposes.

### `flb_task_queue_*()`
Functions for managing task queues:
- `flb_task_queue_create()` - Creates a new task queue
- `flb_task_queue_destroy()` - Destroys a task queue and frees resources

## Important Variables and Constants

### Task Status Constants
- `FLB_TASK_NEW` - Task has been created but not yet processed
- `FLB_TASK_RUNNING` - Task is currently being processed
- `FLB_TASK_DONE` - Task has completed successfully

### Task Route Status Constants
- `FLB_TASK_ROUTE_ACTIVE` - Route is currently active
- `FLB_TASK_ROUTE_INACTIVE` - Route is inactive
- `FLB_TASK_ROUTE_FAILED` - Route processing failed

### Task Structure Fields
- `id` - Unique identifier for the task
- `status` - Current processing status
- `users` - Number of active users of this task
- `routes` - List of output plugin routes for this task
- `retries` - List of retry contexts for failed routes
- `event_chunk` - The event data chunk being processed
- `i_ins` - Associated input instance
- `ic` - Associated input chunk

## Dependencies

This module depends on:
- Fluent Bit core components (`flb_config.h`, `flb_input.h`, `flb_output.h`)
- Memory management (`flb_mem.h`)
- String utilities (`flb_str.h`)
- Scheduler (`flb_scheduler.h`)
- Router (`flb_router.h`)
- Chunk management (`flb_input_chunk.h`)
- Event chunk handling (`flb_event_chunk`)

## Implementation Details

The task system works by:
1. Creating tasks from input data chunks
2. Determining routing paths to output plugins based on configuration
3. Tracking task state through various processing stages
4. Managing retries for failed output operations
5. Coordinating between input plugins and output plugins

Tasks maintain references to their originating input chunks and track which output plugins have successfully processed the data. The retry mechanism allows failed output operations to be retried with exponential backoff.

The task map system provides efficient lookup of tasks by ID, which is crucial for the event-driven architecture where tasks are communicated between engine components.

## Usage Examples

Tasks are typically created internally by the Fluent Bit engine when input plugins generate data chunks. Output plugins receive tasks through their flush callbacks:

```c
static int cb_flush(struct flb_output_instance *ins, 
                    struct flb_config *config,
                    struct flb_task_chunk *tch,
                    struct flb_input_instance *i_ins,
                    void *out_context, 
                    struct flb_task *task)
{
    // Process the task data
    // Call flb_task_retry_create() if processing fails
    // Call flb_task_done() when processing completes
}
```