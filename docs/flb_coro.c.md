# flb_coro.c

## Overview

The `flb_coro.c` file implements coroutine support for Fluent Bit using the libco library. Coroutines provide a lightweight concurrency mechanism that allows Fluent Bit to handle multiple I/O operations concurrently without the overhead of traditional threads.

This module provides thread-local storage for coroutine contexts and initialization functions that ensure proper coroutine support across different execution environments. The coroutine system is fundamental to Fluent Bit's ability to handle asynchronous I/O operations efficiently.

## Key Functions

### `flb_coro_init`
Initializes the coroutine system:
- Sets up thread-local storage for coroutine contexts
- Initializes mutex for coroutine thread safety
- Called once during Fluent Bit startup

### `flb_coro_thread_init`
Initializes coroutine support for a specific thread:
- Creates and immediately destroys a test coroutine
- Ensures libco is properly initialized for the thread
- Required for proper coroutine operation in multi-threaded environments

### `flb_coro_get`
Retrieves the current coroutine context from thread-local storage:
- Returns the currently active coroutine
- Used throughout Fluent Bit to access coroutine state

### `flb_coro_set`
Stores a coroutine context in thread-local storage:
- Associates a coroutine with the current thread
- Called when switching between coroutines

## Data Structures

### `struct flb_coro`
Represents a coroutine context with:
- `caller`: libco context for the calling coroutine
- `callee`: libco context for the target coroutine
- `data`: Pointer to coroutine-specific data
- Valgrind stack registration ID (when enabled)

## Dependencies

This module depends on:
- `libco`: Lightweight coroutine library
- `flb_thread_storage`: Thread-local storage management
- `pthread`: Thread synchronization primitives
- `valgrind`: Memory debugging support (optional)

## Implementation Details

The coroutine system works as follows:

1. **Initialization**: `flb_coro_init()` sets up global coroutine infrastructure
2. **Thread Setup**: `flb_coro_thread_init()` ensures proper libco initialization per thread
3. **Context Management**: Thread-local storage tracks the current coroutine
4. **Switching**: Coroutines switch using `co_switch()` from libco
5. **Cleanup**: Proper resource management with Valgrind integration

Coroutines are used extensively in Fluent Bit for:
- Network I/O operations (async reads/writes)
- Plugin execution (input, filter, output processing)
- Connection handling (upstream/downstream connections)
- Task scheduling and coordination

## Stack Size Configuration

Coroutines use configurable stack sizes:
- Default: `(3 * STACK_FACTOR * PTHREAD_STACK_MIN) / 2`
- macOS ARM64: 36KiB (STACK_FACTOR = 1.5)
- macOS x86_64: 24KiB (STACK_FACTOR = 2)
- Other platforms: 12KiB (STACK_FACTOR = 1)
- Customizable via `FLB_CORO_STACK_SIZE` compile-time definition

## Thread Safety

The coroutine system uses mutexes to ensure thread safety during initialization:
- `coro_mutex_init` protects coroutine creation/destruction
- Thread-local storage isolates coroutine contexts per thread
- Proper cleanup prevents resource leaks

## Usage Example

```c
// Initialize coroutine system (called once at startup)
flb_coro_init();

// Initialize coroutine support for a thread
flb_coro_thread_init();

// In a coroutine function:
void *coroutine_function(void *data)
{
    struct flb_coro *coro = flb_coro_get();
    
    // Do some work
    
    // Yield control back to caller
    flb_coro_yield(coro, FLB_FALSE);
    
    // Continue after yield
    
    // Return from coroutine
    flb_coro_return(coro);
}

// Creating and using a coroutine:
struct flb_coro *coro = flb_coro_create(user_data);
// ... setup coroutine ...
flb_coro_resume(coro);
// ... coroutine runs until yield ...
flb_coro_resume(coro);
// ... coroutine continues until completion ...
flb_coro_destroy(coro);
```