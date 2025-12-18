# flb_log_event_encoder_primitives.c

## Overview

This file contains the implementation of primitive value encoding functions for the Fluent Bit log event encoder. These functions provide low-level serialization capabilities for various data types using MessagePack format. They are used to encode basic values such as strings, integers, booleans, timestamps, and binary data into the log event structure.

The primitives encoder works in conjunction with the dynamic field system to build complex nested data structures incrementally. Each function appends a specific type of value to a target field (metadata, body, or root) in the log event.

## Key Functions

### Core Encoding Functions

- `flb_log_event_encoder_append_binary_length()` - Prepares to append a binary value by specifying its length
- `flb_log_event_encoder_append_binary_body()` - Appends the actual binary data
- `flb_log_event_encoder_append_ext_length()` - Prepares to append an extension type value by specifying its length and type
- `flb_log_event_encoder_append_ext_body()` - Appends the actual extension data
- `flb_log_event_encoder_append_string_length()` - Prepares to append a string value by specifying its length
- `flb_log_event_encoder_append_string_body()` - Appends the actual string data

### Integer Encoding Functions

- `flb_log_event_encoder_append_int8()` - Encodes an 8-bit signed integer
- `flb_log_event_encoder_append_int16()` - Encodes a 16-bit signed integer
- `flb_log_event_encoder_append_int32()` - Encodes a 32-bit signed integer
- `flb_log_event_encoder_append_int64()` - Encodes a 64-bit signed integer
- `flb_log_event_encoder_append_uint8()` - Encodes an 8-bit unsigned integer
- `flb_log_event_encoder_append_uint16()` - Encodes a 16-bit unsigned integer
- `flb_log_event_encoder_append_uint32()` - Encodes a 32-bit unsigned integer
- `flb_log_event_encoder_append_uint64()` - Encodes a 64-bit unsigned integer

### Floating Point and Boolean Encoding

- `flb_log_event_encoder_append_double()` - Encodes a double precision floating point value
- `flb_log_event_encoder_append_boolean()` - Encodes a boolean value
- `flb_log_event_encoder_append_character()` - Encodes a single character

### Special Value Encoding

- `flb_log_event_encoder_append_null()` - Encodes a null value
- `flb_log_event_encoder_append_msgpack_object()` - Encodes a pre-existing MessagePack object
- `flb_log_event_encoder_append_raw_msgpack()` - Encodes raw MessagePack data

### Timestamp Encoding Functions

- `flb_log_event_encoder_append_timestamp()` - Encodes a timestamp in standard format
- `flb_log_event_encoder_append_legacy_timestamp()` - Encodes a timestamp in legacy format
- `flb_log_event_encoder_append_forward_v1_timestamp()` - Encodes a timestamp in Forward v1 format
- `flb_log_event_encoder_append_fluent_bit_v1_timestamp()` - Encodes a timestamp in Fluent Bit v1 format
- `flb_log_event_encoder_append_fluent_bit_v2_timestamp()` - Encodes a timestamp in Fluent Bit v2 format

### Convenience Functions

- `flb_log_event_encoder_append_values_unsafe()` - Processes a variable argument list of encoded values
- `flb_log_event_encoder_append_binary()` - Convenience function to append binary data in one call
- `flb_log_event_encoder_append_string()` - Convenience function to append string data in one call
- `flb_log_event_encoder_append_ext()` - Convenience function to append extension data in one call
- `flb_log_event_encoder_append_cstring()` - Convenience function to append null-terminated strings

## Important Variables and Constants

### Target Field Identifiers

- `FLB_LOG_EVENT_ROOT` (1) - Identifies the root field of the log event
- `FLB_LOG_EVENT_METADATA` (2) - Identifies the metadata field of the log event
- `FLB_LOG_EVENT_BODY` (3) - Identifies the body field of the log event

### Value Type Identifiers

These constants identify different types of values that can be appended:
- `FLB_LOG_EVENT_APPEND_TERMINATOR_VALUE_TYPE` (0) - Terminates a value list
- `FLB_LOG_EVENT_STRING_LENGTH_VALUE_TYPE` (1) - String length specification
- `FLB_LOG_EVENT_STRING_BODY_VALUE_TYPE` (2) - String body data
- `FLB_LOG_EVENT_BINARY_LENGTH_VALUE_TYPE` (3) - Binary length specification
- `FLB_LOG_EVENT_BINARY_BODY_VALUE_TYPE` (4) - Binary body data
- `FLB_LOG_EVENT_EXT_LENGTH_VALUE_TYPE` (5) - Extension length specification
- `FLB_LOG_EVENT_EXT_BODY_VALUE_TYPE` (6) - Extension body data
- And many more for different data types

### Limits

- `FLB_EVENT_ENCODER_VALUE_LIMIT` (64) - Maximum number of values that can be appended in a single operation

## Dependencies and Relationships

