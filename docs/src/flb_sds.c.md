# flb_sds.c and flb_sds.h Documentation

## Overview

The `flb_sds` module provides a Simple Dynamic String (SDS) implementation for Fluent Bit. This implementation is based on the original SDS library created by Antirez, but has been stripped down and adapted for Fluent Bit's specific needs.

SDS is a string library that provides automatic memory management for strings, eliminating the need for manual memory allocation and deallocation. It's particularly useful for scenarios where strings need to be dynamically resized, concatenated, or modified frequently.

## Key Features

- Automatic memory management
- Dynamic resizing capabilities
- Efficient string operations (concatenation, copying, trimming)
- UTF-8 aware operations
- Cross-platform compatibility
- Integration with Fluent Bit's memory management system

## Data Structure

### struct flb_sds

The core SDS data structure that stores string metadata:

```c
struct flb_sds {
    uint64_t len;        /* used length of the string */
    uint64_t alloc;      /* allocated size excluding header and null terminator */
    char buf[];          /* flexible array member for the actual string data */
};
```

### flb_sds_t

A typedef for `char *` that represents a pointer to the SDS buffer:

```c
typedef char *flb_sds_t;
```

## Macros and Constants

### FLB_SDS_HEADER_SIZE

Size of the SDS header in bytes:

```c
#define FLB_SDS_HEADER_SIZE (sizeof(uint64_t) + sizeof(uint64_t))
```

### FLB_SDS_HEADER(s)

Macro to retrieve the SDS header from a buffer pointer:

```c
#define FLB_SDS_HEADER(s)  ((struct flb_sds *) (s - FLB_SDS_HEADER_SIZE))
```

## Key Functions

### flb_sds_create()

```c
flb_sds_t flb_sds_create(const char *str);
```

Creates a new SDS string from a null-terminated C string.

**Parameters:**
- `str`: Null-terminated C string to copy

**Returns:**
- Pointer to the new SDS string on success
- `NULL` on error

### flb_sds_create_len()

```c
flb_sds_t flb_sds_create_len(const char *str, int len);
```

Creates a new SDS string from a buffer with specified length.

**Parameters:**
- `str`: Buffer containing the string data
- `len`: Length of the string data

**Returns:**
- Pointer to the new SDS string on success
- `NULL` on error

### flb_sds_create_size()

```c
flb_sds_t flb_sds_create_size(size_t size);
```

Creates a new SDS string with specified initial size.

**Parameters:**
- `size`: Initial size of the SDS buffer

**Returns:**
- Pointer to the new SDS string on success
- `NULL` on error

### flb_sds_destroy()

```c
void flb_sds_destroy(flb_sds_t s);
```

Destroys an SDS string and frees its memory.

**Parameters:**
- `s`: SDS string to destroy

### flb_sds_cat()

```c
flb_sds_t flb_sds_cat(flb_sds_t s, const char *str, int len);
```

Concatenates a buffer to an existing SDS string.

**Parameters:**
- `s`: Existing SDS string
- `str`: Buffer to append
- `len`: Length of the buffer to append

**Returns:**
- Pointer to the updated SDS string on success
- `NULL` on error

### flb_sds_cat_safe()

```c
int flb_sds_cat_safe(flb_sds_t *buf, const char *str, int len);
```

Safely concatenates a buffer to an SDS string, updating the pointer if reallocation occurs.

**Parameters:**
- `buf`: Pointer to the SDS string buffer
- `str`: Buffer to append
- `len`: Length of the buffer to append

**Returns:**
- `0` on success
- `-1` on error

### flb_sds_cat_esc()

```c
flb_sds_t flb_sds_cat_esc(flb_sds_t s, const char *str, int len,
                                       char *esc, size_t esc_size);
```

Concatenates a buffer to an SDS string with character escaping.

**Parameters:**
- `s`: Existing SDS string
- `str`: Buffer to append
- `len`: Length of the buffer to append
- `esc`: Escape mapping table
- `esc_size`: Size of the escape mapping table

**Returns:**
- Pointer to the updated SDS string on success
- `NULL` on error

### flb_sds_cat_utf8()

```c
flb_sds_t flb_sds_cat_utf8(flb_sds_t *sds, const char *str, int len);
```

Concatenates a UTF-8 string to an SDS string.

**Parameters:**
- `sds`: Pointer to the SDS string
- `str`: UTF-8 string to append
- `len`: Length of the UTF-8 string

**Returns:**
- Pointer to the updated SDS string on success
- `NULL` on error

### flb_sds_copy()

```c
flb_sds_t flb_sds_copy(flb_sds_t s, const char *str, int len);
```

Copies a buffer to an existing SDS string.

**Parameters:**
- `s`: Existing SDS string
- `str`: Buffer to copy
- `len`: Length of the buffer to copy

**Returns:**
- Pointer to the updated SDS string on success
- `NULL` on error

### flb_sds_increase()

```c
flb_sds_t flb_sds_increase(flb_sds_t s, size_t len);
```

Increases the size of an SDS string buffer.

