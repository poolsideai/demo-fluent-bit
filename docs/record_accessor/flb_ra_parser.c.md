# flb_ra_parser.c Documentation

## Overview

This file implements the Record Accessor Parser functionality for Fluent Bit. It provides functions to parse and manage record accessor expressions, which are used to extract data from structured records in various formats.

## Key Functions

### flb_ra_parser_subkey_count()
Returns the count of subkeys in a record accessor parser context.

### flb_ra_parser_dump()
Dumps debug information about a record accessor parser for troubleshooting purposes.

### flb_ra_parser_subentry_add_string()
Adds a string subentry to a record accessor parser context.

### flb_ra_parser_subentry_add_array_id()
Adds an array identifier subentry to a record accessor parser context.

### flb_ra_parser_key_add()
Creates and adds a new key to the record accessor parser context.

### flb_ra_parser_array_add()
Creates and adds a new array reference to the record accessor parser context.

### flb_ra_parser_string_add()
Creates and adds a string value to the record accessor parser context.

### flb_ra_parser_string_create()
Creates a new record accessor parser context initialized with a string value.

### flb_ra_parser_regex_id_create()
Creates a new record accessor parser context initialized with a regex capture group identifier.

### flb_ra_parser_tag_create()
Creates a new record accessor parser context for accessing the record tag.

### flb_ra_parser_tag_part_create()
Creates a new record accessor parser context for accessing a specific part of the record tag.

### flb_ra_parser_meta_create()
Creates a new record accessor parser context by parsing a meta expression using Flex/Bison parsers.

### flb_ra_parser_destroy()
Destroys a record accessor parser context, freeing all associated memory.

## Important Variables/Constants

### FLB_RA_PARSER_STRING
Constant representing a string parser type.

### FLB_RA_PARSER_REGEX_ID
Constant representing a regex capture group identifier parser type.

### FLB_RA_PARSER_TAG
Constant representing a tag parser type.

### FLB_RA_PARSER_TAG_PART
Constant representing a tag part parser type.

### FLB_RA_PARSER_KEYMAP
Constant representing a keymap parser type.

### FLB_RA_PARSER_ARRAY_ID
Constant representing an array identifier parser type.

## Dependencies

- `<fluent-bit/flb_info.h>` - Core Fluent Bit information
- `<fluent-bit/flb_slist.h>` - Simple linked list implementation
- `<fluent-bit/flb_mem.h>` - Memory management utilities
- `<fluent-bit/flb_sds.h>` - Simple Dynamic Strings implementation
- `<fluent-bit/flb_log.h>` - Logging utilities
- `<fluent-bit/record_accessor/flb_ra_parser.h>` - Record accessor parser header
- `ra_parser.h` - Internal parser definitions
- `ra_lex.h` - Lexical analyzer header

## Relationships

This file works closely with:
- `ra.l` - Lexical analyzer definition
- `ra.y` - Parser grammar definition
- Other record accessor components for complete functionality

## Implementation Details

The implementation uses:
1. Flex/Bison for parsing complex record accessor expressions
2. Memory-efficient data structures for storing parsed information
3. Proper error handling and resource cleanup
4. Support for various data access patterns including strings, arrays, tags, and regex captures

## Usage Examples

```c
// Create a parser for a simple string
struct flb_ra_parser *rp = flb_ra_parser_string_create("message", 7);

// Create a parser for a tag part
struct flb_ra_parser *rp = flb_ra_parser_tag_part_create(0);

// Parse a complex expression
struct flb_ra_parser *rp = flb_ra_parser_meta_create("$.key[0]", 8);
```