### Direct Dependencies

- `<fluent-bit/flb_log_event_encoder.h>` - Main encoder interface
- `<fluent-bit/flb_time.h>` - Time handling utilities
- `<fluent-bit/flb_sds.h>` - String data structure utilities
- `<fluent-bit/flb_mp.h>` - MessagePack utilities
- `<msgpack.h>` - MessagePack C library

### Relationship with Other Components

1. **Dynamic Field System**: Works closely with `flb_log_event_encoder_dynamic_field.c` to manage nested data structures
2. **Main Encoder**: Provides the primitive operations that the main encoder (`flb_log_event_encoder.c`) uses to build complex log events
3. **Log Event Structure**: Operates on the `struct flb_log_event_encoder` data structure
4. **MessagePack Integration**: Uses MessagePack packer directly for efficient serialization

## Notable Implementation Details

### Two-Phase Value Appending

For complex values like strings and binaries, the implementation uses a two-phase approach:
1. First append the length specification
2. Then append the actual data

This allows for efficient memory management and proper MessagePack formatting.

### Variable Argument Processing

The `flb_log_event_encoder_append_values_unsafe()` function implements a sophisticated variable argument processor that:
- Iterates through a list of value specifications
- Handles different value types appropriately
- Enforces limits to prevent buffer overflows
- Provides detailed error reporting

### Timestamp Handling

Multiple timestamp formats are supported:
- Standard timestamp format
- Legacy timestamp format
- Forward v1 timestamp format
- Fluent Bit v1/v2 timestamp formats

Each format has specific serialization requirements to maintain compatibility.

### Memory Management

The implementation carefully manages memory allocation:
- Uses MessagePack's internal buffer management
- Properly handles buffer resizing as needed
- Ensures no memory leaks during encoding operations

## Usage Examples

### Basic Value Encoding

```c
struct flb_log_event_encoder *encoder = flb_log_event_encoder_create(FLB_LOG_EVENT_FORMAT_DEFAULT);

// Encode a simple string value
flb_log_event_encoder_append_string(encoder, FLB_LOG_EVENT_BODY, "message", 7);

// Encode an integer value
flb_log_event_encoder_append_int32(encoder, FLB_LOG_EVENT_BODY, 42);

// Encode a boolean value
flb_log_event_encoder_append_boolean(encoder, FLB_LOG_EVENT_BODY, 1);
```

### Complex Data Structure Building

```c
struct flb_log_event_encoder *encoder = flb_log_event_encoder_create(FLB_LOG_EVENT_FORMAT_DEFAULT);

// Begin a map in the body
flb_log_event_encoder_begin_map(encoder, FLB_LOG_EVENT_BODY);

// Add key-value pairs
flb_log_event_encoder_append_string(encoder, FLB_LOG_EVENT_BODY, "key1", 4);
    flb_log_event_encoder_append_string(encoder, FLB_LOG_EVENT_BODY, "value1", 6);

flb_log_event_encoder_append_string(encoder, FLB_LOG_EVENT_BODY, "key2", 4);
    flb_log_event_encoder_append_int32(encoder, FLB_LOG_EVENT_BODY, 123);

// Commit the map
flb_log_event_encoder_commit_map(encoder, FLB_LOG_EVENT_BODY);
```

### Variable Argument Approach

```c
struct flb_log_event_encoder *encoder = flb_log_event_encoder_create(FLB_LOG_EVENT_FORMAT_DEFAULT);

// Use the convenience macro for multiple values
flb_log_event_encoder_append_body_values(
    encoder,
    FLB_LOG_EVENT_STRING_VALUE("message", 7),
    FLB_LOG_EVENT_STRING_VALUE("Hello World", 11),
    FLB_LOG_EVENT_INT32_VALUE(42),
    FLB_LOG_EVENT_BOOLEAN_VALUE(1)
);
```

### Error Handling

```c
struct flb_log_event_encoder *encoder = flb_log_event_encoder_create(FLB_LOG_EVENT_FORMAT_DEFAULT);

int result = flb_log_event_encoder_append_string(encoder, FLB_LOG_EVENT_BODY, "test", 4);

if (result != FLB_EVENT_ENCODER_SUCCESS) {
    const char *error_desc = flb_log_event_encoder_get_error_description(result);
    flb_error("Failed to encode string: %s", error_desc);
    return result;
}
```

## Integration with Fluent Bit Architecture

The primitives encoder forms the foundation of Fluent Bit's log event processing pipeline:

1. **Input Plugins** use these functions to encode raw data into structured log events
2. **Filter Plugins** modify existing log events using the same encoding functions
3. **Output Plugins** receive the encoded log events and can decode them using the corresponding decoder functions
4. **Core Engine** manages the flow of encoded log events between components

This design ensures consistent data representation throughout the Fluent Bit pipeline while maintaining high performance through direct MessagePack integration.