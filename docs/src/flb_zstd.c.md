# flb_zstd.c Documentation

## Overview

The `flb_zstd` module provides Zstandard (Zstd) compression and decompression utilities for Fluent Bit. This implementation handles compression and decompression of data using the Zstandard algorithm, which offers high compression ratios with fast compression and decompression speeds.

Zstandard compression is essential for reducing network bandwidth usage and storage requirements in Fluent Bit's data pipeline, particularly for log data transmission and storage.

## Key Features

- Zstandard compression and decompression
- Stream-based decompression for unknown-size data
- Integration with Fluent Bit's compression framework
- Error handling with detailed diagnostics
- Memory-efficient buffer management

## Data Structures

### struct flb_zstd_decompression_context

Represents a Zstandard decompression context:

```c
struct flb_zstd_decompression_context {
    ZSTD_DCtx *dctx;  /* Zstandard decompression context */
};
```

## Key Functions

### flb_zstd_compress()

```c
int flb_zstd_compress(void *in_data, size_t in_len, void **out_data, size_t *out_len);
```

Compresses data using Zstandard compression.

**Parameters:**
- `in_data`: Input data to compress
- `in_len`: Length of input data
- `out_data`: Pointer to store compressed data
- `out_len`: Pointer to store length of compressed data

**Returns:**
- `0` on success
- `-1` on error

### flb_zstd_uncompress()

```c
int flb_zstd_uncompress(void *in_data, size_t in_len, void **out_data, size_t *out_len);
```

Decompresses Zstandard-compressed data.

**Parameters:**
- `in_data`: Compressed input data
- `in_len`: Length of compressed data
- `out_data`: Pointer to store decompressed data
- `out_len`: Pointer to store length of decompressed data

**Returns:**
- `0` on success
- `-1` on error

### flb_zstd_decompressor_dispatch()

```c
int flb_zstd_decompressor_dispatch(struct flb_decompression_context *context,
                                   void *output_buffer,
                                   size_t *output_length);
```

Decompresses a single Zstandard frame from the decompression context.

**Parameters:**
- `context`: Decompression context
- `output_buffer`: Buffer to store decompressed data
- `output_length`: Pointer to store length of decompressed data

**Returns:**
- `FLB_DECOMPRESSOR_SUCCESS` on success
- `FLB_DECOMPRESSOR_FAILURE` on error

### flb_zstd_decompression_context_create()

```c
void *flb_zstd_decompression_context_create(void);
```

Creates a new Zstandard decompression context.

**Returns:**
- Pointer to the new decompression context on success
- `NULL` on error

### flb_zstd_decompression_context_destroy()

```c
void flb_zstd_decompression_context_destroy(void *context);
```

Destroys a Zstandard decompression context and frees associated resources.

**Parameters:**
- `context`: Decompression context to destroy

## Implementation Details

### Compression Process

The compression implementation follows these steps:

1. **Buffer Allocation**: Allocates a buffer large enough to hold the compressed data using `ZSTD_compressBound()`
2. **Compression**: Compresses the input data using `ZSTD_compress()` with compression level 1
3. **Error Handling**: Checks for compression errors using `ZSTD_isError()`
4. **Result Transfer**: Transfers ownership of the compressed buffer to the caller

### Decompression Process

The decompression implementation handles two scenarios:

1. **Known Size**: When the decompressed size is known, it uses `ZSTD_decompress()` directly
2. **Unknown Size**: When the decompressed size is unknown, it uses a streaming approach with `ZSTD_decompressStream()`

### Streaming Decompression

For unknown-size data, the implementation:

1. **Initial Buffer**: Allocates an initial buffer of 64KB
2. **Stream Processing**: Uses `ZSTD_decompressStream()` to process data incrementally
3. **Buffer Growth**: Doubles the buffer size when needed
4. **Completion Check**: Detects when decompression is complete

### Frame-Based Decompression

The `flb_zstd_decompressor_dispatch()` function implements frame-based decompression:

1. **Frame Detection**: Uses `ZSTD_findFrameCompressedSize()` to find frame boundaries
2. **Error Handling**: Distinguishes between recoverable errors (need more data) and fatal errors
3. **Frame Processing**: Decompresses complete frames using `ZSTD_decompressDCtx()`
4. **Buffer Management**: Updates buffer pointers and reports decompressed sizes

### Memory Management

The module follows these memory management practices:
- Proper allocation and deallocation of buffers
- Error handling with cleanup on failure paths
- Resource cleanup on destruction
- Efficient buffer reuse where possible

## Usage Example

```c
#include <fluent-bit/flb_zstd.h>
#include <fluent-bit/flb_mem.h>
#include <fluent-bit/flb_log.h>

// Compress data example
int compress_data_example(const char *input, size_t input_len) {
    void *compressed_data = NULL;
    size_t compressed_len = 0;
    
    // Compress the data
    if (flb_zstd_compress((void *) input, input_len, &compressed_data, &compressed_len) != 0) {
        flb_error("Failed to compress data");
        return -1;
    }
    
    flb_info("Compressed %zu bytes to %zu bytes (%.1f%%)", 
             input_len, compressed_len, (compressed_len * 100.0) / input_len);
    
    // Use compressed data...
    
    // Clean up
    flb_free(compressed_data);
    return 0;
}

// Decompress data example
int decompress_data_example(const char *compressed_input, size_t compressed_len) {
    void *decompressed_data = NULL;
    size_t decompressed_len = 0;
    
    // Decompress the data
    if (flb_zstd_uncompress((void *) compressed_input, compressed_len, 
                           &decompressed_data, &decompressed_len) != 0) {
        flb_error("Failed to decompress data");
        return -1;
    }
    
    flb_info("Decompressed %zu bytes to %zu bytes", compressed_len, decompressed_len);
    
    // Use decompressed data...
    
    // Clean up
    flb_free(decompressed_data);
    return 0;
}

// Streaming decompression example
int streaming_decompress_example() {
    void *context = flb_zstd_decompression_context_create();
    if (!context) {
        flb_error("Failed to create decompression context");
        return -1;
    }
    
    // Process data in chunks...
    
    flb_zstd_decompression_context_destroy(context);
    return 0;
}
```

## Integration with Fluent Bit

The Zstandard module integrates with other Fluent Bit components:

1. **Compression Framework**: Part of Fluent Bit's generic compression system
2. **Storage**: Used for compressing data in storage backends
3. **Network**: Used for compressing data during network transmission
4. **Plugins**: Available to plugins that need compression capabilities

## Error Handling

All functions follow Fluent Bit's error handling conventions:
- Zstandard errors are checked using `ZSTD_isError()`
- Detailed error messages are logged using `ZSTD_getErrorName()`
- Memory allocation failures are handled with `flb_errno()`
- Proper cleanup is performed on failure paths
- NULL pointers are checked before use
- Resource cleanup is performed on destruction

## Performance Considerations

The implementation is optimized for:
- Fast compression and decompression
- Memory efficiency
- Streaming processing of large data sets
- Integration with Fluent Bit's event-driven architecture