# flb_ra_key.c - Record Accessor Key Operations

## Overview

This file implements key operations for Fluent Bit's Record Accessor system, which provides a flexible way to access and manipulate fields within structured data (typically MessagePack records). The Record Accessor system allows for complex field references including nested structures, array indexing, and conditional access.

The system supports various data types and provides functions for retrieving, comparing, updating, and appending values within structured records.

## Key Components

### Record Accessor Value (`struct flb_ra_value`)
Represents a value extracted from a structured record:
- `type`: Data type (boolean, integer, float, string, null, binary)
- `storage`: Storage method (copy or reference)
- `o`: Original MessagePack object
- `val`: Union containing the actual value based on type

### Value Types
- `FLB_RA_BOOL`: Boolean values
- `FLB_RA_INT`: Integer values (64-bit)
- `FLB_RA_FLOAT`: Floating-point values (64-bit)
- `FLB_RA_STRING`: String values
- `FLB_RA_NULL`: Null values
- `FLB_RA_BINARY`: Binary data values

### Storage Types
- `FLB_RA_COPY`: Value is copied and owned by the accessor
- `FLB_RA_REF`: Value is referenced (no copy made)

## Key Functions

### `flb_ra_key_to_value_ext(flb_sds_t ckey, msgpack_object map, struct mk_list *subkeys, int copy)`
Converts a key reference to a Record Accessor value:
- Searches for the specified key in the MessagePack map
- Handles nested field access through subkeys
- Supports both copy and reference storage modes
- Returns a populated `flb_ra_value` structure or NULL on failure

### `flb_ra_key_to_value(flb_sds_t ckey, msgpack_object map, struct mk_list *subkeys)`
Convenience wrapper for `flb_ra_key_to_value_ext` with copy mode enabled.

### `flb_ra_key_value_destroy(struct flb_ra_value *v)`
Destroys a Record Accessor value:
- Frees any allocated memory for copied strings or binary data
- Frees the value structure itself

### `flb_ra_key_value_get(flb_sds_t ckey, msgpack_object map, struct mk_list *subkeys, msgpack_object **start_key, msgpack_object **out_key, msgpack_object **out_val)`
Retrieves key-value pairs from a structured record:
- Finds the specified key in the MessagePack map
- Handles nested field access through subkeys
- Populates output parameters with key and value references
- Returns 0 on success, -1 on failure

### `flb_ra_key_strcmp(flb_sds_t ckey, msgpack_object map, struct mk_list *subkeys, char *str, int len)`
Compares a field value with a string:
- Extracts the specified field value
- Compares it with the provided string
- Returns comparison result (0 for match, non-zero otherwise)

### `flb_ra_key_regex_match(flb_sds_t ckey, msgpack_object map, struct mk_list *subkeys, struct flb_regex *regex, struct flb_regex_search *result)`
Performs regex matching on a field value:
- Extracts the specified field value
- Applies the provided regex pattern
- Optionally captures groups and populates search results
- Returns match result

### `flb_ra_key_value_update(struct flb_ra_parser *rp, msgpack_object obj, msgpack_object *in_key, msgpack_object *in_val, msgpack_packer *mp_pck)`
Updates a field value in a structured record:
- Uses a Record Accessor parser to locate the target field
- Replaces the existing value with the provided new value
- Packs the updated record using the provided MessagePack packer
- Handles nested field updates through subkeys

### `flb_ra_key_value_append(struct flb_ra_parser *rp, msgpack_object obj, msgpack_object *in_val, msgpack_packer *mp_pck)`
Appends a new field to a structured record:
- Uses a Record Accessor parser to determine where to append
- Adds the new field value to the record
- Packs the updated record using the provided MessagePack packer
- Handles array and map appending operations

## Data Type Handling

The system supports conversion between MessagePack object types and Record Accessor value types:

- **Boolean**: Direct mapping from `MSGPACK_OBJECT_BOOLEAN`
- **Integer**: Mapping from `MSGPACK_OBJECT_POSITIVE_INTEGER` and `MSGPACK_OBJECT_NEGATIVE_INTEGER`
- **Float**: Mapping from `MSGPACK_OBJECT_FLOAT32` and `MSGPACK_OBJECT_FLOAT`
- **String**: Mapping from `MSGPACK_OBJECT_STR` with copy/reference options
- **Map**: Special handling - returns boolean true to indicate existence
- **Binary**: Mapping from `MSGPACK_OBJECT_BIN` with copy/reference options
- **Null**: Mapping from `MSGPACK_OBJECT_NIL`

