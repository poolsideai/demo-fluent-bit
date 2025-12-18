# include/fluent-bit/flb_regex.h

## Overview

The `flb_regex.h` header file defines the interface for Fluent Bit's regular expression functionality. This header provides the necessary declarations for using regex pattern matching within Fluent Bit, particularly for parsing log data and configuration files.

## Header Guards

```c
#ifndef FLB_REGEX_H
#define FLB_REGEX_H

/* ... */

#endif
```

Standard header guards prevent multiple inclusion of the header file.

## Conditional Compilation

```c
#ifdef FLB_HAVE_REGEX

/* ... */

#endif
```

The entire regex functionality is conditionally compiled based on the `FLB_HAVE_REGEX` build configuration flag.

## Included Dependencies

### Core Fluent Bit Headers

```c
#include <fluent-bit/flb_info.h>
```

Basic Fluent Bit types and version information.

### Compatibility Header

```c
#include <fluent-bit/flb_compat.h>
```

Provides compatibility macros and definitions for different platforms.

### Standard Library Headers

```c
#include <stdlib.h>
#include <stddef.h>
```

Standard library headers for memory management and type definitions.

## Data Structures

### `struct flb_regex`

Represents a compiled regular expression pattern:

```c
struct flb_regex {
    void *regex;
};
```

**Fields:**
- `regex`: Pointer to the compiled regex object (implementation-dependent)

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
- `region`: Region object containing match information (implementation-dependent)
- `str`: Input string being searched
- `cb_match`: Callback function for named group matches
- `data`: User data passed to callback function

## Function Prototypes

### Backend Initialization Functions

#### `flb_regex_init`

```c
int flb_regex_init();
```

Initializes the regex backend library.

**Returns:**
- 0 on success
- Negative value on failure

#### `flb_regex_exit`

```c
void flb_regex_exit();
```

Shuts down the regex backend library.

### Pattern Creation and Management Functions

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

### Matching Operations Functions

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

### Result Management Functions

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

## Dependencies

This header depends on:

1. **Fluent Bit Core**: For basic types and compatibility macros
2. **Standard Library**: For memory management and type definitions
3. **FLB_HAVE_REGEX**: Build configuration flag to enable regex functionality

## Integration with Fluent Bit

The regex interface integrates with Fluent Bit's core systems:

1. **Build System**: Conditionally compiled based on build configuration
2. **Parser System**: Used extensively in log parsing and data extraction
3. **Configuration**: Supports regex patterns in various configuration contexts

## Usage Example

The regex interface is typically used as follows:

```c
#include <fluent-bit/flb_regex.h>

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

## Build Configuration

The regex functionality is controlled by the `FLB_HAVE_REGEX` build flag:

1. **Enabled**: When `FLB_HAVE_REGEX` is defined, all regex functions are available
2. **Disabled**: When `FLB_HAVE_REGEX` is not defined, all regex functions are excluded from compilation

## Related Components

This header works in conjunction with:

1. **src/flb_regex.c**: Implementation of the regex functions
2. **Parser Filters**: Use regex for pattern matching in log parsing
3. **Configuration System**: Uses regex for validation and pattern matching

## Thread Safety

The regex interface is designed to be thread-safe:

1. **Reentrant Functions**: No static or global state
2. **Immutable Parameters**: Functions don't modify input parameters
3. **Session Isolation**: Each regex operation has isolated resources

## Error Handling

The regex interface follows robust error handling practices:

1. **Null Pointer Checks**: Validates all input parameters
2. **Resource Cleanup**: Proper cleanup on error conditions
3. **Return Value Conventions**: Uses standard Fluent Bit return value conventions

## Extensibility

The design allows for easy extension:

1. **New Options**: Can add support for additional regex options
2. **Custom Callbacks**: Flexible callback mechanism for processing matches
3. **Pattern Formats**: Support for additional pattern syntaxes
4. **Backend Replacement**: Modular design allows for alternative regex backends

## Performance Considerations

The regex interface is optimized for performance:

1. **Compiled Patterns**: Patterns are compiled once and reused
2. **Efficient Memory**: Proper memory management with no leaks
3. **Minimal Overhead**: Direct integration with backend library