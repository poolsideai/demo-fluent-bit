# flb_lock.c

## Overview

The `flb_lock.c` file provides a thread-safe locking mechanism for Fluent Bit. It implements a wrapper around POSIX mutexes with additional retry logic to handle contention scenarios gracefully. This locking mechanism is used throughout Fluent Bit to protect shared resources in multi-threaded environments.

## Key Functions

### `flb_lock_init`
Initializes a mutex lock. This function wraps `pthread_mutex_init()` and returns -1 on failure.

### `flb_lock_destroy`
Destroys a mutex lock. This function wraps `pthread_mutex_destroy()` and returns -1 on failure.

### `flb_lock_acquire`
Acquires a mutex lock with retry logic. If the lock is unavailable, it will retry up to `retry_limit` times with `retry_delay` microseconds between attempts. Returns -1 on failure.

### `flb_lock_release`
Releases a mutex lock with retry logic. If the unlock operation fails, it will retry up to `retry_limit` times with `retry_delay` microseconds between attempts. Returns -1 on failure.

## Constants

### `FLB_LOCK_INFINITE_RETRY_LIMIT`
Value indicating infinite retry attempts (0).

### `FLB_LOCK_DEFAULT_RETRY_LIMIT`
Default maximum retry attempts (100).

### `FLB_LOCK_DEFAULT_RETRY_DELAY`
Default delay between retry attempts in microseconds (50000, which is 50ms).

## Data Types

### `flb_lock_t`
Typedef for `pthread_mutex_t`, representing a mutex lock.

## Dependencies

- `<fluent-bit/flb_macros.h>`: Core Fluent Bit macros
- `<fluent-bit/flb_compat.h>`: Compatibility layer
- `<fluent-bit/flb_lock.h>`: Header file with declarations
- `<errno.h>`: Error number definitions
- `<fluent-bit/flb_pthread.h>`: POSIX thread support
- `<stddef.h>`: Standard definitions for size_t

## Implementation Details

The locking implementation provides several key features:

1. **Retry Logic**: Instead of blocking indefinitely when a lock is unavailable, the implementation uses `pthread_mutex_trylock()` with configurable retry limits and delays.

2. **Configurable Behavior**: Applications can specify retry limits and delays, or use default values.

3. **Error Handling**: All POSIX mutex operations are wrapped with proper error checking and conversion to Fluent Bit's error conventions (-1 for failure).

4. **Infinite Retry Option**: Setting `retry_limit` to `FLB_LOCK_INFINITE_RETRY_LIMIT` allows for indefinite retry attempts.

The retry mechanism is particularly useful in high-contention scenarios where temporary lock unavailability is expected but should not cause permanent failures.

## Usage Examples

```c
// Declare and initialize a lock
flb_lock_t my_lock;
if (flb_lock_init(&my_lock) != 0) {
    fprintf(stderr, "Failed to initialize lock\n");
    return -1;
}

// Acquire the lock with default retry settings
if (flb_lock_acquire(&my_lock,
                     FLB_LOCK_DEFAULT_RETRY_LIMIT,
                     FLB_LOCK_DEFAULT_RETRY_DELAY) != 0) {
    fprintf(stderr, "Failed to acquire lock\n");
    flb_lock_destroy(&my_lock);
    return -1;
}

// Critical section - protected by the lock
// ... perform thread-safe operations ...

// Release the lock
if (flb_lock_release(&my_lock,
                     FLB_LOCK_DEFAULT_RETRY_LIMIT,
                     FLB_LOCK_DEFAULT_RETRY_DELAY) != 0) {
    fprintf(stderr, "Failed to release lock\n");
}

// Destroy the lock when no longer needed
flb_lock_destroy(&my_lock);
```