# flb_thread_pool.c

## Overview

The `flb_thread_pool.c` file implements a thread pool management system for Fluent Bit. This system provides a way to manage multiple worker threads efficiently, allowing tasks to be distributed across available threads using a round-robin scheduling approach.

The thread pool system is designed to optimize resource utilization by reusing threads rather than creating new ones for each task. This approach reduces the overhead associated with thread creation and destruction while maintaining good performance for concurrent operations.

The system integrates with Fluent Bit's worker thread interface, leveraging existing infrastructure for thread management while providing higher-level abstractions for common threading patterns.

## Key Functions

### `flb_tp_create(struct flb_config *config)`
Creates a new thread pool context. Initializes the thread pool structure and prepares it for thread management.

This function:
1. Allocates memory for the thread pool structure
2. Initializes the linked list for managing thread contexts
3. Sets up the configuration reference
4. Prepares the round-robin scheduler

### `flb_tp_destroy(struct flb_tp *tp)`
Destroys a thread pool and frees all associated resources, including thread contexts.

The destruction process:
1. Iterates through all thread contexts in the pool
2. Removes each thread from the linked list
3. Frees memory allocated for each thread context
4. Frees the thread pool structure itself

### `flb_tp_thread_create(struct flb_tp *tp, void (*func)(void *), void *arg, struct flb_config *config)`
Creates a thread context within the thread pool. This function prepares a thread for execution but doesn't start it immediately.

The creation process:
1. Allocates memory for the thread context
2. Stores the function pointer and argument for later execution
3. Assigns a unique ID to the thread based on list position
4. Links the thread context to the parent thread pool
5. Sets initial status to `FLB_THREAD_POOL_NONE`

### `flb_tp_thread_get_rr(struct flb_tp *tp)`
Returns the next available thread using round-robin scheduling. This function helps distribute work evenly across available threads.

The round-robin algorithm:
1. Maintains a pointer to the last accessed thread
2. Returns the next thread in the sequence using `mk_list_entry_next`
3. Wraps around to the beginning when reaching the end of the list
4. Ensures even distribution of work across threads

### `flb_tp_thread_start(struct flb_tp *tp, struct flb_tp_thread *th)`
Starts a specific thread by creating a worker thread using the Fluent Bit worker interface.

Thread startup involves:
1. Creating the actual OS thread using `flb_worker_create()`
2. Looking up the worker context using `flb_worker_lookup()`
3. Updating the thread status to `FLB_THREAD_POOL_RUNNING`
4. Storing the thread ID for future reference

### `flb_tp_thread_start_id(struct flb_tp *tp, int id)`
Starts a thread by its ID within the thread pool.

This function provides indexed access to threads, allowing direct control over specific thread instances.

### `flb_tp_thread_start_all(struct flb_tp *tp)`
Starts all threads in the thread pool.

Bulk startup is useful for initializing all threads at once, particularly during system initialization.

### `flb_tp_thread_stop(struct flb_tp *tp, struct flb_tp_thread *th)`
Stops a specific thread in the thread pool.

Note: Current implementation is a placeholder and requires enhancement for proper thread stopping. The function currently returns 0 without performing any actual stopping operations.

### `flb_tp_thread_stop_all(struct flb_tp *tp)`
Stops all threads in the thread pool.

This function iterates through all threads and attempts to stop each one using `flb_tp_thread_stop()`, though the individual stop implementation is currently minimal.

### `flb_tp_thread_destroy()`
Destroys a thread context (currently a placeholder implementation).

This function would typically handle cleanup of thread-specific resources. The current implementation simply returns 0 without performing any operations.

## Important Variables and Constants

### Thread Status Constants
- `FLB_THREAD_POOL_NONE` - Thread is not running
- `FLB_THREAD_POOL_RUNNING` - Thread is currently running
- `FLB_THREAD_POOL_ERROR` - Thread encountered an error
- `FLB_THREAD_POOL_STOPPED` - Thread has been stopped

