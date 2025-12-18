# flb_utf8.c

## Overview

The `flb_utf8.c` file provides UTF-8 encoding and decoding functionality for Fluent Bit. This module handles UTF-8 character processing, including determining the length of UTF-8 sequences, decoding UTF-8 bytes into Unicode code points, and validating UTF-8 sequences.

## Key Functions

### `flb_utf8_len`

```c
int flb_utf8_len(const char *s)
```

Returns the length of the next UTF-8 sequence in the given string.

- **Parameters**: 
  - `s`: Pointer to the UTF-8 string
- **Returns**: Length of the next UTF-8 sequence (1-4 bytes)
- **Notes**: Uses a lookup table to quickly determine sequence length based on the first byte

### `flb_utf8_decode`

```c
uint32_t flb_utf8_decode(uint32_t *state, uint32_t *codep, uint8_t byte)
```

Decodes a single UTF-8 byte into a Unicode code point, maintaining state between calls.

- **Parameters**: 
  - `state`: Pointer to decoder state (0 = start, 1-3 = continuation bytes expected)
  - `codep`: Pointer to store the decoded Unicode code point
  - `byte`: Single byte to decode
- **Returns**: One of `FLB_UTF8_ACCEPT`, `FLB_UTF8_REJECT`, or `FLB_UTF8_CONTINUE`
- **Notes**: Maintains state between calls to handle multi-byte sequences

### `flb_utf8_print`

```c
void flb_utf8_print(char *input)
```

Prints valid UTF-8 code points from the input string for debugging purposes.

- **Parameters**: 
  - `input`: UTF-8 string to process
- **Notes**: Prints each valid code point in U+XXXX format or reports invalid sequences

## Constants

### `FLB_UTF8_ACCEPT`

Indicates a complete and valid UTF-8 sequence (value: 0)

### `FLB_UTF8_REJECT`

Indicates an invalid UTF-8 sequence was detected (value: 1)

### `FLB_UTF8_CONTINUE`

Indicates the decoder expects more continuation bytes (value: 2)

## Data Structures

### `trailing_bytes_for_utf8`

Lookup table that maps the first byte of a UTF-8 sequence to the number of trailing bytes required.

```c
static const char trailing_bytes_for_utf8[256]
```

This table enables fast determination of UTF-8 sequence lengths:
- Bytes 0x00-0x7F (ASCII): 0 trailing bytes
- Bytes 0xC0-0xDF: 1 trailing byte
- Bytes 0xE0-0xEF: 2 trailing bytes
- Bytes 0xF0-0xF7: 3 trailing bytes
- Bytes 0xF8-0xFF: 4 trailing bytes (not valid in standard UTF-8)

## Dependencies

- `<fluent-bit/flb_info.h>`: Fluent Bit core information
- `<fluent-bit/flb_utf8.h>`: UTF-8 header definitions
- `<stdio.h>`: Standard I/O functions
- `<string.h>`: String manipulation functions
- `<inttypes.h>`: Fixed-width integer types

## Implementation Details

1. **UTF-8 Length Determination**: Uses a precomputed lookup table for O(1) sequence length determination

2. **State Machine Decoder**: Implements a state machine approach to decode UTF-8 sequences:
   - State 0: Expecting a new character (first byte)
   - States 1-3: Expecting continuation bytes
   - Handles all valid UTF-8 sequences (1-4 bytes)

3. **Validation**: Performs strict validation according to Unicode standards:
   - Rejects surrogate pairs (U+D800-U+DFFF)
   - Rejects code points beyond U+10FFFF
   - Validates continuation byte format

4. **Error Handling**: Returns specific codes to indicate acceptance, rejection, or continuation needs

## Usage Examples

### Decoding a UTF-8 string

```c
// Decode a UTF-8 string character by character
uint32_t state = 0;
uint32_t codepoint = 0;
const char *text = "Hello, 世界";

for (int i = 0; text[i] != '\0'; i++) {
    uint32_t result = flb_utf8_decode(&state, &codepoint, text[i]);
    
    if (result == FLB_UTF8_ACCEPT) {
        printf("Codepoint: U+%04X\n", codepoint);
    } else if (result == FLB_UTF8_REJECT) {
        printf("Invalid UTF-8 sequence\n");
        break;
    }
}
```

### Getting sequence length

```c
const char *text = "café";  // 'é' is 2 bytes in UTF-8
int len = flb_utf8_len(text);  // Returns 1 for 'c'
len = flb_utf8_len(text + 1);  // Returns 1 for 'a'
len = flb_utf8_len(text + 2);  // Returns 1 for 'f'
len = flb_utf8_len(text + 3);  // Returns 2 for 'é'
```