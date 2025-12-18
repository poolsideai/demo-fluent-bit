# flb_fstore.c

## Overview

This file implements the file storage management system for Fluent Bit. It provides functionality for managing persistent storage of data chunks using the Chunk I/O (cio) library, which handles both memory and filesystem-based storage.

The file storage system serves as an abstraction layer over Chunk I/O, providing convenient interfaces for creating, managing, and accessing storage streams and files. It's primarily used for Fluent Bit's filesystem-based storage backend.

## Key Functions

### `flb_fstore_create()`
Creates a new file storage context with the specified root path and storage type. Initializes the underlying Chunk I/O context and loads existing content from the filesystem.

### `flb_fstore_destroy()`
Cleans up and destroys a file storage context, releasing all associated resources and streams.

### `flb_fstore_stream_create()`
Creates or retrieves a storage stream with the specified name. If the stream already exists, it returns the existing reference.

### `flb_fstore_file_create()`
Creates a new file within a specified storage stream, initializing the underlying Chunk I/O chunk.

### `flb_fstore_file_get()`
Retrieves a file reference from a storage stream by name.

### `flb_fstore_file_append()`
Appends data to an existing file, ensuring the chunk is loaded into memory if needed.

### `flb_fstore_file_meta_set()`
Sets metadata for a file, writing it to the underlying Chunk I/O chunk.

### `flb_fstore_file_meta_get()`
Retrieves metadata from a file, reading it from the underlying Chunk I/O chunk.

### `flb_fstore_file_content_copy()`
Creates a copy of the file content in memory, which must be freed by the caller.

### `flb_fstore_file_inactive()`
Sets a file to inactive mode by removing it from the active list without deleting the actual file.

### `flb_fstore_file_delete()`
Permanently deletes a file from both the storage context and the filesystem.

### `flb_fstore_dump()`
Provides a debug dump of the current file storage state, showing all streams and files.

## Important Variables/Constants

### File Storage Context (`struct flb_fstore`)
The main storage context contains:
- `cio`: Underlying Chunk I/O context
- `root_path`: Root directory for filesystem storage
- `store_type`: Type of storage (memory, filesystem, etc.)
- `streams`: List of managed storage streams

### Storage Stream (`struct flb_fstore_stream`)
Represents a logical grouping of files:
- `stream`: Underlying Chunk I/O stream
- `path`: Full path to the stream directory
- `name`: Stream name
- `files`: List of files in this stream

### File Reference (`struct flb_fstore_file`)
Represents a single file:
- `chunk`: Underlying Chunk I/O chunk
- `stream`: Parent stream
- `name`: File name
- `meta_buf`: Cached metadata buffer
- `meta_size`: Size of metadata

## Dependencies

- `fluent-bit/flb_info.h`: Fluent Bit core information
- `fluent-bit/flb_fstore.h`: File storage interface
- `fluent-bit/flb_log.h`: Logging utilities
- `fluent-bit/flb_mem.h`: Memory management utilities
- `fluent-bit/flb_sds.h`: Simple Dynamic String utilities
- `chunkio/chunkio.h`: Chunk I/O operations

## Implementation Details

1. **Chunk I/O Abstraction**: Provides a higher-level interface over Chunk I/O, simplifying common storage operations.

2. **Metadata Management**: Handles file metadata caching and synchronization with the underlying storage.

3. **Memory Management**: Uses Fluent Bit's memory allocation functions and SDS strings for efficient memory handling.

4. **Error Handling**: Implements comprehensive error checking with proper resource cleanup.

5. **Lazy Loading**: Files are loaded into memory only when needed for operations.

6. **Reference Counting**: Manages file references to prevent premature cleanup.

## Usage Example

```c
// Create file storage context
struct flb_fstore *fs = flb_fstore_create("/var/log/fluent-bit", CIO_STORE_FS);

if (!fs) {
    flb_error("Failed to create file storage");
    return -1;
}

// Create a storage stream
struct flb_fstore_stream *stream = flb_fstore_stream_create(fs, "input1");

// Create a new file
struct flb_fstore_file *file = flb_fstore_file_create(fs, stream, "chunk_001", 1024);

// Append data to the file
const char *data = "Sample log data";
int ret = flb_fstore_file_append(file, (void *)data, strlen(data));

// Set metadata
const char *meta = "{"tag":"app.logs","time":1234567890}";
ret = flb_fstore_file_meta_set(fs, file, (void *)meta, strlen(meta));

// Read file content
void *content = NULL;
size_t content_size = 0;
ret = flb_fstore_file_content_copy(fs, file, &content, &content_size);

if (ret == 0 && content) {
    // Process content
    process_file_content(content, content_size);
    flb_free(content);
}

// Clean up
flb_fstore_destroy(fs);
```