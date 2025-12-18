# flb_callback.c

## Overview

This file implements a callback management system for Fluent Bit. It provides a registry for registering and executing named callbacks, allowing different components to register functions that can be invoked by name.

The module handles:
- Callback registration with unique names
- Callback lookup and execution
- Hash table-based storage for efficient callback retrieval
- Memory management for callback entries
- Thread-safe callback execution

## Key Functions

### `flb_callback_create()`
Creates a new callback context with an internal hash table for storing callback entries.

### `flb_callback_destroy()`
Destroys a callback context, freeing all allocated memory including callback entries and the hash table.

### `flb_callback_set()`
Registers a new callback function with a unique name. The callback function takes three parameters: the callback name, and two void pointers for custom data.

### `flb_callback_exists()`
Checks if a callback with the specified name has been registered.

### `flb_callback_do()`
Executes a registered callback by name, passing two void pointers as parameters to the callback function.

## Important Variables/Constants

### Data Structures
- `struct flb_callback`: Main callback context containing the hash table and linked list of entries
- `struct flb_callback_entry`: Individual callback entry with name and function pointer
- `struct flb_hash_table`: Hash table for efficient callback lookup
- `struct mk_list`: Linked list for managing callback entries

### Callback Function Signature
```c
void (*cb)(char *, void *, void *)
```
Where:
- First parameter: Callback name
- Second parameter: First custom data pointer
- Third parameter: Second custom data pointer

## Dependencies

- `fluent-bit/flb_info.h`: Fluent Bit core information
- `fluent-bit/flb_mem.h`: Memory management utilities
- `fluent-bit/flb_log.h`: Logging utilities
- `fluent-bit/flb_callback.h`: Callback interface headers
- `fluent-bit/flb_hash_table.h`: Hash table implementation
- `fluent-bit/flb_sds.h`: String data structure utilities

## Implementation Details

1. **Hash Table Storage**: Uses a hash table for O(1) average-case lookup performance for registered callbacks.

2. **Memory Management**: Properly allocates and frees memory for callback entries and their names using Fluent Bit's memory management functions.

3. **Linked List**: Maintains a linked list of callback entries for easy iteration and cleanup.

4. **Error Handling**: Returns appropriate error codes for memory allocation failures and missing callbacks.

5. **Thread Safety**: Designed to be thread-safe for concurrent callback registration and execution.

## Usage Example

```c
// Create callback context
struct flb_callback *callbacks = flb_callback_create();

// Define a callback function
void my_callback(char *name, void *data1, void *data2) {
    printf("Callback '%s' executed with data: %s, %s\n", 
           name, (char*)data1, (char*)data2);
}

// Register the callback
int result = flb_callback_set(callbacks, "my_callback", my_callback);

if (result == 0) {
    // Check if callback exists
    if (flb_callback_exists(callbacks, "my_callback")) {
        // Execute the callback
        flb_callback_do(callbacks, "my_callback", "Hello", "World");
    }
}

// Clean up
flb_callback_destroy(callbacks);
```