# flb_storage.c and flb_storage.h Documentation

## Overview

The `flb_storage` module provides the storage layer implementation for Fluent Bit, managing data persistence using the Chunk I/O (cio) library. It handles different storage types including memory-only, filesystem-based, and memory ring buffer storage.

The module is responsible for:
- Initializing and managing storage contexts
- Creating streams for input instances
- Handling storage metrics collection
- Managing chunk lifecycle operations
- Providing storage statistics and monitoring

## Data Structures

### struct flb_storage_metrics

Represents the storage metrics context for collecting and reporting storage-related metrics.

```c
struct flb_storage_metrics {
    int fd;

    struct cmt *cmt;

    /* cmetrics */
    struct cmt_gauge *cmt_chunks;           /* total number of chunks */
    struct cmt_gauge *cmt_mem_chunks;       /* number of chunks up in memory */
    struct cmt_gauge *cmt_fs_chunks;        /* total number of filesystem chunks */
    struct cmt_gauge *cmt_fs_chunks_up;     /* number of filesystem chunks up in memory */
    struct cmt_gauge *cmt_fs_chunks_down;   /* number of filesystem chunks down */
};
```

### struct flb_storage_input

Represents the storage context associated with an input instance.

```c
struct flb_storage_input {
    int type;                   /* CIO_STORE_FS | CIO_STORE_MEM */
    struct cio_stream *stream;
    struct cio_ctx *cio;
};
```

## Key Functions

### flb_storage_create()

```c
int flb_storage_create(struct flb_config *ctx);
```

Initializes the storage layer for Fluent Bit.

**Parameters:**
- `ctx`: Pointer to the Fluent Bit configuration context

**Returns:**
- `0` on success
- `-1` on error

### flb_storage_input_create()

```c
int flb_storage_input_create(struct cio_ctx *cio,
                              struct flb_input_instance *in);
```

Creates storage context for an input instance.

**Parameters:**
- `cio`: Pointer to the Chunk I/O context
- `in`: Pointer to the input instance

**Returns:**
- `0` on success
- `-1` on error

### flb_storage_destroy()

```c
void flb_storage_destroy(struct flb_config *ctx);
```

Destroys the storage layer and cleans up resources.

**Parameters:**
- `ctx`: Pointer to the Fluent Bit configuration context

### flb_storage_input_destroy()

```c
void flb_storage_input_destroy(struct flb_input_instance *in);
```

Destroys storage context for an input instance.

**Parameters:**
- `in`: Pointer to the input instance

### flb_storage_metrics_create()

```c
struct flb_storage_metrics *flb_storage_metrics_create(struct flb_config *ctx);
```

Creates a storage metrics context for collecting metrics.

**Parameters:**
- `ctx`: Pointer to the Fluent Bit configuration context

**Returns:**
- Pointer to the newly created `struct flb_storage_metrics`
- `NULL` on error

### flb_storage_metrics_update()

```c
int flb_storage_metrics_update(struct flb_config *config, struct flb_storage_metrics *sm);
```

Updates storage metrics with current values.

**Parameters:**
- `config`: Pointer to the Fluent Bit configuration
- `sm`: Pointer to the storage metrics context

**Returns:**
- `0` on success
- `-1` on error

### flb_storage_chunk_count()

```c
void flb_storage_chunk_count(struct flb_config *ctx, int *mem_chunks, int *fs_chunks);
```

Retrieves the count of chunks in memory and on filesystem.

**Parameters:**
- `ctx`: Pointer to the Fluent Bit configuration context
- `mem_chunks`: Pointer to store the count of memory chunks
- `fs_chunks`: Pointer to store the count of filesystem chunks

## Constants

### Storage Types

- `FLB_STORAGE_FS`: Filesystem storage (memory + filesystem)
- `FLB_STORAGE_MEM`: Memory-only storage
- `FLB_STORAGE_MEMRB`: Memory ring buffer storage

### Defaults

- `FLB_STORAGE_BL_MEM_LIMIT`: "100M" - Default memory limit for storage backlog
- `FLB_STORAGE_MAX_CHUNKS_UP`: 128 - Default maximum number of chunks kept in memory

## Dependencies

This module depends on:
- Chunk I/O (cio) library for chunk management
- CMetrics library for metrics collection
- Fluent Bit core components (flb_config, flb_input_instance, etc.)

## Implementation Details

### Storage Types

The storage layer supports three types of storage:

1. **Filesystem Storage (`FLB_STORAGE_FS`)**: Data is stored in memory buffers and periodically flushed to the filesystem.
2. **Memory Storage (`FLB_STORAGE_MEM`)**: Data is kept entirely in memory.
3. **Memory Ring Buffer (`FLB_STORAGE_MEMRB`)**: Uses a ring buffer approach for memory storage.

### Chunk Management

The storage layer manages chunks through:
- Creation and destruction of streams for input instances
- Loading existing chunks from filesystem on startup
- Sorting chunks by timestamp for proper ordering
- Tracking chunk states (up, down, busy)

### Metrics Collection

The module collects various storage metrics:
- Total number of chunks
- Memory chunks count
- Filesystem chunks count
- Up/down status of filesystem chunks
- Per-input instance metrics including:
  - Overlimit status
  - Memory usage
  - Chunk counts and statuses

### Error Handling

The storage layer handles errors gracefully:
- Invalid storage types fall back to defaults
- Missing filesystem paths are reported for filesystem storage
- Corrupted chunks can be deleted with appropriate configuration

## Usage Example

```c
#include <fluent-bit/flb_storage.h>

// Initialize storage layer
int ret = flb_storage_create(ctx);
if (ret != 0) {
    flb_error("Failed to initialize storage layer");
    return -1;
}

// Access storage metrics
int mem_chunks, fs_chunks;
flb_storage_chunk_count(ctx, &mem_chunks, &fs_chunks);
printf("Memory chunks: %d, Filesystem chunks: %d\n", mem_chunks, fs_chunks);

// Cleanup storage layer
flb_storage_destroy(ctx);
```

## Configuration Options

The storage layer can be configured through Fluent Bit configuration:
- `storage.path`: Filesystem path for storage (enables filesystem storage)
- `storage.sync`: Synchronization mode ("normal" or "full")
- `storage.checksum`: Enable/disable checksums for data integrity
- `storage.backlog.mem_limit`: Memory limit for storage backlog
- `storage.max_chunks_up`: Maximum number of chunks to keep in memory