### Thread Pool Structure Fields
- `config` - Reference to the Fluent Bit configuration
- `list_threads` - Linked list of thread contexts managed by the pool
- `thread_cur` - Current thread pointer for round-robin scheduling

### Thread Context Structure Fields
- `id` - Unique identifier for the thread within the pool
- `status` - Current status of the thread
- `params` - Function and argument parameters for the thread
- `worker` - Reference to the underlying worker thread context
- `tid` - Thread ID assigned by the operating system
- `_head` - Link to the parent thread pool's thread list
- `config` - Reference to the Fluent Bit configuration

## Dependencies

This module depends on:
- Fluent Bit core components (`flb_config.h`)
- Memory management (`flb_mem.h`)
- Logging system (`flb_log.h`)
- Worker thread management (`flb_worker.h`)
- Thread pool interface (`flb_thread_pool.h`)
- Monkey Core library for linked list operations
- POSIX threads or Windows pthreads for thread operations

## Implementation Details

The thread pool system works by:
1. Creating a thread pool context that manages multiple thread contexts
2. Using round-robin scheduling to distribute work across available threads
3. Leveraging the Fluent Bit worker interface for actual thread creation
4. Maintaining thread status to track execution state

### Thread Creation Strategy

The system uses a deferred execution model:
1. Threads are created as contexts with function pointers and arguments
2. Actual thread startup is triggered explicitly via `flb_tp_thread_start()`
3. This allows for flexible thread management where threads can be prepared in advance

### Round-Robin Scheduler

The round-robin algorithm ensures even distribution of work:
1. Maintains a pointer to the last accessed thread (`thread_cur`)
2. Returns the next thread in sequence using `mk_list_entry_next`
3. Wraps around to the beginning when reaching the end of the list
4. Prevents any single thread from becoming a bottleneck

### Integration with Worker System

The thread pool leverages Fluent Bit's existing worker infrastructure:
1. Uses `flb_worker_create()` for actual thread creation
2. Uses `flb_worker_lookup()` to retrieve worker contexts
3. Integrates with the broader thread management ecosystem

### Thread ID Management

Thread IDs are managed automatically:
1. Assigned based on position in the thread list using `flb_tp_thread_get_id`
2. Provides a simple way to identify threads within the pool
3. Enables indexed access to specific threads

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

For bulk operations:

```c
// Start all threads in the pool
flb_tp_thread_start_all(tp);

// Stop all threads
flb_tp_thread_stop_all(tp);

// Clean up the thread pool
flb_tp_destroy(tp);
```

## Thread Safety

The thread pool implementation maintains thread safety through:
- Proper use of linked lists with appropriate locking
- Atomic operations for thread status updates
- Integration with Fluent Bit's existing synchronization primitives

## Error Handling

The system implements robust error handling:
- Memory allocation failures are detected and propagated
- Thread creation failures update thread status appropriately
- Invalid thread IDs are handled gracefully
- Resource cleanup occurs even in error conditions

## Performance Considerations

The thread pool is designed for optimal performance:
- Minimal overhead for thread context creation
- Efficient round-robin scheduling with O(1) complexity
- Reuse of existing worker infrastructure
- Proper memory management to prevent leaks

## Configuration and Tuning

While the thread pool doesn't have extensive configuration options, its behavior can be influenced by:
- The number of threads created in the pool
- The timing of thread startup operations
- Integration with Fluent Bit's worker thread configuration

## Known Limitations

The current implementation has several limitations:
- Thread stopping functionality is not fully implemented
- Thread destruction is a placeholder implementation
- No support for thread priority or affinity
- Limited error handling for thread operations

## Future Enhancements

Potential improvements to the thread pool system:
- Enhanced thread stopping mechanisms
- More sophisticated scheduling algorithms
- Better integration with Fluent Bit's event loop
- Support for thread priority and affinity
- Proper implementation of thread destruction
- Enhanced error handling and recovery mechanisms