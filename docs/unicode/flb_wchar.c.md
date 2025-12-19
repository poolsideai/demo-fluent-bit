# flb_wchar.c Documentation

## Overview

This file contains the core implementation for working with multibyte characters in various encodings. It provides essential functions for character length calculation, display width determination, and string verification for different character encodings.

The implementation supports multiple encodings including ASCII, UTF-8, Windows code pages, and East Asian encodings like Shift-JIS, Big5, GBK, UHC, and GB18030. It uses a centralized table-driven approach where each encoding has associated function pointers for its specific operations.

## Key Functions

### `flb_utf_mblen`
Returns the byte length of a UTF-8 character based on its first byte.

**Parameters:**
- `s`: Pointer to the start of the character

**Returns:** The number of bytes in the character (1-4). Returns 1 for invalid or unsupported (5+ byte) lead bytes.

### `flb_utf8_islegal`
Checks if a UTF-8 character of a given length is valid.

**Parameters:**
- `source`: Pointer to the start of the character
- `length`: The length of the character in bytes

**Returns:** true if the character is a valid UTF-8 sequence, false otherwise.

### `flb_encoding_mblen`
Returns the byte length of a character in the given encoding.

**Parameters:**
- `encoding`: The encoding identifier
- `mbstr`: Pointer to the character

**Returns:** The byte length of the character.

### `flb_encoding_dsplen`
Returns the display width of a character in the given encoding.

**Parameters:**
- `encoding`: The encoding identifier
- `mbstr`: Pointer to the character

**Returns:** The display width of the character.

### `flb_encoding_verifymbchar`
Verifies the first character in a string for the given encoding.

**Parameters:**
- `encoding`: The encoding identifier
- `mbstr`: Pointer to the string
- `len`: Length of the string buffer

**Returns:** Character length if valid, -1 if invalid.

### `flb_encoding_verifymbstr`
Verifies an entire string in the given encoding.

**Parameters:**
- `encoding`: The encoding identifier
- `mbstr`: Pointer to the string
- `len`: Length of the string

**Returns:** The number of valid bytes from the start of the string.

### `flb_encoding_max_length`
Returns the maximum byte length of a character for the given encoding.

**Parameters:**
- `encoding`: The encoding identifier

**Returns:** The maximum byte length of a character in the encoding.

## Important Variables

### `flb_wchar_table`
Global array that maps encoding identifiers to their corresponding function tables. Each entry contains:
- `mb2wchar_with_len`: Function to convert multibyte string to wide character string
- `wchar2mb_with_len`: Function to convert wide character string to multibyte string
- `mblen`: Function to get byte length of a character
- `dsplen`: Function to get display width of a character
- `mbverifychar`: Function to verify a single character
- `mbverifystr`: Function to verify an entire string
- `maxmblen`: Maximum bytes for a character in this encoding

## Dependencies

- `<limits.h>` - For INT_MAX constant
- `<fluent-bit/unicode/flb_wchar.h>` - Header file with declarations and data structures

## Implementation Details

The file implements a table-driven architecture where each encoding has its own set of functions for character operations:

1. **ASCII Encoding**: Simple single-byte operations with standard ASCII rules
2. **UTF-8 Encoding**: Complex multi-byte sequences with strict validation rules
3. **Legacy Encodings**: Shared logic for similar encodings (Big5, GBK, UHC) with encoding-specific verification
4. **Windows Code Pages**: Unified handling through single-byte encoding functions

Key architectural features:

- **Centralized Table**: All encoding functions are accessed through the `flb_wchar_table` lookup table
- **Macro-based Initialization**: Uses macros to reduce code duplication for similar encodings
- **Validation Functions**: Each encoding has specific character verification logic
- **Display Width Calculation**: Accounts for double-width characters in East Asian encodings
- **Error Handling**: Special invalid byte sequences for marking conversion errors

The implementation carefully handles edge cases like overlong UTF-8 sequences, surrogate pairs, and invalid byte combinations in various encodings.

## Usage Examples

Getting character length in a specific encoding:
```c
int len = flb_encoding_mblen(FLB_UTF8, utf8_string);
```

Verifying a string in a specific encoding:
```c
int valid_len = flb_encoding_verifymbstr(FLB_SJIS, sjis_string, strlen(sjis_string));
```

Checking if a UTF-8 sequence is valid:
```c
if (flb_utf8_islegal((unsigned char*)utf8_char, 3)) {
    // Valid 3-byte UTF-8 sequence
}
```