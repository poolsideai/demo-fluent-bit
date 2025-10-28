# lib/cfl Documentation

## Overview

CFL is a tiny library that provides interfaces for data structures, originally created to satisfy the needs of Fluent Bit and other libraries used internally like CMetrics and CTraces projects.

The library provides several key interfaces:

* `cfl_sds`: string manipulation
* `cfl_list`: linked list 
* `cfl_kv`: key value pairs by using a linked list (cfl_list)
* `cfl_array`: array of elements
* `cfl_variant`: interface to manage contexts with variant types
* `cfl_time`: time utilities
* `cfl_hash`: 64bit hashing functions

## Key Functions

### String Manipulation (cfl_sds)

* `cfl_sds_create()` - Create a new string
* `cfl_sds_create_len()` - Create a new string with specified length
* `cfl_sds_create_size()` - Create a new string with specified size
* `cfl_sds_destroy()` - Destroy a string
* `cfl_sds_cat()` - Concatenate a string to another
* `cfl_sds_len()` - Get the length of a string
* `cfl_sds_alloc()` - Get the allocated size of a string
* `cfl_sds_avail()` - Get the available space in a string
* `cfl_sds_increase()` - Increase the size of a string
* `cfl_sds_printf()` - Print formatted string to a string

### Linked Lists (cfl_list)

* `cfl_list_init()` - Initialize a list
* `cfl_list_add()` - Add an element to the beginning of a list
* `cfl_list_append()` - Add an element to the end of a list
* `cfl_list_prepend()` - Add an element to the beginning of a list
* `cfl_list_del()` - Delete an element from a list
* `cfl_list_is_empty()` - Check if a list is empty
* `cfl_list_size()` - Get the size of a list
* `cfl_list_foreach()` - Iterate through a list
* `cfl_list_foreach_r()` - Iterate through a list in reverse
* `cfl_list_entry()` - Get the container of a list element
* `cfl_list_entry_first()` - Get the first element of a list
* `cfl_list_entry_last()` - Get the last element of a list

### Key-Value Pairs (cfl_kv)

* `cfl_kv_init()` - Initialize a key-value list
* `cfl_kv_item_create()` - Create a key-value item
* `cfl_kv_item_create_len()` - Create a key-value item with specified lengths
* `cfl_kv_item_destroy()` - Destroy a key-value item
* `cfl_kv_release()` - Release all key-value items
* `cfl_kv_get_key_value()` - Get the value for a key

### Arrays (cfl_array)

* `cfl_array_create()` - Create a new array
* `cfl_array_destroy()` - Destroy an array
* `cfl_array_append()` - Append a variant to an array
* `cfl_array_append_string()` - Append a string to an array
* `cfl_array_append_int64()` - Append an int64 to an array
* `cfl_array_append_uint64()` - Append a uint64 to an array
* `cfl_array_append_double()` - Append a double to an array
* `cfl_array_append_bool()` - Append a boolean to an array
* `cfl_array_append_null()` - Append a null to an array
* `cfl_array_append_array()` - Append an array to an array
* `cfl_array_append_kvlist()` - Append a key-value list to an array
* `cfl_array_fetch_by_index()` - Fetch an element by index
* `cfl_array_size()` - Get the size of an array
* `cfl_array_remove_by_index()` - Remove an element by index
* `cfl_array_resizable()` - Set whether an array is resizable

### Variants (cfl_variant)

* `cfl_variant_create()` - Create a new variant
* `cfl_variant_destroy()` - Destroy a variant
* `cfl_variant_create_from_string()` - Create a variant from a string
* `cfl_variant_create_from_int64()` - Create a variant from an int64
* `cfl_variant_create_from_uint64()` - Create a variant from a uint64
* `cfl_variant_create_from_double()` - Create a variant from a double
* `cfl_variant_create_from_bool()` - Create a variant from a boolean
* `cfl_variant_create_from_null()` - Create a variant from null
* `cfl_variant_create_from_array()` - Create a variant from an array
* `cfl_variant_create_from_kvlist()` - Create a variant from a key-value list
* `cfl_variant_create_from_reference()` - Create a variant from a reference
* `cfl_variant_size_get()` - Get the size of a variant
* `cfl_variant_size_set()` - Set the size of a variant

### Time Utilities (cfl_time)

* `cfl_time_now()` - Get the current time
* `cfl_time_to_nanosec()` - Convert time to nanoseconds
* `cfl_time_to_microsec()` - Convert time to microseconds
* `cfl_time_to_milli()` - Convert time to milliseconds
* `cfl_time_to_sec()` - Convert time to seconds
* `cfl_time_diff()` - Calculate the difference between two times

### Hash Functions (cfl_hash)

* `cfl_hash_simple()` - Simple hash function
* `cfl_hash_32bit()` - 32-bit hash function
* `cfl_hash_64bit()` - 64-bit hash function

## Usage Notes

1. **Initialization**: The library should be initialized with `cfl_init()` before use.

2. **Memory Management**: All data structures must be properly destroyed to avoid memory leaks:
   * Strings: Use `cfl_sds_destroy()`
   * Lists: Use `cfl_list_del()` for individual elements
   * Key-Value pairs: Use `cfl_kv_release()`
   * Arrays: Use `cfl_array_destroy()`
   * Variants: Use `cfl_variant_destroy()`

3. **String Handling**: The `cfl_sds` interface provides a simple string manipulation interface with automatic memory management.

4. **Linked Lists**: The `cfl_list` interface provides a doubly-linked list implementation with various utility functions for iteration and manipulation.

5. **Key-Value Pairs**: The `cfl_kv` interface provides a simple key-value pair implementation built on top of the linked list interface.

6. **Arrays**: The `cfl_array` interface provides a dynamic array implementation that can hold variants of different types.

7. **Variants**: The `cfl_variant` interface provides a way to handle different data types in a uniform way.

## Example Usage

```c
#include <cfl/cfl.h>
#include <stdio.h>

int main() {
    // Initialize the library
    cfl_init();
    
    // Create a string
    cfl_sds_t str = cfl_sds_create("Hello, World!");
    printf("String: %s\n", str);
    
    // Create a linked list
    struct cfl_list list;
    cfl_list_init(&list);
    
    // Add some elements to the list
    cfl_sds_t item1 = cfl_sds_create("Item 1");
    cfl_sds_t item2 = cfl_sds_create("Item 2");
    
    struct cfl_list_item {
        cfl_sds_t data;
        struct cfl_list _head;
    };
    
    struct cfl_list_item *elem1 = malloc(sizeof(struct cfl_list_item));
    elem1->data = item1;
    cfl_list_add(&elem1->_head, &list);
    
    struct cfl_list_item *elem2 = malloc(sizeof(struct cfl_list_item));
    elem2->data = item2;
    cfl_list_add(&elem2->_head, &list);
    
    // Iterate through the list
    struct cfl_list_item *item;
    cfl_list_foreach(item, &list) {
        printf("List item: %s\n", item->data);
    }
    
    // Clean up
    cfl_sds_destroy(str);
    cfl_list_del(&elem1->_head);
    cfl_list_del(&elem2->_head);
    free(elem1);
    free(elem2);
    
    return 0;
}
```