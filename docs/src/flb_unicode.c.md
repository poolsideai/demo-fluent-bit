# flb_unicode.c

## Overview

The `flb_unicode.c` file provides Unicode handling functionality for Fluent Bit. This module acts as a wrapper around Unicode conversion libraries, enabling Fluent Bit to handle various character encodings and perform Unicode validation and conversion operations.

The Unicode handling system is designed to provide a consistent interface for character encoding operations regardless of the underlying implementation. It conditionally compiles Unicode functionality based on whether `FLB_HAVE_UNICODE_ENCODER` is defined, allowing Fluent Bit to operate with or without advanced Unicode support.

When Unicode support is enabled, the module integrates with the SIMDUTF library for high-performance Unicode operations. When disabled, functions return appropriate error codes indicating that the operation is unsupported.

## Key Functions

### `flb_unicode_convert(int preferred_encoding, const char *input, size_t length, char **output, size_t *out_size)`
Converts input text from one encoding to another. Uses SIMDUTF library for optimized conversion when available.

The function:
1. Checks if Unicode support is compiled in via `FLB_HAVE_UNICODE_ENCODER`
2. Delegates to `flb_simdutf_connector_convert_from_unicode()` when supported
3. Returns `FLB_UNICODE_CONVERT_UNSUPPORTED` when Unicode support is disabled
4. Handles automatic encoding detection when `FLB_SIMDUTF_ENCODING_TYPE_UNICODE_AUTO` is specified

### `flb_unicode_validate(const char *record, size_t size)`
Validates that a given text buffer contains valid UTF-8 encoded data.

The function:
1. Uses SIMDUTF library for validation when Unicode support is enabled
2. Returns -1 when Unicode support is disabled
3. Efficiently checks for proper UTF-8 byte sequences
4. Handles edge cases like overlong encodings and surrogate pairs

### `flb_unicode_generic_supported_encoding(const char *encoding_name)`
Checks if a specific character encoding is supported by the Unicode conversion system.

Delegates to `flb_conv_supported_encoding()` for encoding support checking.

### `flb_unicode_generic_select_encoding_type(const char *encoding_name)`
Selects a specific encoding type for use in subsequent conversion operations.

Delegates to `flb_conv_select_encoding_type()` for encoding type selection.

### `flb_unicode_generic_convert_to_utf8(const char *encoding_name, const unsigned char *input, unsigned char **output, size_t length)`
Converts text from a specified encoding to UTF-8 encoding.

The function:
1. Delegates to `flb_conv_convert_to_utf8()` for the actual conversion
2. Uses `FLB_FALSE` for the last parameter to indicate standard conversion behavior
3. Handles various source encodings including legacy encodings
4. Properly allocates and manages the output buffer

### `flb_unicode_generic_convert_from_utf8(const char *encoding_name, const unsigned char *input, unsigned char **output, size_t length)`
Converts text from UTF-8 encoding to a specified target encoding.

The function:
1. Delegates to `flb_conv_convert_from_utf8()` for the actual conversion
2. Uses `FLB_FALSE` for the last parameter to indicate standard conversion behavior
3. Handles various target encodings including legacy encodings
4. Properly allocates and manages the output buffer

## Important Variables and Constants

### Generic Encoding Types
- `FLB_GENERIC_ASCII` - ASCII encoding
- `FLB_GENERIC_WIN1256` - Windows-1256 (Arabic)
- `FLB_GENERIC_WIN866` - MS-DOS CP866 (Cyrillic)
- `FLB_GENERIC_WIN874` - Windows-874 (Thai)
- `FLB_GENERIC_WIN1251` - Windows-1251 (Cyrillic)
- `FLB_GENERIC_WIN1252` - Windows-1252 (Western European)
- `FLB_GENERIC_WIN1250` - Windows-1250 (Central European)
- `FLB_GENERIC_WIN1253` - Windows-1253 (Greek)
- `FLB_GENERIC_WIN1254` - Windows-1254 (Turkish)
- `FLB_GENERIC_WIN1255` - Windows-1255 (Hebrew)
- `FLB_GENERIC_SJIS` - Shift JIS (Windows-932)
- `FLB_GENERIC_BIG5` - Big5 (Windows-950)
- `FLB_GENERIC_GBK` - GBK (Windows-936)
- `FLB_GENERIC_UHC` - UHC (Windows-949)
- `FLB_GENERIC_GB18030` - GB18030 (Chinese)
- `FLB_GENERIC_UNSPECIFIED` - Unspecified encoding

### Unicode Encoding Types (when FLB_HAVE_UNICODE_ENCODER is defined)
- `FLB_UNICODE_ENCODING_UTF8` - UTF-8 encoding
- `FLB_UNICODE_ENCODING_UTF16_LE` - UTF-16 Little Endian
- `FLB_UNICODE_ENCODING_UTF16_BE` - UTF-16 Big Endian
- `FLB_UNICODE_ENCODING_UTF32_LE` - UTF-32 Little Endian
- `FLB_UNICODE_ENCODING_UTF32_BE` - UTF-32 Big Endian
- `FLB_UNICODE_ENCODING_Latin1` - Latin-1 encoding
- `FLB_UNICODE_ENCODING_UNSPECIFIED` - Unspecified encoding
- `FLB_UNICODE_ENCODING_AUTO` - Automatic encoding detection

