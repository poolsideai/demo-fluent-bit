# flb_conv.c Documentation

## Overview

This file contains the core implementation for character encoding conversion in Fluent Bit. It provides functions to convert between UTF-8 and various local character encodings using radix trees and lookup tables. The implementation handles both single-character conversions and combined character sequences (such as those found in East Asian encodings).

The file implements a flexible conversion framework that supports multiple encodings through a plugin-like architecture where each encoding has its own converter structure with callbacks for conversion operations.

## Key Functions

### `flb_convert_to_local_internal`
Converts a string from UTF-8 to a specified local encoding. This function handles:
- ASCII characters (passed through unchanged)
- Multi-byte UTF-8 characters
- Combined character sequences (using lookup tables)
- Error reporting for invalid or untranslatable characters

### `flb_convert_to_utf_internal`
Converts a string from a local encoding to UTF-8 with similar capabilities as the reverse conversion.

### `flb_conv_select_converter`
Selects an appropriate converter based on the encoding name, supporting both primary names and aliases.

### `flb_conv_convert_to_utf8` and `flb_conv_convert_from_utf8`
High-level wrapper functions that handle memory allocation and error management for encoding conversions.

### `flb_mb_radix_conv`
Core radix tree lookup function that efficiently converts multi-byte characters using precomputed lookup tables.

### `format_byte_sequence_for_display`
Helper function to format byte sequences for error reporting in a human-readable hex format.

### `flb_report_invalid_encoding` and `flb_report_untranslatable_char`
Error reporting functions that provide detailed information about conversion failures.

## Important Variables and Constants

### `FLB_CONV_CONVERT_OK`, `FLB_CONV_CONVERTER_NOT_FOUND`, etc.
Return codes for conversion operations indicating success or various failure conditions.

### Converter Structures
Global converter structures for each supported encoding (sjis_converter, gb18030_converter, etc.) that contain:
- Name and aliases
- Description
- Encoding identifier
- Maximum character width
- Callback functions for conversion

## Dependencies

- `<fluent-bit/flb_log.h>` - For logging functionality
- `<fluent-bit/flb_mem.h>` - For memory allocation functions
- `<fluent-bit/unicode/flb_wchar.h>` - For wide character utilities
- `<fluent-bit/unicode/flb_conv.h>` - Header file with declarations
- `<monkey/mk_core.h>` - For linked list functionality

## Implementation Details

The conversion system uses several optimization techniques:

1. **Radix Trees**: Efficient lookup tables for character conversions that minimize memory usage while maintaining fast access times.

2. **Combined Character Support**: Handles special character combinations (common in East Asian encodings) through separate lookup tables.

3. **Macro-based Code Generation**: Uses macros to avoid duplicating complex switch statements for different data types.

4. **Flexible Architecture**: Supports multiple encodings through a plugin-like system with converter structures.

5. **Error Handling**: Comprehensive error reporting with detailed information about invalid sequences or untranslatable characters.

## Usage Examples

Basic conversion from UTF-8 to a local encoding:
```c
unsigned char *dest;
int result = flb_conv_convert_from_utf8("SJIS", utf8_string, &dest, strlen(utf8_string), false);
if (result > 0) {
    // Successfully converted, dest contains the result
    flb_free(dest);
} else {
    // Handle conversion error
}
```

Checking if an encoding is supported:
```c
if (flb_conv_supported_encoding("GB18030")) {
    // Encoding is supported
}
```