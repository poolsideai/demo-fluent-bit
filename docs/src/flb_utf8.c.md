# flb_utf8.c and flb_utf8.h Documentation

## Overview

The `flb_utf8` module provides UTF-8 encoding and decoding utilities for Fluent Bit. This implementation handles UTF-8 character sequences, validation, and conversion to Unicode code points.

UTF-8 is a variable-width character encoding that can represent every character in the Unicode character set. This module provides essential functions for working with UTF-8 encoded text in Fluent Bit.

## Key Features

- UTF-8 sequence length calculation
- UTF-8 decoding to Unicode code points
- UTF-8 validation and error detection
- Unicode code point printing
- State machine-based decoding

## Constants

### FLB_UTF8_ACCEPT

Constant indicating successful acceptance of a UTF-8 sequence:

```c
#define FLB_UTF8_ACCEPT   0
```

### FLB_UTF8_REJECT

Constant indicating rejection of an invalid UTF-8 sequence:

```c
#define FLB_UTF8_REJECT   1
```

### FLB_UTF8_CONTINUE

Constant indicating continuation of a multi-byte UTF-8 sequence:

```c
#define FLB_UTF8_CONTINUE 2
```

## Key Functions

### flb_utf8_len()

```c
int flb_utf8_len(const char *s);
```

Returns the length of the next UTF-8 sequence starting at the given position.

**Parameters:**
- `s`: Pointer to the start of a UTF-8 sequence

**Returns:**
- Length of the UTF-8 sequence in bytes (1-4)

### flb_utf8_decode()

```c
uint32_t flb_utf8_decode(uint32_t *state, uint32_t *codep, uint8_t byte);
```

Decodes a single byte of a UTF-8 sequence and updates the decoding state.

**Parameters:**
- `state`: Pointer to the decoding state (0 for new sequence)
- `codep`: Pointer to store the resulting Unicode code point
- `byte`: Next byte of the UTF-8 sequence

**Returns:**
- `FLB_UTF8_ACCEPT` if the sequence is complete and valid
- `FLB_UTF8_REJECT` if the sequence is invalid
- `FLB_UTF8_CONTINUE` if more bytes are needed for the sequence

### flb_utf8_print()

```c
void flb_utf8_print(char *input);
```

Prints the Unicode code points of a UTF-8 string.

**Parameters:**
- `input`: UTF-8 encoded string to process

## Implementation Details

### UTF-8 Sequence Length Lookup

The implementation uses a lookup table to quickly determine the length of UTF-8 sequences:

```c
static const char trailing_bytes_for_utf8[256] = {
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1, 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,
    2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2, 3,3,3,3,3,3,3,3,4,4,4,4,5,5,5,5
};
```

This table maps the first byte of a UTF-8 sequence to the number of trailing bytes required.

### State Machine Decoding

The `flb_utf8_decode` function implements a state machine approach to UTF-8 decoding:

1. **Initial State (0)**: Processes the first byte to determine sequence type
2. **Continuation States (1-3)**: Process subsequent bytes of multi-byte sequences
3. **Completion**: Validates the final code point and checks for surrogate pairs

### Validation Rules

The decoder validates UTF-8 sequences according to these rules:

- **ASCII Range (0x00-0x7F)**: Single byte sequences
- **2-byte Sequences (0xC0-0xDF)**: First byte followed by one continuation byte (0x80-0xBF)
- **3-byte Sequences (0xE0-0xEF)**: First byte followed by two continuation bytes
- **4-byte Sequences (0xF0-0xF7)**: First byte followed by three continuation bytes

Additionally, the decoder rejects:
- Surrogate pairs (0xD800-0xDFFF)
- Code points beyond Unicode range (> 0x10FFFF)
- Invalid continuation bytes
- Overlong encodings

## Usage Example

```c
#include <fluent-bit/flb_utf8.h>
#include <fluent-bit/flb_log.h>

// Get UTF-8 sequence length
const char *text = "Hello 世界";
int len = flb_utf8_len(text);
flb_info("First UTF-8 sequence is %d bytes long", len);

// Decode UTF-8 byte by byte
uint32_t state = 0;
uint32_t codepoint = 0;
const char *ptr = text;

while (*ptr) {
    uint32_t result = flb_utf8_decode(&state, &codepoint, (uint8_t)*ptr);
    
    if (result == FLB_UTF8_ACCEPT) {
        flb_info("Valid codepoint: U+%04X", codepoint);
    }
    else if (result == FLB_UTF8_REJECT) {
        flb_error("Invalid UTF-8 sequence");
        break;
    }
    
    ptr++;
}

// Print codepoints for debugging
flb_utf8_print("Fluent Bit 🌟");

// Process a string character by character
const char *message = "Fluent Bit supports Unicode: αβγ";

for (int i = 0; message[i] != '\0';) {
    int utf8_len = flb_utf8_len(&message[i]);
    if (utf8_len > 0) {
        flb_info("Character at position %d: %.*s (%d bytes)", 
                 i, utf8_len, &message[i], utf8_len);
        i += utf8_len;
    } else {
        flb_error("Invalid UTF-8 at position %d", i);
        break;
    }
}
```