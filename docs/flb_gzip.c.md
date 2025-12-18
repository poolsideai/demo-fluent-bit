# flb_gzip.c

## Overview

This file implements GZIP compression and decompression functionality for Fluent Bit. It provides high-performance compression/decompression capabilities using the miniz library, which is a lightweight zlib-compatible compression library.

The GZIP implementation supports both single-shot compression/decompression operations and stateful streaming decompression for handling large data streams efficiently.

## Key Functions

### `flb_gzip_compress()`
Compresses input data using GZIP format and returns the compressed data in a newly allocated buffer. This is the primary compression function for single-shot operations.

### `flb_gzip_uncompress()`
Decompresses GZIP-compressed data and returns the uncompressed data in a newly allocated buffer. Handles complete GZIP files with proper header and footer validation.

### `flb_gzip_uncompress_multi()`
Decompresses multiple concatenated GZIP streams from a single input buffer, supporting streaming scenarios where multiple compressed chunks may be present.

### `flb_gzip_decompressor_dispatch()`
Stateful decompression dispatcher that processes GZIP data incrementally, maintaining decompression context between calls.

### `flb_gzip_decompression_context_create()`
Creates a new decompression context for stateful decompression operations.

### `flb_gzip_decompression_context_destroy()`
Destroys and cleans up a decompression context.

### `flb_is_http_session_gzip_compressed()`
Checks if an HTTP session contains GZIP-compressed content based on the Content-Encoding header.

## Important Variables/Constants

### GZIP Header Structure (`struct flb_gzip_header`)
Represents the GZIP file header with fields:
- `magic_number`: GZIP magic bytes (0x1F8B)
- `compression_method`: Compression method (deflated)
- `header_flags`: Header flags indicating optional fields
- `timestamp`: Modification time
- `compression_flags`: Compression level and flags
- `operating_system_id`: Operating system identifier

### Decompression Context (`struct flb_gzip_decompression_context`)
Maintains state for streaming decompression:
- `gzip_header`: Parsed GZIP header
- `miniz_stream`: Miniz stream context for decompression

### Buffer Management Constants
- `FLB_GZIP_BUFFER_SIZE`: Size for decompression buffers (1MB)
- `FLB_GZIP_MAX_BUFFERS`: Maximum number of buffers for decompression (100)
- `FLB_GZIP_HEADER_OFFSET`: Offset to compressed data in GZIP header
- `FLB_GZIP_MAGIC_NUMBER`: Expected GZIP magic bytes

### GZIP Flags
- `FTEXT`: Text file flag
- `FHCRC`: Header CRC flag
- `FEXTRA`: Extra field flag
- `FNAME`: Original filename flag
- `FCOMMENT`: Comment flag

## Dependencies

- `fluent-bit/flb_info.h`: Fluent Bit core information
- `fluent-bit/flb_mem.h`: Memory management utilities
- `fluent-bit/flb_log.h`: Logging utilities
- `fluent-bit/flb_gzip.h`: GZIP interface
- `fluent-bit/flb_compression.h`: Compression interface
- `miniz/miniz.h`: Miniz compression library

## Implementation Details

1. **Header/Footer Processing**: Properly handles GZIP headers (magic bytes, flags, timestamps) and footers (CRC32, uncompressed size).

2. **CRC32 Validation**: Validates data integrity using CRC32 checksums for both compressed and uncompressed data.

3. **Stateful Decompression**: Supports streaming decompression with context preservation between calls.

4. **Multi-Stream Support**: Can handle multiple concatenated GZIP streams in a single buffer.

5. **Memory Management**: Uses Fluent Bit's memory allocation functions for consistent memory handling.

6. **Error Handling**: Comprehensive error checking with detailed error messages and proper resource cleanup.

7. **HTTP Integration**: Provides utility functions for detecting GZIP-compressed HTTP content.

## Usage Example

```c
// Compress data
const char *input_data = "This is sample text to compress";
size_t input_len = strlen(input_data);

void *compressed_data = NULL;
size_t compressed_len = 0;

int ret = flb_gzip_compress((void *)input_data, input_len, 
                             &compressed_data, &compressed_len);

if (ret == 0) {
    printf("Compressed %zu bytes to %zu bytes\n", input_len, compressed_len);
    
    // Decompress the data
    void *decompressed_data = NULL;
    size_t decompressed_len = 0;
    
    ret = flb_gzip_uncompress(compressed_data, compressed_len,
                               &decompressed_data, &decompressed_len);
    
    if (ret == 0) {
        printf("Decompressed %zu bytes\n", decompressed_len);
        // Verify the data matches
        if (memcmp(input_data, decompressed_data, input_len) == 0) {
            printf("Round-trip successful!\n");
        }
        flb_free(decompressed_data);
    }
    
    flb_free(compressed_data);
}

// Stateful decompression example
struct flb_decompression_context *ctx = flb_gzip_decompression_context_create();

// Process data in chunks
void *chunk1 = ...; // First chunk of compressed data
size_t chunk1_len = ...; // Length of first chunk

void *output_buffer = flb_malloc(4096);
size_t output_len = 4096;

// Feed data to decompressor
int status = flb_gzip_decompressor_dispatch(ctx, output_buffer, &output_len);

while (status == FLB_DECOMPRESSOR_INSUFFICIENT_DATA) {
    // More data needed, feed another chunk
    // ...
    status = flb_gzip_decompressor_dispatch(ctx, output_buffer, &output_len);
}

if (status == FLB_DECOMPRESSOR_SUCCESS) {
    // Process decompressed data
    process_decompressed_data(output_buffer, output_len);
}

flb_gzip_decompression_context_destroy(ctx);
flb_free(output_buffer);
```