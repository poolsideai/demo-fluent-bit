# flb_unescape.c

## Overview

The `flb_unescape.c` file implements string unescaping functionality for Fluent Bit. This module provides utilities to handle escaped characters in strings, particularly for processing log data that may contain escape sequences. It supports various escaping formats including standard C-style escapes, Unicode escapes, and MySQL-specific quoting.

## Key Functions

### `flb_unescape_string_utf8(const char *in_buf, int sz, char *out_buf)`
Unescapes a UTF-8 encoded string, converting escape sequences to their actual character representations. This function handles a wide range of escape sequences including octal, hexadecimal, and Unicode escapes.

### `flb_unescape_string(const char *buf, int buf_len, char **unesc_buf)`
Basic string unescaping function that converts common escape sequences (\n, \t, \r, etc.) to their actual characters.

### `flb_mysql_unquote_string(char *buf, int buf_len, char **unesc_buf)`
Unescapes MySQL-specific quoted strings, handling MySQL's particular escape sequence format.

## Important Variables and Constants

### Escape Sequence Handlers
- `octal_digit()` - Checks if a character is a valid octal digit
- `hex_digit()` - Checks if a character is a valid hexadecimal digit
- `u8_wc_toutf8()` - Converts a Unicode code point to UTF-8 encoding
- `u8_high_surrogate()` - Checks if a Unicode code point is a high surrogate
- `u8_low_surrogate()` - Checks if a Unicode code point is a low surrogate
- `u8_combine_surrogates()` - Combines high and low surrogates into a single Unicode code point
- `u8_read_escape_sequence()` - Parses escape sequences and converts them to Unicode code points

## Dependencies

This module depends on:
- Fluent Bit compatibility layer (`flb_compat.h`)
- Fluent Bit information header (`flb_info.h`)
- Fluent Bit logging system (`flb_log.h`)
- Standard C library functions (`stdlib.h`, `string.h`)
- Standard integer types (`inttypes.h`)

## Implementation Details

The unescaping system handles several types of escape sequences:

1. **Standard C escapes**:
   - `\n` - newline
   - `\t` - tab
   - `\r` - carriage return
   - `\b` - backspace
   - `\f` - form feed
   - `\v` - vertical tab
   - `\a` - alert/bell
   - `"` - double quote
   - `'` - single quote
   - `\\` - backslash
   - `\/` - forward slash

2. **Octal escapes**: Sequences like `\123` are converted to the corresponding character.

3. **Hexadecimal escapes**: Sequences like `\x1A` are converted to the corresponding character.

4. **Unicode escapes**:
   - `\u1234` - 16-bit Unicode escapes
   - `\U12345678` - 32-bit Unicode escapes
   - Surrogate pair handling for characters outside the Basic Multilingual Plane

5. **MySQL-specific escapes**: Special handling for MySQL's quoting rules.

The UTF-8 unescaping function is particularly sophisticated, handling:
- Proper UTF-8 encoding of Unicode code points
- Surrogate pair combination for characters requiring more than 16 bits
- Error handling for invalid escape sequences
- Boundary checking to prevent buffer overflows

Each unescaping function takes an input buffer and produces an output buffer with the escape sequences converted to actual characters. The functions are designed to be efficient and handle edge cases gracefully.

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