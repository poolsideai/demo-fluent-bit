# flb_opentelemetry_utils.c

## Overview

This file implements utility functions for processing OpenTelemetry Protocol (OTLP) data in Fluent Bit. It provides helper functions for converting between different data representations, finding map entries, and handling the complex nested structures used in OTLP JSON formats. These utilities are used by both the logs and traces processing modules to simplify common operations.

## Key Functions

### `flb_otel_utils_find_map_entry_by_key`

Finds a map entry by key name in a MessagePack object map.

**Parameters:**
- `map`: MessagePack object map to search
- `key`: Key name to find
- `match_index`: Index of matching entry if multiple entries match
- `case_insensitive`: Whether to perform case-insensitive matching

**Returns:**
- Index of the found entry on success
- -1 if not found

### `flb_otel_utils_json_payload_get_wrapped_value`

Extracts the actual value from an OTLP JSON-wrapped value structure.

**Parameters:**
- `wrapper`: MessagePack object containing the wrapped value
- `value`: Output parameter for the extracted value
- `type`: Output parameter for the value type

**Returns:**
- 0 on success
- Negative value on failure

### `flb_otel_utils_json_payload_append_converted_value`

Appends a converted MessagePack value to a log event encoder.

### `flb_otel_utils_json_payload_append_converted_map`

Appends a converted MessagePack map to a log event encoder.

### `flb_otel_utils_json_payload_append_converted_array`

Appends a converted MessagePack array to a log event encoder.

### `flb_otel_utils_json_payload_append_converted_kvlist`

Appends a converted key-value list to a log event encoder.

### `flb_otel_utils_hex_to_id`

Converts a hexadecimal string to binary ID format.

### `flb_otel_utils_convert_string_number_to_u64`

Converts a string representation of a number to uint64_t.

## Important Variables/Constants

- None specific to this module

## Dependencies

- `flb_log_event_encoder.h`: Log event encoding utilities
- `flb_pack.h`: Data packing utilities
- `flb_sds.h`: Simple Dynamic Strings
- `flb_opentelemetry.h`: OpenTelemetry core functionality
- `flb_log.h`: Logging utilities
- `flb_time.h`: Time utilities

## Implementation Details

### Data Structure Conversion

The module handles the complex nested structures used in OTLP JSON:

1. **Value Wrapping**: OTLP wraps primitive values in maps with type-specific keys (e.g., `stringValue`, `intValue`)
2. **Key-Value Lists**: Attributes are represented as arrays of maps with `key` and `value` entries
3. **Nested Structures**: Supports nested arrays and maps within the OTLP structure

### Map Entry Finding

Provides efficient searching of MessagePack maps with features:

- **Case Sensitivity Options**: Supports both case-sensitive and case-insensitive matching
- **Multiple Match Handling**: Can find specific instances when multiple entries match
- **Type Safety**: Validates that found entries are of the expected type

### ID Processing

Handles the conversion of hexadecimal trace and span identifiers:

- **Hexadecimal Validation**: Ensures input strings contain only valid hex characters
- **Binary Conversion**: Converts hex strings to compact binary representations
- **Length Validation**: Verifies correct ID lengths (16 bytes for trace IDs, 8 bytes for span IDs)

### Number Conversion

Provides safe conversion of string numbers to numeric types:

- **Digit Validation**: Ensures all characters are digits before conversion
- **Buffer Management**: Uses safe temporary buffers to avoid overflow
- **Type Preservation**: Maintains the appropriate numeric type during conversion

### Memory Management

Efficient memory handling through:

- **Stack Allocation**: Uses stack buffers where possible for small operations
- **Error Handling**: Proper cleanup on conversion failures
- **Resource Safety**: Validates inputs before processing to prevent memory issues

## Usage

These utility functions are used internally by the OpenTelemetry logs and traces processing modules:

```c
// Find a map entry by key
int index = flb_otel_utils_find_map_entry_by_key(map, "traceId", 0, FLB_TRUE);
if (index >= 0) {
    // Process the found entry
    msgpack_object *found_entry = &map->ptr[index].val;
}

// Convert hex ID to binary
unsigned char trace_id_bin[16];
if (flb_otel_utils_hex_to_id(hex_trace_id, 32, trace_id_bin, 16) == 0) {
    // Successfully converted hex to binary ID
}

// Extract wrapped value from OTLP structure
msgpack_object *value;
int type;
if (flb_otel_utils_json_payload_get_wrapped_value(wrapper, &value, &type) == 0) {
    // Successfully extracted the wrapped value
}
```

The utilities are particularly important for handling the complexity of OTLP JSON structures, which use nested maps and arrays to represent typed values and key-value lists.