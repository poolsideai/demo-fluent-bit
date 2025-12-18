# flb_worker.c

## Overview

The `flb_worker.c` file provides worker thread management functionality for Fluent Bit. This module handles the creation, management, and cleanup of POSIX threads (workers) that perform background tasks in Fluent Bit.

## Key Functions

### `step_callback`

```c
static void step_callback(void *data)
```

Internal callback function that runs in a POSIX thread context. This function sets up Fluent Bit-specific requirements and then calls the target callback function.

- **Parameters**: 
  - `data`: Worker context data
- **Notes**: Sets up thread-local storage for the worker context and calls the target function

### `flb_worker_context_create`

```c
struct flb_worker *flb_worker_context_create(void (*func) (void *), void *arg, struct flb_config *config)
```

Creates a new worker context without spawning the thread.

- **Parameters**: 
  - `func`: Function to execute in the worker thread
  - `arg`: Argument to pass to the function
  - `config`: Fluent Bit configuration context
- **Returns**: Pointer to the new worker context, or NULL on failure
- **Notes**: Initializes the worker structure but doesn't start the thread

### `flb_worker_create`

```c
int flb_worker_create(void (*func) (void *), void *arg, pthread_t *tid, struct flb_config *config)
```

Creates and starts a new worker thread.

- **Parameters**: 
  - `func`: Function to execute in the worker thread
  - `arg`: Argument to pass to the function
  - `tid`: Pointer to store the thread ID
  - `config`: Fluent Bit configuration context
- **Returns**: 0 on success, -1 on failure
- **Notes**: Creates the worker context, initializes logging, and spawns the thread

### `flb_worker_init`

```c
int flb_worker_init(struct flb_config *config)
```

Initializes the worker subsystem.

- **Parameters**: 
  - `config`: Fluent Bit configuration context
- **Returns**: 0 on success, -1 on failure
- **Notes**: Initializes thread-local storage for worker contexts

### `flb_worker_lookup`

```c
struct flb_worker *flb_worker_lookup(pthread_t tid, struct flb_config *config)
```

Finds a worker by its thread ID.

- **Parameters**: 
  - `tid`: Thread ID to look up
  - `config`: Fluent Bit configuration context
- **Returns**: Pointer to the worker context, or NULL if not found

### `flb_worker_get`

```c
struct flb_worker *flb_worker_get()
```

Retrieves the current worker context for the calling thread.

- **Returns**: Pointer to the current worker context, or NULL if none

### `flb_worker_destroy`

```c
void flb_worker_destroy(struct flb_worker *worker)
```

Destroys a worker context and cleans up associated resources.

- **Parameters**: 
  - `worker`: Worker context to destroy
- **Notes**: Destroys logging cache and removes from the workers list

### `flb_worker_exit`

```c
int flb_worker_exit(struct flb_config *config)
```

Cleans up all worker contexts and exits the worker subsystem.

- **Parameters**: 
  - `config`: Fluent Bit configuration context
- **Returns**: Number of workers destroyed
- **Notes**: Calls `flb_worker_destroy` for each worker

### `flb_worker_log_level`

```c
int flb_worker_log_level(struct flb_worker *worker)
```

Retrieves the log level for a worker.

- **Parameters**: 
  - `worker`: Worker context
- **Returns**: Log level value

## Data Structures

### `flb_worker`

Structure representing a worker thread context.

```c
struct flb_worker {
    struct mk_event event;          /* Event structure */
    
    /* Callback data */
    void (*func) (void *);          /* function to execute */
    void *data;                     /* opaque data for the function */
    pthread_t tid;                  /* thread ID */
    
    /* Logging */
    struct flb_log_cache *log_cache; /* log cache for the worker */
#ifdef _WIN32
    intptr_t log[2];                /* Windows log pipes */
#else
    flb_pipefd_t log[2];            /* Unix log pipes */
#endif
    
    /* Runtime context */
    void *config;                   /* configuration context */
    void *log_ctx;                  /* logging context */
    
    pthread_mutex_t mutex;          /* mutex for synchronization */
    struct mk_list _head;           /* link to head at config->workers */
};
```

## Dependencies

- `<monkey/mk_core.h>`: Monkey HTTP server core utilities
- `<fluent-bit/flb_info.h>`: Fluent Bit core information
- `<fluent-bit/flb_mem.h>`: Fluent Bit memory management
- `<fluent-bit/flb_utils.h>`: Fluent Bit utility functions
- `<fluent-bit/flb_config.h>`: Fluent Bit configuration
- `<fluent-bit/flb_worker.h>`: Worker header definitions
- `<fluent-bit/flb_log.h>`: Fluent Bit logging

## Implementation Details

1. **Thread Management**: Uses POSIX threads (pthread) for worker implementation

2. **Thread-Local Storage**: Maintains worker context in thread-local storage for easy access

3. **Initialization Steps**: 
   - Creates worker context
   - Initializes logging subsystem
   - Spawns the worker thread
   - Adds worker to the configuration's workers list

4. **Cleanup Process**: 
   - Destroys logging cache
   - Removes worker from the list
   - Frees worker memory

5. **Platform Support**: Handles both Unix and Windows platforms for logging pipes

## Usage Examples

### Creating a worker thread

```c
// Define a worker function
void my_worker_function(void *data) {
    // Perform background work
    printf("Worker thread running with data: %s\n", (char*)data);
    
    // Worker automatically exits when function returns
}

// Create and start a worker thread
char *worker_data = "Hello from worker";

struct flb_config *config; // Assume this is initialized

if (flb_worker_create(my_worker_function, worker_data, &tid, config) == 0) {
    printf("Worker created successfully, TID: %lu\n", (unsigned long)tid);
} else {
    printf("Failed to create worker\n");
}
```

### Getting the current worker context

```c
// In a worker thread function
void worker_function(void *data) {
    struct flb_worker *worker = flb_worker_get();
    if (worker) {
        printf("Current worker log level: %d\n", flb_worker_log_level(worker));
        
        // Access configuration
        struct flb_config *config = (struct flb_config *)worker->config;
        // ... use config ...
    }
}
```

### Looking up a worker by thread ID

```c
// Find a worker by its thread ID
struct flb_worker *worker = flb_worker_lookup(some_tid, config);
if (worker) {
    printf("Found worker with function: %p\n", worker->func);
}
```