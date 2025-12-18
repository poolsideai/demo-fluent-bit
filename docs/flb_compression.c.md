# flb_compression.c Documentation

## Overview

This file implements compression utilities for data reduction in Fluent Bit. The compression system provides a unified interface for different compression algorithms (currently gzip and Zstandard) to compress and decompress data chunks efficiently. This is essential for reducing network bandwidth usage and storage requirements when transmitting or storing large volumes of log data.

The implementation supports both compression and decompression operations, with a flexible architecture that can accommodate additional compression algorithms in the future.

## Key Functions

### `flb_decompression_context_create()`
Creates a new decompression context for a specific compression algorithm. This function allocates the necessary buffers and initializes the algorithm-specific decompression context.

### `flb_decompression_context_destroy()`
Destroys a decompression context and frees all associated resources, including the algorithm-specific context and input buffers.

### `flb_decompression_context_get_append_buffer()`
Returns a pointer to the buffer where new compressed data can be appended for decompression. This function also manages buffer adjustments to optimize memory usage.

### `flb_decompression_context_get_available_space()`
Calculates and returns the amount of available space in the input buffer for appending new compressed data.

### `flb_decompression_context_resize_buffer()`
Resizes the input buffer to accommodate larger compressed data chunks.

### `flb_decompress()`
Performs the actual decompression operation using the appropriate algorithm based on the context configuration.

## Important Variables and Constants

### `struct flb_decompression_context`
Main context structure for decompression that holds:
- Input buffer for storing compressed data
- Read buffer pointer for tracking current position
- Buffer size and length information
- Algorithm identifier (gzip or Zstandard)
- State information for tracking decompression progress
- Pointer to algorithm-specific decompression context

### `FLB_COMPRESSION_ALGORITHM_*` constants
Enumeration values for supported compression algorithms:
- `FLB_COMPRESSION_ALGORITHM_GZIP`
- `FLB_COMPRESSION_ALGORITHM_ZSTD`

### `FLB_DECOMPRESSOR_STATE_*` constants
Enumeration values for tracking decompression state:
- `FLB_DECOMPRESSOR_STATE_EXPECTING_HEADER`
- `FLB_DECOMPRESSOR_STATE_EXPECTING_BODY`

### `FLB_DECOMPRESSION_BUFFER_SIZE`
Default buffer size for decompression operations.

## Dependencies and Relationships

### Core Dependencies
- `fluent-bit/flb_info.h` - For general Fluent Bit information
- `fluent-bit/flb_mem.h` - For memory management functions
- `fluent-bit/flb_log.h` - For logging functionality
- `fluent-bit/flb_gzip.h` - For gzip compression/decompression
- `fluent-bit/flb_zstd.h` - For Zstandard compression/decompression
- `fluent-bit/flb_compression.h` - For compression-related definitions

### External Dependencies
- Standard C library functions (malloc, free, memmove)
- System headers for memory management

## Notable Implementation Details

### Unified Interface Design
The implementation provides a single interface (`flb_decompress`) that delegates to algorithm-specific implementations based on the context configuration. This design makes it easy to add new compression algorithms without changing the public API.

### Dynamic Buffer Management
The system includes sophisticated buffer management features:
- Automatic buffer adjustment to optimize memory usage
- Dynamic buffer resizing to accommodate varying data sizes
- Efficient memory movement to minimize copying operations

### State Tracking
The decompression context maintains state information to track the decompression process, which is particularly important for streaming decompression scenarios where data arrives in chunks.

### Error Handling
Comprehensive error handling is implemented throughout the compression system, with proper cleanup of resources in case of failures.

### Memory Efficiency
The implementation optimizes memory usage by:
- Adjusting buffer positions to minimize memory fragmentation
- Only allocating the required buffer size
- Properly freeing all allocated resources

## Usage Examples

### Creating a Decompression Context
A decompression context is created when decompression is needed for a specific algorithm:
```c
struct flb_decompression_context *ctx =
    flb_decompression_context_create(FLB_COMPRESSION_ALGORITHM_GZIP, 
                                     FLB_DECOMPRESSION_BUFFER_SIZE);
```

### Appending Compressed Data
Compressed data can be appended to the context for later decompression:
```c
uint8_t *append_buffer = 
    flb_decompression_context_get_append_buffer(ctx);

// Copy compressed data to append_buffer
memcpy(append_buffer, compressed_data, data_size);
ctx->input_buffer_length += data_size;
```

### Performing Decompression
Once compressed data has been added to the context, it can be decompressed:
```c
char *output_buffer = malloc(expected_output_size);
size_t output_length = expected_output_size;

int result = flb_decompress(ctx, output_buffer, &output_length);

if (result == FLB_DECOMPRESSOR_SUCCESS) {
    // Process decompressed data
}
```

### Cleaning Up Resources
When decompression is complete, the context should be destroyed to free resources:
```c
flb_decompression_context_destroy(ctx);
```

### Buffer Management
The system automatically manages buffer space and can resize buffers when needed:
```c
size_t available_space = 
    flb_decompression_context_get_available_space(ctx);

if (available_space < required_space) {
    flb_decompression_context_resize_buffer(ctx, 
                                           new_buffer_size);
}
```