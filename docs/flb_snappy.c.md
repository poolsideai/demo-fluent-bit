# flb_snappy.c

## Overview

The `flb_snappy.c` file implements Snappy compression and decompression functionality for Fluent Bit. This module provides a wrapper around the Google Snappy compression library to enable efficient compression and decompression of data streams within Fluent Bit.

Snappy is a fast compression and decompression library designed for high-speed processing with reasonable compression ratios. It's particularly well-suited for log processing and data streaming scenarios where speed is more important than maximum compression.

Key features:
- Compression and decompression of raw data using Snappy algorithm
- Support for framed Snappy data format with checksum validation
- Integration with Fluent Bit's memory management system
- Error handling for various compression scenarios
- Support for both simple and framed data formats

## Key Functions/Components

### Core Data Structures

#### `struct flb_snappy_data_chunk`
Represents a chunk of data in framed Snappy format:
- `dynamically_allocated_buffer`: Flag indicating if buffer was dynamically allocated
- `buffer`: Pointer to the data buffer
- `length`: Length of the data in the buffer
- `_head`: Linked list node for maintaining chunk list structure

### Main Functions

#### `flb_snappy_compress(char *in_data, size_t in_len, char **out_data, size_t *out_len)`
Compresses raw data using Snappy algorithm:
1. Calculates maximum compressed size needed
2. Allocates output buffer with appropriate size
3. Initializes Snappy environment
4. Performs compression operation
5. Cleans up Snappy environment
6. Returns compressed data and its length

#### `flb_snappy_uncompress(char *in_data, size_t in_len, char **out_data, size_t *out_len)`
Decompresses Snappy-compressed data:
1. Calculates uncompressed data length
2. Allocates output buffer with appropriate size
3. Performs decompression operation
4. Returns decompressed data and its length

#### `flb_snappy_uncompress_framed_data(char *in_data, size_t in_len, char **out_data, size_t *out_len)`
Decompresses framed Snappy data with checksum validation:
1. Parses framed data structure
2. Validates stream identifier if present
3. Processes each frame according to its type
4. Validates checksums for compressed data frames
5. Aggregates decompressed data from all frames
6. Returns consolidated decompressed data

### Helper Functions

#### `calculate_checksum(char *buffer, size_t length)`
Calculates CRC-32C checksum for Snappy data validation:
1. Computes CRC-32C checksum using CFL library
2. Applies Snappy-specific transformation to checksum
3. Returns transformed checksum value

## Important Constants and Frame Types

### Stream Identifier
- `FLB_SNAPPY_STREAM_IDENTIFIER_STRING`: "sNaPpY" - Identifies framed Snappy data streams

### Frame Size Limits
- `FLB_SNAPPY_FRAME_SIZE_LIMIT`: 65540 - Maximum size for individual frames

### Frame Type Definitions
- `FLB_SNAPPY_FRAME_TYPE_STREAM_IDENTIFIER` (0xFF): Stream identifier frame
- `FLB_SNAPPY_FRAME_TYPE_COMPRESSED_DATA` (0x00): Compressed data frame
- `FLB_SNAPPY_FRAME_TYPE_UNCOMPRESSED_DATA` (0x01): Uncompressed data frame
- `FLB_SNAPPY_FRAME_TYPE_RESERVED_UNSKIPPABLE_BASE` (0x02) to `FLB_SNAPPY_FRAME_TYPE_RESERVED_UNSKIPPABLE_TOP` (0x7F): Reserved unskippable frames
- `FLB_SNAPPY_FRAME_TYPE_RESERVED_SKIPPABLE_BASE` (0x80) to `FLB_SNAPPY_FRAME_TYPE_RESERVED_SKIPPABLE_TOP` (0xFD): Reserved skippable frames
- `FLB_SNAPPY_FRAME_TYPE_PADDING` (0xFE): Padding frame

## Dependencies and Relationships

This module depends on:
- `snappy`: Google Snappy compression library
- `flb_mem`: Fluent Bit memory allocation functions
- `flb_log`: Logging functions for error reporting
- `cfl_checksum`: Checksum calculation functions
- `cfl_list`: Linked list implementation for chunk management

It integrates with:
- Input plugins for decompressing incoming data
- Output plugins for compressing outgoing data
- Record accessor for processing compressed data
- Storage layer for managing compressed chunks

## Implementation Details

### Compression Process
The compression implementation follows these steps:
1. Calculate maximum possible compressed size
2. Allocate output buffer
3. Initialize Snappy environment for optimal performance
4. Perform compression with error checking
5. Clean up environment resources
6. Return compressed data and size

### Decompression Process
The decompression implementation handles both simple and framed formats:
1. **Simple Format**: Direct decompression of raw Snappy data
2. **Framed Format**: Parsing and validation of structured frames

### Framed Data Processing
For framed data, the implementation:
1. Validates stream identifier if present
2. Processes frames sequentially
3. Handles different frame types appropriately
4. Validates checksums for compressed data frames
5. Aggregates output from multiple frames
6. Provides optimized path for single-chunk data

### Memory Management
- Efficient buffer allocation with size pre-calculation
- Proper cleanup of temporary buffers and structures
- Error handling with graceful resource deallocation
- Optimized memory usage patterns for streaming data

### Checksum Validation
- CRC-32C checksums for data integrity verification
- Snappy-specific checksum transformation
- Validation of compressed data frames
- Error reporting for checksum mismatches

