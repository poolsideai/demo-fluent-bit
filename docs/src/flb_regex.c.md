# src/flb_regex.c

## Overview

The `flb_regex.c` file implements Fluent Bit's regular expression functionality using the Onigmo library. This module provides pattern matching capabilities for parsing and processing log data, configuration files, and other text-based inputs within Fluent Bit.

## Included Headers

```c
#include <fluent-bit/flb_info.h>
#include <fluent-bit/flb_regex.h>
#include <fluent-bit/flb_log.h>
#include <fluent-bit/flb_mem.h>
#include <string.h>
#include <onigmo.h>
```

These headers provide essential Fluent Bit functionality and the Onigmo regex library:
- `flb_info.h`: Basic types and version information
- `flb_regex.h`: Regex interface definitions
- `flb_log.h`: Logging functionality
- `flb_mem.h`: Memory management functions
- `string.h`: Standard string functions
- `onigmo.h`: Onigmo regex library interface

## Data Structures

### `struct flb_regex`

Represents a compiled regular expression pattern:

```c
struct flb_regex {
    void *regex;
};
```

**Fields:**
- `regex`: Pointer to the compiled Onigmo regex object

### `struct flb_regex_search`

Holds search results and context for regex operations:

```c
struct flb_regex_search {
    int last_pos;
    void *region;
    const char *str;
    void (*cb_match) (const char *,          /* name  */
                      const char *, size_t,  /* value */
                      void *);                  /* caller data */
    void *data;
};
```

**Fields:**
- `last_pos`: Last position of a match
- `region`: Onigmo region object containing match information
- `str`: Input string being searched
- `cb_match`: Callback function for named group matches
- `data`: User data passed to callback function

## Key Functions

### Backend Initialization

#### `flb_regex_init`

```c
int flb_regex_init();
```

Initializes the Onigmo regex library backend.

**Returns:**
- 0 on success
- Negative value on failure

#### `flb_regex_exit`

```c
void flb_regex_exit();
```

Shuts down the Onigmo regex library backend.

### Pattern Creation and Management

#### `flb_regex_create`

```c
struct flb_regex *flb_regex_create(const char *pattern);
```

Compiles a regular expression pattern into a usable regex object.

**Parameters:**
- `pattern`: Regular expression pattern string

**Returns:**
- Pointer to new regex object on success
- NULL on failure

#### `flb_regex_destroy`

```c
int flb_regex_destroy(struct flb_regex *r);
```

Frees all resources associated with a regex object.

**Parameters:**
- `r`: Regex object to destroy

**Returns:**
- 0 on success
- Negative value on failure

### Matching Operations

#### `flb_regex_match`

```c
int flb_regex_match(struct flb_regex *r, unsigned char *str, size_t slen);
```

Performs a simple match operation against a string.

**Parameters:**
- `r`: Compiled regex object
- `str`: Input string to match
- `slen`: Length of input string

**Returns:**
- 1 if match found
- 0 if no match
- Negative value on error

#### `flb_regex_do`

```c
ssize_t flb_regex_do(struct flb_regex *r, const char *str, size_t slen,
                     struct flb_regex_search *result);
```

Performs a detailed regex search operation and populates the result structure.

**Parameters:**
- `r`: Compiled regex object
- `str`: Input string to search
- `slen`: Length of input string
- `result`: Structure to hold search results

**Returns:**
- Number of matches found (0 or positive)
- -1 on error or no match

#### `flb_regex_parse`

```c
int flb_regex_parse(struct flb_regex *r, struct flb_regex_search *result,
                    void (*cb_match) (const char *,          /* name  */
                                      const char *, size_t,  /* value */
                                      void *),                  /* caller data */
                    void *data);
```

Parses named capture groups from a regex match and invokes a callback for each group.

**Parameters:**
- `r`: Compiled regex object
- `result`: Search result structure
- `cb_match`: Callback function for each named group
- `data`: User data passed to callback

**Returns:**
- Last position of match on success
- -1 on error

### Result Management

#### `flb_regex_results_get`

```c
int flb_regex_results_get(struct flb_regex_search *result, int i,
                          ptrdiff_t *start, ptrdiff_t *end);
```

Retrieves the start and end positions of a specific match group.

