# flb_libco

## Overview

flb_libco is a fork of the original library [libco](https://byuu.org/library/libco/) v18 created by Byuu. It provides cooperative threading capabilities for C applications. This library is used inside Fluent Bit project.

Compared to the original version, this fork includes the following changes:
- ARMv8: workaround for GCC bug
- Added aarch64.c backend file created by webgeek1234
- Fixes on settings.h to get MacOS support
- co_create() has a third argument to retrieve the real size of the stack created

## Key Methods/Functions

### Thread Management
- `co_active()` - Returns the currently active thread
- `co_create(unsigned int size, void (*entry)(void), size_t *real_size)` - Creates a new thread with specified stack size and entry function
- `co_delete(cothread_t thread)` - Deletes a thread and frees its resources
- `co_switch(cothread_t thread)` - Switches execution to the specified thread

## Usage Notes

1. flb_libco provides cooperative threading, meaning threads yield control explicitly rather than being preemptively scheduled.
2. Each thread requires a stack size to be specified during creation.
3. The library automatically detects the target architecture and uses the appropriate implementation (x86, amd64, arm, ppc, etc.).
4. Memory for thread stacks is allocated internally by the library.
5. Error handling is minimal - functions typically return NULL or undefined behavior on failure.

## Example Usage

```c
#include "libco.h"

static cothread_t main_thread;
static cothread_t worker_thread;

void worker_entry(void) {
    // Worker thread code
    printf("Worker thread running\n");
    
    // Yield control back to main thread
    co_switch(main_thread);
    
    // Continue worker thread execution
    printf("Worker thread continuing\n");
    
    // Return to main thread
    co_switch(main_thread);
}

int main() {
    size_t real_size;
    
    // Store main thread
    main_thread = co_active();
    
    // Create worker thread with 8KB stack
    worker_thread = co_create(8192, worker_entry, &real_size);
    
    printf("Created worker thread with %zu bytes stack\n", real_size);
    
    // Switch to worker thread
    co_switch(worker_thread);
    
    printf("Back in main thread\n");
    
    // Switch to worker thread again
    co_switch(worker_thread);
    
    printf("Worker thread completed\n");
    
    // Clean up worker thread
    co_delete(worker_thread);
    
    return 0;
}
```