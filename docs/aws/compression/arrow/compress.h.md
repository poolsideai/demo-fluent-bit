# src/aws/compression/arrow/compress.h Documentation

## Overview

This header file defines the public interface for Apache Arrow-based compression functionality in Fluent Bit's AWS integration. It provides function declarations for compressing JSON data into Arrow and optionally Parquet formats.

## Key Functions

### `out_s3_compress_arrow`

Converts JSON data into Apache Arrow format:

- **Parameters**:
  - `json`: Pointer to JSON data buffer (concatenated JSON objects)
  - `size`: Size of JSON data (excluding null terminator)
  - `out_buf`: Output parameter for compressed buffer pointer
  - `out_size`: Output parameter for compressed buffer size
- **Return**: 0 on success, -1 on failure
- **Description**: Main entry point for Arrow compression. Converts JSON input into Arrow format for efficient storage and transmission to AWS services.

### `out_s3_compress_parquet` (conditional)

Converts JSON data into Apache Parquet format:

- **Parameters**:
  - `json`: Pointer to JSON data buffer (concatenated JSON objects)
  - `size`: Size of JSON data (excluding null terminator)
  - `out_buf`: Output parameter for compressed buffer pointer
  - `out_size`: Output parameter for compressed buffer size
- **Return**: 0 on success, -1 on failure
- **Description**: Entry point for Parquet compression (conditional compilation). Converts JSON input into Parquet format, a columnar storage format optimized for analytical queries.

## Conditional Compilation

The Parquet compression function is only available when `FLB_HAVE_ARROW_PARQUET` is defined, indicating that Parquet support is enabled in the build.

## Usage

This header file is included by AWS output plugins (like the S3 plugin) that need to compress data before transmission to AWS services. The functions provide a simple interface for converting JSON data into efficient binary formats that can significantly reduce data transfer costs and improve performance.

## Implementation Notes

- The functions are implemented in `compress.c`
- Memory management is handled internally, with the caller responsible for freeing the output buffer
- Error handling is consistent across both functions
- Both functions follow the same parameter convention for ease of use