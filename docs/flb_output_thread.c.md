# flb_output_thread.c Documentation

## Overview

This file implements the output threading mechanism in Fluent Bit, which handles concurrent processing of log records by output plugins. It provides a thread pool implementation that allows multiple output threads to process log data simultaneously, improving throughput and reducing bottlenecks in the logging pipeline.

The threading system is designed to handle the asynchronous nature of output operations, particularly when dealing with network-based outputs or other I/O-bound operations that might block.

## Key Functions/Components

### Thread Pool Management
- `flb_output_thread_pool_init()`: Initializes the thread pool with a specified number of worker threads
- `flb_output_thread_destroy()`: Cleans up and destroys the thread pool
- `flb_output_thread_spawn()`: Spawns a new output thread to process log records

### Thread Worker Implementation
- `flb_output_thread_worker()`: Main worker function that executes in each thread
- `flb_output_thread_consume()`: Consumes and processes log records from the input queue

### Synchronization Primitives
- Mutex locks for protecting shared data structures
- Condition variables for thread signaling
- Atomic operations for thread-safe counters and flags

## Important Variables/Constants

### Configuration Parameters
- `FLB_OUTPUT_THREAD_POOL_SIZE`: Default size of the thread pool (typically 2)
- `FLB_OUTPUT_THREAD_MAX_RECORDS`: Maximum number of records a thread can process at once

### State Management
- `struct flb_output_thread`: Represents an output thread with its state and buffers
- `struct flb_output_thread_pool`: Manages the collection of worker threads

## Dependencies and Relationships

### Core Dependencies
- `libpthread`: POSIX threads library for thread management
- `flb_info.h`: General Fluent Bit information and logging
- `flb_mem.h`: Memory allocation utilities
- `flb_utils.h`: Utility functions for data handling
- `flb_output.h`: Output plugin interface and data structures
- `flb_config.h`: Configuration management

### Related Components
- Integrates with the output plugin system (`flb_output`)
- Works with the scheduler system for managing output timing
- Connects to the buffer system for log record storage

## Notable Implementation Details

### Thread Safety
The implementation uses mutex locks to ensure thread-safe access to shared resources, particularly when multiple threads access the same output plugin instance or configuration data.

### Work Distribution
The system implements a work-stealing approach where threads can pull work from a shared queue when their local queue is empty, ensuring better load balancing across threads.

### Error Handling
Threads are designed to gracefully handle errors in individual log records without affecting the overall processing pipeline. Failed records are typically logged and skipped rather than causing thread termination.

### Resource Management
The implementation carefully manages memory allocation and deallocation to prevent leaks, especially important in long-running threaded applications.

## Usage Examples

```c
// Initialize the output thread pool
struct flb_output_thread_pool *pool = flb_output_thread_pool_init(2);

// Spawn a new output thread for processing
struct flb_output_thread *thread = flb_output_thread_spawn(pool, out_context);

// Wait for thread completion
while (thread->status != FLB_OUTPUT_THREAD_DONE) {
    usleep(1000); // 1ms sleep
}

// Clean up resources
flb_output_thread_destroy(thread);
flb_output_thread_pool_destroy(pool);
```

## Thread Lifecycle

1. **Initialization**: Thread pool is created with specified number of worker threads
2. **Work Assignment**: Log records are assigned to available threads
3. **Processing**: Each thread processes its assigned records using the output plugin
4. **Completion**: Threads signal completion and return results
5. **Cleanup**: Resources are released when threads terminate