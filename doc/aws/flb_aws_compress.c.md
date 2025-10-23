# src/aws/flb_aws_compress.c Documentation

## Overview

This file implements the AWS compression functionality for Fluent Bit. It provides a unified interface for various compression algorithms used in AWS integrations, including GZIP, ZSTD, Arrow Feather, and Arrow Parquet formats. The module handles compression selection, execution, and special cases like base64-encoded truncated compression.

## Key Functions

### `flb_aws_compression_get_type`
Maps compression keyword strings to internal compression type identifiers.
- **Parameters**: 
  - `compression_keyword`: String identifier for compression type ("gzip", "zstd", etc.)
- **Return Value**: Integer compression type identifier or -1 on failure
- **Description**: Searches the compression options array to find a matching keyword

### `flb_aws_compression_compress`
Executes the specified compression algorithm on input data.
- **Parameters**: 
  - `compression_type`: Integer identifier for compression algorithm
  - `in_data`: Pointer to input data buffer
  - `in_len`: Size of input data buffer
  - `out_data`: Pointer to output buffer pointer for compressed data
  - `out_len`: Pointer to output size of compressed data
- **Return Value**: 0 on success, -1 on failure
- **Description**: Dispatches to the appropriate compression function based on type

### `flb_aws_compression_b64_truncate_compress`
Compresses data with iterative truncation to fit within a maximum output size.
- **Parameters**: 
  - `compression_type`: Integer identifier for compression algorithm
  - `max_out_len`: Maximum allowed output size in bytes
  - `in_data`: Pointer to input data buffer
  - `in_len`: Size of input data buffer
  - `out_data`: Pointer to output buffer pointer for compressed data
  - `out_len`: Pointer to output size of compressed data
- **Return Value**: 0 on success, -1 on failure
- **Description**: Iteratively truncates input data until compressed output fits within limit

## Important Variables

### `compression_options`
Array of supported compression algorithms with their identifiers and function pointers:
- `FLB_AWS_COMPRESS_GZIP`: GZIP compression
- `FLB_AWS_COMPRESS_ZSTD`: ZSTD compression
- `FLB_AWS_COMPRESS_ARROW`: Arrow Feather compression (conditional)
- `FLB_AWS_COMPRESS_PARQUET`: Arrow Parquet compression (conditional)

### Constants for Truncation
- `truncation_suffix`: "[Truncated...]" suffix appended to truncated data
- `truncation_suffix_len`: Length of truncation suffix (14)
- `truncation_reduction_percent`: 90% reduction factor for iterative truncation
- `truncation_compression_max_attempts`: Maximum 10 compression attempts

## Dependencies

- Fluent Bit memory management (`flb_mem.h`)
- Fluent Bit logging (`flb_log.h`)
- Fluent Bit base64 encoding (`flb_base64.h`)
- Fluent Bit GZIP compression (`flb_gzip.h`)
- Fluent Bit ZSTD compression (`flb_zstd.h`)
- Arrow compression (conditional) (`compression/arrow/compress.h`)

## Implementation Details

### Compression Algorithm Dispatch
The module uses a function pointer array to dispatch compression requests to the appropriate algorithm:
- Each compression option has a type identifier, keyword, and function pointer
- Functions are selected by matching the compression type identifier
- Conditional compilation enables/disables Arrow-based algorithms

### Iterative Truncation Algorithm
For the `b64_truncate_compress` function:
1. Attempts compression with full input data
2. If output exceeds limit, calculates reduced input size
3. Iteratively truncates input and recompresses until output fits
4. Appends "[Truncated...]" suffix to indicate truncation
5. Base64 encodes the final compressed result

### Memory Management
- Uses Fluent Bit's memory allocation functions (`flb_malloc`, `flb_free`)
- Properly cleans up temporary buffers on both success and failure paths
- Handles buffer size calculations for base64 encoding

### Error Handling
Comprehensive error handling with detailed logging:
- Checks for NULL returns from all function calls
- Validates buffer sizes and allocation results
- Provides informative error messages for debugging

### Conditional Compilation
Arrow-based compression algorithms are conditionally compiled:
- Arrow Feather support requires `FLB_HAVE_ARROW`
- Arrow Parquet support requires `FLB_HAVE_ARROW_PARQUET`

## Usage Examples

To compress data using a specific algorithm:
```c
#include <fluent-bit/aws/flb_aws_compress.h>

void *compressed_data;
size_t compressed_size;
int compression_type = flb_aws_compression_get_type("gzip");

if (compression_type != -1) {
    int result = flb_aws_compression_compress(compression_type, 
                                              input_data, 
                                              input_size, 
                                              &compressed_data, 
                                              &compressed_size);
    if (result == 0) {
        // Successfully compressed data
        // Send compressed_data to AWS service
        flb_free(compressed_data);
    } else {
        // Compression failed
    }
} else {
    // Unknown compression type
}
```

To compress data with truncation to fit size limits:
```c
#include <fluent-bit/aws/flb_aws_compress.h>

void *compressed_data;
size_t compressed_size;
size_t max_size = 1024 * 1024; // 1MB limit
int compression_type = flb_aws_compression_get_type("zstd");

if (compression_type != -1) {
    int result = flb_aws_compression_b64_truncate_compress(compression_type,
                                                           max_size,
                                                           input_data,
                                                           input_size,
                                                           &compressed_data,
                                                           &compressed_size);
    if (result == 0) {
        // Successfully compressed and possibly truncated data
        // Send compressed_data to AWS service
        flb_free(compressed_data);
    } else {
        // Compression or truncation failed
    }
} else {
    // Unknown compression type
}
```