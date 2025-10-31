# Jemalloc Library Documentation

## Overview

Jemalloc is a general purpose malloc(3) implementation that emphasizes fragmentation avoidance and scalable concurrency support. It first came into use as the FreeBSD libc allocator in 2005, and since then it has found its way into numerous applications that rely on its predictable behavior.

In 2010, jemalloc development efforts broadened to include developer support features such as heap profiling and extensive monitoring/tuning hooks. Modern jemalloc releases continue to be integrated back into FreeBSD, and therefore versatility remains critical.

Ongoing development efforts trend toward making jemalloc among the best allocators for a broad range of demanding applications, and eliminating/mitigating weaknesses that have practical repercussions for real world applications.

## Key Methods/Functions

### Standard Memory Allocation

- `void *malloc(size_t size)` - Allocates size bytes and returns a pointer to the allocated memory
- `void *calloc(size_t num, size_t size)` - Allocates memory for an array of num elements of size bytes each and returns a pointer to the allocated memory
- `void *realloc(void *ptr, size_t size)` - Changes the size of the memory block pointed to by ptr to size bytes
- `void free(void *ptr)` - Frees the memory space pointed to by ptr

### Extended Memory Allocation

- `void *mallocx(size_t size, int flags)` - Allocates at least size bytes of memory and returns a pointer to the allocated memory
- `void *rallocx(void *ptr, size_t size, int flags)` - Resizes the allocation at ptr to be at least size bytes
- `size_t xallocx(void *ptr, size_t size, size_t extra, int flags)` - Resizes the allocation at ptr in place to be at least size+extra bytes
- `size_t sallocx(const void *ptr, int flags)` - Returns the real size of the allocation at ptr
- `void dallocx(void *ptr, int flags)` - Frees the memory referenced by ptr
- `void sdallocx(void *ptr, size_t size, int flags)` - Size-aware variant of dallocx
- `size_t nallocx(size_t size, int flags)` - Allocates at least size bytes of memory and returns the real size of the allocation

### Memory Alignment

- `int posix_memalign(void **memptr, size_t alignment, size_t size)` - Allocates size bytes and stores the address of the allocated memory in memptr
- `void *aligned_alloc(size_t alignment, size_t size)` - Allocates size bytes of memory such that the allocation's base address is an even multiple of alignment

### Control Interface

- `int mallctl(const char *name, void *oldp, size_t *oldlenp, void *newp, size_t newlen)` - Provides a general interface for introspecting the memory allocator, setting modifiable parameters, and triggering actions
- `int mallctlnametomib(const char *name, size_t *mibp, size_t *miblenp)` - Translates a name to a Management Information Base (MIB) that can be passed repeatedly to mallctlbymib
- `int mallctlbymib(const size_t *mib, size_t miblen, void *oldp, size_t *oldlenp, void *newp, size_t newlen)` - Similar to mallctl, but uses a MIB instead of a name
- `void malloc_stats_print(void (*write_cb)(void *, const char *), void *cbopaque, const char *opts)` - Writes human-readable summary statistics via the write_cb callback function pointer and cbopaque data passed to write_cb
- `size_t malloc_usable_size(const void *ptr)` - Returns the real size of the allocation at ptr

## Usage Notes

1. Jemalloc is designed to be a drop-in replacement for the standard C library malloc implementation. Most applications can simply link against jemalloc without any code changes.

2. Jemalloc provides several advantages over standard malloc implementations:
   - Better fragmentation avoidance
   - Scalable concurrency support
   - Heap profiling capabilities
   - Extensive monitoring and tuning hooks

3. The extended allocation functions (mallocx, rallocx, etc.) provide additional functionality not available with standard malloc:
   - Allocation flags for controlling behavior
   - Size-aware deallocation
   - In-place resizing

4. Jemalloc supports various allocation flags that can be used with the extended allocation functions:
   - `MALLOCX_LG_ALIGN(la)` - Align the memory allocation to start at an address that is a multiple of (1 << la)
   - `MALLOCX_ALIGN(a)` - Align the memory allocation to start at an address that is a multiple of a
   - `MALLOCX_ZERO` - Initialize newly allocated memory to contain zero bytes
   - `MALLOCX_TCACHE(tc)` - Use the thread-specific cache specified by tc
   - `MALLOCX_TCACHE_NONE` - Do not use a thread-specific cache

5. Jemalloc provides extensive control over its behavior through the mallctl interface, allowing you to:
   - Query statistics
   - Modify configuration parameters
   - Trigger actions like garbage collection
   - Monitor memory usage

## Example

```c
#include <stdlib.h>
#include <stdio.h>

int main() {
    // Allocate memory using standard malloc
    int *array = malloc(10 * sizeof(int));
    if (array == NULL) {
        fprintf(stderr, "Memory allocation failed\n");
        return 1;
    }
    
    // Use the allocated memory
    for (int i = 0; i < 10; i++) {
        array[i] = i * 2;
    }
    
    // Print the array
    for (int i = 0; i < 10; i++) {
        printf("%d ", array[i]);
    }
    printf("\n");
    
    // Free the memory
    free(array);
    
    return 0;
}
```