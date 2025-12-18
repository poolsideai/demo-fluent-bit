# flb_slist.c and flb_slist.h Documentation

## Overview

The `flb_slist` module implements a simple string list data structure for Fluent Bit. This implementation provides efficient storage and manipulation of collections of strings, leveraging the Monkey Core library's linked list functionality and Fluent Bit's Simple Dynamic Strings (SDS) for memory management.

## Data Structures

### struct flb_slist_entry

Represents an individual entry in the string list.

```c
struct flb_slist_entry {
    flb_sds_t str;          // The SDS string
    struct mk_list _head;   // Linked list node
};
```

## Key Functions

### flb_slist_create()

```c
int flb_slist_create(struct mk_list *list);
```

Initializes a new string list.

**Parameters:**
- `list`: Pointer to the mk_list structure to initialize

**Returns:**
- `0` on success
- `-1` on error

### flb_slist_add()

```c
int flb_slist_add(struct mk_list *head, const char *str);
```

Adds a NULL-terminated string to the list.

**Parameters:**
- `head`: Pointer to the list head
- `str`: NULL-terminated string to add

**Returns:**
- `0` on success
- `-1` on error

### flb_slist_add_n()

```c
int flb_slist_add_n(struct mk_list *head, const char *str, int len);
```

Adds a string of specified length to the list.

**Parameters:**
- `head`: Pointer to the list head
- `str`: String to add
- `len`: Length of the string

**Returns:**
- `0` on success
- `-1` on error

### flb_slist_add_sds()

```c
int flb_slist_add_sds(struct mk_list *head, flb_sds_t str);
```

Adds an SDS string to the list.

**Parameters:**
- `head`: Pointer to the list head
- `str`: SDS string to add

**Returns:**
- `0` on success
- `-1` on error

### flb_slist_destroy()

```c
void flb_slist_destroy(struct mk_list *list);
```

Destroys a string list and frees all associated memory.

**Parameters:**
- `list`: Pointer to the list to destroy

### flb_slist_split_string()

```c
int flb_slist_split_string(struct mk_list *list, const char *str,
                           int separator, int max_split);
```

Splits a string using a separator character and adds the resulting substrings to the list.

**Parameters:**
- `list`: Pointer to the list to populate
- `str`: Input string to split
- `separator`: Character to use as separator
- `max_split`: Maximum number of splits (0 for unlimited)

**Returns:**
- Number of elements added to the list
- `-1` on error

### flb_slist_split_tokens()

```c
int flb_slist_split_tokens(struct mk_list *list, const char *str, int max_split);
```

Splits a string into tokens and adds them to the list. Tokens are separated by whitespace and can be quoted.

**Parameters:**
- `list`: Pointer to the list to populate
- `str`: Input string to tokenize
- `max_split`: Maximum number of tokens (0 for unlimited)

**Returns:**
- `0` on success
- `-1` on error

### flb_slist_dump()

```c
void flb_slist_dump(struct mk_list *list);
```

Dumps the contents of the list to stdout for debugging purposes.

**Parameters:**
- `list`: Pointer to the list to dump

### flb_slist_entry_get()

```c
struct flb_slist_entry *flb_slist_entry_get(struct mk_list *list, int n);
```

Retrieves an entry by its index position.

**Parameters:**
- `list`: Pointer to the list
- `n`: Index of the entry to retrieve

**Returns:**
- Pointer to the entry at the specified index
- `NULL` if index is out of bounds

## Implementation Details

The slist implementation provides:

- Efficient memory management through SDS
- Thread-safe operations (when used with proper synchronization)
- Automatic memory cleanup when destroying the list
- Support for various string addition methods
- String splitting with multiple separator options
- Token parsing with quote handling

## Usage Example

```c
#include <fluent-bit/flb_slist.h>
#include <fluent-bit/flb_log.h>

// Create a new string list
struct mk_list *list = flb_malloc(sizeof(struct mk_list));
if (flb_slist_create(list) == -1) {
    flb_error("Failed to create string list");
    return -1;
}

// Add strings to the list
flb_slist_add(list, "Hello");
flb_slist_add(list, "World");
flb_slist_add_n(list, "Fluent Bit", 10); // Add first 10 chars

// Split a string and add to the list
flb_slist_split_string(list, "apple,banana,cherry", ',', 0);

// Split tokens from a string
flb_slist_split_tokens(list, "one \"two three\" four", 0);

// Iterate through the list
struct mk_list *head;
struct flb_slist_entry *entry;

mk_list_foreach(head, list) {
    entry = mk_list_entry(head, struct flb_slist_entry, _head);
    flb_info("String: %s", entry->str);
}

// Get an entry by index
entry = flb_slist_entry_get(list, 0);
if (entry != NULL) {
    flb_info("First entry: %s", entry->str);
}

// Clean up
flb_slist_destroy(list);
flb_free(list);
```