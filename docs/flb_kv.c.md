# flb_kv.c

## Overview

The `flb_kv.c` file provides key-value pair management functionality for Fluent Bit. It implements data structures and functions for creating, managing, and manipulating key-value pairs that are used throughout the Fluent Bit system for configuration, metadata, and record handling.

## Key Functions

### `flb_kv_init`
Initializes a key-value list structure.

### `flb_kv_item_create_len`
Creates a new key-value item with specified key and value lengths, adding it to the provided list.

### `flb_kv_item_create`
Creates a new key-value item using null-terminated strings for key and value, adding it to the provided list.

### `flb_kv_item_set`
Sets a key-value pair in the list. If the key already exists, it updates the value; otherwise, it creates a new entry.

### `flb_kv_item_destroy`
Destroys a key-value item, freeing its memory and removing it from the list.

### `flb_kv_release`
Releases all key-value items in a list, freeing their memory.

### `flb_kv_get_key_value`
Retrieves the value associated with a given key from the list.

## Data Structures

### `struct flb_kv`
Represents a key-value pair with the following fields:
- `key`: The key string (flb_sds_t)
- `val`: The value string (flb_sds_t)
- `_head`: List linkage structure for maintaining the key-value list

## Dependencies

- `<fluent-bit/flb_info.h>`: Core Fluent Bit definitions
- `<fluent-bit/flb_kv.h>`: Header file with declarations
- `<fluent-bit/flb_log.h>`: Logging functionality
- `<fluent-bit/flb_mem.h>`: Memory management functions
- `<monkey/mk_core.h>`: Monkey core utilities including list management

## Implementation Details

The key-value implementation uses Fluent Bit's SDS (Simple Dynamic String) library for efficient string handling. It leverages the Monkey framework's list management (`mk_list`) for maintaining collections of key-value pairs.

All functions properly handle memory allocation failures and clean up resources appropriately.

## Usage Examples

```c
// Initialize a key-value list
struct mk_list kv_list;
flb_kv_init(&kv_list);

// Add key-value pairs
flb_kv_item_create(&kv_list, "key1", "value1");
flb_kv_item_create(&kv_list, "key2", "value2");

// Set or update a key-value pair
flb_kv_item_set(&kv_list, "key1", "updated_value");

// Retrieve a value
const char *value = flb_kv_get_key_value("key1", &kv_list);

// Clean up
flb_kv_release(&kv_list);
```