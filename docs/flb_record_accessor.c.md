# flb_record_accessor.c

## Overview

The `flb_record_accessor.c` file implements the Record Accessor functionality in Fluent Bit. This component provides a mechanism to access and manipulate data within records (MessagePack objects) using a flexible syntax that supports various data access patterns.

The Record Accessor allows users to reference specific fields in records using a syntax that includes:
- Record keys (`$key`, `$key['x']`, `$key['x'][N]['z']`)  
- Regex capture groups (`$0`, `$1`, ..., `$9`)  
- Tag information (`$TAG`, `$TAG[n]`)  
- Environment variables (`${X}`)

This functionality is essential for plugins that need to dynamically access record data based on configuration.

## Key Functions/Components

### Core Data Structures

#### `struct flb_record_accessor`
The main context structure that holds the parsed record accessor pattern:
- `size_hint`: Estimated size for output buffer allocation
- `pattern`: Original pattern string
- `list`: Linked list of parsed components (strings, keys, etc.)
- `_head`: Internal linking for memory management

#### `struct flb_ra_parser`
Represents individual components of a parsed record accessor pattern:
- `type`: Component type (string, keymap, regex_id, tag, etc.)
- `id`: Identifier for regex/tag components
- `key`: Key information for record access
- `slist`: Subkey parsing list
- `_head`: Linking to parent record accessor

### Main Functions

#### `flb_ra_create(char *str, int translate_env)`
Creates a new record accessor context from a pattern string. If `translate_env` is set, environment variables in the pattern will be expanded.

#### `flb_ra_destroy(struct flb_record_accessor *ra)`
Destroys a record accessor context and frees all associated resources.

#### `flb_ra_translate(...)`
Translates a record accessor pattern into actual values by resolving references against a record map, tag, and regex results. Returns a new string that must be freed by the caller.

#### `flb_ra_translate_check(...)`
Similar to `flb_ra_translate()` but with an additional check parameter that causes the function to return NULL if any key lookup fails.

#### `flb_ra_is_static(struct flb_record_accessor *ra)`
Checks if a record accessor pattern is static (doesn't depend on record data) or dynamic.

#### `flb_ra_strcmp(...)`
Compares a string value against the result of evaluating a record accessor against a record map.

#### `flb_ra_regex_match(...)`
Checks if a regular expression matches against the value obtained from evaluating a record accessor.

#### `flb_ra_get_kv_pair(...)`
Retrieves the key-value pair referenced by the record accessor from a record map.

#### `flb_ra_get_value_object(...)`
Returns the value object referenced by the record accessor from a record map.

#### `flb_ra_update_kv_pair(...)`
Updates a key-value pair in a record map based on the record accessor pattern.

#### `flb_ra_append_kv_pair(...)`
Adds a new key-value pair to a record map based on the record accessor pattern.

#### `flb_ra_create_str_from_list(...)`
Creates a record accessor string from a list of string components.

#### `flb_ra_create_from_list(...)`
Creates a record accessor from a list of string components.

## Important Variables/Constants

### Parser Types
- `FLB_RA_PARSER_STRING`: Fixed string literal
- `FLB_RA_PARSER_KEYMAP`: Record map key reference
- `FLB_RA_PARSER_ARRAY_ID`: Array index reference
- `FLB_RA_PARSER_FUNC`: Built-in function reference
- `FLB_RA_PARSER_REGEX_ID`: Regex capture group reference
- `FLB_RA_PARSER_TAG`: Full tag reference
- `FLB_RA_PARSER_TAG_PART`: Specific part of tag reference

### Storage Types
- `FLB_RA_COPY`: Value is copied
- `FLB_RA_REF`: Value is referenced (no copy)

### Value Types
- `FLB_RA_BOOL`: Boolean value
- `FLB_RA_INT`: Integer value
- `FLB_RA_FLOAT`: Floating point value
- `FLB_RA_STRING`: String value
- `FLB_RA_NULL`: Null value
- `FLB_RA_BINARY`: Binary data

## Dependencies and Relationships

This module depends on several core Fluent Bit components:
- `flb_sds`: String data structure for efficient string handling
- `flb_regex`: Regular expression support for pattern matching
- `flb_ra_key`: Key parsing and value extraction functionality
- `flb_ra_parser`: Parser components for different pattern types
- `msgpack`: MessagePack serialization library for record handling
- `mk_core`: Monkey Core utilities for linked lists and memory management

It's used extensively by:
- Filter plugins that need to reference record fields
- Output plugins that need to extract specific data
- Router conditions that evaluate record content

## Implementation Details

The record accessor implementation follows these key principles:

1. **Pattern Parsing**: The input pattern string is parsed into a linked list of components, each representing a part of the pattern (literal strings, key references, regex captures, etc.).

2. **Lazy Evaluation**: Values are resolved at translation time rather than parse time, allowing for dynamic data access.

3. **Memory Management**: Uses Fluent Bit's SDS (String Data Structure) for efficient string handling and proper memory management.

4. **Type Safety**: Maintains type information for values to ensure proper conversion and comparison operations.

5. **Extensibility**: Designed to support additional pattern types through the parser architecture.

The implementation handles nested key access (e.g., `$key['x'][N]['z']`) by maintaining subkey information and traversing MessagePack objects recursively.

## Usage Examples

### Creating a Record Accessor
```c
// Create a record accessor for a simple key
struct flb_record_accessor *ra = flb_ra_create("$message", FLB_FALSE);

// Create a record accessor with environment variable expansion
struct flb_record_accessor *ra = flb_ra_create("${HOSTNAME}", FLB_TRUE);

// Create a record accessor for nested keys
struct flb_record_accessor *ra = flb_ra_create("$record['field']['subfield']", FLB_FALSE);
```

### Translating a Record Accessor
```c
// Translate against a record map
flb_sds_t result = flb_ra_translate(ra, tag, tag_len, record_map, regex_result);

// Check if translation was successful
if (result) {
    // Use the translated value
    printf("Translated value: %s\n", result);
    
    // Don't forget to free the result
    flb_sds_destroy(result);
}
```

### Checking Record Values
```c
// Compare a string against record value
int match = flb_ra_strcmp(ra, record_map, "expected_value", 14);

// Match against a regex pattern
struct flb_regex *regex = flb_regex_create("^[0-9]+$");
struct flb_regex_search *result = flb_regex_create_search();
int matched = flb_ra_regex_match(ra, record_map, regex, result);
```

### Updating Records
```c
// Update a key-value pair in a record
void *new_map;
size_t new_size;
msgpack_object new_key = /* ... */;
msgpack_object new_val = /* ... */;

int ret = flb_ra_update_kv_pair(ra, old_map, &new_map, &new_size, &new_key, &new_val);
```