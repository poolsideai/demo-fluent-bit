# src/aws/flb_aws_compress.c Documentation

## Overview

This C file implements AWS compression functionality for Fluent Bit. It provides a unified interface for various compression algorithms that can be used by AWS output plugins to compress data before transmission to AWS services.

## Key Data Structures

### `compression_option`

Structure that defines a compression algorithm option:

- `compression_type`: Integer identifier for the compression type
- `compression_keyword`: String keyword used to identify the compression type
- `compress`: Function pointer to the compression function

### `compression_options`

Static array of available compression options:

- `FLB_AWS_COMPRESS_GZIP`: GZIP compression using `flb_gzip_compress`
- `FLB_AWS_COMPRESS_ZSTD`: Zstandard compression using `flb_zstd_compress`
- `FLB_AWS_COMPRESS_ARROW`: Arrow format compression (conditional)
- `FLB_AWS_COMPRESS_PARQUET`: Parquet format compression (conditional)

## Key Functions

### `flb_aws_compression_get_type`

Converts a compression keyword string to its corresponding integer type:

- **Parameters**: `compression_keyword` - String keyword identifying the compression type
- **Return**: Integer compression type identifier, or -1 on error
- **Description**: Looks up the compression type in the `compression_options` array and returns the matching integer identifier

### `flb_aws_compression_compress`

Applies compression to input data using the specified compression type:

- **Parameters**:
  - `compression_type`: Integer identifier for the compression algorithm
  - `in_data`: Pointer to input data buffer
  - `in_len`: Size of input data
  - `out_data`: Output parameter for compressed data buffer
  - `out_len`: Output parameter for compressed data size
- **Return**: 0 on success, -1 on error
- **Description**: Finds the appropriate compression function based on the compression type and applies it to the input data

### `flb_aws_compression_b64_truncate_compress`

Applies compression with iterative truncation to ensure output fits within size limits:

- **Parameters**:
  - `compression_type`: Integer identifier for the compression algorithm
  - `max_out_len`: Maximum allowed output size
  - `in_data`: Pointer to input data buffer
  - `in_len`: Size of input data
  - `out_data`: Output parameter for base64-encoded compressed data buffer
  - `out_len`: Output parameter for base64-encoded compressed data size
- **Return**: 0 on success, -1 on error
- **Description**: Applies compression and iteratively truncates input data if needed to ensure the base64-encoded output fits within the maximum size limit

## Conditional Compilation

The file supports conditional compilation for advanced compression formats:

- `FLB_HAVE_ARROW`: Enables Arrow format compression support
- `FLB_HAVE_ARROW_PARQUET`: Enables Parquet format compression support

## Dependencies

The implementation depends on:

- Fluent Bit core libraries (`flb_mem.h`, `flb_log.h`, `flb_base64.h`)
- AWS compression header (`flb_aws_compress.h`)
- GZIP compression (`flb_gzip.h`)
- Zstandard compression (`flb_zstd.h`)
- Arrow compression (when enabled)

## Implementation Details

### Compression Algorithms

The library supports multiple compression algorithms:

1. **GZIP**: Standard GZIP compression
2. **Zstandard**: Fast lossless compression algorithm
3. **Arrow**: Apache Arrow binary format (conditional)
4. **Parquet**: Apache Parquet columnar storage format (conditional)

### Truncation Algorithm

The `flb_aws_compression_b64_truncate_compress` function implements an iterative truncation algorithm:

1. Attempts compression with full input data
2. If output exceeds size limit, calculates reduced input size
3. Truncates input data and adds "[Truncated...]" suffix
4. Repeats until output fits within size limit or maximum attempts reached
5. Returns base64-encoded compressed data

### Memory Management

- Uses Fluent Bit's memory allocation functions (`flb_malloc`, `flb_free`)
- Caller is responsible for freeing the output buffer
- Proper error handling with resource cleanup

## Usage

This file is part of the AWS library (`flb-aws`) and is used by AWS output plugins (like S3, CloudWatch Logs) to compress data before transmission to AWS services. The compression can significantly reduce data transfer costs and improve performance for large datasets.