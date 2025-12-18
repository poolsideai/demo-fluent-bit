# flb_unicode.c

## Overview

The `flb_unicode.c` file provides Unicode handling functionality for Fluent Bit. This module acts as a wrapper around Unicode conversion libraries, enabling Fluent Bit to handle various character encodings and perform Unicode validation and conversion operations.

## Key Functions

### `flb_unicode_convert(int preferred_encoding, const char *input, size_t length, char **output, size_t *out_size)`
Converts input text from one encoding to another. Uses SIMDUTF library for optimized conversion when available.

### `flb_unicode_validate(const char *record, size_t size)`
Validates that a given text buffer contains valid UTF-8 encoded data.

### `flb_unicode_generic_supported_encoding(const char *encoding_name)`
Checks if a specific character encoding is supported by the Unicode conversion system.

### `flb_unicode_generic_select_encoding_type(const char *encoding_name)`
Selects a specific encoding type for use in subsequent conversion operations.

### `flb_unicode_generic_convert_to_utf8(const char *encoding_name, const unsigned char *input, unsigned char **output, size_t length)`
Converts text from a specified encoding to UTF-8 encoding.

### `flb_unicode_generic_convert_from_utf8(const char *encoding_name, const unsigned char *input, unsigned char **output, size_t length)`
Converts text from UTF-8 encoding to a specified target encoding.

## Important Variables and Constants

### Encoding Types
- Various encoding constants are defined in the underlying conversion libraries
- Common encodings include UTF-8, UTF-16, ASCII, ISO-8859-1, and others

### Conversion Status Codes
- `FLB_UNICODE_CONVERT_SUCCESS` - Conversion completed successfully
- `FLB_UNICODE_CONVERT_UNSUPPORTED` - Requested conversion not supported
- Various error codes for different failure conditions

## Dependencies

This module depends on:
- Fluent Bit Unicode interface (`flb_unicode.h`)
- SIMDUTF connector for Unicode operations (`unicode/flb_conv.h`)
- Standard C library (`stddef.h`)
- Underlying Unicode conversion libraries (when FLB_HAVE_UNICODE_ENCODER is defined)

## Implementation Details

The Unicode handling system works as follows:

1. **Conditional Compilation**: The module uses preprocessor directives to conditionally compile Unicode functionality based on whether `FLB_HAVE_UNICODE_ENCODER` is defined.

2. **Library Integration**: When Unicode support is enabled, the module integrates with the SIMDUTF library for high-performance Unicode operations.

3. **Fallback Behavior**: When Unicode support is not available, functions return appropriate error codes indicating that the operation is unsupported.

4. **Generic Interface**: Provides a generic interface for handling various character encodings through the underlying conversion libraries.

5. **Validation Support**: Includes functionality to validate UTF-8 encoded text for proper Unicode compliance.

The module serves as a bridge between Fluent Bit's core functionality and external Unicode conversion libraries, providing a consistent interface regardless of the underlying implementation.

## Usage Examples

Converting between encodings:
```c
char *output;
size_t out_size;
int result;

// Convert from UTF-8 to another encoding
result = flb_unicode_generic_convert_from_utf8("ISO-8859-1", 
                                                 input_utf8, 
                                                 (unsigned char**)&output, 
                                                 input_length);

if (result == 0) {
    // Conversion successful
    // Process output buffer
    flb_free(output);
}
```

Validating UTF-8 text:
```c
const char *text = "Hello, 世界!";
size_t length = strlen(text);

if (flb_unicode_validate(text, length) == 0) {
    printf("Text is valid UTF-8\n");
} else {
    printf("Text contains invalid UTF-8 sequences\n");
}
```

Checking encoding support:
```c
if (flb_unicode_generic_supported_encoding("UTF-16BE") == 1) {
    printf("UTF-16 Big Endian encoding is supported\n");
} else {
    printf("UTF-16 Big Endian encoding is not supported\n");
}
```