# src/aws/compression/arrow/compress.c Documentation

## Overview

This file implements Arrow compression functionality for Fluent Bit's AWS integration. It provides the capability to convert JSON data into Apache Arrow format (both Feather and Parquet formats) for efficient data storage and transmission to AWS services like S3.

## Key Functions

### `parse_json`
Converts JSON data into an Arrow Table structure using the Arrow C++ GLib bindings.
- Takes a JSON buffer and size as input
- Returns a GArrowTable pointer or NULL on failure
- Handles error cleanup for all allocated resources

### `table_to_buffer`
Converts an Arrow Table to a Feather format buffer.
- Takes a GArrowTable pointer as input
- Returns a GArrowResizableBuffer pointer or NULL on failure
- Writes the table data to a buffer output stream in Feather format

### `out_s3_compress_arrow`
Main entry point for Arrow Feather compression.
- Takes JSON data and converts it to Arrow Feather format
- Returns compressed buffer and size
- Returns 0 on success, -1 on failure

### `table_to_parquet_buffer` (conditional)
Converts an Arrow Table to a Parquet format buffer (only compiled when Parquet support is enabled).
- Takes a GArrowTable pointer as input
- Returns a GArrowResizableBuffer pointer or NULL on failure
- Writes the table data to a buffer output stream in Parquet format

### `out_s3_compress_parquet` (conditional)
Main entry point for Arrow Parquet compression (only compiled when Parquet support is enabled).
- Takes JSON data and converts it to Arrow Parquet format
- Returns compressed buffer and size
- Returns 0 on success, -1 on failure

## Important Variables

- `json`: Input JSON data buffer
- `size`: Size of the JSON data buffer
- `out_buf`: Output buffer pointer for compressed data
- `out_size`: Output size of compressed data
- Various GArrow objects for table manipulation and buffer management

## Dependencies

- Arrow C++ GLib bindings (`arrow-glib/arrow-glib.h`)
- Optional Parquet GLib bindings (`parquet-glib/parquet-glib.h`)
- Fluent Bit logging and memory management (`flb_log.h`, `flb_mem.h`)
- Standard C library functions

## Implementation Details

### Arrow Integration
The implementation uses the Arrow C++ GLib bindings to interface with the Arrow C++ libraries:
- Uses `garrow_json_reader` to parse JSON into Arrow Tables
- Uses `garrow_table_write_as_feather` to write tables in Feather format
- Optionally uses `gparquet_arrow_file_writer` to write tables in Parquet format

### Memory Management
The implementation carefully manages memory:
- Uses Arrow's reference counting for object lifecycle management
- Properly cleans up all allocated resources on both success and failure paths
- Uses Fluent Bit's memory allocation functions for output buffers

### Error Handling
Comprehensive error handling with proper cleanup:
- Checks for NULL returns from all Arrow function calls
- Frees error objects and unreferences Arrow objects on failure
- Returns appropriate error codes to callers

### Conditional Compilation
The Parquet functionality is conditionally compiled based on the `FLB_HAVE_ARROW_PARQUET` flag.

## Usage Examples

To compress JSON data to Arrow Feather format:
```c
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