# flb_worker.c Documentation

## Overview

The `flb_worker` module provides worker thread management for Fluent Bit. This implementation handles the creation, management, and destruction of POSIX threads that execute specific functions within the Fluent Bit engine.

Worker threads are essential for concurrent processing in Fluent Bit, allowing different components to run in parallel without blocking the main event loop.

## Key Features

- POSIX thread creation and management
- Worker context initialization
- Thread-local storage for worker contexts
- Worker lookup by thread ID
- Resource cleanup and destruction
- Integration with Fluent Bit's logging system

## Data Structures

### struct flb_worker

Represents a worker thread context:

```c
struct flb_worker {
    void (*func) (void *);     /* Target function to execute */
    void *data;                /* Data passed to the function */
    pthread_t tid;             /* POSIX thread identifier */
    struct flb_config *config; /* Fluent Bit configuration context */
    struct flb_log *log_ctx;   /* Logging context for the worker */
    struct flb_log_cache *log_cache; /* Log cache for the worker */
    struct mk_list _head;     /* Link for the workers list */
};
```

## Key Functions

### flb_worker_context_create()

```c
struct flb_worker *flb_worker_context_create(void (*func) (void *), void *arg,
                                             struct flb_config *config);
```

Creates a new worker context without spawning the thread.

**Parameters:**
- `func`: Function to execute in the worker thread
- `arg`: Data to pass to the function
- `config`: Fluent Bit configuration context

**Returns:**
- Pointer to the new worker context on success
- `NULL` on error

### flb_worker_create()

```c
int flb_worker_create(void (*func) (void *), void *arg, pthread_t *tid,
                      struct flb_config *config);
```

Creates and starts a new worker thread.

**Parameters:**
- `func`: Function to execute in the worker thread
- `arg`: Data to pass to the function
- `tid`: Pointer to store the thread ID
- `config`: Fluent Bit configuration context

**Returns:**
- `0` on success
- `-1` on error

### flb_worker_init()

```c
int flb_worker_init(struct flb_config *config);
```

Initializes the worker subsystem.

**Parameters:**
- `config`: Fluent Bit configuration context

**Returns:**
- `0` on success
- Error code on failure

### flb_worker_lookup()

```c
struct flb_worker *flb_worker_lookup(pthread_t tid, struct flb_config *config);
```

Finds a worker by its thread ID.

**Parameters:**
- `tid`: Thread ID to search for
- `config`: Fluent Bit configuration context

**Returns:**
- Pointer to the worker context if found
- `NULL` if not found

### flb_worker_get()

```c
struct flb_worker *flb_worker_get();
```

Retrieves the current worker context using thread-local storage.

**Returns:**
- Pointer to the current worker context
- `NULL` if no worker context is set

### flb_worker_destroy()

```c
void flb_worker_destroy(struct flb_worker *worker);
```

Destroys a worker context and frees associated resources.

**Parameters:**
- `worker`: Worker context to destroy

### flb_worker_exit()

```c
int flb_worker_exit(struct flb_config *config);
```

Destroys all worker contexts and cleans up resources.

**Parameters:**
- `config`: Fluent Bit configuration context

**Returns:**
- Number of workers destroyed

### flb_worker_log_level()

```c
int flb_worker_log_level(struct flb_worker *worker);
```

Retrieves the log level for a worker.

**Parameters:**
- `worker`: Worker context

**Returns:**
- Log level for the worker

## Implementation Details

### Thread Management

The worker module uses POSIX threads for concurrent execution:

1. **Context Creation**: Each worker has its own context that includes the target function, data, and configuration references
2. **Thread Spawning**: Uses `mk_utils_worker_spawn()` to create threads
3. **Context Storage**: Worker contexts are stored in a linked list in the configuration context
4. **Thread-Local Storage**: Uses TLS to store the current worker context for easy access

### Logging Integration

Each worker maintains its own logging context:
- Initializes logging for the worker thread
- Destroys logging resources when the worker is destroyed
- Provides log level access for the worker

### Resource Management

The module follows these resource management principles:
- Proper memory allocation and deallocation
- Thread cleanup on destruction
- List management for worker contexts
- Error handling with appropriate cleanup

## Usage Example

```c
#include <fluent-bit/flb_worker.h>
#include <fluent-bit/flb_config.h>
#include <fluent-bit/flb_log.h>

// Function to execute in worker thread
void worker_function(void *data) {
    char *message = (char *) data;
    flb_info("Worker executing: %s", message);
    
    // Do some work...
    sleep(5);
    
    flb_info("Worker completed");
}

// Create and start a worker
int start_worker_example(struct flb_config *config) {
    pthread_t tid;
    char *message = "Hello from worker!";
    
    // Create and start worker
    if (flb_worker_create(worker_function, message, &tid, config) != 0) {
        flb_error("Failed to create worker");
        return -1;
    }
    
    flb_info("Worker started with ID: %lu", tid);
    return 0;
}

// Lookup a worker by thread ID
struct flb_worker *find_worker_example(pthread_t tid, struct flb_config *config) {
    struct flb_worker *worker = flb_worker_lookup(tid, config);
    if (worker) {
        flb_info("Found worker with function: %p", worker->func);
        return worker;
    }
    
    flb_info("Worker not found");
    return NULL;
}

// Clean up all workers
int cleanup_workers_example(struct flb_config *config) {
    int count = flb_worker_exit(config);
    flb_info("Cleaned up %d workers", count);
    return count;
}
```

## Integration with Fluent Bit

The worker module integrates with other Fluent Bit components:

1. **Engine**: Workers are used for background tasks in the engine
2. **Plugins**: Plugin threads may use worker contexts
3. **Logging**: Each worker has its own logging context
4. **Configuration**: Worker contexts reference the main configuration

## Error Handling

All functions follow Fluent Bit's error handling conventions:
- Memory allocation failures are handled with `flb_errno()`
- Invalid parameters result in appropriate return values
- Resource cleanup is performed on failure paths
- NULL pointers are checked before use
- Thread creation failures are properly handled