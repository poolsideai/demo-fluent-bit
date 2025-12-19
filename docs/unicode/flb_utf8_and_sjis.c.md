# flb_utf8_and_sjis.c Documentation

## Overview

This file implements the character encoding conversion functions specifically for the SHIFT-JIS (SJIS) encoding (also known as CP932). It provides bidirectional conversion between UTF-8 and SHIFT-JIS character sets.

SHIFT-JIS is a character encoding standard used primarily for Japanese characters. It is a variable-width encoding that supports both ASCII characters and multi-byte sequences for Japanese Kanji, Hiragana, and Katakana characters.

## Key Functions

### `flb_sjis_to_utf8`
Converts a string from SHIFT-JIS encoding to UTF-8.

**Parameters:**
- `src`: Pointer to the source string in SHIFT-JIS encoding
- `dest`: Pointer to a buffer where the converted UTF-8 string will be stored
- `len`: Length of the source string in bytes
- `no_error`: Boolean flag indicating whether to suppress error reporting
- `encoding`: Encoding identifier (should be FLB_SJIS)

**Returns:** The number of bytes successfully converted, or -1 on error.

### `flb_utf8_to_sjis`
Converts a string from UTF-8 encoding to SHIFT-JIS.

**Parameters:**
- `src`: Pointer to the source string in UTF-8 encoding
- `dest`: Pointer to a buffer where the converted SHIFT-JIS string will be stored
- `len`: Length of the source string in bytes
- `no_error`: Boolean flag indicating whether to suppress error reporting
- `encoding`: Encoding identifier (should be FLB_SJIS)

**Returns:** The number of bytes successfully converted, or -1 on error.

## Important Variables

### `sjis_converter`
Global converter structure that defines the SHIFT-JIS encoding handler. This structure contains:
- Name: "SHIFTJIS"
- Aliases: {"SJIS", "CP932", "Windows-31J", NULL}
- Description: "SHIFTJIS encoding converter"
- Encoding identifier: FLB_SJIS
- Maximum character width: 3 bytes
- Callback functions for conversion operations

## Dependencies

- `<fluent-bit/unicode/flb_wchar.h>` - Wide character utilities and encoding definitions
- `<fluent-bit/unicode/flb_conv.h>` - Core conversion framework
- `maps/sjis_to_utf8.map` - Lookup table for converting SHIFT-JIS to UTF-8
- `maps/utf8_to_sjis.map` - Lookup table for converting UTF-8 to SHIFT-JIS

## Implementation Details

The conversion functions are thin wrappers around the generic conversion functions defined in `flb_conv.c`:

1. **SHIFT-JIS to UTF-8**: Uses `flb_convert_to_utf_internal()` with the SHIFT-JIS-to-Unicode radix tree
2. **UTF-8 to SHIFT-JIS**: Uses `flb_convert_to_local_internal()` with the UTF-8-to-SHIFT-JIS radix tree

Both functions leverage precomputed radix trees for efficient character lookup, avoiding the need for complex algorithmic conversions.

The converter structure registers the SHIFT-JIS encoding with the global conversion framework, making it available for use through the standard conversion API.

## Usage Examples

Converting from SHIFT-JIS to UTF-8:
```c
unsigned char *dest;
int result = flb_conv_convert_from_utf8("SHIFTJIS", sjis_string, &dest, strlen(sjis_string), false);
if (result > 0) {
    // Successfully converted, dest contains the UTF-8 result
    flb_free(dest);
}
```

Converting from UTF-8 to SHIFT-JIS:
```c
unsigned char *dest;
int result = flb_conv_convert_to_utf8("SHIFTJIS", utf8_string, &dest, strlen(utf8_string), false);
if (result > 0) {
    // Successfully converted, dest contains the SHIFT-JIS result
    flb_free(dest);
}
```

Direct function usage:
```c
unsigned char dest[1024];
int result = flb_utf8_to_sjis(utf8_string, &dest, strlen(utf8_string), false, FLB_SJIS);
```