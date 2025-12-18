# flb_thread_pool.c

## Overview

The `flb_thread_pool.c` file implements a thread pool management system for Fluent Bit. This system provides a way to manage multiple worker threads efficiently, allowing tasks to be distributed across available threads using a round-robin scheduling approach.

## Key Functions

### `flb_tp_create(struct flb_config *config)`
Creates a new thread pool context. Initializes the thread pool structure and prepares it for thread management.

### `flb_tp_destroy(struct flb_tp *tp)`
Destroys a thread pool and frees all associated resources, including thread contexts.

### `flb_tp_thread_create(struct flb_tp *tp, void (*func)(void *), void *arg, struct flb_config *config)`
Creates a thread context within the thread pool. This function prepares a thread for execution but doesn't start it immediately.

### `flb_tp_thread_get_rr(struct flb_tp *tp)`
Returns the next available thread using round-robin scheduling. This function helps distribute work evenly across available threads.

### `flb_tp_thread_start(struct flb_tp *tp, struct flb_tp_thread *th)`
Starts a specific thread by creating a worker thread using the Fluent Bit worker interface.

### `flb_tp_thread_start_id(struct flb_tp *tp, int id)`
Starts a thread by its ID within the thread pool.

### `flb_tp_thread_start_all(struct flb_tp *tp)`
Starts all threads in the thread pool.

### `flb_tp_thread_stop(struct flb_tp *tp, struct flb_tp_thread *th)`
Stops a specific thread in the thread pool.

### `flb_tp_thread_stop_all(struct flb_tp *tp)`
Stops all threads in the thread pool.

### `flb_tp_thread_destroy()`
Destroys a thread context (currently a placeholder implementation).

## Important Variables and Constants

### Thread Status Constants
- `FLB_THREAD_POOL_NONE` - Thread is not running
- `FLB_THREAD_POOL_RUNNING` - Thread is currently running
- `FLB_THREAD_POOL_ERROR` - Thread encountered an error

### Thread Pool Structure Fields
- `config` - Reference to the Fluent Bit configuration
- `list_threads` - List of thread contexts managed by the pool
- `thread_cur` - Current thread pointer for round-robin scheduling

### Thread Context Structure Fields
- `id` - Unique identifier for the thread
- `status` - Current status of the thread
- `params` - Function and argument parameters for the thread
- `worker` - Reference to the underlying worker thread
- `tid` - Thread ID

## Dependencies

This module depends on:
- Fluent Bit core components (`flb_config.h`)
- Memory management (`flb_mem.h`)
- Logging system (`flb_log.h`)
- Worker thread management (`flb_worker.h`)
- Thread pool interface (`flb_thread_pool.h`)

## Implementation Details

The thread pool system works by:
1. Creating a thread pool context that manages multiple thread contexts
2. Using round-robin scheduling to distribute work across available threads
3. Leveraging the Fluent Bit worker interface for actual thread creation
4. Maintaining thread status to track execution state

Each thread context stores the function to execute and its arguments, but threads are only started when explicitly requested. This design allows for flexible thread management where threads can be created in advance but started on demand.

The round-robin scheduler ensures that work is distributed evenly across available threads, preventing any single thread from becoming overloaded while others remain idle.

## Usage Examples

Creating and using a thread pool:

```c
struct flb_tp *tp;
struct flb_tp_thread *thread;

// Create thread pool
tp = flb_tp_create(config);

// Create a thread with a function and argument
thread = flb_tp_thread_create(tp, my_worker_function, my_argument, config);

// Start the thread
flb_tp_thread_start(tp, thread);

// Get next available thread using round-robin
struct flb_tp_thread *next_thread = flb_tp_thread_get_rr(tp);
```