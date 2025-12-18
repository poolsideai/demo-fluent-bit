# flb_thread_pool.c

## Overview

This file implements a thread pool management system for Fluent Bit, providing an abstraction layer for managing worker threads. The thread pool allows for efficient resource utilization by reusing threads for multiple tasks rather than creating new threads for each operation.

The thread pool system provides:
- Thread creation and management
- Round-robin thread selection for load balancing
- Integration with Fluent Bit's worker system
- Thread lifecycle management (start, stop, destroy)
- Thread identification and tracking

The implementation leverages Fluent Bit's existing worker infrastructure while providing a higher-level interface for managing thread pools. It uses round-robin scheduling to distribute work evenly across available threads.

## Key Functions

### `flb_tp_create()`
Creates a new thread pool context. Initializes the thread pool structure and prepares it for thread management.

### `flb_tp_destroy()`
Destroys a thread pool and cleans up all associated resources, including thread contexts.

### `flb_tp_thread_create()`
Creates a new thread context within the thread pool. The thread is not started immediately but is prepared for later execution.

### `flb_tp_thread_get_rr()`
Retrieves a thread using round-robin scheduling for load balancing across available threads.

### `flb_tp_thread_start()`
Starts a specific thread in the thread pool. This actually spawns the worker thread using Fluent Bit's worker system.

### `flb_tp_thread_start_id()`
Starts a thread identified by its ID within the thread pool.

### `flb_tp_thread_start_all()`
Starts all threads in the thread pool simultaneously.

### `flb_tp_thread_stop()`
Stops a specific thread in the thread pool. Currently returns success without implementation.

### `flb_tp_thread_stop_all()`
Stops all running threads in the thread pool by signaling each worker thread to stop.

### `flb_tp_thread_destroy()`
Destroys a thread context. Currently returns success without implementation.

## Important Variables/Constants

### Thread Pool States
- `FLB_THREAD_POOL_NONE`: Thread has not been started
- `FLB_THREAD_POOL_RUNNING`: Thread is currently executing
- `FLB_THREAD_POOL_ERROR`: Thread encountered an error

### Thread Pool Structures
- `struct flb_tp`: Main thread pool context containing thread lists and configuration
- `struct flb_tp_thread`: Individual thread context with status, parameters, and worker references

### Thread Identification
- Thread IDs assigned sequentially based on list position
- Round-robin pointer for load balancing
- Worker thread identification through pthread_t

## Dependencies

- Fluent Bit core components:
  - `flb_info.h`: Core information and logging
  - `flb_mem.h`: Memory allocation utilities
  - `flb_log.h`: Logging functionality
  - `flb_worker.h`: Worker thread interface
  - `flb_thread_pool.h`: Thread pool interface definitions

## Implementation Details

1. **Thread Creation Deferral**: Threads are created in a deferred state and only started when explicitly requested, allowing for better resource management.

2. **Worker Integration**: The thread pool leverages Fluent Bit's existing worker system rather than implementing its own threading mechanism.

3. **Round-Robin Scheduling**: Uses round-robin algorithm to distribute work evenly across threads for optimal load balancing.

4. **Thread Identification**: Threads are identified by sequential IDs and tracked through linked lists for efficient management.

5. **Status Tracking**: Each thread maintains its execution status to enable proper lifecycle management.

6. **Resource Cleanup**: Comprehensive cleanup procedures ensure no memory leaks when destroying thread pools.

## Usage Example

```c
// Create a new thread pool
struct flb_tp *tp = flb_tp_create(config);

// Create multiple threads
struct flb_tp_thread *thread1 = flb_tp_thread_create(tp, worker_func1, arg1, config);
struct flb_tp_thread *thread2 = flb_tp_thread_create(tp, worker_func2, arg2, config);

// Start all threads
flb_tp_thread_start_all(tp);

// Or start specific threads
flb_tp_thread_start(tp, thread1);

// Later, when cleaning up
flb_tp_thread_stop_all(tp);
flb_tp_destroy(tp);
```