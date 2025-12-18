# flb_input_chunk.c

## Overview

This file contains the core implementation for managing input chunks in Fluent Bit. Input chunks are fundamental data structures that store records (logs, metrics, traces, etc.) collected by input plugins before they are processed and forwarded to output plugins.

The module implements chunk lifecycle management, data storage and retrieval, size management, and integration with the Chunk I/O library for persistent storage. It also handles chunk routing, metrics collection, and memory management for efficient data processing.

Chunks serve as the primary data container in Fluent Bit's data pipeline, bridging the gap between input collection and output forwarding while providing persistence and reliability guarantees.

## Key Functions

### Chunk Lifecycle Management

#### `flb_input_chunk_create()`
Creates a new input chunk with specified event type (logs, metrics, traces, etc.) and tag. Initializes all necessary data structures and associates the chunk with the parent input instance.

#### `flb_input_chunk_destroy()`
Destroys an input chunk and frees all associated resources. Optionally deletes the underlying storage.

#### `flb_input_chunk_destroy_all()`
Destroys all chunks associated with an input plugin instance.

#### `flb_input_chunk_destroy_corrupted()`
Destroys a corrupted chunk with specific cleanup procedures.

### Data Operations

#### `flb_input_chunk_append_obj()`
Appends a MessagePack object to a chunk, typically used for structured log data.

#### `flb_input_chunk_append_raw()`
Appends raw binary data to a chunk, used for various data types including blobs.

#### `flb_input_chunk_write()`
Writes data to a chunk at the current position.

#### `flb_input_chunk_write_at()`
Writes data to a chunk at a specific offset.

### Chunk State Management

#### `flb_input_chunk_set_up()`
Marks a chunk as "up" (active) for processing.

#### `flb_input_chunk_down()`
Marks a chunk as "down" (inactive) to prevent further modifications.

#### `flb_input_chunk_is_up()`
Checks if a chunk is currently marked as up (active).

### Data Retrieval

#### `flb_input_chunk_flush()`
Retrieves the complete data content of a chunk for processing.

#### `flb_input_chunk_get_name()`
Returns the unique identifier name of a chunk.

#### `flb_input_chunk_get_event_type()`
Returns the event type (logs, metrics, traces, etc.) of a chunk.

#### `flb_input_chunk_get_tag()`
Retrieves the tag associated with a chunk.

#### `flb_input_chunk_get_size()`
Returns the current size of a chunk.

### Chunk Mapping

#### `flb_input_chunk_map()`
Maps an existing Chunk I/O chunk to a Fluent Bit input chunk structure.

#### `flb_input_chunk_set_up_down()`
Manages the up/down state of a chunk with proper synchronization.

### Routing and Metrics

#### `flb_input_chunk_update_output_instances()`
Updates output instance tracking for a chunk based on its size.

#### `flb_input_chunk_ring_buffer_collector()`
Handles ring buffer collection for chunks.

### Utility Functions

#### `flb_input_chunk_release_lock()`
Releases locks associated with a chunk.

#### `flb_input_chunk_set_limits()`
Sets size limits for chunks based on configuration.

#### `flb_input_chunk_total_size()`
Calculates the total size of all chunks for an input instance.

## Important Variables/Constants

### Chunk Size Definitions
- `FLB_INPUT_CHUNK_SIZE`: Default hint size for new chunks (256KB)
- `FLB_INPUT_CHUNK_FS_MAX_SIZE`: Maximum file system chunk size (2MB)
- `FLB_INPUT_CHUNK_META_HEADER`: Reserved bytes for metadata header (4 bytes)

### Chunk Magic Bytes
- `FLB_INPUT_CHUNK_MAGIC_BYTE_0`: First magic byte for chunk identification (0xF1)
- `FLB_INPUT_CHUNK_MAGIC_BYTE_1`: Second magic byte for chunk identification (0x77)

### Chunk Types
- `FLB_INPUT_CHUNK_TYPE_LOGS`: Log data chunks (0)
- `FLB_INPUT_CHUNK_TYPE_METRICS`: Metrics data chunks (1)
- `FLB_INPUT_CHUNK_TYPE_TRACES`: Trace data chunks (2)
- `FLB_INPUT_CHUNK_TYPE_BLOBS`: Blob data chunks (3)
- `FLB_INPUT_CHUNK_TYPE_PROFILES`: Profile data chunks (4)

### Tag Limits
- `FLB_INPUT_CHUNK_TAG_MAX`: Maximum tag length (65535 - metadata header size)

### Data Structures
- `struct flb_input_chunk`: Main chunk structure containing event type, file system tracking, busy status, chunk reference, stream offset, MessagePack packer, input instance reference, task reference, creation time, and routing mask.
- `struct input_chunk_raw`: Raw chunk structure for direct data operations.

