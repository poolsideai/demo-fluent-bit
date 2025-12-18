# flb_slist.c

## Overview

The `flb_slist.c` file implements a string list data structure for managing collections of strings in Fluent Bit. This module provides functions for creating, manipulating, and destroying lists of strings, which are commonly used for handling collections of string values such as configuration tokens, log fields, or metadata entries.

This implementation leverages the Monkey library's linked list (`mk_list`) data structure to maintain a collection of strings. Each entry in the list contains an SDS (Simple Dynamic String) string and is managed through a doubly-linked list structure. The module provides various utility functions for string manipulation, splitting, and tokenization.

Key features:
- Creation and destruction of string lists
- Addition of strings to lists with various formats
- String splitting and tokenization capabilities
- Memory management for both the list structure and contained strings
- Debugging utilities for dumping list contents

## Key Functions/Components

### Core Data Structures

#### `struct flb_slist_entry`
Represents an individual entry in the string list:
- `str`: The SDS string contained in this entry
- `_head`: Linked list node for maintaining list structure

### Main Functions

#### `flb_slist_create(struct mk_list *list)`
Initializes a new empty string list:
1. Initializes the internal linked list structure
2. Returns success/failure status

#### `flb_slist_destroy(struct mk_list *list)`
Destroys a string list and frees all associated memory:
1. Removes all entries from the list
2. Destroys each SDS string in the entries
3. Frees the entry structures

#### `flb_slist_add(struct mk_list *head, const char *str)`
Adds a null-terminated string to the list:
1. Validates input string
2. Calculates string length
3. Creates an SDS string from the input
4. Allocates memory for a new list entry
5. Adds the entry to the list
6. Returns success/failure status

#### `flb_slist_add_n(struct mk_list *head, const char *str, int len)`
Adds a string of specified length to the list:
1. Validates input parameters
2. Creates an SDS string from the input with specified length
3. Allocates memory for a new list entry
4. Adds the entry to the list
5. Returns success/failure status

#### `flb_slist_add_sds(struct mk_list *head, flb_sds_t str)`
Adds an existing SDS string to the list:
1. Validates input SDS string
2. Allocates memory for a new list entry
3. Assigns the SDS string to the entry
4. Adds the entry to the list
5. Returns success/failure status

### Utility Functions

#### `flb_slist_split_string(struct mk_list *list, const char *str, int separator, int max_split)`
Splits a string into tokens based on a separator character:
1. Validates input string
2. Iterates through the string looking for separator characters
3. Extracts tokens between separators
4. Trims whitespace from tokens
5. Adds each token as a new entry to the list
6. Handles maximum split limit if specified
7. Returns count of added tokens

#### `flb_slist_split_tokens(struct mk_list *list, const char *str, int max_split)`
Splits a string into tokens with advanced parsing capabilities:
1. Parses quoted strings and escaped characters
2. Handles whitespace-separated tokens
3. Manages quoted token boundaries
4. Processes escape sequences within quoted strings
5. Adds parsed tokens to the list
6. Respects maximum split limit if specified
7. Returns success/failure status

#### `flb_slist_entry_get(struct mk_list *list, int n)`
Retrieves an entry at a specific position in the list:
1. Validates input list and position
2. Iterates through the list to find the nth entry
3. Returns pointer to the entry or NULL if not found

#### `flb_slist_dump(struct mk_list *list)`
Dumps the contents of a string list for debugging:
1. Prints list header information
2. Iterates through all entries in the list
3. Prints each string entry with formatting

### Helper Functions

#### `token_retrieve(char **str)`
Retrieves the next token from a string with advanced parsing:
1. Handles quoted strings and escaped characters
2. Skips whitespace between tokens
3. Processes escape sequences within quoted strings
4. Updates string pointer to next position
5. Returns SDS string containing the extracted token

#### `token_unescape(char *token)`
Unescapes special characters in a token:
1. Processes backslash-escaped quotes
2. Removes escape characters
3. Updates token length
4. Returns updated length of the token

## Important Variables and Constants

### Data Structure Layout
- String list entries use a header-prefix layout for efficient memory management
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
- Standard C library functions (strlen, etc.)

It integrates with:
- Configuration parsing for handling multiple configuration values
- Log processing for managing collections of log fields
- Metadata management for key-value pair collections
- String manipulation utilities throughout Fluent Bit

## Implementation Details