**Parameters:**
- `result`: Search result structure
- `i`: Index of match group (0 for full match)
- `start`: Output parameter for start position
- `end`: Output parameter for end position

**Returns:**
- 0 on success
- -1 on error

#### `flb_regex_results_release`

```c
void flb_regex_results_release(struct flb_regex_search *result);
```

Frees resources associated with search results.

**Parameters:**
- `result`: Search result structure to release

#### `flb_regex_results_size`

```c
int flb_regex_results_size(struct flb_regex_search *result);
```

Returns the number of capture groups in the search results.

**Parameters:**
- `result`: Search result structure

**Returns:**
- Number of capture groups
- -1 on error

## Helper Functions

### `cb_onig_named`

Internal callback function that processes named capture groups during regex parsing.

### `check_option`

Parses regex options from a pattern string (e.g., `/pattern/options`).

### `str_to_regex`

Converts a string pattern to a compiled Onigmo regex object, handling various pattern formats.

## Dependencies

This module depends on:

1. **Fluent Bit Core**: For basic types, memory management, and logging
2. **Onigmo Library**: For regex pattern matching functionality

## Integration with Fluent Bit

The regex module integrates with Fluent Bit's core systems:

1. **Memory Management**: Uses Fluent Bit's memory allocation functions
2. **Logging**: Uses Fluent Bit's logging infrastructure
3. **Configuration**: Supports regex patterns in various configuration contexts
4. **Parser System**: Used extensively in log parsing and data extraction

## Pattern Format Support

The regex implementation supports several pattern formats:

### Standard Patterns
- Simple patterns without delimiters: `pattern`

### Delimited Patterns
- Ruby-style patterns: `/pattern/`
- Patterns with options: `/pattern/options`

### Supported Options
- `m`: Multiline mode
- `i`: Case-insensitive matching
- `x`: Extended mode (ignores whitespace)

## Named Capture Groups

The implementation fully supports named capture groups using the Onigmo library's naming convention:

```regex
(?<name>pattern)
```

These can be accessed through the `flb_regex_parse` function with a callback.

## Thread Safety

The regex implementation is designed to be thread-safe:

1. **Reentrant Functions**: No static or global state
2. **Immutable Parameters**: Functions don't modify input parameters
3. **Session Isolation**: Each regex operation has isolated resources

## Performance Characteristics

The regex implementation is optimized for performance:

1. **Compiled Patterns**: Patterns are compiled once and reused
2. **Efficient Memory**: Proper memory management with no leaks
3. **Minimal Overhead**: Direct integration with Onigmo library

## Error Handling

The regex implementation follows robust error handling practices:

1. **Null Pointer Checks**: Validates all input parameters
2. **Resource Cleanup**: Proper cleanup on error conditions
3. **Return Value Conventions**: Uses standard Fluent Bit return value conventions
4. **Logging**: Appropriate error logging through Fluent Bit's logging system

## Usage Example

The regex module is typically used as follows:

```c
struct flb_regex *re;
struct flb_regex_search result;

// Initialize regex library
flb_regex_init();

// Create regex pattern
re = flb_regex_create("(?<time>\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}) (?<level>\w+) (?<message>.*)");

if (re != NULL) {
    // Perform search
    if (flb_regex_do(re, log_line, strlen(log_line), &result) > 0) {
        // Process named capture groups
        flb_regex_parse(re, &result, process_group_callback, user_data);
        
        // Clean up results
        flb_regex_results_release(&result);
    }
    
    // Destroy regex
    flb_regex_destroy(re);
}

// Shutdown regex library
flb_regex_exit();
```

## Security Considerations

The regex implementation includes several security features:

1. **Input Validation**: Validates all regex patterns and input strings
2. **Buffer Bounds**: Prevents buffer overflows
3. **Resource Limits**: Enforces reasonable size limits
4. **Memory Safety**: Proper cleanup of all resources

## Extensibility

The design allows for easy extension:

1. **New Options**: Can add support for additional regex options
2. **Custom Callbacks**: Flexible callback mechanism for processing matches
3. **Pattern Formats**: Support for additional pattern syntaxes
4. **Backend Replacement**: Modular design allows for alternative regex backends