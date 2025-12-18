# flb_unicode.c

## Overview

This file implements Unicode conversion and validation functionality for Fluent Bit, providing utilities to handle different character encodings and ensure proper Unicode support throughout the data processing pipeline. The system acts as a bridge between Fluent Bit's core and external Unicode libraries.

Key features include:
- Character encoding conversion between different formats
- UTF-8 validation for data integrity
- Support for multiple encoding formats through external libraries
- Conditional compilation based on available Unicode support
- Generic encoding interface for extensibility

The implementation provides a unified interface for Unicode operations while leveraging optimized external libraries when available.

## Key Functions

### `flb_unicode_convert()`
Converts text from one encoding to another, with UTF-8 as the target encoding. Uses SIMDUTF library when available for optimized performance.

### `flb_unicode_validate()`
Validates that a given text buffer contains valid UTF-8 encoding. Returns success or failure based on the validity of the UTF-8 sequence.

### `flb_unicode_generic_supported_encoding()`
Checks if a specific character encoding is supported by the underlying conversion library.

### `flb_unicode_generic_select_encoding_type()`
Selects and configures a specific encoding type for subsequent conversion operations.

### `flb_unicode_generic_convert_to_utf8()`
Converts text from a specified encoding to UTF-8 format.

### `flb_unicode_generic_convert_from_utf8()`
Converts text from UTF-8 format to a specified encoding.

## Important Variables/Constants

### Encoding Types
- Various encoding identifiers supported by the underlying conversion library
- UTF-8 as the primary internal encoding

### Conditional Compilation
- `FLB_HAVE_UNICODE_ENCODER`: Compile-time flag indicating availability of Unicode encoder support
- Runtime fallbacks when Unicode support is not available

### Return Values
- `FLB_UNICODE_CONVERT_UNSUPPORTED`: Indicates that Unicode conversion is not supported in the current build
- Standard success/failure codes for conversion operations

## Dependencies

- External libraries:
  - `simdutf`: SIMD-accelerated Unicode processing library (when available)
  - `flb_conv`: Fluent Bit's generic character conversion library

- Standard C library headers:
  - `stddef.h`: Standard definitions

- Fluent Bit core components:
  - `flb_unicode.h`: Unicode interface definitions
  - `unicode/flb_conv.h`: Character conversion utilities

## Implementation Details

1. **Conditional Compilation**: Uses preprocessor directives to enable/disable Unicode features based on build configuration and available libraries.

2. **SIMD Optimization**: Leverages SIMDUTF library for hardware-accelerated Unicode processing when available, falling back to generic implementations otherwise.

3. **External Library Integration**: Provides clean abstraction layer between Fluent Bit core and external Unicode libraries.

4. **UTF-8 Focus**: Treats UTF-8 as the canonical internal encoding format for consistency and compatibility.

5. **Validation First**: Prioritizes data validation before conversion to ensure data integrity.

6. **Generic Interface**: Provides extensible interface for adding support for new character encodings.

7. **Memory Management**: Proper allocation and cleanup of converted buffers to prevent memory leaks.

8. **Error Handling**: Comprehensive error reporting with meaningful return codes for different failure scenarios.

## Usage Example

```c
// Check if Unicode support is available
#ifdef FLB_HAVE_UNICODE_ENCODER
    // Unicode conversion is supported
#else
    // Unicode conversion not supported in this build
    return FLB_UNICODE_CONVERT_UNSUPPORTED;
#endif

// Convert text from a specific encoding to UTF-8
char *input_text = "Some text in different encoding";
size_t input_length = strlen(input_text);
char *output_text = NULL;
size_t output_length = 0;

int ret = flb_unicode_convert(FLB_UNICODE_UTF8, input_text, input_length,
                               &output_text, &output_length);
if (ret == 0) {
    // Conversion successful
    flb_debug("Successfully converted %zu bytes to UTF-8", output_length);
    // Use output_text as needed
    // Remember to free output_text when done
    flb_free(output_text);
} else {
    // Conversion failed
    flb_error("Unicode conversion failed with code %d", ret);
}

// Validate UTF-8 text
char *text_to_validate = "Valid UTF-8 text";
size_t text_length = strlen(text_to_validate);

int validation_result = flb_unicode_validate(text_to_validate, text_length);
if (validation_result == 0) {
    flb_info("Text is valid UTF-8");
} else {
    flb_warn("Text contains invalid UTF-8 sequences");
}

// Check encoding support
if (flb_unicode_generic_supported_encoding("ISO-8859-1")) {
    flb_info("ISO-8859-1 encoding is supported");
} else {
    flb_warn("ISO-8859-1 encoding is not supported");
}

// Use generic conversion functions
unsigned char *generic_input = (unsigned char*)"Text in ISO-8859-1";
unsigned char *generic_output = NULL;
size_t generic_length = strlen((char*)generic_input);

int generic_ret = flb_unicode_generic_convert_to_utf8("ISO-8859-1",
                                                        generic_input,
                                                        &generic_output,
                                                        generic_length);
if (generic_ret == 0) {
    flb_debug("Generic conversion successful");
    flb_free(generic_output);
}
```