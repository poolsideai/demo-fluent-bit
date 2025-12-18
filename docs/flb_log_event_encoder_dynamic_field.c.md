# flb_log_event_encoder_dynamic_field.c

## Overview

The `flb_log_event_encoder_dynamic_field.c` file implements a dynamic field construction system for Fluent Bit's log event encoder. It provides functionality to build complex MessagePack structures (maps and arrays) incrementally, supporting nested scopes and efficient memory management. This module is a core component that enables the flexible construction of log event metadata, body content, and root structures.

The dynamic field system allows for:
- Incremental construction of complex data structures
- Nested map and array scopes
- Efficient memory management with automatic cleanup
- Support for rollback operations to abort partial constructions
- Integration with Fluent Bit's MessagePack utilities

## Key Functions

### `flb_log_event_encoder_dynamic_field_init`
Initializes a dynamic field with the specified base type (map or array).

### `flb_log_event_encoder_dynamic_field_destroy`
Destroys a dynamic field and releases all associated resources.

### `flb_log_event_encoder_dynamic_field_reset`
Resets a dynamic field, clearing all accumulated data and scopes.

### `flb_log_event_encoder_dynamic_field_flush`
Finalizes and serializes the dynamic field content.

### `flb_log_event_encoder_dynamic_field_begin_map`
Begins construction of a new map within the dynamic field.

### `flb_log_event_encoder_dynamic_field_begin_array`
Begins construction of a new array within the dynamic field.

### `flb_log_event_encoder_dynamic_field_commit_map`
Commits the current map construction, finalizing its structure.

### `flb_log_event_encoder_dynamic_field_commit_array`
Commits the current array construction, finalizing its structure.

### `flb_log_event_encoder_dynamic_field_rollback_map`
Rolls back the current map construction, discarding it.

### `flb_log_event_encoder_dynamic_field_rollback_array`
Rolls back the current array construction, discarding it.

### `flb_log_event_encoder_dynamic_field_append`
Appends an entry to the current scope (used for tracking map/array elements).

## Data Structures

### `struct flb_log_event_encoder_dynamic_field`
Represents a dynamic field with the following fields:
- `initialized`: Initialization flag
- `entry_count`: Count of entries in the field
- `data_offset`: Offset to the actual data
- `packer`: MessagePack packer instance
- `buffer`: MessagePack string buffer
- `scopes`: List of active scopes
- `data`: Pointer to serialized data
- `size`: Size of serialized data
- `type`: Base type of the field (map or array)

### `struct flb_log_event_encoder_dynamic_field_scope`
Represents a nested scope within a dynamic field:
- `offset`: Buffer offset where scope begins
- `header`: Map header for tracking entries
- `type`: Type of scope (map or array)
- `_head`: List linkage structure

## Dependencies

- `<fluent-bit/flb_log_event_encoder.h>`: Main encoder definitions
- `<fluent-bit/flb_log_event_encoder_dynamic_field.h>`: Header file with declarations
- `<fluent-bit/flb_time.h>`: Time handling functions
- `<fluent-bit/flb_sds.h>`: Simple Dynamic Strings
- `<fluent-bit/flb_mp.h>`: MessagePack utilities
- `<cfl/cfl_list.h>`: CFL list utilities
- `<msgpack.h>`: MessagePack C library
- `<ctype.h>`: Character type utilities

## Implementation Details

### Scope Management
The dynamic field system uses a stack-based approach for managing nested scopes:
- Each `begin_map` or `begin_array` creates a new scope
- Scopes are tracked in a list with the most recent scope at the head
- `commit_*` functions finalize scopes and update their headers
- `rollback_*` functions discard scopes and truncate the buffer

### Memory Management
Efficient memory management is achieved through:
- Reuse of MessagePack buffers
- Automatic cleanup of scopes during reset/destroy
- Proper handling of buffer truncation during rollbacks
- Integration with Fluent Bit's memory allocation system

### Entry Tracking
For map structures, the system tracks entries to ensure proper header construction:
- Each `append` call increments the entry count
- Maps require dividing the entry count by 2 (key-value pairs)
- Arrays use the raw entry count

### Type Safety
The implementation enforces type safety by:
- Validating scope types during entry
- Ensuring proper nesting of map/array constructions
- Checking for valid scope transitions

## Usage Examples

### Basic Map Construction
```c
struct flb_log_event_encoder_dynamic_field field;

// Initialize as a map
flb_log_event_encoder_dynamic_field_init(&field, MSGPACK_OBJECT_MAP);

// Begin constructing the map
flb_log_event_encoder_dynamic_field_begin_map(&field);

// Add key-value pairs (this would typically be done through
// higher-level encoder functions)
// ... add entries ...

// Commit the map
flb_log_event_encoder_dynamic_field_commit_map(&field);

// Flush to get serialized data
flb_log_event_encoder_dynamic_field_flush(&field);

// Access the serialized data
const char *serialized_data = field.data;
size_t data_size = field.size;

// Cleanup
flb_log_event_encoder_dynamic_field_destroy(&field);
```

### Nested Structure Construction
```c
// Start with a root map
flb_log_event_encoder_dynamic_field_begin_map(&field);

// Add a simple key-value pair
// ... add entry ...

// Begin a nested map
flb_log_event_encoder_dynamic_field_begin_map(&field);

// Add nested entries
// ... add entries ...

// Commit the nested map
flb_log_event_encoder_dynamic_field_commit_map(&field);

// Continue with root map entries
// ... add more entries ...

// Commit the root map
flb_log_event_encoder_dynamic_field_commit_map(&field);

// Flush to get the complete serialized structure
flb_log_event_encoder_dynamic_field_flush(&field);
```

### Error Handling and Rollback
```c
// Begin constructing a complex structure
flb_log_event_encoder_dynamic_field_begin_map(&field);

// Add some entries
// ... add entries ...

// If something goes wrong, we can rollback
if (some_error_condition) {
    flb_log_event_encoder_dynamic_field_rollback_map(&field);
    // The field is now reset to its previous state
    return -1;
}

// Otherwise, commit the construction
flb_log_event_encoder_dynamic_field_commit_map(&field);
```

### Integration with Higher-Level Encoders
This module is typically used internally by the main log event encoder:
```c
// In flb_log_event_encoder.c
flb_log_event_encoder_dynamic_field_init(&context->metadata, MSGPACK_OBJECT_MAP);
flb_log_event_encoder_dynamic_field_init(&context->body, MSGPACK_OBJECT_MAP);
flb_log_event_encoder_dynamic_field_init(&context->root, MSGPACK_OBJECT_ARRAY);
```