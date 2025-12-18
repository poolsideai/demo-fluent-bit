# flb_sds.c

## Overview

The `flb_sds.c` file implements the Simple Dynamic String (SDS) library for Fluent Bit. This is a lightweight, efficient string handling library that provides dynamic string operations with automatic memory management.

The SDS library is a simplified version of the original SDS library created by Antirez, adapted specifically for Fluent Bit's needs. It offers:

- Dynamic string allocation and resizing
- Efficient concatenation operations
- Automatic memory management
- String formatting capabilities
- UTF-8 support for international characters
- Safe string operations with bounds checking

This implementation is optimized for Fluent Bit's use cases, particularly for handling log data, configuration strings, and metadata.

## Key Functions/Components

### Core Data Structures

#### `struct flb_sds`
The SDS header structure containing:
- `len`: Current length of the string content
- `alloc`: Allocated buffer size
- `buf`: Pointer to the actual string buffer

#### `flb_sds_t`
Typedef for `char *` representing an SDS string pointer

### Main Functions

#### `flb_sds_create_len(const char *str, int len)`
Creates a new SDS string with specified length:
1. Allocates memory for SDS header + string content + null terminator
2. Copies input string content if provided
3. Initializes header with length and allocation size
4. Returns pointer to string buffer

#### `flb_sds_create(const char *str)`
Creates a new SDS string from null-terminated input:
1. Calculates input string length
2. Calls `flb_sds_create_len()` with calculated length
3. Returns new SDS string

#### `flb_sds_create_size(size_t size)`
Creates a new SDS string with specified allocation size:
1. Allocates memory for SDS header + requested size + null terminator
2. Initializes header with zero length and requested allocation
3. Returns pointer to string buffer

#### `flb_sds_cat(flb_sds_t s, const char *str, int len)`
Appends string content to existing SDS string:
1. Checks available space in current buffer
2. Increases buffer size if needed
3. Copies new content to end of existing string
4. Updates length and null terminator
5. Returns updated SDS string pointer

#### `flb_sds_copy(flb_sds_t s, const char *str, int len)`
Replaces content of existing SDS string:
1. Checks if current allocation is sufficient
2. Increases buffer size if needed
3. Copies new content to beginning of buffer
4. Updates length and null terminator
5. Returns updated SDS string pointer

#### `flb_sds_destroy(flb_sds_t s)`
Destroys SDS string and frees associated memory:
1. Validates input pointer
2. Retrieves header from buffer pointer
3. Frees entire SDS structure including header

### Utility Functions

#### `flb_sds_increase(flb_sds_t s, size_t len)`
Increases SDS buffer allocation size:
1. Calculates new required size
2. Reallocates memory block
3. Updates header allocation size
4. Returns pointer to new buffer location

#### `flb_sds_trim(flb_sds_t s)`
Removes whitespace from beginning and end of SDS string:
1. Finds first non-whitespace character
2. Finds last non-whitespace character
3. Shifts content to remove leading whitespace
4. Truncates trailing whitespace
5. Updates length and null terminator
6. Returns new content length

#### `flb_sds_cat_safe(flb_sds_t *buf, const char *str, int len)`
Safely appends string content to SDS string:
1. Calls `flb_sds_cat()` to append content
2. Updates caller's SDS pointer if reallocation occurred
3. Returns success/failure status

#### `flb_sds_cat_esc(flb_sds_t s, const char *str, int len, char *esc, size_t esc_size)`
Appends string content with character escaping:
1. Checks available space and increases buffer if needed
2. Iterates through input characters
3. Escapes characters according to escape table
4. Updates length and null terminator
5. Returns updated SDS string pointer

#### `flb_sds_cat_utf8(flb_sds_t *sds, const char *str, int str_len)`
Appends UTF-8 encoded string content:
1. Ensures sufficient buffer space
2. Writes UTF-8 content using utility functions
3. Handles buffer reallocation if needed
4. Updates length and null terminator
5. Returns updated SDS string pointer

#### `flb_sds_printf(flb_sds_t *sds, const char *fmt, ...)`
Formats and appends content to SDS string:
1. Estimates required buffer space
2. Ensures sufficient buffer space
3. Formats content using vsnprintf
4. Handles buffer reallocation if needed
5. Updates length and null terminator
6. Returns updated SDS string pointer

#### `flb_sds_snprintf(flb_sds_t *str, size_t size, const char *fmt, ...)`
Formats content into SDS string with automatic resizing:
1. Attempts to format content in current buffer
2. Automatically increases buffer size if needed
3. Retries formatting with larger buffer
4. Updates length and returns formatted content length

### Helper Functions

#### `flb_sds_len(flb_sds_t s)`
Returns current length of SDS string content

#### `flb_sds_alloc(flb_sds_t s)`
Returns current allocation size of SDS string

#### `flb_sds_avail(flb_sds_t s)`
Returns available space in SDS string buffer

#### `flb_sds_len_set(flb_sds_t s, size_t len)`
Sets the length of SDS string content

## Important Constants

### Header Size
- `FLB_SDS_HEADER_SIZE`: Size of SDS header structure
- Used for memory allocation calculations
- Ensures proper alignment of string buffer

### Buffer Management
- Automatic buffer resizing when needed
- Conservative growth strategy to minimize reallocations
- Null termination maintained for all operations

## Dependencies and Relationships

This module depends on:
- `flb_mem`: Memory allocation functions
- `flb_utf8`: UTF-8 handling utilities
- `flb_utils`: General utility functions
- Standard C library functions (memcpy, strlen, etc.)

