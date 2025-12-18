# flb_unescape.c

## Overview

The `flb_unescape.c` file implements string unescaping functionality for Fluent Bit. This module provides utilities to handle escaped characters in strings, particularly for processing log data that may contain escape sequences. It supports various escaping formats including standard C-style escapes, Unicode escapes, and MySQL-specific quoting.

The unescaping system is crucial for Fluent Bit's data processing pipeline as it handles the conversion of escaped characters in log data back to their actual representations. This is particularly important when dealing with data from sources like databases, JSON parsers, or systems that use escape sequences to represent special characters.

## Key Functions

### `flb_unescape_string_utf8(const char *in_buf, int sz, char *out_buf)`
Unescapes a UTF-8 encoded string, converting escape sequences to their actual character representations. This function handles a wide range of escape sequences including octal, hexadecimal, and Unicode escapes.

The function supports comprehensive Unicode handling:
- 16-bit Unicode escapes (`\u1234`)
- 32-bit Unicode escapes (`\U12345678`)
- Surrogate pair combination for characters outside the Basic Multilingual Plane
- Proper UTF-8 encoding of Unicode code points
- Error handling for invalid escape sequences
- Boundary checking to prevent buffer overflows

### `flb_unescape_string(const char *buf, int buf_len, char **unesc_buf)`
Basic string unescaping function that converts common escape sequences (\n, \t, \r, etc.) to their actual characters.

Supports standard C escape sequences:
- `\n` - newline
- `\t` - tab
- `\r` - carriage return
- `\b` - backspace
- `\f` - form feed
- `\v` - vertical tab
- `\a` - alert/bell
- `\'` - single quote
- `\"` - double quote
- `\\` - backslash
- `\/` - forward slash

### `flb_mysql_unquote_string(char *buf, int buf_len, char **unesc_buf)`
Unescapes MySQL-specific quoted strings, handling MySQL's particular escape sequence format.

Supports MySQL-specific escape sequences:
- `\n` - newline
- `\r` - carriage return
- `\t` - tab
- `\\` - backslash
- `\'` - single quote
- `\"` - double quote
- `\0` - null character
- `\Z` - Windows EOF character (0x1A)

## Important Variables and Constants

### Utility Functions
- `octal_digit()` - Checks if a character is a valid octal digit (0-7)
- `hex_digit()` - Checks if a character is a valid hexadecimal digit (0-9, A-F, a-f)
- `u8_wc_toutf8()` - Converts a Unicode code point to UTF-8 encoding
- `u8_high_surrogate()` - Checks if a Unicode code point is a high surrogate (0xD800-0xDBFF)
- `u8_low_surrogate()` - Checks if a Unicode code point is a low surrogate (0xDC00-0xDFFF)
- `u8_combine_surrogates()` - Combines high and low surrogates into a single Unicode code point
- `u8_read_escape_sequence()` - Parses escape sequences and converts them to Unicode code points

### Buffer Management
- Input buffer pointers and size tracking
- Output buffer management with proper null termination
- Boundary checking to prevent buffer overflows
- Error handling for malformed escape sequences

## Dependencies

This module depends on:
- Fluent Bit compatibility layer (`flb_compat.h`)
- Fluent Bit information header (`flb_info.h`)
- Fluent Bit logging system (`flb_log.h`)
- Standard C library functions (`stdlib.h`, `string.h`)
- Standard integer types (`inttypes.h`)

## Implementation Details

The unescaping system handles several types of escape sequences:

### Standard C Escapes

The basic unescaping function handles common C escape sequences:
- **Control characters**: `\n`, `\t`, `\r`, `\b`, `\f`, `\v`, `\a`
- **Quotes**: `\'`, `\"`
- **Special characters**: `\\`, `\/`

### Octal Escapes

Sequences like `\123` are converted to the corresponding character by interpreting the digits as an octal number.

### Hexadecimal Escapes

Sequences like `\x1A` are converted to the corresponding character by interpreting the digits as a hexadecimal number.

### Unicode Escapes

The UTF-8 unescaping function provides sophisticated Unicode handling:

#### 16-bit Unicode Escapes (`\u1234`)
Converts 4 hexadecimal digits to a Unicode code point. Handles:
- Basic Multilingual Plane characters (U+0000 to U+FFFF)
- Surrogate pair detection and combination
- Error handling for incomplete sequences

#### 32-bit Unicode Escapes (`\U12345678`)
Converts 8 hexadecimal digits to a Unicode code point for characters beyond the Basic Multilingual Plane.

#### Surrogate Pair Handling
Properly combines high surrogates (0xD800-0xDBFF) and low surrogates (0xDC00-0xDFFF) to form complete Unicode code points:
1. Detects high surrogate in first `\u` sequence
2. Validates subsequent `\u` sequence for low surrogate
3. Combines surrogates using `u8_combine_surrogates()`
4. Handles error cases for invalid surrogate combinations

