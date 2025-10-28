# src/aws/compression/arrow/compress.c Documentation

## Overview

This C file implements Apache Arrow-based compression functionality for Fluent Bit's AWS integration. It provides functions to convert JSON data into Arrow format and optionally Parquet format for efficient data storage and transmission to AWS services.

## Key Functions

### `parse_json`

Converts JSON data into an Arrow Table structure:

- Takes a JSON buffer and size as input
- Creates Arrow buffer and input stream from the JSON data
- Uses Arrow JSON reader to parse the JSON into a table
- Returns a GArrowTable pointer or NULL on failure
- Properly cleans up resources on error

### `table_to_buffer`

Converts an Arrow Table into a Feather format buffer:

- Creates a resizable buffer and output stream
- Writes the table to the buffer in Feather format
- Returns a GArrowResizableBuffer pointer or NULL on failure
- Properly cleans up resources on error

### `out_s3_compress_arrow`

Main entry point for Arrow compression:

- Parses JSON input into an Arrow Table
- Converts the table to a Feather format buffer
- Extracts the compressed data into a malloc'd buffer
- Returns the compressed buffer and its size via output parameters
- Returns 0 on success, -1 on failure

### `table_to_parquet_buffer` (conditional)

Converts an Arrow Table into a Parquet format buffer:

- Creates a resizable buffer and output stream
- Gets the table schema
- Creates a Parquet file writer
- Writes the entire table to the Parquet buffer
- Closes the writer to finalize metadata
- Returns a GArrowResizableBuffer pointer or NULL on failure
- Properly cleans up resources on error

### `out_s3_compress_parquet` (conditional)

Main entry point for Parquet compression:

- Parses JSON input into an Arrow Table
- Converts the table to a Parquet format buffer
- Extracts the compressed data into a malloc'd buffer
- Returns the compressed buffer and its size via output parameters
- Returns 0 on success, -1 on failure

## Dependencies

The implementation depends on:

- Arrow GLib library (`arrow-glib/arrow-glib.h`)
- Parquet GLib library (when `FLB_HAVE_ARROW_PARQUET` is defined)
- Fluent Bit logging (`fluent-bit/flb_log.h`)
- Fluent Bit memory management (`fluent-bit/flb_mem.h`)

## Implementation Details

### Memory Management

- Uses Arrow's reference counting for automatic memory management
- Properly unrefs all Arrow objects to prevent memory leaks
- Uses malloc/flb_malloc for output buffer allocation
- Returns ownership of the output buffer to the caller

### Error Handling

- Comprehensive error checking at each step
- Proper cleanup of resources on failure
- Uses GError for detailed error reporting
- Logs errors using Fluent Bit's logging infrastructure

### Format Support

- **Feather format**: Default Arrow serialization format
- **Parquet format**: Columnar storage format (conditional compilation)

## Usage

This file is compiled as part of the AWS Arrow compression library (`flb-aws-arrow`). The functions are typically called by AWS output plugins (like the S3 plugin) to compress data before transmission to AWS services. The compression can significantly reduce data transfer costs and improve performance for large datasets.