# flb_ring_buffer.c

## Overview

The `flb_ring_buffer.c` file implements a ring buffer (circular buffer) abstraction for Fluent Bit, built on top of the `lwrb` (lightweight ring buffer) library. This component provides efficient, thread-safe storage for data that needs to be processed in a first-in-first-out manner.

Ring buffers are particularly useful in Fluent Bit for buffering data between different components of the pipeline, such as between input and filter plugins, or for temporary data storage during processing.

The implementation wraps the `lwrb` library to provide:
- Fixed-size circular buffer storage
- Thread-safe read/write operations
- Automatic flush signaling when buffer reaches a certain occupancy level
- Integration with Fluent Bit's event loop system

## Key Functions/Components

### Core Data Structure

#### `struct flb_ring_buffer`
The main ring buffer context:
- `ctx`: Pointer to the underlying `lwrb` context
- `event_loop`: Event loop for flush signaling
- `flush_pending`: Flag to prevent signal flooding
- `signal_event`: Event loop entry for flush signals
- `signal_channels`: Pipe file descriptors for flush signaling
- `data_window`: Occupancy threshold for flush signaling (0-100%)
- `data_size`: Total buffer size
- `data_buf`: Actual buffer storage

### Main Functions

#### `flb_ring_buffer_create(uint64_t size)`
Creates a new ring buffer with the specified size. Returns a pointer to the new ring buffer context or NULL on failure.

#### `flb_ring_buffer_destroy(struct flb_ring_buffer *rb)`
Destroys a ring buffer context and frees all associated resources.

#### `flb_ring_buffer_add_event_loop(struct flb_ring_buffer *rb, void *evl, uint8_t window_size)`
Integrates the ring buffer with Fluent Bit's event loop system. When the buffer reaches the specified occupancy percentage (`window_size`), it will signal the event loop to trigger a flush operation.

#### `flb_ring_buffer_write(struct flb_ring_buffer *rb, void *ptr, size_t size)`
Writes data to the ring buffer. Returns 0 on success or -1 if there isn't enough space available.

#### `flb_ring_buffer_read(struct flb_ring_buffer *rb, void *ptr, size_t size)`
Reads data from the ring buffer. Returns 0 on success or -1 if there isn't enough data available.

### Helper Functions

#### `flb_ring_buffer_remove_event_loop(struct flb_ring_buffer *rb)`
Removes the ring buffer from the event loop and cleans up associated resources.

## Important Variables/Constants

### Buffer Size
- The buffer size is specified in bytes when creating the ring buffer
- The actual allocated size includes additional space for the `lwrb` implementation

### Flush Window Size
- Range: 0-100% of buffer capacity
- When set to 0, flush signaling is disabled
- When set above 100%, it's capped at 100%
- Typical values: 80-95% to trigger flush before buffer fills completely

## Dependencies and Relationships

This module depends on:
- `lwrb`: Lightweight ring buffer library
- `flb_pipe`: Pipe utilities for inter-thread communication
- `flb_mem`: Memory management functions
- `flb_log`: Logging functionality
- `mk_core`: Monkey Core event loop integration

It's used by:
- Input plugins for buffering incoming data
- Filter plugins for temporary data storage
- Output plugins for batching data before sending
- Various internal buffering mechanisms

## Implementation Details

The ring buffer implementation provides several key features:

1. **Fixed-Size Storage**: The buffer has a fixed capacity specified at creation time, making memory usage predictable.

2. **Circular Nature**: When the end of the buffer is reached, writing continues from the beginning, overwriting old data if necessary.

3. **Automatic Flush Signaling**: When integrated with the event loop, the buffer automatically signals when it reaches a specified occupancy level, enabling efficient data processing.

4. **Thread Safety**: The underlying `lwrb` implementation provides thread-safe operations, though external synchronization may be needed for complex usage patterns.

5. **Efficient Memory Usage**: Minimal overhead beyond the actual buffer storage.

6. **Non-blocking Operations**: Write operations fail gracefully when the buffer is full, allowing callers to handle backpressure appropriately.

The flush signaling mechanism works by:
1. Monitoring buffer occupancy during write operations
2. When occupancy exceeds the configured threshold, setting a pending flag
3. Writing a signal byte to a pipe to notify the event loop
4. Preventing further signals until the buffer is drained below the threshold

## Usage Examples

### Creating and Using a Ring Buffer
```c
// Create a ring buffer with 1MB capacity
struct flb_ring_buffer *rb = flb_ring_buffer_create(1024 * 1024);

if (rb == NULL) {
    flb_error("Failed to create ring buffer");
    return -1;
}

// Write data to the buffer
char *data = "Hello, Fluent Bit!";
size_t data_len = strlen(data);

int ret = flb_ring_buffer_write(rb, data, data_len);
if (ret != 0) {
    flb_error("Failed to write to ring buffer");
    flb_ring_buffer_destroy(rb);
    return -1;
}

// Read data from the buffer
char buffer[1024];
ret = flb_ring_buffer_read(rb, buffer, data_len);
if (ret == 0) {
    buffer[data_len] = '\0';
    printf("Read from buffer: %s\n", buffer);
}

// Clean up
flb_ring_buffer_destroy(rb);
```

### Integrating with Event Loop
```c
// Create ring buffer
struct flb_ring_buffer *rb = flb_ring_buffer_create(1024 * 1024);

// Integrate with event loop (trigger flush at 80% occupancy)
int ret = flb_ring_buffer_add_event_loop(rb, event_loop, 80);
if (ret != 0) {
    flb_error("Failed to integrate ring buffer with event loop");
    flb_ring_buffer_destroy(rb);
    return -1;
}

// Write data (will trigger flush signal when buffer reaches 80%)
for (int i = 0; i < 1000; i++) {
    char data[256];
    snprintf(data, sizeof(data), "Message %d", i);
    
    ret = flb_ring_buffer_write(rb, data, strlen(data));
    if (ret != 0) {
        flb_warn("Ring buffer full, dropping data");
        break;
    }
}

// Event loop will receive flush signals when buffer reaches 80% occupancy
```

### Handling Flush Signals in Event Loop
```c
// Event loop callback function
void handle_flush_signal(void *data) {
    struct flb_ring_buffer *rb = (struct flb_ring_buffer *) data;
    
    // Drain the buffer
    char buffer[4096];
    size_t bytes_read;
    
    do {
        bytes_read = lwrb_peek(rb->ctx, buffer, sizeof(buffer));
        if (bytes_read > 0) {
            // Process the data
            process_data(buffer, bytes_read);
            
            // Remove processed data from buffer
            lwrb_skip(rb->ctx, bytes_read);
        }
    } while (bytes_read > 0);
    
    // Reset flush pending flag
    rb->flush_pending = FLB_FALSE;
}
```

### Checking Buffer Status
```c
// Check available space
size_t free_space = lwrb_get_free(rb->ctx);
printf("Free space: %zu bytes\n", free_space);

// Check used space
size_t used_space = lwrb_get_used(rb->ctx);
printf("Used space: %zu bytes\n", used_space);

// Check total capacity
size_t capacity = rb->data_size;
printf("Total capacity: %zu bytes\n", capacity);

// Check occupancy percentage
if (capacity > 0) {
    int occupancy = (used_space * 100) / capacity;
    printf("Occupancy: %d%%\n", occupancy);
}
```