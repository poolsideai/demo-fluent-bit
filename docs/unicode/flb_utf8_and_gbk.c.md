# flb_utf8_and_gbk.c Documentation

## Overview

This file implements the character encoding conversion functions specifically for the GBK encoding (also known as CP936). It provides bidirectional conversion between UTF-8 and GBK character sets.

GBK is a character encoding standard used for Simplified Chinese characters. It extends the GB2312 standard to support a larger character set and is widely used in China.

## Key Functions

### `flb_gbk_to_utf8`
Converts a string from GBK encoding to UTF-8.

**Parameters:**
- `src`: Pointer to the source string in GBK encoding
- `dest`: Pointer to a buffer where the converted UTF-8 string will be stored
- `len`: Length of the source string in bytes
- `no_error`: Boolean flag indicating whether to suppress error reporting
- `encoding`: Encoding identifier (should be FLB_GBK)

**Returns:** The number of bytes successfully converted, or -1 on error.

### `flb_utf8_to_gbk`
Converts a string from UTF-8 encoding to GBK.

**Parameters:**
- `src`: Pointer to the source string in UTF-8 encoding
- `dest`: Pointer to a buffer where the converted GBK string will be stored
- `len`: Length of the source string in bytes
- `no_error`: Boolean flag indicating whether to suppress error reporting
- `encoding`: Encoding identifier (should be FLB_GBK)

**Returns:** The number of bytes successfully converted, or -1 on error.

## Important Variables

### `gbk_converter`
Global converter structure that defines the GBK encoding handler. This structure contains:
- Name: "GBK"
- Aliases: {"CP936", NULL}
- Description: "GBK encoding converter"
- Encoding identifier: FLB_GBK
- Maximum character width: 3 bytes
- Callback functions for conversion operations

## Dependencies

- `<fluent-bit/unicode/flb_wchar.h>` - Wide character utilities and encoding definitions
- `<fluent-bit/unicode/flb_conv.h>` - Core conversion framework
- `maps/gbk_to_utf8.map` - Lookup table for converting GBK to UTF-8
- `maps/utf8_to_gbk.map` - Lookup table for converting UTF-8 to GBK

## Implementation Details

The conversion functions are thin wrappers around the generic conversion functions defined in `flb_conv.c`:

1. **GBK to UTF-8**: Uses `flb_convert_to_utf_internal()` with the GBK-to-Unicode radix tree
2. **UTF-8 to GBK**: Uses `flb_convert_to_local_internal()` with the UTF-8-to-GBK radix tree

Both functions leverage precomputed radix trees for efficient character lookup, avoiding the need for complex algorithmic conversions.

The converter structure registers the GBK encoding with the global conversion framework, making it available for use through the standard conversion API.

## Usage Examples

Converting from GBK to UTF-8:
```c
unsigned char *dest;
int result = flb_conv_convert_from_utf8("GBK", gbk_string, &dest, strlen(gbk_string), false);
if (result > 0) {
    // Successfully converted, dest contains the UTF-8 result
    flb_free(dest);
}
```

Converting from UTF-8 to GBK:
```c
unsigned char *dest;
int result = flb_conv_convert_to_utf8("GBK", utf8_string, &dest, strlen(utf8_string), false);
if (result > 0) {
    // Successfully converted, dest contains the GBK result
    flb_free(dest);
}
```

Direct function usage:
```c
unsigned char dest[1024];
int result = flb_utf8_to_gbk(utf8_string, &dest, strlen(utf8_string), false, FLB_GBK);
```