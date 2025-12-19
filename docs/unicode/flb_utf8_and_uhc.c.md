# flb_utf8_and_uhc.c Documentation

## Overview

This file implements the character encoding conversion functions specifically for the Unified Hangul Code (UHC) encoding (also known as CP949). It provides bidirectional conversion between UTF-8 and UHC character sets.

UHC is a character encoding standard used for Korean characters. It extends the KS X 1001 standard to include Hangul syllables and other Korean-specific characters, and is widely used in South Korea.

## Key Functions

### `flb_uhc_to_utf8`
Converts a string from UHC encoding to UTF-8.

**Parameters:**
- `src`: Pointer to the source string in UHC encoding
- `dest`: Pointer to a buffer where the converted UTF-8 string will be stored
- `len`: Length of the source string in bytes
- `no_error`: Boolean flag indicating whether to suppress error reporting
- `encoding`: Encoding identifier (should be FLB_UHC)

**Returns:** The number of bytes successfully converted, or -1 on error.

### `flb_utf8_to_uhc`
Converts a string from UTF-8 encoding to UHC.

**Parameters:**
- `src`: Pointer to the source string in UTF-8 encoding
- `dest`: Pointer to a buffer where the converted UHC string will be stored
- `len`: Length of the source string in bytes
- `no_error`: Boolean flag indicating whether to suppress error reporting
- `encoding`: Encoding identifier (should be FLB_UHC)

**Returns:** The number of bytes successfully converted, or -1 on error.

## Important Variables

### `uhc_converter`
Global converter structure that defines the UHC encoding handler. This structure contains:
- Name: "UHC"
- Aliases: {"CP949", "Windows-949", NULL}
- Description: "UHC encoding converter"
- Encoding identifier: FLB_UHC
- Maximum character width: 3 bytes
- Callback functions for conversion operations

## Dependencies

- `<fluent-bit/unicode/flb_wchar.h>` - Wide character utilities and encoding definitions
- `<fluent-bit/unicode/flb_conv.h>` - Core conversion framework
- `maps/uhc_to_utf8.map` - Lookup table for converting UHC to UTF-8
- `maps/utf8_to_uhc.map` - Lookup table for converting UTF-8 to UHC

## Implementation Details

The conversion functions are thin wrappers around the generic conversion functions defined in `flb_conv.c`:

1. **UHC to UTF-8**: Uses `flb_convert_to_utf_internal()` with the UHC-to-Unicode radix tree
2. **UTF-8 to UHC**: Uses `flb_convert_to_local_internal()` with the UTF-8-to-UHC radix tree

Both functions leverage precomputed radix trees for efficient character lookup, avoiding the need for complex algorithmic conversions.

The converter structure registers the UHC encoding with the global conversion framework, making it available for use through the standard conversion API.

## Usage Examples

Converting from UHC to UTF-8:
```c
unsigned char *dest;
int result = flb_conv_convert_from_utf8("UHC", uhc_string, &dest, strlen(uhc_string), false);
if (result > 0) {
    // Successfully converted, dest contains the UTF-8 result
    flb_free(dest);
}
```

Converting from UTF-8 to UHC:
```c
unsigned char *dest;
int result = flb_conv_convert_to_utf8("UHC", utf8_string, &dest, strlen(utf8_string), false);
if (result > 0) {
    // Successfully converted, dest contains the UHC result
    flb_free(dest);
}
```

Direct function usage:
```c
unsigned char dest[1024];
int result = flb_utf8_to_uhc(utf8_string, &dest, strlen(utf8_string), false, FLB_UHC);
```