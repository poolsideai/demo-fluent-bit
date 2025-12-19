# flb_utf8_and_gb18030.c Documentation

## Overview

This file implements the character encoding conversion functions specifically for the GB18030 encoding. It provides bidirectional conversion between UTF-8 and GB18030 character sets.

GB18030 is a character encoding standard used for Simplified Chinese characters. It is an extension of the GBK encoding and supports a larger character set including Unicode characters beyond the Basic Multilingual Plane.

## Key Functions

### `flb_gb18030_to_utf8`
Converts a string from GB18030 encoding to UTF-8.

**Parameters:**
- `src`: Pointer to the source string in GB18030 encoding
- `dest`: Pointer to a buffer where the converted UTF-8 string will be stored
- `len`: Length of the source string in bytes
- `no_error`: Boolean flag indicating whether to suppress error reporting
- `encoding`: Encoding identifier (should be FLB_GB18030)

**Returns:** The number of bytes successfully converted, or -1 on error.

### `flb_utf8_to_gb18030`
Converts a string from UTF-8 encoding to GB18030.

**Parameters:**
- `src`: Pointer to the source string in UTF-8 encoding
- `dest`: Pointer to a buffer where the converted GB18030 string will be stored
- `len`: Length of the source string in bytes
- `no_error`: Boolean flag indicating whether to suppress error reporting
- `encoding`: Encoding identifier (should be FLB_GB18030)

**Returns:** The number of bytes successfully converted, or -1 on error.

### `flb_gb_linear` and `flb_gb_unlinear`
Helper functions for converting between GB18030's 4-byte representation and a linear code space. These functions are essential for mapping GB18030 ranges to Unicode code points.

### `flb_unicode_to_utf8word` and `flb_utf8word_to_unicode`
Utility functions for converting between Unicode code points and word-formatted UTF-8 representations.

### `flb_conv_18030_to_utf8` and `flb_conv_utf8_to_18030`
Algorithmic conversion functions that handle the mapping between GB18030 ranges and Unicode code points based on the specifications in gb-18030-2000.xml.

## Important Variables

### `gb18030_converter`
Global converter structure that defines the GB18030 encoding handler. This structure contains:
- Name: "GB18030"
- Aliases: {NULL}
- Description: "GB18030 encoding converter"
- Encoding identifier: FLB_GB18030
- Maximum character width: 4 bytes
- Callback functions for conversion operations

## Dependencies

- `<fluent-bit/unicode/flb_wchar.h>` - Wide character utilities and encoding definitions
- `<fluent-bit/unicode/flb_conv.h>` - Core conversion framework
- `maps/gb18030_to_utf8.map` - Lookup table for converting GB18030 to UTF-8
- `maps/utf8_to_gb18030.map` - Lookup table for converting UTF-8 to GB18030

## Implementation Details

The conversion functions combine lookup tables with algorithmic conversions:

1. **GB18030 to UTF-8**: Uses `flb_convert_to_utf_internal()` with both a radix tree for common characters and `flb_conv_18030_to_utf8` for algorithmic conversion of extended ranges
2. **UTF-8 to GB18030**: Uses `flb_convert_to_local_internal()` with both a radix tree for common characters and `flb_conv_utf8_to_18030` for algorithmic conversion

The file includes special handling for GB18030's unique characteristics:
- Support for 4-byte sequences
- Mapping of specific Unicode ranges to GB18030 code points
- Linearization of GB18030's multi-dimensional code space for efficient conversion

The converter structure registers the GB18030 encoding with the global conversion framework.

## Usage Examples

Converting from GB18030 to UTF-8:
```c
unsigned char *dest;
int result = flb_conv_convert_from_utf8("GB18030", gb18030_string, &dest, strlen(gb18030_string), false);
if (result > 0) {
    // Successfully converted, dest contains the UTF-8 result
    flb_free(dest);
}
```

Converting from UTF-8 to GB18030:
```c
unsigned char *dest;
int result = flb_conv_convert_to_utf8("GB18030", utf8_string, &dest, strlen(utf8_string), false);
if (result > 0) {
    // Successfully converted, dest contains the GB18030 result
    flb_free(dest);
}
```