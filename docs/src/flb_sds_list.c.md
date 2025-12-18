# flb_sds_list.c and flb_sds_list.h Documentation

## Overview

The `flb_sds_list` module implements a list data structure specifically designed to manage collections of Simple Dynamic Strings (SDS). This implementation leverages the Monkey Core library's linked list functionality to provide efficient storage and manipulation of string collections.

## Data Structures

### struct flb_sds_list_entry

Represents an individual entry in the SDS list.

```c
struct flb_sds_list_entry {
    flb_sds_t str;          // The SDS string
    struct mk_list _head;   // Linked list node
};
```

### struct flb_sds_list

Represents the SDS list container.

```c
struct flb_sds_list {
    struct mk_list strs;    // Linked list of SDS entries
};
```

## Key Functions

### flb_sds_list_create()

```c
struct flb_sds_list *flb_sds_list_create();
```

Creates a new SDS list.

**Returns:**
- Pointer to the newly created `struct flb_sds_list`
- `NULL` if allocation fails

### flb_sds_list_destroy()

```c
int flb_sds_list_destroy(struct flb_sds_list* list);
```

Destroys an SDS list and frees all associated memory.

**Parameters:**
- `list`: Pointer to the SDS list to destroy

**Returns:**
- `0` on success
- `-1` on error

### flb_sds_list_add()

```c
int flb_sds_list_add(struct flb_sds_list* list, char* in_str, size_t in_size);
```

Adds a new string to the SDS list.

**Parameters:**
- `list`: Pointer to the SDS list
- `in_str`: Input string to add
- `in_size`: Size of the input string

**Returns:**
- `0` on success
- `-1` on error

### flb_sds_list_del()

```c
int flb_sds_list_del(struct flb_sds_list_entry* entry);
```

Deletes a specific entry from the SDS list.

**Parameters:**
- `entry`: Pointer to the entry to delete

**Returns:**
- `0` on success
- `-1` on error

### flb_sds_list_del_last_entry()

```c
int flb_sds_list_del_last_entry(struct flb_sds_list* list);
```

Deletes the last entry from the SDS list.

**Parameters:**
- `list`: Pointer to the SDS list

**Returns:**
- `0` on success
- `-1` on error

### flb_sds_list_size()

```c
size_t flb_sds_list_size(struct flb_sds_list *list);
```

Returns the number of entries in the SDS list.

**Parameters:**
- `list`: Pointer to the SDS list

**Returns:**
- Number of entries in the list
- `0` if list is NULL or empty

### flb_sds_list_create_str_array()

```c
char **flb_sds_list_create_str_array(struct flb_sds_list *list);
```

Creates a NULL-terminated array of C strings from the SDS list.

**Parameters:**
- `list`: Pointer to the SDS list

**Returns:**
- Pointer to the newly created string array
- `NULL` on error

### flb_sds_list_destroy_str_array()

```c
int flb_sds_list_destroy_str_array(char **array);
```

Destroys a string array created by `flb_sds_list_create_str_array()`.

**Parameters:**
- `array`: Pointer to the string array to destroy

**Returns:**
- `0` on success
- `-1` on error

## Implementation Details

The SDS list implementation is built on top of the Monkey Core library's `mk_list` data structure, providing:

- Efficient memory management through SDS
- Thread-safe operations (when used with proper synchronization)
- Automatic memory cleanup when destroying the list
- Support for converting to/from standard C string arrays

## Usage Example

```c
#include <fluent-bit/flb_sds_list.h>

// Create a new SDS list
struct flb_sds_list *list = flb_sds_list_create();

if (list != NULL) {
    // Add strings to the list
    flb_sds_list_add(list, "Hello", 5);
    flb_sds_list_add(list, "World", 5);
    
    // Get the size of the list
    printf("List size: %zu\n", flb_sds_list_size(list));
    
    // Convert to string array for easier iteration
    char **str_array = flb_sds_list_create_str_array(list);
    if (str_array != NULL) {
        for (int i = 0; str_array[i] != NULL; i++) {
            printf("String %d: %s\n", i, str_array[i]);
        }
        
        // Clean up the string array
        flb_sds_list_destroy_str_array(str_array);
    }
    
    // Destroy the list
    flb_sds_list_destroy(list);
} else {
    printf("Failed to create SDS list\n");
}
```