#### UTF-8 Encoding
Converts Unicode code points to proper UTF-8 byte sequences:
- 1-byte sequences for ASCII characters (U+0000 to U+007F)
- 2-byte sequences for characters up to U+07FF
- 3-byte sequences for characters up to U+FFFF
- 4-byte sequences for characters up to U+10FFFF

### MySQL-Specific Escapes

Handles MySQL's particular quoting rules:
- Standard control character escapes
- Quote escaping with single and double quotes
- Null character representation (`\0`)
- Windows EOF character (`\Z`)
- Proper handling of backslash-escaped sequences

### Error Handling

The system implements robust error handling:
- Boundary checking to prevent buffer overflows
- Invalid escape sequence detection and replacement
- Surrogate pair validation
- Proper logging of unescaping errors
- Graceful degradation for malformed input

### Buffer Management

Careful buffer management is implemented:
- Proper null termination of output strings
- Boundary checking to prevent buffer overflows
- Efficient memory usage without unnecessary allocations
- Clear separation of input and output buffers

## Usage Examples

Basic string unescaping:
```c
char input[] = "Hello\nWorld\t!";
char *output;
int output_len;

// Allocate output buffer (same size as input in worst case)
output = malloc(strlen(input) + 1);

output_len = flb_unescape_string(input, strlen(input), &output);

// output now contains "Hello\nWorld\t!" with actual newline and tab characters
```

UTF-8 string unescaping:
```c
char input[] = "Hello\u0041\u0042";  // "HelloAB"
char output[100];
int output_len;

output_len = flb_unescape_string_utf8(input, strlen(input), output);

// output now contains "HelloAB" with actual Unicode characters
```

MySQL string unescaping:
```c
char input[] = "SELECT * FROM table WHERE name = '\\'\\'\\";
char *output;
int output_len;

// Allocate output buffer
output = malloc(strlen(input) + 1);

output_len = flb_mysql_unquote_string(input, strlen(input), &output);

// Unescaped MySQL string
```

Unicode surrogate pair handling:
```c
char input[] = "Surrogate: \uD83D\uDE00";  // Grinning face emoji
char output[100];
int output_len;

output_len = flb_unescape_string_utf8(input, strlen(input), output);

// output contains the actual emoji character
```

## Performance Considerations

The unescaping functions are designed for optimal performance:
- Minimal memory allocations
- Efficient character-by-character processing
- Early termination for simple cases
- Optimized UTF-8 encoding functions
- Proper buffer boundary checking

## Unicode Support

The UTF-8 unescaping function provides comprehensive Unicode support:
- Full range of Unicode code points (U+0000 to U+10FFFF)
- Proper handling of surrogate pairs for supplementary characters
- Correct UTF-8 encoding of all valid code points
- Error handling for invalid Unicode sequences
- Replacement character (U+FFFD) for malformed sequences

## Error Handling

The system implements comprehensive error handling:
- Invalid escape sequence detection and replacement with U+FFFD
- Buffer overflow prevention with boundary checking
- Surrogate pair validation and error reporting
- Proper logging of unescaping errors
- Graceful degradation for malformed input

## Thread Safety

The unescaping functions are designed to be thread-safe:
- No shared mutable state between function calls
- Proper input/output buffer separation
- Reentrant design for concurrent usage

## Integration with Fluent Bit Pipeline

The unescaping system integrates seamlessly with Fluent Bit's data pipeline:
- Works with MessagePack string objects throughout the pipeline
- Compatible with filter plugin architectures
- Supports dynamic unescaping based on configuration
- Integrates with record accessor for field-level unescaping

## Supported Escape Sequences

### Standard C Style
- `\n` - Line feed (LF)
- `\r` - Carriage return (CR)
- `\t` - Tab
- `\b` - Backspace
- `\f` - Form feed
- `\v` - Vertical tab
- `\a` - Bell/alert
- `\'` - Single quote
- `\"` - Double quote
- `\\` - Backslash
- `\/` - Forward slash
- `\ooo` - Octal escape (1-3 digits)
- `\xhh` - Hexadecimal escape (1-2 digits)

### Unicode Style
- `\uhhhh` - 16-bit Unicode escape (4 hex digits)
- `\Uhhhhhhhh` - 32-bit Unicode escape (8 hex digits)
- Surrogate pair combination for supplementary characters

### MySQL Style
- `\n` - Line feed
- `\r` - Carriage return
- `\t` - Tab
- `\\` - Backslash
- `\'` - Single quote
- `\"` - Double quote
- `\0` - Null character
- `\Z` - Windows EOF character

## Memory Management

All unescaping operations follow Fluent Bit's memory management patterns:
- Clear separation of input and output buffers
- Proper null termination of output strings
- Boundary checking to prevent buffer overflows
- Error-safe memory operations

## Extensibility

The unescaping system is designed for extensibility:
- Modular escape sequence handlers
- Clear separation of concerns
- Well-defined interfaces for adding new escape formats
- Support for custom unescaping rules

## Debugging and Monitoring

The system includes debugging aids:
- Detailed error messages for failed unescaping operations
- Logging of unescaping errors and warnings
- Validation of escape sequence boundaries
- Memory leak detection support