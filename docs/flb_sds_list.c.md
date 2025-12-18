# flb_sds_list.c

## Overview

The `flb_sds_list.c` file implements a list data structure for managing collections of Simple Dynamic Strings (SDS) in Fluent Bit. This module provides functions for creating, manipulating, and destroying lists of SDS strings, which are commonly used for handling collections of strings such as log lines, configuration values, or metadata.

This implementation leverages the Monkey library's linked list (`mk_list`) data structure to maintain a collection of SDS strings. Each entry in the list contains an SDS string and is managed through a doubly-linked list structure.

Key features:
- Creation and destruction of SDS string lists
- Addition of SDS strings to lists
- Removal of individual entries or the last entry
- Conversion between SDS lists and standard C string arrays
- Memory management for both the list structure and contained strings

## Key Functions/Components

### Core Data Structures

#### `struct flb_sds_list_entry`
Represents an individual entry in the SDS list:
- `str`: The SDS string contained in this entry
- `_head`: Linked list node for maintaining list structure

#### `struct flb_sds_list`
The main list container:
- `strs`: Linked list of SDS entries

### Main Functions

#### `flb_sds_list_create()`
Creates a new empty SDS list:
1. Allocates memory for the list structure
2. Initializes the internal linked list
3. Returns pointer to the new list

#### `flb_sds_list_destroy(struct flb_sds_list *list)`
Destroys an SDS list and frees all associated memory:
1. Removes all entries from the list
2. Destroys each SDS string in the entries
3. Frees the list structure itself
4. Returns success/failure status

#### `flb_sds_list_add(struct flb_sds_list *list, char *in_str, size_t in_size)`
Adds a new SDS string to the list:
1. Validates input parameters
2. Creates an SDS string from the input
3. Allocates memory for a new list entry
4. Adds the entry to the list
5. Returns success/failure status

#### `flb_sds_list_del(struct flb_sds_list_entry *entry)`
Removes and destroys a specific list entry:
1. Validates the entry pointer
2. Destroys the SDS string in the entry
3. Removes the entry from the list
4. Frees the entry structure
5. Returns success/failure status

#### `flb_sds_list_size(struct flb_sds_list *list)`
Returns the number of entries in the list:
1. Validates the list pointer
2. Returns count of entries using mk_list_size()

### Utility Functions

#### `flb_sds_list_create_str_array(struct flb_sds_list *list)`
Converts an SDS list to a standard C string array:
1. Validates the input list
2. Calculates required array size
3. Allocates memory for the string array
4. Copies each SDS string to a new C string
5. Returns the string array (NULL-terminated)

#### `flb_sds_list_destroy_str_array(char **array)`
Destroys a string array created by flb_sds_list_create_str_array():
1. Validates the array pointer
2. Frees each string in the array
3. Frees the array structure itself

#### `flb_sds_list_del_last_entry(struct flb_sds_list *list)`
Removes and destroys the last entry in the list:
1. Validates the list and checks for entries
2. Gets the last entry from the list
3. Calls flb_sds_list_del() to remove it
4. Returns success/failure status

## Important Variables and Constants

### Data Structure Layout
- SDS list entries use a header-prefix layout for efficient memory management
- Linked list nodes are embedded within each entry for minimal memory overhead
- SDS strings are stored as pointers to dynamically allocated buffers

### Memory Management
- Automatic memory management for both list structures and contained strings
- Proper cleanup on destruction to prevent memory leaks
- Error handling for memory allocation failures

## Dependencies and Relationships

This module depends on:
- `flb_sds`: Simple Dynamic String library for string management
- `mk_list`: Monkey library's linked list implementation
- `flb_mem`: Memory allocation functions
- Standard C library functions (strncpy, etc.)

It integrates with:
- Log processing for managing collections of log lines
- Configuration parsing for handling multiple configuration values
- Metadata management for key-value pair collections
- Output formatting for batch processing of log entries

## Implementation Details

### Memory Layout
SDS lists use a two-level structure:
```
[List Structure: flb_sds_list] -> [Linked List of Entries]
[Entry Structure: flb_sds_list_entry] -> [SDS String]
```

### String Management
- Each entry maintains its own SDS string with automatic memory management
- String copying is performed during addition to ensure data isolation
- Proper null termination is maintained for all string operations

### Linked List Operations
- Uses Monkey library's mk_list for efficient list management
- Provides O(1) insertion at the end of the list
- Provides O(n) lookup for specific entries
- Supports safe iteration with concurrent modification

