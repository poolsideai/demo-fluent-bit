# flb_cfl_ra_key.c

## Overview

This file implements key-based record accessor functionality for Fluent Bit using the CFL (Common Fluent Library) variant data structures. It provides utilities to access, compare, and manipulate values within complex data structures (maps/arrays) using key paths.

The module handles:
- Key-based value lookup in CFL variant data structures
- String comparison operations on accessed values
- Regular expression matching on accessed values
- Value update and append operations
- Sub-key navigation for nested data structures

## Key Functions

### `flb_cfl_ra_key_to_value()`
Converts a CFL variant value to a record accessor value format based on a key and optional subkeys.

### `flb_cfl_ra_key_value_get()`
Retrieves a key-value pair from a CFL variant data structure, supporting nested lookups via subkeys.

### `flb_cfl_ra_key_strcmp()`
Compares a string with a value accessed via key path in a CFL variant data structure.

### `flb_cfl_ra_key_regex_match()`
Performs regular expression matching on a value accessed via key path in a CFL variant data structure.

### `flb_cfl_ra_key_value_update()`
Updates a value in a CFL variant data structure at a specified key path.

### `flb_cfl_ra_key_value_append()`
Appends a value to a CFL variant data structure at a specified key path.

## Important Variables/Constants

### Data Structures
- `struct flb_cfl_ra_value`: Record accessor value wrapper for CFL variants
- `struct flb_ra_subentry`: Sub-key entry for navigating nested structures
- `struct cfl_variant`: CFL variant data structure for holding various data types
- `struct cfl_kvlist`: Key-value list for map-like data structures
- `struct cfl_array`: Array data structure for list-like data

### Value Types
- `FLB_CFL_RA_BOOL`: Boolean value type
- `FLB_CFL_RA_INT`: Integer value type
- `FLB_CFL_RA_FLOAT`: Float value type
- `FLB_CFL_RA_STRING`: String value type
- `FLB_CFL_RA_NULL`: Null value type

## Dependencies

- `fluent-bit/flb_info.h`: Fluent Bit core information
- `fluent-bit/flb_log.h`: Logging utilities
- `fluent-bit/flb_sds.h`: String data structure utilities
- `fluent-bit/flb_mem.h`: Memory management utilities
- `fluent-bit/flb_regex.h`: Regular expression utilities
- `fluent-bit/flb_cfl_ra_key.h`: CFL Record Accessor interface headers
- `fluent-bit/record_accessor/flb_ra_parser.h`: Record accessor parser
- `cfl/cfl.h`: CFL core library
- `limits.h`: System limits

## Implementation Details

1. **Variant Mapping**: Converts CFL variants to record accessor values with proper type handling.

2. **Nested Navigation**: Supports complex key paths with subkeys for accessing nested data structures.

3. **Array Handling**: Special handling for array indices using `FLB_RA_PARSER_ARRAY_ID` type.

4. **Memory Management**: Proper allocation and cleanup of intermediate data structures.

5. **Error Handling**: Comprehensive error checking for invalid keys, types, and indices.

6. **Recursive Operations**: Supports recursive traversal of nested data structures for complex lookups.

7. **Type Safety**: Ensures type compatibility during value operations.

## Usage Example

```c
// Create a CFL variant map
struct cfl_kvlist *kvlist = cfl_kvlist_create();
struct cfl_variant *vobj = cfl_variant_create_from_kvlist(kvlist);

// Add some data
cfl_kvlist_insert_string(kvlist, "name", "John");
cfl_kvlist_insert_int(kvlist, "age", 30);

// Access values by key
struct flb_cfl_ra_value *value = flb_cfl_ra_key_to_value("name", *vobj, NULL);
if (value && value->type == FLB_CFL_RA_STRING) {
    printf("Name: %s\n", value->val.string);
}

// Compare string values
if (flb_cfl_ra_key_strcmp("name", *vobj, NULL, "John", 4) == 0) {
    printf("Name matches\n");
}

// Clean up
cfl_variant_destroy(vobj);
```