# flb_uri.c

## Overview

The `flb_uri.c` file provides URI (Uniform Resource Identifier) parsing and encoding functionality for Fluent Bit. This module handles URI manipulation, including splitting URI paths into components and encoding special characters according to RFC standards.

## Key Functions

### `flb_uri_encode`

```c
flb_sds_t flb_uri_encode(const char *uri, size_t len)
```

Performs URI encoding for the given string. This function encodes special characters according to RFC 3986 standards, converting them to percent-encoded format (e.g., space becomes `%20`).

- **Parameters**: 
  - `uri`: Pointer to the URI string to encode
  - `len`: Length of the URI string
- **Returns**: A new SDS buffer containing the encoded URI, or NULL on failure
- **Notes**: Always allocates a new buffer; caller is responsible for freeing the returned buffer

### `flb_uri_get`

```c
struct flb_uri_field *flb_uri_get(struct flb_uri *uri, int pos)
```

Retrieves a specific field from the URI structure based on its position.

- **Parameters**: 
  - `uri`: Pointer to the URI context
  - `pos`: Position index of the field to retrieve
- **Returns**: Pointer to the URI field at the specified position, or NULL if invalid

### `flb_uri_create`

```c
struct flb_uri *flb_uri_create(const char *full_uri)
```

Creates a URI context by parsing a full URI string and splitting it into components.

- **Parameters**: 
  - `full_uri`: The complete URI string to parse
- **Returns**: Pointer to a newly allocated URI context, or NULL on failure
- **Notes**: Splits the URI by '/' characters and creates a map for O(1) lookup by position

### `flb_uri_destroy`

```c
void flb_uri_destroy(struct flb_uri *uri)
```

Destroys a URI context and frees all associated resources.

- **Parameters**: 
  - `uri`: Pointer to the URI context to destroy

### `flb_uri_dump`

```c
void flb_uri_dump(struct flb_uri *uri)
```

Dumps the contents of a URI context to stdout for debugging purposes.

- **Parameters**: 
  - `uri`: Pointer to the URI context to dump

## Data Structures

### `flb_uri_field`

Represents a single component of a URI path.

```c
struct flb_uri_field {
    size_t length;               /* Length of the field value */
    char *value;                 /* Field value string */
    struct mk_list _head;        /* Linked list node */
};
```

### `flb_uri`

Main URI context structure that holds parsed URI information.

```c
struct flb_uri {
    char *full;                    /* Original full URI */
    uint8_t count;                 /* Number of entries in the list */
    struct mk_list list;           /* List head for uri patterns */
    struct flb_uri_field *map;     /* Map for O(1) lookup by position */
};
```

## Constants

### `FLB_URI_MAX`

Defines the maximum number of URI patterns allowed in the map (default: 8).

## Dependencies

- `<stdlib.h>`: Standard library functions
- `<monkey/mk_core.h>`: Monkey HTTP server core utilities
- `<fluent-bit/flb_info.h>`: Fluent Bit core information
- `<fluent-bit/flb_mem.h>`: Fluent Bit memory management
- `<fluent-bit/flb_str.h>`: Fluent Bit string utilities
- `<fluent-bit/flb_uri.h>`: URI header definitions
- `<fluent-bit/flb_utils.h>`: Fluent Bit utility functions

## Implementation Details

1. **URI Encoding Algorithm**: Implements RFC 3986 compliant URI encoding, escaping characters that are not alphanumeric or part of the allowed set (`?`, `&`, `-`, `_`, `.`, `~`, `/`, `=`)

2. **URI Parsing**: Splits URI strings by '/' characters and stores components in both a linked list (for sequential access) and an array map (for O(1) positional access)

3. **Memory Management**: Uses Fluent Bit's custom memory allocation functions (`flb_calloc`, `flb_strdup`, `flb_free`) for consistent memory handling

## Usage Examples

### Creating and using a URI context

```c
// Parse a URI
struct flb_uri *uri = flb_uri_create("/api/v1/users/123");

// Access specific components
struct flb_uri_field *component = flb_uri_get(uri, 2);  // Gets "users"
if (component) {
    printf("Component: %.*s\n", component->length, component->value);
}

// Encode a URI string
flb_sds_t encoded = flb_uri_encode("hello world", 11);
if (encoded) {
    printf("Encoded: %s\n", encoded);  // Outputs: hello%20world
    flb_sds_destroy(encoded);
}

// Cleanup
flb_uri_destroy(uri);
```