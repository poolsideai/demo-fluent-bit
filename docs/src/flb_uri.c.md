# flb_uri.c and flb_uri.h Documentation

## Overview

The `flb_uri` module provides URI (Uniform Resource Identifier) handling utilities for Fluent Bit. This implementation includes functions for URI encoding, parsing, and manipulation.

URI handling is essential for web-based protocols and APIs, particularly for HTTP-based outputs and inputs in Fluent Bit. This module provides both encoding capabilities and URI parsing functionality.

## Key Features

- URI encoding for special characters
- URI parsing into component fields
- URI field access by position
- Memory-efficient URI representation
- Debugging utilities for URI inspection

## Data Structures

### struct flb_uri_field

Represents a single field in a parsed URI:

```c
struct flb_uri_field {
    size_t length;      /* Length of the field value */
    char *value;        /* The field value */
    struct mk_list _head; /* Link for the list */
};
```

### struct flb_uri

Main URI context structure:

```c
struct flb_uri {
    char *full;                    /* Original full URI */
    uint8_t count;                 /* Number of entries in the list */
    struct mk_list list;           /* List head for uri patterns    */
    struct flb_uri_field *map;     /* Map / O(1) lookup by position */
};
```

## Constants

### FLB_URI_MAX

Maximum number of URI patterns allowed in a URI:

```c
#define FLB_URI_MAX       8
```

## Key Functions

### flb_uri_create()

```c
struct flb_uri *flb_uri_create(const char *full_uri);
```

Parses a URI string and creates a URI context.

**Parameters:**
- `full_uri`: URI string to parse

**Returns:**
- Pointer to the new URI context on success
- `NULL` on error

### flb_uri_destroy()

```c
void flb_uri_destroy(struct flb_uri *uri);
```

Destroys a URI context and frees associated resources.

**Parameters:**
- `uri`: URI context to destroy

### flb_uri_get()

```c
struct flb_uri_field *flb_uri_get(struct flb_uri *uri, int pos);
```

Retrieves a URI field by position.

**Parameters:**
- `uri`: URI context
- `pos`: Position of the field to retrieve

**Returns:**
- Pointer to the URI field on success
- `NULL` if position is invalid

### flb_uri_encode()

```c
flb_sds_t flb_uri_encode(const char *uri, size_t len);
```

Encodes a URI string, escaping special characters.

**Parameters:**
- `uri`: URI string to encode
- `len`: Length of the URI string

**Returns:**
- SDS string with encoded URI on success
- `NULL` on error

### flb_uri_dump()

```c
void flb_uri_dump(struct flb_uri *uri);
```

Dumps URI field information for debugging purposes.

**Parameters:**
- `uri`: URI context to dump

## Helper Functions

### flb_uri_to_encode()

```c
static inline int flb_uri_to_encode(char c)
```

Determines if a character needs to be encoded in a URI.

**Parameters:**
- `c`: Character to check

**Returns:**
- `FLB_TRUE` if the character needs encoding
- `FLB_FALSE` if the character doesn't need encoding

## Implementation Details

### URI Encoding Rules

The `flb_uri_to_encode` function implements RFC 3986 URI encoding rules:

Characters that do NOT need encoding:
- Alphanumeric characters (0-9, A-Z, a-z)
- Special characters: `?`, `&`, `-`, `_`, `.`, `~`, `/`, `=`

All other characters are percent-encoded using uppercase hexadecimal notation.

### URI Parsing Algorithm

The `flb_uri_create` function parses URIs by:
1. Splitting the URI by `/` characters
2. Creating `flb_uri_field` structures for each component
3. Maintaining both a linked list and array map for efficient access
4. Preserving the original URI string

### Memory Management

The URI context uses a single memory allocation for efficiency:
- The main `struct flb_uri` is allocated
- An array of `FLB_URI_MAX` `struct flb_uri_field` structures follows
- Individual field values are separately allocated

## Usage Example

```c
#include <fluent-bit/flb_uri.h>
#include <fluent-bit/flb_sds.h>
#include <fluent-bit/flb_log.h>

// Parse a URI
struct flb_uri *uri = flb_uri_create("/api/v1/logs/app?filter=error&limit=100");
if (!uri) {
    flb_error("Failed to parse URI");
    return -1;
}

// Access URI fields by position
struct flb_uri_field *field;

field = flb_uri_get(uri, 0);
if (field) {
    flb_info("First field: '%.*s'", (int) field->length, field->value);
}

field = flb_uri_get(uri, 1);
if (field) {
    flb_info("Second field: '%.*s'", (int) field->length, field->value);
}

// Encode a URI string
const char *raw_uri = "https://example.com/api/users/john doe?filter=special chars";
flb_sds_t encoded_uri = flb_uri_encode(raw_uri, strlen(raw_uri));
if (encoded_uri) {
    flb_info("Encoded URI: %s", encoded_uri);
    flb_sds_destroy(encoded_uri);
}

// Dump URI for debugging
flb_info("URI dump:");
flb_uri_dump(uri);

// Clean up
flb_uri_destroy(uri);

// Example of URI field iteration
struct flb_uri_field *f;
struct mk_list *head;

mk_list_foreach(head, &uri->list) {
    f = mk_list_entry(head, struct flb_uri_field, _head);
    flb_info("Field: '%.*s' (length: %lu)", 
             (int) f->length, f->value, f->length);
}

return 0;
```

## Integration with Fluent Bit

The URI module integrates with other Fluent Bit components:

1. **HTTP Outputs**: Used for constructing and parsing API endpoints
2. **Web Servers**: Used for routing and endpoint matching
3. **Configuration**: Used for parsing URI-based configuration options
4. **Logging**: Used for formatting log messages with URI components

## Error Handling

All functions follow Fluent Bit's error handling conventions:
- Memory allocation failures are logged with `flb_error()`
- Invalid parameters result in appropriate return values
- Resource cleanup is performed on failure paths
- NULL pointers are checked before use