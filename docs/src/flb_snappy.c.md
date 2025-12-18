# flb_snappy.c and flb_snappy.h Documentation

## Overview

The `flb_snappy` module provides Snappy compression and decompression functionality for Fluent Bit. Snappy is a fast compression and decompression library developed by Google that prioritizes speed over maximum compression ratio.

This implementation wraps the Google Snappy library and provides additional functionality for handling framed Snappy data, which is commonly used in distributed systems and log processing pipelines.

## Key Functions

### flb_snappy_compress()

```c
int flb_snappy_compress(char *in_data, size_t in_len,
                        char **out_data, size_t *out_len);
```

Compresses data using the Snappy algorithm.

**Parameters:**
- `in_data`: Input data to compress
- `in_len`: Length of input data
- `out_data`: Pointer to store the compressed data buffer
- `out_len`: Pointer to store the length of compressed data

**Returns:**
- `0` on success
- `-1` on memory allocation failure
- `-2` on Snappy environment initialization failure
- `-3` on compression failure

### flb_snappy_uncompress()

```c
int flb_snappy_uncompress(char *in_data, size_t in_len,
                          char **out_data, size_t *out_size);
```

Decompresses data using the Snappy algorithm.

**Parameters:**
- `in_data`: Input compressed data
- `in_len`: Length of input compressed data
- `out_data`: Pointer to store the decompressed data buffer
- `out_size`: Pointer to store the length of decompressed data

**Returns:**
- `0` on success
- `-1` on invalid compressed data
- `-2` on memory allocation failure
- `-3` on decompression failure

### flb_snappy_uncompress_framed_data()

```c
int flb_snappy_uncompress_framed_data(char *in_data, size_t in_len,
                                      char **out_data, size_t *out_len);
```

Decompresses framed Snappy data, which consists of multiple chunks with headers and checksums.

**Parameters:**
- `in_data`: Input framed compressed data
- `in_len`: Length of input framed compressed data
- `out_data`: Pointer to store the decompressed data buffer
- `out_len`: Pointer to store the length of decompressed data

**Returns:**
- `0` on success
- `-1` on invalid parameters
- `-2` on frame size limit exceeded
- `-3` on checksum mismatch
- `-4` on chunk decompression failure
- `-5` on reserved unskippable frame type
- `-6` on memory allocation failure

## Data Structures

### struct flb_snappy_data_chunk

Represents a chunk of data in framed Snappy format.

```c
struct flb_snappy_data_chunk {
    int             dynamically_allocated_buffer;
    char           *buffer;
    size_t          length;
    struct cfl_list _head;
};
```

## Frame Types

The implementation supports the following Snappy frame types:

- `FLB_SNAPPY_FRAME_TYPE_STREAM_IDENTIFIER` (0xFF): Identifies the stream
- `FLB_SNAPPY_FRAME_TYPE_COMPRESSED_DATA` (0x00): Compressed data chunk
- `FLB_SNAPPY_FRAME_TYPE_UNCOMPRESSED_DATA` (0x01): Uncompressed data chunk
- `FLB_SNAPPY_FRAME_TYPE_PADDING` (0xFE): Padding frames
- Reserved frame types for future use

## Implementation Details

### Compression Process

1. Calculates the maximum possible compressed size
2. Allocates memory for the compressed output
3. Initializes the Snappy environment
4. Performs the compression operation
5. Cleans up the Snappy environment
6. Returns the compressed data and its size

### Decompression Process

1. Determines the required output buffer size
2. Allocates memory for the decompressed output
3. Performs the decompression operation
4. Returns the decompressed data and its size

### Framed Data Handling

For framed data, the implementation:

1. Parses frame headers to identify frame types
2. Validates stream identifiers
3. Processes compressed and uncompressed chunks
4. Verifies checksums for data integrity
5. Aggregates multiple chunks into a single output buffer
6. Handles padding and reserved frame types appropriately

## Performance Considerations

Snappy is optimized for speed:
- Fast compression and decompression
- Low memory overhead
- Good compression ratio for typical log data
- Efficient handling of small data chunks

## Usage Example

```c
#include <fluent-bit/flb_snappy.h>
#include <fluent-bit/flb_log.h>

// Compress data
char *input_data = "This is some data to compress";
size_t input_len = strlen(input_data);
char *compressed_data = NULL;
size_t compressed_len = 0;

if (flb_snappy_compress(input_data, input_len, &compressed_data, &compressed_len) == 0) {
    flb_info("Compressed %zu bytes to %zu bytes", input_len, compressed_len);
    
    // Decompress data
    char *decompressed_data = NULL;
size_t decompressed_len = 0;
    
    if (flb_snappy_uncompress(compressed_data, compressed_len, &decompressed_data, &decompressed_len) == 0) {
        flb_info("Decompressed %zu bytes to %zu bytes", compressed_len, decompressed_len);
        flb_info("Original: %s", input_data);
        flb_info("Decompressed: %s", decompressed_data);
        
        // Clean up
        flb_free(compressed_data);
        flb_free(decompressed_data);
    } else {
        flb_error("Failed to decompress data");
        flb_free(compressed_data);
    }
} else {
    flb_error("Failed to compress data");
}

// Handle framed data
char *framed_data = /* ... framed Snappy data ... */;
size_t framed_len = /* ... length of framed data ... */;
char *decompressed_framed = NULL;
size_t decompressed_framed_len = 0;

if (flb_snappy_uncompress_framed_data(framed_data, framed_len, &decompressed_framed, &decompressed_framed_len) == 0) {
    flb_info("Successfully decompressed framed data (%zu bytes)", decompressed_framed_len);
    flb_free(decompressed_framed);
} else {
    flb_error("Failed to decompress framed data");
}
```