# flb_task.c

## Overview

The `flb_task.c` file implements the task management system for Fluent Bit. Tasks represent units of work that need to be processed by output plugins. Each task encapsulates data, routing information, and state management for efficient processing of log events through the Fluent Bit pipeline.

The task system is central to Fluent Bit's architecture, serving as the mechanism for coordinating data flow between input plugins (which generate data) and output plugins (which consume and forward data). Tasks maintain references to their originating input chunks and track which output plugins have successfully processed the data.

## Key Functions

### `flb_task_create()`
Creates a new task with the provided data buffer, input instance, chunk, tag, and configuration. This function handles routing logic to determine which output plugins should receive the task.

The function:
1. Allocates a new task structure with a unique ID from the task map
2. Creates an event chunk from the provided data
3. Determines routing paths based on the input instance's configuration
4. Links the task to the input instance for tracking
5. Initializes task routes based on routing configuration

### `flb_task_destroy()`
Destroys a task and frees all associated resources including routes, retries, and the underlying chunk.

This function ensures proper cleanup of:
- Task routes (output plugin connections)
- Retry contexts for failed operations
- Associated input chunks
- Event chunk data
- Thread synchronization resources
- Task map entry

### `flb_task_retry_*()`
A family of functions for managing task retries when output plugins fail to process data:

- `flb_task_retry_create()` - Creates a retry context for a failed task
- `flb_task_retry_reschedule()` - Reschedules a retry attempt with exponential backoff
- `flb_task_retry_destroy()` - Cleans up a retry context
- `flb_task_retry_clean()` - Removes retry contexts for specific output instances
- `flb_task_retry_count()` - Gets the retry count for a specific output instance

The retry mechanism implements exponential backoff to prevent overwhelming output systems during temporary failures. It also handles chunk storage management during retries.

### `flb_task_running_count()`
Returns the number of currently active tasks (tasks with users or retries).

This function is used for monitoring and debugging purposes to track the load on the Fluent Bit engine.

### `flb_task_running_print()`
Prints information about currently running tasks for debugging purposes.

Useful for diagnosing stuck tasks or understanding the current workload distribution.

### `flb_task_queue_*()`
Functions for managing task queues:
- `flb_task_queue_create()` - Creates a new task queue for pending operations
- `flb_task_queue_destroy()` - Destroys a task queue and frees resources

These functions support synchronous output operations where tasks need to be queued until resources are available.

## Important Variables and Constants

### Task Status Constants
- `FLB_TASK_NEW` - Task has been created but not yet processed
- `FLB_TASK_RUNNING` - Task is currently being processed

### Task Route Status Constants
- `FLB_TASK_ROUTE_INACTIVE` - Route is currently inactive
- `FLB_TASK_ROUTE_ACTIVE` - Route is actively processing data
- `FLB_TASK_ROUTE_DROPPED` - Route has been dropped (data will not be sent)

### Task Structure Fields
- `id` - Unique identifier for the task (from task map)
- `status` - Current processing status
- `users` - Number of active users of this task (threads/coroutines)
- `routes` - List of output plugin routes for this task
- `retries` - List of retry contexts for failed routes
- `event_chunk` - The event data chunk being processed
- `i_ins` - Associated input instance that generated the data
- `ic` - Associated input chunk containing the raw data
- `ref_id` - External reference ID for tracking purposes
- `lock` - Mutex for thread-safe access to task data
- `_head` - Link to input instance's task list

### Task Route Structure Fields
- `out` - Associated output instance
- `status` - Current route status
- `_head` - Link to task's route list

### Task Retry Structure Fields
- `attempts` - Number of retry attempts
- `o_ins` - Associated output instance
- `parent` - Parent task reference
- `_head` - Link to task's retry list

## Dependencies

This module depends on:
- Fluent Bit core components (`flb_config.h`, `flb_input.h`, `flb_output.h`)
- Memory management (`flb_mem.h`)
- String utilities (`flb_str.h`)
- Scheduler (`flb_scheduler.h`)
- Router (`flb_router.h`)
- Chunk management (`flb_input_chunk.h`)
- Event chunk handling (`flb_event_chunk`)
- Monkey Core library for linked lists and data structures
- POSIX threads for synchronization

## Implementation Details

The task system works by:
1. Creating tasks from input data chunks
2. Determining routing paths to output plugins based on configuration
3. Tracking task state through various processing stages
4. Managing retries for failed output operations
5. Coordinating between input plugins and output plugins

### Task Lifecycle

Each task follows this lifecycle:
1. **Creation**: Task is created from input data via `flb_task_create()`
2. **Routing**: Output plugin destinations are determined based on configuration
3. **Processing**: Task is dispatched to output plugins for processing
4. **Completion**: Task is destroyed when all routes are completed
5. **Retry**: Failed routes may trigger retry mechanisms

### Task Map System

The task map system provides efficient lookup of tasks by ID, which is crucial for the event-driven architecture where tasks are communicated between engine components. Tasks are assigned unique IDs from a pre-allocated map to ensure fast access.

The task map is implemented as:
- Pre-allocated array of task references
- Dynamic growth capability when needed
- O(1) lookup complexity for task retrieval
- Automatic ID management to prevent conflicts

### Concurrency Management

Tasks use mutex locks to ensure thread-safe access to shared data structures. The `users` counter tracks how many threads or coroutines are actively working with the task, preventing premature destruction.

### Memory Management

The task system carefully manages memory to prevent leaks:
- Tasks are destroyed when no longer referenced
- Associated chunks are properly cleaned up
- Retry contexts are removed when no longer needed
- Event chunks are destroyed when tasks are completed
- Proper handling of chunk storage during retries

### Retry Mechanism

The retry mechanism handles failed output operations with the following features:
- Exponential backoff scheduling to prevent overwhelming output systems
- Attempt counting with configurable limits
- Chunk storage management (up/down operations)
- Automatic cleanup of exhausted retry contexts
- Integration with the scheduler for delayed execution

### Routing System

Tasks implement a sophisticated routing system that:
- Supports both direct connections and configuration-based routing
- Uses bitmask operations for efficient route determination
- Handles different event types appropriately
- Manages route status tracking
- Supports route dropping for failed destinations

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

For programmatic usage, tasks can be created directly:

```c
struct flb_task *task = flb_task_create(ref_id, buf, size, i_ins, ic, tag, config, &err);
if (task) {
    // Task created successfully
    // Process task routes
    // Clean up with flb_task_destroy() when done
}
```

## Error Handling

The task system implements robust error handling:
- Failed task creation results in appropriate error codes
- Memory allocation failures are gracefully handled
- Retry mechanisms handle temporary output failures
- Deadlock prevention through proper lock ordering
- Proper cleanup of partially created tasks

## Performance Considerations

The task system is designed for high performance:
- Task ID assignment uses pre-allocated maps for O(1) lookup
- Minimal memory overhead per task
- Efficient routing determination using bitmask operations
- Thread-safe operations with fine-grained locking
- Optimized retry scheduling with exponential backoff

## Configuration Impact

Task behavior is influenced by several configuration settings:
- Output plugin retry limits
- Input plugin buffer settings
- Routing rules defined in configuration
- Memory limits that affect task queuing
- Chunk storage settings that impact retry behavior

## Debugging and Monitoring

The task system provides several debugging aids:
- `flb_task_running_print()` for displaying active tasks
- Detailed logging of task creation and destruction
- Retry attempt tracking
- Route status monitoring
- Task map utilization statistics