### Error Handling
- Comprehensive validation of input parameters
- Graceful handling of memory allocation failures
- Consistent return value conventions (-1 for error, 0 for success)
- Proper cleanup on operation failures

## Usage Examples

### Basic List Creation and Destruction
```c
// Create an SDS list
struct flb_sds_list *list = flb_sds_list_create();
if (list) {
    printf("List created with %zu entries\n", flb_sds_list_size(list));
    
    // Destroy the list
    flb_sds_list_destroy(list);
}
```

### Adding Strings to a List
```c
// Create a list and add strings
struct flb_sds_list *list = flb_sds_list_create();
if (list) {
    // Add strings to the list
    flb_sds_list_add(list, "First entry", 11);
    flb_sds_list_add(list, "Second entry", 12);
    flb_sds_list_add(list, "Third entry", 11);
    
    printf("List now has %zu entries\n", flb_sds_list_size(list));
    
    // Destroy the list
    flb_sds_list_destroy(list);
}
```

### Converting to String Array
```c
// Convert SDS list to standard string array
struct flb_sds_list *list = flb_sds_list_create();
if (list) {
    // Add some strings
    flb_sds_list_add(list, "apple", 5);
    flb_sds_list_add(list, "banana", 6);
    flb_sds_list_add(list, "cherry", 6);
    
    // Convert to string array
    char **str_array = flb_sds_list_create_str_array(list);
    if (str_array) {
        // Process the string array
        for (int i = 0; str_array[i] != NULL; i++) {
            printf("String %d: %s\n", i, str_array[i]);
        }
        
        // Destroy the string array
        flb_sds_list_destroy_str_array(str_array);
    }
    
    // Destroy the list
    flb_sds_list_destroy(list);
}
```

### Removing Entries
```c
// Remove specific entries from a list
struct flb_sds_list *list = flb_sds_list_create();
if (list) {
    // Add some strings
    flb_sds_list_add(list, "first", 5);
    flb_sds_list_add(list, "second", 6);
    flb_sds_list_add(list, "third", 5);
    
    printf("Before removal: %zu entries\n", flb_sds_list_size(list));
    
    // Remove the last entry
    flb_sds_list_del_last_entry(list);
    
    printf("After removing last: %zu entries\n", flb_sds_list_size(list));
    
    // Destroy the list
    flb_sds_list_destroy(list);
}
```

### Configuration Example
```ini
[SERVICE]
    # SDS list configuration
    log_level info

[INPUT]
    name tail
    path /var/log/app/*.log
    # Uses SDS lists for managing multiple log file paths
    
[OUTPUT]
    name stdout
    match *
    # Uses SDS lists for batch processing of log entries
```

### Performance Optimization Pattern
```c
// Efficient SDS list usage pattern
struct flb_sds_list *process_log_lines(char **lines, int count) {
    struct flb_sds_list *list = flb_sds_list_create();
    if (!list) {
        return NULL;
    }
    
    // Add all lines to the list
    for (int i = 0; i < count; i++) {
        if (flb_sds_list_add(list, lines[i], strlen(lines[i])) != 0) {
            flb_sds_list_destroy(list);
            return NULL;
        }
    }
    
    return list;
}

// Usage
char *log_lines[] = {"Error: Connection failed", "Warning: High CPU usage", "Info: Process started"};
struct flb_sds_list *processed_lines = process_log_lines(log_lines, 3);
if (processed_lines) {
    printf("Processed %zu log lines\n", flb_sds_list_size(processed_lines));
    flb_sds_list_destroy(processed_lines);
}
```

### Error Handling Pattern
```c
// Robust SDS list error handling
int safe_add_strings_to_list(struct flb_sds_list *list, char **strings, int count) {
    if (!list || !strings) {
        return -1;
    }
    
    for (int i = 0; i < count; i++) {
        if (strings[i] && strlen(strings[i]) > 0) {
            if (flb_sds_list_add(list, strings[i], strlen(strings[i])) != 0) {
                // On failure, we might want to clean up previously added strings
                // depending on the application's requirements
                return -1;
            }
        }
    }
    
    return 0;
}

// Usage
struct flb_sds_list *list = flb_sds_list_create();
if (list) {
    char *strings[] = {"one", "two", "three"};
    if (safe_add_strings_to_list(list, strings, 3) == 0) {
        printf("Successfully added %zu strings\n", flb_sds_list_size(list));
    }
    flb_sds_list_destroy(list);
}
```