## Dependencies

- `fluent-bit/flb_info.h`: Core Fluent Bit information
- `fluent-bit/flb_config.h`: Configuration management
- `fluent-bit/flb_input.h`: Input plugin interface
- `fluent-bit/flb_input_chunk.h`: Chunk interface definitions
- `fluent-bit/flb_input_plugin.h`: Plugin interface definitions
- `fluent-bit/flb_storage.h`: Storage management
- `fluent-bit/flb_time.h`: Time utilities
- `fluent-bit/flb_lib.h`: Library interface
- `fluent-bit/flb_router.h`: Routing system
- `fluent-bit/flb_task.h`: Task management
- `fluent-bit/flb_routes_mask.h`: Route masking
- `fluent-bit/flb_metrics.h`: Metrics collection
- `fluent-bit/stream_processor/flb_sp.h`: Stream processor
- `fluent-bit/flb_ring_buffer.h`: Ring buffer implementation
- `chunkio/chunkio.h`: Chunk I/O library
- `monkey/mk_core.h`: Monkey Core event loop
- `fluent-bit/flb_chunk_trace.h`: Chunk tracing (conditional)

## Implementation Details

1. **Chunk I/O Integration**: Deep integration with the Chunk I/O library for persistent storage and efficient data management.

2. **Multi-Type Support**: Comprehensive support for different data types including logs, metrics, traces, blobs, and profiles through event type classification.

3. **Memory Management**: Efficient memory handling with proper allocation, deallocation, and size tracking for chunks.

4. **State Management**: Robust up/down state management to control chunk accessibility during processing.

5. **Routing System**: Integration with the routing system to track which output plugins a chunk should be sent to.

6. **Metrics Collection**: Built-in metrics tracking for record counts and chunk sizes.

7. **Error Handling**: Comprehensive error detection and reporting throughout all chunk operations.

8. **Thread Safety**: Proper synchronization mechanisms for multi-threaded environments.

9. **Backlog Support**: Special handling for file system backlog chunks with dedicated tracking.

10. **Stream Processing Integration**: Coordination with the stream processor for data transformation.

## Usage Example

```c
// Create a new input chunk for log data
struct flb_input_chunk *chunk = flb_input_chunk_create(
    instance,           // Input plugin instance
    FLB_INPUT_CHUNK_TYPE_LOGS, // Event type
    "my.log.tag",       // Tag
    12                  // Tag length
);

if (chunk != NULL) {
    // Append log data to the chunk
    msgpack_sbuffer *sbuf = msgpack_sbuffer_new();
    msgpack_packer *pck = msgpack_packer_new(sbuf, msgpack_sbuffer_write);
    
    // Pack log data
    msgpack_pack_array(pck, 2);
    msgpack_pack_double(pck, flb_time_now());
    msgpack_pack_map(pck, 1);
    msgpack_pack_str(pck, 4);
    msgpack_pack_str_body(pck, "msg", 3);
    msgpack_pack_str(pck, 12);
    msgpack_pack_str_body(pck, "Hello World!", 12);
    
    // Convert to msgpack object and append to chunk
    msgpack_zone *zone = msgpack_zone_new(2048);
    msgpack_object obj;
    msgpack_unpack(sbuf->data, sbuf->size, NULL, zone, &obj);
    
    int ret = flb_input_chunk_append_obj(
        instance,       // Input plugin instance
        "my.log.tag",   // Tag
        12,              // Tag length
        obj              // Log data object
    );
    
    if (ret == 0) {
        printf("Log data appended to chunk successfully\n");
    }
    
    // Clean up
    msgpack_packer_free(pck);
    msgpack_sbuffer_free(sbuf);
    msgpack_zone_free(zone);
    
    // Later, when processing the chunk
    size_t chunk_size;
    const void *chunk_data = flb_input_chunk_flush(chunk, &chunk_size);
    if (chunk_data != NULL) {
        printf("Processing chunk with %zu bytes of data\n", chunk_size);
        // Process chunk_data...
    }
    
    // Destroy the chunk when done
    flb_input_chunk_destroy(chunk, FLB_TRUE);
}

// Example of getting chunk information
if (chunk != NULL) {
    flb_sds_t chunk_name = flb_input_chunk_get_name(chunk);
    int event_type = flb_input_chunk_get_event_type(chunk);
    const char *tag_buf;
    int tag_len;
    
    flb_input_chunk_get_tag(chunk, &tag_buf, &tag_len);
    size_t size = flb_input_chunk_get_size(chunk);
    
    printf("Chunk: %s\n", chunk_name);
    printf("Event Type: %d\n", event_type);
    printf("Tag: %.*s\n", tag_len, tag_buf);
    printf("Size: %zu bytes\n", size);
    
    cfl_sds_destroy(chunk_name);
}
```