### Error Handling
- Comprehensive validation of input parameters
- Graceful degradation on memory allocation failures
- Detailed error codes for different failure scenarios
- Consistent return value conventions
- Proper cleanup on operation failures

## Usage Examples

### Basic Compression and Decompression
```c
// Compress data using Snappy
char *input_data = "This is some data to compress";
size_t input_len = strlen(input_data);
char *compressed_data = NULL;
size_t compressed_len = 0;

int result = flb_snappy_compress(input_data, input_len,
                                 &compressed_data, &compressed_len);
if (result == 0) {
    printf("Successfully compressed %zu bytes to %zu bytes\n",
           input_len, compressed_len);
    
    // Decompress the data
    char *decompressed_data = NULL;
size_t decompressed_len = 0;
    
    result = flb_snappy_uncompress(compressed_data, compressed_len,
                                   &decompressed_data, &decompressed_len);
    if (result == 0) {
        printf("Successfully decompressed %zu bytes\n", decompressed_len);
        printf("Original: %s\n", input_data);
        printf("Decompressed: %s\n", decompressed_data);
        
        // Cleanup
        flb_free(decompressed_data);
    }
    
    // Cleanup
    flb_free(compressed_data);
} else {
    printf("Compression failed with code: %d\n", result);
}
```

### Framed Data Processing
```c
// Process framed Snappy data
char *framed_data = /* ... framed Snappy data ... */;
size_t framed_len = /* ... length of framed data ... */;
char *output_data = NULL;
size_t output_len = 0;

int result = flb_snappy_uncompress_framed_data(framed_data, framed_len,
                                               &output_data, &output_len);
if (result == 0) {
    printf("Successfully processed framed data: %zu bytes\n", output_len);
    
    // Use the decompressed data
    process_decompressed_data(output_data, output_len);
    
    // Cleanup
    flb_free(output_data);
} else {
    printf("Framed data processing failed with code: %d\n", result);
}
```

### Configuration Example
```ini
[INPUT]
    name tail
    path /var/log/app.log
    # Uses Snappy decompression for compressed log files
    
[OUTPUT]
    name s3
    match *
    # Uses Snappy compression for efficient data transfer
```

### Integration Pattern
```c
// Typical integration in an input plugin for compressed data
int input_plugin_process_compressed_data(struct flb_input_instance *ins,
                                        char *compressed_data, size_t data_len) {
    char *decompressed_data = NULL;
    size_t decompressed_len = 0;
    
    // Decompress the data
    int result = flb_snappy_uncompress(compressed_data, data_len,
                                       &decompressed_data, &decompressed_len);
    
    if (result == 0) {
        // Process the decompressed data
        process_log_data(ins, decompressed_data, decompressed_len);
        
        // Cleanup
        flb_free(decompressed_data);
        return 0;
    } else {
        flb_error("Failed to decompress data: %d", result);
        return -1;
    }
}

// Typical integration in an output plugin for compression
int output_plugin_compress_data(char *input_data, size_t input_len,
                               char **output_data, size_t *output_len) {
    // Compress the data
    int result = flb_snappy_compress(input_data, input_len,
                                     output_data, output_len);
    
    if (result == 0) {
        printf("Compressed %zu bytes to %zu bytes (%.1f%%)\n",
               input_len, *output_len,
               (*output_len * 100.0) / input_len);
        return 0;
    } else {
        flb_error("Failed to compress data: %d", result);
        return -1;
    }
}
```

### Error Handling Pattern
```c
// Robust Snappy operations with error handling
int safe_compress_data(const char *input_data, size_t input_len,
                      char **output_data, size_t *output_len) {
    if (!input_data || !output_data || !output_len) {
        return -1;
    }
    
    int result = flb_snappy_compress((char *) input_data, input_len,
                                     output_data, output_len);
    
    if (result != 0) {
        switch (result) {
            case -1:
                flb_error("Memory allocation failed during compression");
                break;
            case -2:
                flb_error("Snappy environment initialization failed");
                break;
            case -3:
                flb_error("Snappy compression operation failed");
                break;
            default:
                flb_error("Unknown compression error: %d", result);
                break;
        }
    }
    
    return result;
}

// Usage
char *compressed = NULL;
size_t compressed_len = 0;
int result = safe_compress_data("Hello, World!", 13, &compressed, &compressed_len);
if (result == 0) {
    printf("Successfully compressed data\n");
    flb_free(compressed);
} else {
    printf("Compression failed\n");
}
```

### Performance Considerations
```c
// Performance-optimized Snappy usage
void process_large_data_stream(char *data, size_t data_len) {
    // For large data, consider chunking to avoid memory issues
    const size_t chunk_size = 1024 * 1024; // 1MB chunks
    
    for (size_t offset = 0; offset < data_len; offset += chunk_size) {
        size_t current_chunk_size = (data_len - offset < chunk_size) ? 
                                    (data_len - offset) : chunk_size;
        
        char *chunk_data = &data[offset];
        char *compressed_chunk = NULL;
        size_t compressed_chunk_len = 0;
        
        // Compress the chunk
        int result = flb_snappy_compress(chunk_data, current_chunk_size,
                                         &compressed_chunk, &compressed_chunk_len);
        
        if (result == 0) {
            // Process compressed chunk
            send_compressed_chunk(compressed_chunk, compressed_chunk_len);
            flb_free(compressed_chunk);
        } else {
            flb_error("Failed to compress chunk at offset %zu", offset);
            break;
        }
    }
}
```