# flb_sp_key.c

## Overview

This file implements key handling functionality for the Fluent Bit Stream Processor. It provides utilities for converting MessagePack objects to internal value representations, looking up keys in records, and managing key-value pairs during stream processing operations.

## Key Functions

### `flb_sp_key_to_value`

The primary function for converting a key name and optional subkeys into a structured value representation. This function handles complex nested key lookups in MessagePack objects.

### `flb_sp_key_value_print`

Utility function for printing the value of a key in a human-readable format, supporting all data types.

### `flb_sp_key_value_destroy`

Properly cleans up memory allocated for a key value structure, including string data that requires special handling.

### `msgpack_object_to_sp_value`

Converts a MessagePack object to the internal `flb_sp_value` representation, handling all supported data types.

### `subkey_to_value`

Handles lookup of nested keys within complex MessagePack maps, supporting multi-level key navigation.

## Important Variables and Constants

- `FLB_EXP_BOOL`: Boolean expression type
- `FLB_EXP_INT`: Integer expression type
- `FLB_EXP_FLOAT`: Float expression type
- `FLB_EXP_STRING`: String expression type
- `FLB_EXP_NULL`: Null expression type

## Dependencies

This file depends on:
- `<fluent-bit/flb_info.h>`: Core Fluent Bit information
- `<fluent-bit/flb_log.h>`: Logging utilities
- `<fluent-bit/flb_sds.h>`: String data structure utilities
- `<fluent-bit/flb_mem.h>`: Memory management utilities
- `<fluent-bit/flb_slist.h>`: Simple linked list utilities
- `<fluent-bit/stream_processor/flb_sp.h>`: Stream processor core definitions
- `<fluent-bit/stream_processor/flb_sp_parser.h>`: Stream processor parser definitions

## Implementation Details

### Key Lookup Mechanism

The implementation supports complex key lookups with the following features:

1. **Nested Key Support**: Handles dot notation and bracket notation for accessing nested values in complex objects.

2. **Type Conversion**: Automatically converts MessagePack objects to appropriate internal representations:
   - Booleans: Direct mapping
   - Integers: 64-bit signed integers
   - Floats: 64-bit double precision
   - Strings: SDS (Simple Dynamic String) allocation
   - Maps: Boolean representation indicating key existence
   - Nil: Special null representation

3. **Memory Management**: Proper allocation and deallocation of SDS strings and other dynamic structures.

4. **Error Handling**: Graceful handling of missing keys and invalid data types with appropriate error returns.

### Data Structure Navigation

The `subkey_to_value` function implements a sophisticated navigation mechanism for complex nested structures:
- Iterates through subkey lists to navigate deep into nested maps
- Validates data types at each level
- Handles string comparisons for key matching
- Supports partial navigation with proper cleanup on failure

## Usage Examples

Key lookup is used internally by the stream processor during query execution:
```sql
SELECT record.key1.subkey AS alias FROM STREAM:input_stream;
```

The key handling functions automatically resolve `record.key1.subkey` to the appropriate nested value in the input records.