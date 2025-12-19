# flb_utf8_and_win.c Documentation

## Overview

This file implements the character encoding conversion functions for various Windows code page encodings. It provides bidirectional conversion between UTF-8 and multiple Windows-specific character sets including:

- Windows-866 (Cyrillic)
- Windows-874 (Thai)
- Windows-1250 (Central European)
- Windows-1251 (Cyrillic)
- Windows-1252 (Western European)
- Windows-1253 (Greek)
- Windows-1254 (Turkish)
- Windows-1255 (Hebrew)
- Windows-1256 (Arabic)

These encodings are commonly used in Windows environments for different language regions.

## Key Functions

### `flb_win_to_utf8`
Converts a string from a Windows code page encoding to UTF-8.

**Parameters:**
- `src`: Pointer to the source string in Windows code page encoding
- `dest`: Pointer to a buffer where the converted UTF-8 string will be stored
- `len`: Length of the source string in bytes
- `no_error`: Boolean flag indicating whether to suppress error reporting
- `encoding`: Encoding identifier (one of the FLB_WIN* constants)

**Returns:** The number of bytes successfully converted, or -1 on error.

### `flb_utf8_to_win`
Converts a string from UTF-8 encoding to a Windows code page encoding.

**Parameters:**
- `src`: Pointer to the source string in UTF-8 encoding
- `dest`: Pointer to a buffer where the converted Windows code page string will be stored
- `len`: Length of the source string in bytes
- `no_error`: Boolean flag indicating whether to suppress error reporting
- `encoding`: Encoding identifier (one of the FLB_WIN* constants)

**Returns:** The number of bytes successfully converted, or -1 on error.

## Important Variables

### `maps`
Static array that maps encoding identifiers to their corresponding radix trees:
- `FLB_WIN866` → `win866_to_unicode_tree` and `win866_from_unicode_tree`
- `FLB_WIN874` → `win874_to_unicode_tree` and `win874_from_unicode_tree`
- `FLB_WIN1250` → `win1250_to_unicode_tree` and `win1250_from_unicode_tree`
- And so on for all supported Windows encodings

### Converter Structures
Multiple global converter structures for each Windows encoding:
- `win866_converter`, `win874_converter`, `win1250_converter`, etc.

Each structure contains:
- Name (e.g., "Win866")
- Aliases (e.g., {"CP866", NULL})
- Description: "Windows code pages' converters"
- Encoding identifier
- Maximum character width
- Callback functions for conversion operations

## Dependencies

- `<fluent-bit/flb_log.h>` - For logging functionality
- `<fluent-bit/unicode/flb_wchar.h>` - Wide character utilities and encoding definitions
- `<fluent-bit/unicode/flb_conv.h>` - Core conversion framework
- Various map files for each Windows encoding:
  - `maps/utf8_to_win1250.map` through `maps/utf8_to_win874.map`
  - `maps/win1250_to_utf8.map` through `maps/win874_to_utf8.map`

## Implementation Details

The conversion functions use a unified approach for all Windows encodings:

1. **Windows to UTF-8**: Uses `flb_convert_to_utf_internal()` with the appropriate radix tree from the `maps` array
2. **UTF-8 to Windows**: Uses `flb_convert_to_local_internal()` with the appropriate radix tree from the `maps` array

Both functions leverage precomputed radix trees for efficient character lookup, avoiding the need for complex algorithmic conversions.

The file defines separate converter structures for each Windows encoding, allowing them to be registered individually with the global conversion framework while sharing common conversion logic.

## Usage Examples

Converting from Windows-1252 to UTF-8:
```c
unsigned char *dest;
int result = flb_conv_convert_from_utf8("Win1252", win1252_string, &dest, strlen(win1252_string), false);
if (result > 0) {
    // Successfully converted, dest contains the UTF-8 result
    flb_free(dest);
}
```

Converting from UTF-8 to Windows-1251:
```c
unsigned char *dest;
int result = flb_conv_convert_to_utf8("Win1251", utf8_string, &dest, strlen(utf8_string), false);
if (result > 0) {
    // Successfully converted, dest contains the Windows-1251 result
    flb_free(dest);
}
```

Direct function usage with encoding identifier:
```c
unsigned char dest[1024];
int result = flb_utf8_to_win(utf8_string, &dest, strlen(utf8_string), false, FLB_WIN1252);
```