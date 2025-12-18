# flb_unescape.c

## Overview

This file implements string unescaping functionality for Fluent Bit, providing utilities to convert escaped character sequences back to their original forms. The unescaping system handles various escape formats including standard C-style escapes, Unicode escapes, and database-specific unquoting.

Key features include:
- UTF-8 aware unescaping for international character support
- Comprehensive escape sequence handling (octal, hexadecimal, Unicode)
- Database-specific unquoting (MySQL)
- Surrogate pair handling for extended Unicode characters
- Memory-safe operations with proper bounds checking

The unescaping system is essential for processing log data that may contain escaped characters, ensuring that data is properly interpreted and stored in its original form.

## Key Functions

### `flb_unescape_string_utf8()`
Unescapes a UTF-8 encoded string, converting escape sequences to their corresponding characters. Handles complex Unicode escapes including surrogate pairs.

### `flb_unescape_string()`
Basic string unescaping that converts common escape sequences to their corresponding characters. Simpler than the UTF-8 version but sufficient for ASCII content.

### `flb_mysql_unquote_string()`
Database-specific unquoting for MySQL strings, handling MySQL's escape sequences for special characters.

### `u8_wc_toutf8()`
Converts a wide character (Unicode code point) to its UTF-8 representation.

### `u8_read_escape_sequence()`
Parses escape sequences from a string and converts them to Unicode code points, handling various escape formats.

### `octal_digit()`
Helper function to check if a character is an octal digit.

### `hex_digit()`
Helper function to check if a character is a hexadecimal digit.

### `u8_high_surrogate()`
Checks if a Unicode code point is a high surrogate.

### `u8_low_surrogate()`
Checks if a Unicode code point is a low surrogate.

### `u8_combine_surrogates()`
Combines high and low surrogate pairs to form a complete Unicode character.

## Important Variables/Constants

### Escape Sequences Handled
- Standard C escapes: `\n`, `\t`, `\r`, `\b`, `\f`, `\v`, `\a`, `\\`, `\"`, `\'`
- Octal escapes: `\nnn` (1-3 octal digits)
- Hexadecimal escapes: `\xhh` (2 hex digits), `\uhhhh` (4 hex digits), `\Uhhhhhhhh` (8 hex digits)
- Surrogate pairs: `\uhhhh\uhhhh` for extended Unicode characters
- Special characters: `\0`, `\Z` (MySQL-specific)

### Unicode Handling
- UTF-8 encoding support for international characters
- Surrogate pair combination for characters beyond the Basic Multilingual Plane
- Invalid sequence handling with replacement characters (`\uFFFD`)

### Character Validation
- Octal digit validation
- Hexadecimal digit validation
- Surrogate range validation

## Dependencies

- Standard C library headers:
  - `stdlib.h`: Standard library functions
  - `string.h`: String manipulation functions
  - `inttypes.h`: Fixed-width integer types

- Fluent Bit core components:
  - `flb_compat.h`: Compatibility layer
  - `flb_info.h`: Core information
  - `flb_log.h`: Logging functionality

## Implementation Details

1. **UTF-8 Support**: Full UTF-8 encoding support for international character sets, including proper handling of multi-byte sequences.

2. **Unicode Escape Processing**: Comprehensive handling of Unicode escape sequences including surrogate pairs for extended character sets.

3. **Database Integration**: Special handling for database-specific escape sequences, particularly MySQL unquoting.

4. **Memory Safety**: Bounds checking and proper memory management to prevent buffer overflows.

5. **Error Recovery**: Graceful handling of invalid escape sequences with replacement characters.

6. **Surrogate Pair Handling**: Proper combination of high and low surrogate pairs to form complete Unicode characters.

7. **Platform Compatibility**: Cross-platform compatibility with proper handling of signed/unsigned char differences.

8. **Performance Optimization**: Efficient parsing algorithms that minimize unnecessary processing.

## Usage Example

```c
// Basic string unescaping
char input[] = "Hello\\nWorld\\tTest";
char output[100];
int len = flb_unescape_string(input, strlen(input), &output);
// Result: "Hello\nWorld\tTest"

// UTF-8 unescaping with Unicode
char utf8_input[] = "Test\\u00E9\\u00F1\\u00ED";  // é ñ í
char utf8_output[100];
int utf8_len = flb_unescape_string_utf8(utf8_input, strlen(utf8_input), utf8_output);
// Result: "Testéñí"

// MySQL unquoting
char mysql_input[] = "\\'Test\\nLine\\'";
char mysql_output[100];
int mysql_len = flb_mysql_unquote_string(mysql_input, strlen(mysql_input), &mysql_output);
// Result: \"Test\nLine\"

// Complex Unicode with surrogate pairs
char surrogate_input[] = "Test\\uD83D\\uDE00";  // 😀 emoji
char surrogate_output[100];
int surrogate_len = flb_unescape_string_utf8(surrogate_input, strlen(surrogate_input), surrogate_output);
// Result: "Test😀"
```

## Escape Sequence Reference

| Escape | Character | Description |
|--------|-----------|-------------|
| `\n` | Line Feed | Newline character |
| `\t` | Tab | Horizontal tab |
| `\r` | Carriage Return | Carriage return |
| `\b` | Backspace | Backspace character |
| `\f` | Form Feed | Form feed |
| `\v` | Vertical Tab | Vertical tab |
| `\a` | Alert | Bell character |
| `\\` | Backslash | Literal backslash |
| `\"` | Quote | Double quote |
| `\'` | Apostrophe | Single quote |
| `\nnn` | Octal | 1-3 octal digits |
| `\xhh` | Hex | 2 hexadecimal digits |
| `\uhhhh` | Unicode | 4 hexadecimal digits |
| `\Uhhhhhhhh` | Unicode | 8 hexadecimal digits |
| `\uhhhh\uhhhh` | Surrogate Pair | Combined surrogate pairs |
| `\0` | Null | Null character (MySQL) |
| `\Z` | EOF | End of file (MySQL) |