### Memory Layout
String lists use a two-level structure:
```
[List Structure: mk_list] -> [Linked List of Entries]
[Entry Structure: flb_slist_entry] -> [SDS String]
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

### Tokenization Algorithms
- Advanced token parsing handles quoted strings and escape sequences
- Whitespace trimming ensures clean token extraction
- Maximum split limits provide control over parsing behavior

### Error Handling
- Comprehensive validation of input parameters
- Graceful handling of memory allocation failures
- Consistent return value conventions (-1 for error, 0 for success)
- Proper cleanup on operation failures

## Usage Examples

### Basic List Creation and Destruction
```c
// Create a string list
struct mk_list list;
if (flb_slist_create(&list) == 0) {
    printf("List created successfully\n");
    
    // Destroy the list
    flb_slist_destroy(&list);
}
```

### Adding Strings to a List
```c
// Create a list and add strings
struct mk_list list;
if (flb_slist_create(&list) == 0) {
    // Add strings to the list
    flb_slist_add(&list, "First entry");
    flb_slist_add(&list, "Second entry");
    flb_slist_add_n(&list, "Third entry with length", 21);
    
    printf("List now has %d entries\n", mk_list_size(&list));
    
    // Destroy the list
    flb_slist_destroy(&list);
}
```

### String Splitting
```c
// Split a comma-separated string into a list
struct mk_list list;
if (flb_slist_create(&list) == 0) {
    // Split a string by commas
    int count = flb_slist_split_string(&list, "apple,banana,cherry", ',', -1);
    if (count > 0) {
        printf("Split %d tokens\n", count);
        
        // Iterate through the tokens
        struct mk_list *head;
        struct flb_slist_entry *entry;
        mk_list_foreach(head, &list) {
            entry = mk_list_entry(head, struct flb_slist_entry, _head);
            printf("Token: %s\n", entry->str);
        }
    }
    
    // Destroy the list
    flb_slist_destroy(&list);
}
```

### Advanced Tokenization
```c
// Parse tokens with quotes and escaping
struct mk_list list;
if (flb_slist_create(&list) == 0) {
    // Parse tokens with quoted strings
    int result = flb_slist_split_tokens(&list, "\"quoted string\" normal \"escaped quote: \\\" end\"", -1);
    if (result == 0) {
        printf("Successfully parsed tokens\n");
        
        // Dump the list contents
        flb_slist_dump(&list);
    }
    
    // Destroy the list
    flb_slist_destroy(&list);
}
```

### Configuration Example
```ini
[SERVICE]
    # String list configuration
    log_level info

[INPUT]
    name tail
    path /var/log/app/*.log
    # Uses string lists for managing multiple log file paths
    
[OUTPUT]
    name stdout
    match *
    # Uses string lists for batch processing of log entries
```

### Integration Pattern
```c
// Typical integration in a Fluent Bit component
int process_string_list(const char *input_string) {
    struct mk_list list;
    
    // Create string list
    if (flb_slist_create(&list) != 0) {
        return -1;
    }
    
    // Process the input string
    if (input_string) {
        // Split by spaces
        flb_slist_split_string(&list, input_string, ' ', -1);
        
        // Process each token
        struct mk_list *head;
        struct flb_slist_entry *entry;
        mk_list_foreach(head, &list) {
            entry = mk_list_entry(head, struct flb_slist_entry, _head);
            process_token(entry->str);
        }
    }
    
    // Cleanup
    flb_slist_destroy(&list);
    return 0;
}

// Usage
process_string_list("token1 token2 \"quoted token\" token4");
```

### Error Handling Pattern
```c
// Robust string list error handling
int safe_add_strings_to_list(struct mk_list *list, const char **strings, int count) {
    if (!list || !strings) {
        return -1;
    }
    
    for (int i = 0; i < count; i++) {
        if (strings[i] && strlen(strings[i]) > 0) {
            if (flb_slist_add(list, strings[i]) != 0) {
                // On failure, we might want to clean up previously added strings
                // depending on the application's requirements
                return -1;
            }
        }
    }
    
    return 0;
}

// Usage
struct mk_list list;
if (flb_slist_create(&list) == 0) {
    const char *strings[] = {"one", "two", "three"};
    if (safe_add_strings_to_list(&list, strings, 3) == 0) {
        printf("Successfully added %d strings\n", mk_list_size(&list));
    }
    flb_slist_destroy(&list);
}
```

### Memory Management
```c
// Proper string list lifecycle management
struct mk_list list;

// Create string list
if (flb_slist_create(&list) != 0) {
    flb_error("Failed to create string list");
    return -1;
}

// Use the list
// ... operations ...

// Destroy string list
flb_slist_destroy(&list);
```