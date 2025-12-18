# flb_base64.c

## Overview

This file implements Base64 encoding and decoding functionality for Fluent Bit. It provides high-performance Base64 operations based on the mbedtls-2.25.0 library implementation, specifically optimized for Fluent Bit's needs.

The module handles:
- Base64 encoding of binary data to ASCII strings
- Base64 decoding of ASCII strings back to binary data
- Proper padding handling with '=' characters
- Whitespace and newline character handling
- Buffer size validation and error reporting

## Key Functions

### `flb_base64_encode()`
Encodes binary data into Base64 format. Takes source data and outputs encoded string with proper padding.

### `flb_base64_decode()`
Decodes Base64 formatted data back to binary. Handles whitespace, newlines, and padding characters properly.

## Important Variables/Constants

### Base64 Encoding Map
- `base64_enc_map[]`: Lookup table for encoding 6-bit values to Base64 characters
- Contains the standard Base64 alphabet: A-Z, a-z, 0-9, +, /

### Base64 Decoding Map
- `base64_dec_map[]`: Lookup table for decoding Base64 characters to 6-bit values
- Maps ASCII characters to their corresponding 6-bit indices
- Invalid characters mapped to 127 for error detection

### Error Codes
- `FLB_BASE64_ERR_BUFFER_TOO_SMALL`: Output buffer is too small for the result
- `FLB_BASE64_ERR_INVALID_CHARACTER`: Invalid character found in input

## Dependencies

- `fluent-bit/flb_base64.h`: Base64 interface headers
- `stdint.h`: Standard integer types

## Implementation Details

1. **Performance Optimization**: Based on mbedtls-2.25.0 implementation chosen for better performance compared to later versions.

2. **Buffer Management**: Both functions validate buffer sizes and return appropriate error codes when buffers are insufficient.

3. **Padding Handling**: Properly handles '=' padding characters during decoding.

4. **Whitespace Handling**: Ignores whitespace and newline characters during decoding.

5. **Lookup Tables**: Uses precomputed lookup tables for fast encoding/decoding operations.

6. **Integer Overflow Protection**: Implements safe calculations to prevent integer overflow in buffer size computations.

## Usage Example

```c
// Encode binary data to Base64
unsigned char input[] = "Hello, World!";
size_t input_len = strlen((char*)input);
unsigned char output[100];
size_t output_len;

int result = flb_base64_encode(output, sizeof(output), &output_len, input, input_len);
if (result == 0) {
    printf("Encoded: %.*s\n", (int)output_len, output);
}

// Decode Base64 back to binary
unsigned char encoded[] = "SGVsbG8sIFdvcmxkIQ==";
size_t encoded_len = strlen((char*)encoded);
unsigned char decoded[100];
size_t decoded_len;

result = flb_base64_decode(decoded, sizeof(decoded), &decoded_len, encoded, encoded_len);
if (result == 0) {
    printf("Decoded: %.*s\n", (int)decoded_len, decoded);
}
```