## Nested Field Access

The system supports accessing nested fields through a subkeys mechanism:

- **Map Navigation**: Access nested map fields using dot notation (e.g., `user.name`)
- **Array Indexing**: Access array elements using bracket notation (e.g., `items[0]`)
- **Complex Paths**: Combine map and array access for complex nested structures

Example path resolution:
```c
// For path "user.addresses[1].street"
// 1. Access "user" field in root map
// 2. Access "addresses" field in user map
// 3. Access index 1 in addresses array
// 4. Access "street" field in that address map
```

## Memory Management

The system provides flexible memory management through storage types:

- **Copy Mode**: Values are copied into new memory, ensuring independence from original data
- **Reference Mode**: Values reference the original data, avoiding unnecessary copying but requiring careful lifetime management

## Dependencies

- `<fluent-bit/flb_info.h>` - Core information headers
- `<fluent-bit/flb_log.h>` - Logging utilities
- `<fluent-bit/flb_sds.h>` - String data structure utilities
- `<fluent-bit/flb_mem.h>` - Memory management utilities
- `<fluent-bit/flb_regex.h>` - Regular expression utilities
- `<fluent-bit/flb_ra_key.h>` - Public interface header
- `<fluent-bit/record_accessor/flb_ra_parser.h>` - Record accessor parser utilities
- `<msgpack.h>` - MessagePack library
- `<limits.h>` - System limits
- `<monkey/mk_core.h>` - Monkey core utilities
- `<string.h>` - String utilities

## Notable Implementation Details

1. **Efficient Key Lookup**: Uses reverse iteration for faster key matching in maps

2. **Type Safety**: Comprehensive type checking and validation throughout operations

3. **Memory Optimization**: Supports both copy and reference modes for efficient memory usage

4. **Nested Structure Support**: Handles complex nested maps and arrays with proper indexing

5. **Error Handling**: Detailed error reporting with appropriate return codes

6. **Regex Integration**: Seamless integration with Fluent Bit's regex system for pattern matching

7. **Pack/Unpack Operations**: Efficient MessagePack serialization/deserialization

## Usage Examples

### Extracting a Field Value
```c
// Assume we have a MessagePack map representing a record
msgpack_object record_map;

// Extract a simple field value
struct flb_ra_value *value = flb_ra_key_to_value("status", record_map, NULL);

if (value != NULL) {
    // Access the value based on its type
    switch (value->type) {
        case FLB_RA_STRING:
            printf("Status: %s\n", value->val.string);
            break;
        case FLB_RA_INT:
            printf("Status code: %ld\n", (long)value->val.i64);
            break;
    }
    
    // Clean up
    flb_ra_key_value_destroy(value);
}
```

### Updating a Nested Field
```c
// Assume we have a Record Accessor parser and MessagePack packer
struct flb_ra_parser *parser; // Pre-configured parser for "user.name"
msgpack_packer *mp_pck;      // MessagePack packer
msgpack_object record_map;    // Original record map

// New value to set
msgpack_object new_value;
new_value.type = MSGPACK_OBJECT_STR;
new_value.via.str.ptr = "John Doe";
new_value.via.str.size = 8;

// Update the field
if (flb_ra_key_value_update(parser, record_map, NULL, &new_value, mp_pck) == 0) {
    // Successfully updated - mp_pck now contains the updated record
}
```

### String Comparison
```c
// Check if a field equals a specific string
if (flb_ra_key_strcmp("environment", record_map, NULL, "production", 11) == 0) {
    printf("Running in production environment\n");
}
```

### Regex Matching
```c
// Check if an email field matches a pattern
struct flb_regex *email_regex = flb_regex_create("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");

if (flb_ra_key_regex_match("email", record_map, NULL, email_regex, NULL) == 1) {
    printf("Valid email address\n");
} else {
    printf("Invalid email address\n");
}

flb_regex_destroy(email_regex);
```