**Parameters:**
- `s`: Existing SDS string
- `len`: Additional bytes to allocate

**Returns:**
- Pointer to the updated SDS string on success
- `NULL` on error

### flb_sds_trim()

```c
int flb_sds_trim(flb_sds_t s);
```

Removes whitespace from both ends of an SDS string.

**Parameters:**
- `s`: SDS string to trim

**Returns:**
- New length of the string on success
- `-1` on error

### flb_sds_printf()

```c
flb_sds_t flb_sds_printf(flb_sds_t *sds, const char *fmt, ...);
```

Formats and appends data to an SDS string.

**Parameters:**
- `sds`: Pointer to the SDS string
- `fmt`: Format string
- `...`: Arguments for the format string

**Returns:**
- Pointer to the updated SDS string on success
- `NULL` on error

### flb_sds_snprintf()

```c
int flb_sds_snprintf(flb_sds_t *str, size_t size, const char *fmt, ...);
```

Formats data into an SDS string with length checking.

**Parameters:**
- `str`: Pointer to the SDS string
- `size`: Buffer size
- `fmt`: Format string
- `...`: Arguments for the format string

**Returns:**
- Number of characters written on success
- `-1` on error

## Helper Functions

### flb_sds_len()

```c
static inline size_t flb_sds_len(flb_sds_t s)
```

Returns the length of an SDS string.

**Parameters:**
- `s`: SDS string

**Returns:**
- Length of the string

### flb_sds_is_empty()

```c
static inline int flb_sds_is_empty(flb_sds_t s)
```

Checks if an SDS string is empty.

**Parameters:**
- `s`: SDS string

**Returns:**
- `FLB_TRUE` if empty
- `FLB_FALSE` if not empty

### flb_sds_len_set()

```c
static inline void flb_sds_len_set(flb_sds_t s, size_t len)
```

Sets the length of an SDS string.

**Parameters:**
- `s`: SDS string
- `len`: New length

### flb_sds_alloc()

```c
static inline size_t flb_sds_alloc(flb_sds_t s)
```

Returns the allocated size of an SDS string buffer.

**Parameters:**
- `s`: SDS string

**Returns:**
- Allocated size of the buffer

### flb_sds_avail()

```c
static inline size_t flb_sds_avail(flb_sds_t s)
```

Returns the available space in an SDS string buffer.

**Parameters:**
- `s`: SDS string

**Returns:**
- Available space in bytes

### flb_sds_cmp()

```c
static inline int flb_sds_cmp(flb_sds_t s, const char *str, int len)
```

Compares an SDS string with a buffer.

**Parameters:**
- `s`: SDS string
- `str`: Buffer to compare
- `len`: Length of the buffer

**Returns:**
- `0` if equal
- Negative value if s < str
- Positive value if s > str

### flb_sds_casecmp()

```c
static inline int flb_sds_casecmp(flb_sds_t s, const char *str, int len)
```

Compares an SDS string with a buffer (case-insensitive).

**Parameters:**
- `s`: SDS string
- `str`: Buffer to compare
- `len`: Length of the buffer

**Returns:**
- `0` if equal
- Negative value if s < str
- Positive value if s > str

## Implementation Details

### Memory Layout

SDS strings use a header-based approach where the string data is preceded by metadata:

```
[Header: 16 bytes][String Data][Null Terminator]
```

The header contains:
- `len`: Current length of the string data
- `alloc`: Allocated size of the buffer

### Automatic Resizing

SDS automatically resizes buffers when needed:
- When concatenating data that exceeds available space
- When increasing buffer size explicitly
- Memory is reallocated using Fluent Bit's memory management system

### Thread Safety

SDS itself is not thread-safe. External synchronization is required when accessing SDS strings from multiple threads.

## Usage Example

```c
#include <fluent-bit/flb_sds.h>
#include <fluent-bit/flb_mem.h>
#include <fluent-bit/flb_log.h>

// Create an SDS string
flb_sds_t sds = flb_sds_create("Hello");
if (!sds) {
    flb_error("Failed to create SDS string");
    return -1;
}

// Append to the string
flb_sds_t tmp = flb_sds_cat(sds, " World", 6);
if (!tmp) {
    flb_error("Failed to append to SDS string");
    flb_sds_destroy(sds);
    return -1;
}
sds = tmp;

// Print the string
flb_info("String: %s", sds);

// Use printf-style formatting
if (flb_sds_printf(&sds, " Length: %d", flb_sds_len(sds)) == NULL) {
    flb_error("Failed to format SDS string");
    flb_sds_destroy(sds);
    return -1;
}

// Trim whitespace
if (flb_sds_trim(sds) < 0) {
    flb_error("Failed to trim SDS string");
    flb_sds_destroy(sds);
    return -1;
}

// Compare strings
if (flb_sds_cmp(sds, "Hello World Length: 11", 24) == 0) {
    flb_info("Strings are equal");
} else {
    flb_info("Strings are not equal");
}

// Destroy the string
flb_sds_destroy(sds);

return 0;
```