It integrates with:
- Log processing for dynamic string handling
- Configuration parsing for string operations
- Metadata management for key-value pairs
- Output formatting for log serialization

## Implementation Details

The SDS implementation provides several key optimizations:

### Memory Layout
SDS strings use a header-prefix layout:
```
[Header: flb_sds][String Content][Null Terminator]
```

The header contains:
- Length of actual string content
- Total allocated buffer size
- Implicit pointer to string content

### Buffer Management
- Automatic resizing when operations exceed current allocation
- Conservative growth to minimize memory fragmentation
- Efficient memory reuse for common operations

### String Operations
- All operations maintain null termination
- Bounds checking prevents buffer overflows
- Efficient concatenation through pre-allocation

### UTF-8 Support
- Proper handling of multi-byte UTF-8 characters
- Safe string operations that respect character boundaries
- Integration with Fluent Bit's internationalization features

### Error Handling
- Graceful handling of memory allocation failures
- Consistent return value conventions
- Proper cleanup on operation failures

## Usage Examples

### Basic String Creation and Destruction
```c
// Create SDS string from literal
flb_sds_t s = flb_sds_create("Hello, World!");
if (s) {
    printf("String: %s\n", s);
    printf("Length: %zu\n", flb_sds_len(s));
    flb_sds_destroy(s);
}
```

### String Concatenation
```c
// Append content to SDS string
flb_sds_t s = flb_sds_create("Hello");
if (s) {
    s = flb_sds_cat(s, ", World!", 8);
    if (s) {
        printf("Result: %s\n", s);
    }
    flb_sds_destroy(s);
}
```

### Safe String Operations
```c
// Safely append to SDS string
flb_sds_t s = flb_sds_create_size(10);
if (s) {
    int ret = flb_sds_cat_safe(&s, "Hello, World!", 13);
    if (ret == 0) {
        printf("Safe append result: %s\n", s);
    }
    flb_sds_destroy(s);
}
```

### String Formatting
```c
// Format content into SDS string
flb_sds_t s = flb_sds_create_size(50);
if (s) {
    s = flb_sds_printf(&s, "User %s has %d points", "Alice", 100);
    if (s) {
        printf("Formatted string: %s\n", s);
    }
    flb_sds_destroy(s);
}
```

### String Trimming
```c
// Trim whitespace from SDS string
flb_sds_t s = flb_sds_create("   Hello, World!   ");
if (s) {
    int new_len = flb_sds_trim(s);
    if (new_len >= 0) {
        printf("Trimmed string: '%s' (length: %d)\n", s, new_len);
    }
    flb_sds_destroy(s);
}
```

### Character Escaping
```c
// Escape special characters in SDS string
flb_sds_t s = flb_sds_create("Hello \"World\"!");
if (s) {
    char escape_table[256] = {0};
    escape_table['\"'] = '\"';
    escape_table['\\'] = '\\';
    
    s = flb_sds_cat_esc(s, " Special chars: \"\\\n", 16, escape_table, 256);
    if (s) {
        printf("Escaped string: %s\n", s);
    }
    flb_sds_destroy(s);
}
```

### UTF-8 String Handling
```c
// Handle UTF-8 content in SDS string
flb_sds_t s = flb_sds_create_size(100);
if (s) {
    // Append UTF-8 content safely
    s = flb_sds_cat_utf8(&s, "Hello 世界!", 10);
    if (s) {
        printf("UTF-8 string: %s\n", s);
    }
    flb_sds_destroy(s);
}
```

### Configuration Example
```ini
[SERVICE]
    # SDS configuration parameters
    sds_initial_size 1024

[INPUT]
    name tail
    path /var/log/app.log
    # Uses SDS for log line buffering

[OUTPUT]
    name stdout
    match *
    # Uses SDS for formatted output
```

In this example:
- SDS configured with initial buffer size of 1024 bytes
- Tail input uses SDS for log line buffering
- Stdout output uses SDS for formatted log output

### Performance Optimization Pattern
```c
// Optimized SDS usage pattern
flb_sds_t buffer = flb_sds_create_size(1024);
if (!buffer) {
    return -1;
}

// Pre-allocate for expected content size
int expected_size = 512;
if (flb_sds_avail(buffer) < expected_size) {
    buffer = flb_sds_increase(buffer, expected_size - flb_sds_avail(buffer));
    if (!buffer) {
        return -1;
    }
}

// Efficiently build content
buffer = flb_sds_printf(&buffer, "Timestamp: %ld, Message: %s", 
                        time(NULL), "Log entry");

if (buffer) {
    // Use the buffer
    process_log_entry(buffer);
}

// Cleanup
flb_sds_destroy(buffer);
```

### Error Handling Pattern
```c
// Robust SDS error handling
flb_sds_t build_json_string(const char *key, const char *value) {
    flb_sds_t result = flb_sds_create_size(256);
    if (!result) {
        return NULL;
    }
    
    // Format JSON content
    result = flb_sds_printf(&result, "{\"%s\":\"%s\"}", key, value);
    if (!result) {
        return NULL;
    }
    
    return result;
}

// Usage
flb_sds_t json = build_json_string("status", "success");
if (json) {
    printf("JSON: %s\n", json);
    flb_sds_destroy(json);
} else {
    printf("Failed to create JSON string\n");
}
```

### Memory Management
```c
// Proper SDS lifecycle management
flb_sds_t s = NULL;

// Create SDS string
s = flb_sds_create("Initial content");
if (!s) {
    flb_error("Failed to create SDS string");
    return -1;
}

// Use SDS string
// ... operations ...

// Destroy SDS string
flb_sds_destroy(s);
```