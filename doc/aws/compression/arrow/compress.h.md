# src/aws/compression/arrow/compress.h Documentation

## Overview

This header file defines the public interface for Arrow compression functionality in Fluent Bit's AWS integration. It provides function declarations for converting JSON data into Apache Arrow format (both Feather and Parquet formats) for efficient data storage and transmission to AWS services.

## Key Functions

### `out_s3_compress_arrow`
Main entry point for Arrow Feather compression.
- **Parameters**: 
  - `json`: Pointer to JSON data buffer to compress
  - `size`: Size of the JSON data buffer (excluding null terminator)
  - `out_buf`: Pointer to output buffer pointer for compressed data
  - `out_size`: Pointer to output size of compressed data
- **Return Value**: 0 on success, -1 on failure
- **Description**: Converts JSON data to Arrow Feather format and returns the compressed buffer and size

### `out_s3_compress_parquet` (conditional)
Main entry point for Arrow Parquet compression (only compiled when Parquet support is enabled).
- **Parameters**: 
  - `json`: Pointer to JSON data buffer to compress
  - `size`: Size of the JSON data buffer (excluding null terminator)
  - `out_buf`: Pointer to output buffer pointer for compressed data
  - `out_size`: Pointer to output size of compressed data
- **Return Value**: 0 on success, -1 on failure
- **Description**: Converts JSON data to Arrow Parquet format and returns the compressed buffer and size

## Important Variables

- `json`: Input JSON data buffer
- `size`: Size of the JSON data buffer
- `out_buf`: Output buffer pointer for compressed data
- `out_size`: Output size of compressed data

## Dependencies

- None (this is a header file)
- Implementation depends on Arrow C++ GLib bindings
- Implementation depends on Fluent Bit logging and memory management

## Implementation Details

### Function Signatures
Both functions follow the same signature pattern:
- Take JSON data buffer and size as input
- Return compressed buffer and size through output parameters
- Return integer status code (0 for success, -1 for failure)

### Conditional Compilation
The Parquet function is conditionally compiled based on the `FLB_HAVE_ARROW_PARQUET` flag.

### Memory Management
Functions are responsible for allocating the output buffer, which callers must free using `flb_free()`.

## Usage Examples

To compress JSON data to Arrow Feather format:
```c
#include "compress.h"

void *compressed_data;
size_t compressed_size;
int result = out_s3_compress_arrow(json_data, json_size, &compressed_data, &compressed_size);
if (result == 0) {
    // Successfully compressed data
    // Send compressed_data to S3
    flb_free(compressed_data);
} else {
    // Compression failed
}
```

To compress JSON data to Arrow Parquet format (when enabled):
```c
#include "compress.h"

void *compressed_data;
size_t compressed_size;
int result = out_s3_compress_parquet(json_data, json_size, &compressed_data, &compressed_size);
if (result == 0) {
    // Successfully compressed data
    // Send compressed_data to S3
    flb_free(compressed_data);
} else {
    // Compression failed
}
```