# flb_cfl_record_accessor.c

## Overview

This file implements a record accessor system for Fluent Bit using the CFL (Common Fluent Library) variant data structures. It provides a flexible way to access, manipulate, and transform data within complex nested structures using key paths and pattern matching.

The module handles:
- Record accessor pattern parsing and compilation
- Key-based value lookup in nested data structures
- String translation with environment variable substitution
- Regular expression capture integration
- Tag manipulation and extraction
- JSON serialization of CFL variants
- Value comparison and matching operations
- Key-value pair update and append operations

## Key Functions

### `flb_cfl_ra_create()`
Creates a new record accessor context from a pattern string, optionally translating environment variables.

### `flb_cfl_ra_create_from_list()`
Creates a record accessor from a string list, converting it to the appropriate accessor pattern.

### `flb_cfl_ra_destroy()`
Destroys a record accessor context, freeing all allocated memory.

### `flb_cfl_ra_translate()`
Translates a record accessor pattern into a concrete string value using provided data (tag, variant, regex results).

### `flb_cfl_ra_translate_check()`
Translates a record accessor pattern with validation - returns NULL if any key lookup fails.

### `flb_cfl_ra_is_static()`
Checks if a record accessor pattern generates static content (no dynamic key lookups).

### `flb_cfl_ra_strcmp()`
Compares a string with a value accessed via record accessor pattern.

### `flb_cfl_ra_regex_match()`
Performs regular expression matching on a value accessed via record accessor pattern.

### `flb_cfl_ra_update_kv_pair()`
Updates a key-value pair in a CFL variant using a record accessor pattern.

### `flb_cfl_ra_append_kv_pair()`
Appends a new key-value pair to a CFL variant using a record accessor pattern.

## Important Variables/Constants

### Data Structures
- `struct flb_cfl_record_accessor`: Main record accessor context
- `struct flb_ra_parser`: Parser context for individual accessor components
- `struct cfl_variant`: CFL variant data structure for holding various data types
- `struct flb_regex_search`: Regex search results for capture group access

### Accessor Patterns
- `$key`: Simple key lookup
- `$key['subkey']`: Nested key lookup
- `$key['array'][N]`: Array index access
- `$0,$1..$9`: Regex capture group access
- `$TAG`: Full tag access
- `$TAG[N]`: Specific tag part access
- `${ENV_VAR}`: Environment variable substitution

### Parser Types
- `FLB_RA_PARSER_STRING`: Static string component
- `FLB_RA_PARSER_KEYMAP`: Key-based value lookup
- `FLB_RA_PARSER_REGEX_ID`: Regex capture group reference
- `FLB_RA_PARSER_TAG`: Full tag reference
- `FLB_RA_PARSER_TAG_PART`: Specific tag part reference

## Dependencies

- `fluent-bit/flb_info.h`: Fluent Bit core information
- `fluent-bit/flb_mem.h`: Memory management utilities
- `fluent-bit/flb_env.h`: Environment variable utilities
- `fluent-bit/flb_log.h`: Logging utilities
- `fluent-bit/flb_pack.h`: Data packing utilities
- `fluent-bit/flb_sds.h`: String data structure utilities
- `fluent-bit/flb_sds_list.h`: String list utilities
- `fluent-bit/flb_cfl_record_accessor.h`: CFL Record Accessor interface headers
- `fluent-bit/flb_cfl_ra_key.h`: CFL Record Accessor key utilities
- `fluent-bit/record_accessor/flb_ra_parser.h`: Record accessor parser
- `monkey/mk_core.h`: Monkey core utilities
- `ctype.h`: Character type utilities

## Implementation Details

1. **Pattern Parsing**: Complex parsing logic to handle various accessor patterns including nested keys, arrays, and special tokens.

2. **Environment Translation**: Optional environment variable substitution during pattern creation.

3. **Memory Management**: Efficient buffer management with size hints for optimal performance.

4. **JSON Serialization**: Built-in JSON conversion for CFL variants to string representation.

5. **Error Handling**: Comprehensive error checking and validation throughout the translation process.

6. **Thread Safety**: Designed to be thread-safe for concurrent accessor operations.

7. **Recursive Navigation**: Supports deep navigation of nested data structures through subkey chains.

8. **Type Coercion**: Automatic type conversion during value retrieval and comparison operations.

## Usage Example

```c
// Create a record accessor for accessing nested data
struct flb_cfl_record_accessor *accessor = flb_cfl_ra_create("$user['profile']['name']", FLB_TRUE);

// Create a CFL variant with sample data
struct cfl_kvlist *kvlist = cfl_kvlist_create();
struct cfl_kvlist *profile = cfl_kvlist_create();
cfl_kvlist_insert_string(profile, "name", "John Doe");
cfl_kvlist_insert_int(profile, "age", 30);
cfl_kvlist_insert_kvlist(kvlist, "profile", profile);
struct cfl_variant var = *cfl_variant_create_from_kvlist(kvlist);

// Translate the accessor to get the actual value
char *tag = "application.log";
struct flb_regex_search *regex_result = NULL; // No regex in this example

char *result = flb_cfl_ra_translate(accessor, tag, strlen(tag), var, regex_result);
if (result) {
    printf("Translated value: %s\n", result);
    flb_sds_destroy(result); // Clean up the translated string
}

// Check if accessor is static (no dynamic lookups)
if (flb_cfl_ra_is_static(accessor)) {
    printf("Accessor is static\n");
}

// Clean up
flb_cfl_ra_destroy(accessor);
cfl_variant_destroy(&var);
```