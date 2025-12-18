# flb_zstd.c

## Overview

The `flb_zstd.c` file provides Zstandard (zstd) compression and decompression functionality for Fluent Bit. This module implements the Zstandard algorithm for efficient data compression and decompression, which is particularly useful for reducing network bandwidth and storage requirements.

## Key Functions

### `flb_zstd_compress`

```c
int flb_zstd_compress(void *in_data, size_t in_len, void **out_data, size_t *out_len)
```

Compresses data using the Zstandard algorithm.

- **Parameters**: 
  - `in_data`: Pointer to input data to compress
  - `in_len`: Length of input data
  - `out_data`: Pointer to output buffer (allocated by function)
  - `out_len`: Pointer to store length of compressed data
- **Returns**: 0 on success, -1 on failure
- **Notes**: Allocates output buffer; caller is responsible for freeing it

### `flb_zstd_uncompress`

```c
int flb_zstd_uncompress(void *in_data, size_t in_len, void **out_data, size_t *out_len)
```

Decompresses data using the Zstandard algorithm.

- **Parameters**: 
  - `in_data`: Pointer to compressed input data
  - `in_len`: Length of compressed input data
  - `out_data`: Pointer to output buffer (allocated by function)
  - `out_len`: Pointer to store length of decompressed data
- **Returns**: 0 on success, -1 on failure
- **Notes**: Allocates output buffer; caller is responsible for freeing it

### `zstd_uncompress_unknown_size`

```c
static int zstd_uncompress_unknown_size(void *in_data, size_t in_len, void **out_data, size_t *out_len)
```

Internal function to decompress data when the original size is unknown.

- **Parameters**: 
  - `in_data`: Pointer to compressed input data
  - `in_len`: Length of compressed input data
  - `out_data`: Pointer to output buffer (allocated by function)
  - `out_len`: Pointer to store length of decompressed data
- **Returns**: 0 on success, -1 on failure
- **Notes**: Dynamically resizes output buffer as needed

### `flb_zstd_decompressor_dispatch`

```c
int flb_zstd_decompressor_dispatch(struct flb_decompression_context *context, void *output_buffer, size_t *output_length)
```

Processes a single Zstandard frame in a streaming decompression context.

- **Parameters**: 
  - `context`: Decompression context
  - `output_buffer`: Buffer to write decompressed data
  - `output_length`: Pointer to store length of decompressed data
- **Returns**: One of `FLB_DECOMPRESSOR_SUCCESS` or `FLB_DECOMPRESSOR_FAILURE`
- **Notes**: Designed for streaming scenarios where data arrives incrementally

### `flb_zstd_decompression_context_create`

```c
void *flb_zstd_decompression_context_create(void)
```

Creates a new Zstandard decompression context.

- **Returns**: Pointer to new decompression context, or NULL on failure

### `flb_zstd_decompression_context_destroy`

```c
void flb_zstd_decompression_context_destroy(void *context)
```

Destroys a Zstandard decompression context and frees associated resources.

- **Parameters**: 
  - `context`: Decompression context to destroy

## Data Structures

### `flb_zstd_decompression_context`

Structure representing a Zstandard decompression context.

```c
struct flb_zstd_decompression_context {
    ZSTD_DCtx *dctx;  /* Zstandard decompression context */
};
```

## Constants

### `FLB_ZSTD_DEFAULT_CHUNK`

Default chunk size for decompression buffer (64 KB).

## Dependencies

- `<fluent-bit/flb_info.h>`: Fluent Bit core information
- `<fluent-bit/flb_mem.h>`: Fluent Bit memory management
- `<fluent-bit/flb_log.h>`: Fluent Bit logging
- `<fluent-bit/flb_gzip.h>`: GZIP compression (for compatibility)
- `<fluent-bit/flb_compression.h>`: General compression utilities
- `<fluent-bit/flb_zstd.h>`: Zstandard header definitions
- `<zstd.h>`: Zstandard library
- `<zstd_errors.h>`: Zstandard error handling

## Implementation Details

1. **Compression Algorithm**: Uses Zstandard library with default compression level (1)

2. **Memory Management**: Dynamically allocates output buffers; caller must free them

3. **Unknown Size Handling**: For compressed data where original size is unknown, uses streaming decompression with dynamic buffer resizing

4. **Streaming Support**: Provides a dispatcher function for incremental decompression in streaming scenarios

5. **Error Handling**: Comprehensive error checking with detailed error messages using Zstandard's error reporting

6. **Context Management**: Maintains decompression contexts for efficient repeated operations

## Usage Examples

### Compressing data

```c
// Compress some data
const char *input = "This is some data to compress";
void *compressed_data;
size_t compressed_len;

if (flb_zstd_compress((void*)input, strlen(input), &compressed_data, &compressed_len) == 0) {
    printf("Compressed %zu bytes to %zu bytes\n", strlen(input), compressed_len);
    
    // Use compressed data...
    
    // Don't forget to free the allocated buffer
    flb_free(compressed_data);
} else {
    printf("Compression failed\n");
}
```

### Decompressing data

```c
// Decompress previously compressed data
void *decompressed_data;
size_t decompressed_len;

if (flb_zstd_uncompress(compressed_data, compressed_len, &decompressed_data, &decompressed_len) == 0) {
    printf("Decompressed %zu bytes\n", decompressed_len);
    printf("Original data: %.*s\n", (int)decompressed_len, (char*)decompressed_data);
    
    // Don't forget to free the allocated buffer
    flb_free(decompressed_data);
} else {
    printf("Decompression failed\n");
}
```

### Streaming decompression

```c
// For streaming scenarios, create a decompression context
void *decompression_context = flb_zstd_decompression_context_create();
if (decompression_context) {
    struct flb_decompression_context ctx = {
        .inner_context = decompression_context,
        .read_buffer = input_data,
        .input_buffer_length = input_len,
        .state = FLB_DECOMPRESSOR_STATE_RUNNING
    };
    
    char output_buffer[8192];
    size_t output_length = sizeof(output_buffer);
    
    int result = flb_zstd_decompressor_dispatch(&ctx, output_buffer, &output_length);
    if (result == FLB_DECOMPRESSOR_SUCCESS) {
        printf("Decompressed %zu bytes\n", output_length);
        // Process decompressed data...
    }
    
    // Cleanup
    flb_zstd_decompression_context_destroy(decompression_context);
}
```