### Conversion Status Codes
- `FLB_UNICODE_CONVERT_OK` - Conversion completed successfully
- `FLB_UNICODE_CONVERT_NOP` - No operation needed (input already in target encoding)
- `FLB_UNICODE_CONVERT_UNSUPPORTED` - Requested conversion not supported
- `FLB_UNICODE_CONVERT_ERROR` - Conversion failed due to error

## Dependencies

This module depends on:
- Fluent Bit Unicode interface (`flb_unicode.h`)
- SIMDUTF connector for Unicode operations (`unicode/flb_conv.h`)
- Standard C library (`stddef.h`)
- Underlying Unicode conversion libraries (when `FLB_HAVE_UNICODE_ENCODER` is defined)
- SIMDUTF connector interface (`simdutf/flb_simdutf_connector.h`)

## Implementation Details

The Unicode handling system works as follows:

### Conditional Compilation

The module uses preprocessor directives to conditionally compile Unicode functionality based on whether `FLB_HAVE_UNICODE_ENCODER` is defined:
- When enabled: Full Unicode support with SIMDUTF integration
- When disabled: Functions return appropriate error codes indicating unsupported operations

### Library Integration

When Unicode support is enabled, the module integrates with the SIMDUTF library for high-performance Unicode operations:
- Conversion functions delegate to `flb_simdutf_connector_*` functions
- Validation functions use SIMDUTF's optimized UTF-8 validation
- Automatic encoding detection capabilities
- Support for various Unicode encoding formats

### Generic Interface

Provides a generic interface for handling various character encodings through the underlying conversion libraries:
- Support for legacy encodings (Windows code pages, ISO encodings)
- Bidirectional conversion (to and from UTF-8)
- Encoding support checking
- Type selection for specific encodings

### Validation Support

Includes functionality to validate UTF-8 encoded text for proper Unicode compliance:
- Efficient checking for proper UTF-8 byte sequences
- Detection of invalid sequences and overlong encodings
- Surrogate pair validation
- Boundary checking to prevent buffer overflows

### Error Handling

The system implements robust error handling:
- Clear status codes for different outcomes
- Graceful degradation when Unicode support is disabled
- Proper error reporting for conversion failures
- Memory management for allocated output buffers

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

Converting to UTF-8:
```c
unsigned char *output;
int result;

// Convert from a legacy encoding to UTF-8
result = flb_unicode_generic_convert_to_utf8("Windows-1252",
                                              input_legacy,
                                              &output,
                                              input_length);

if (result == 0) {
    // Conversion successful
    // Process UTF-8 output
    flb_free(output);
}
```

## Supported Encodings

### Legacy Encodings
- ASCII
- Windows code pages (1250-1258, 866, 874)
- Shift JIS (Japanese)
- Big5 (Traditional Chinese)
- GBK (Simplified Chinese)
- UHC (Korean)
- GB18030 (Chinese)

### Unicode Encodings (when FLB_HAVE_UNICODE_ENCODER is defined)
- UTF-8
- UTF-16 Little Endian
- UTF-16 Big Endian
- UTF-32 Little Endian
- UTF-32 Big Endian
- Latin-1

## Performance Considerations

The Unicode handling system is optimized for performance:
- SIMDUTF integration for high-speed operations when available
- Minimal overhead when Unicode support is disabled
- Efficient memory allocation patterns
- Proper use of underlying library optimizations

## Thread Safety

The Unicode functions are designed to be thread-safe:
- No shared mutable state between function calls
- Proper input/output buffer separation
- Reentrant design for concurrent usage
- Thread-safe underlying library calls

## Integration with Fluent Bit Pipeline

The Unicode handling system integrates seamlessly with Fluent Bit's data pipeline:
- Works with MessagePack string objects throughout the pipeline
- Compatible with filter plugin architectures
- Supports dynamic encoding conversion based on configuration
- Integrates with record accessor for field-level encoding operations

## Memory Management

All Unicode operations follow Fluent Bit's memory management patterns:
- Proper allocation and deallocation of output buffers
- Clear ownership semantics for allocated memory
- Error-safe memory operations
- Prevention of memory leaks in error conditions

## Extensibility

The Unicode handling system is designed for extensibility:
- Modular interface for adding new encoding support
- Clear separation of concerns
- Well-defined interfaces for underlying library integration
- Support for custom encoding handlers

## Debugging and Monitoring

The system includes debugging aids:
- Detailed error messages for failed operations
- Logging of conversion operations and results
- Validation error reporting
- Memory leak detection support