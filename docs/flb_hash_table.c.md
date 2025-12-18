# flb_hash_table.c

## Overview

This file implements a hash table data structure for Fluent Bit that provides fast key-value storage and retrieval. The implementation uses separate chaining to resolve collisions and supports various eviction policies when the table reaches capacity.

The module serves as a general-purpose hash table implementation that can be used throughout Fluent Bit for caching, configuration storage, and other key-value mapping needs. It includes features like time-based expiration, case-insensitive lookups, and multiple eviction strategies.

## Key Functions

### `flb_hash_table_create()`
Creates a new hash table with specified size, eviction mode, and maximum entry limit.

### `flb_hash_table_create_with_ttl()`
Creates a new hash table with time-to-live support for automatic expiration of entries.

### `flb_hash_table_destroy()`
Destroys the hash table and frees all associated memory.

### `flb_hash_table_set_case_sensitivity()`
Configures whether key lookups should be case-sensitive or case-insensitive.

### `flb_hash_table_add()`
Adds a key-value pair to the hash table. If the key already exists, it updates the value.

### `flb_hash_table_get()`
Retrieves a value from the hash table by key.

### `flb_hash_table_exists()`
Checks if an entry with a specific hash exists in the table.

### `flb_hash_table_get_by_id()`
Retrieves an entry by its table index ID.

### `flb_hash_table_get_ptr()`
Retrieves a pointer value directly without copying.

### `flb_hash_table_del()`
Removes an entry from the hash table by key.

### `flb_hash_table_del_ptr()`
Removes an entry from the hash table by key and pointer value.

## Important Variables/Constants

### Eviction Modes
- `FLB_HASH_TABLE_EVICT_NONE`: No automatic eviction (default)
- `FLB_HASH_TABLE_EVICT_OLDER`: Evict oldest entries first
- `FLB_HASH_TABLE_EVICT_LESS_USED`: Evict least frequently used entries
- `FLB_HASH_TABLE_EVICT_RANDOM`: Evict random entries

### Hash Table Structures
- `struct flb_hash_table`: Main hash table structure containing configuration and statistics
- `struct flb_hash_table_chain`: Chain structure for handling hash collisions
- `struct flb_hash_table_entry`: Individual entry structure storing key-value pairs and metadata

### Entry Metadata
Each entry tracks:
- `created`: Timestamp when the entry was created
- `hits`: Number of times the entry has been accessed
- `hash`: Computed hash value of the key
- `key`: The entry's key
- `key_len`: Length of the key
- `val`: The entry's value
- `val_size`: Size of the value data

## Dependencies

- `fluent-bit/flb_hash_table.h`: Header file defining the interface and structures
- `fluent-bit/flb_info.h`: Core Fluent Bit information
- `fluent-bit/flb_mem.h`: Memory management utilities
- `fluent-bit/flb_log.h`: Logging utilities
- `fluent-bit/flb_str.h`: String utilities
- `cfl/cfl.h`: CFL library for hash computation
- `monkey/mk_core.h`: Monkey core utilities for linked lists

## Implementation Details

1. **Hash Function**: Uses CFL's 64-bit hash function for key hashing with optional case conversion.

2. **Collision Resolution**: Implements separate chaining using linked lists to handle hash collisions.

3. **Memory Management**: Uses Fluent Bit's memory allocation functions (`flb_calloc`, `flb_free`) for consistency.

4. **Eviction Policies**: Supports multiple automatic eviction strategies when the table reaches capacity.

5. **Time-based Expiration**: Entries can be automatically expired based on a configurable TTL.

6. **Case Sensitivity**: Configurable case-sensitive or case-insensitive key lookups.

7. **Performance Optimizations**: Special handling for single-entry chains to avoid iteration.

## Usage Example

```c
// Create a hash table with size 1024 and random eviction
struct flb_hash_table *table = flb_hash_table_create(FLB_HASH_TABLE_EVICT_RANDOM, 1024, 1000);

// Add some entries
char *value1 = "Hello World";
char *value2 = "Fluent Bit";

flb_hash_table_add(table, "greeting", 8, value1, strlen(value1));
flb_hash_table_add(table, "application", 11, value2, strlen(value2));

// Retrieve an entry
void *retrieved_value;
size_t value_size;

if (flb_hash_table_get(table, "greeting", 8, &retrieved_value, &value_size) == 0) {
    printf("Retrieved: %s\n", (char*)retrieved_value);
}

// Direct pointer access
char *direct_value = (char*)flb_hash_table_get_ptr(table, "application", 11);
if (direct_value) {
    printf("Direct access: %s\n", direct_value);
}

// Clean up
flb_hash_table_destroy(table);
```