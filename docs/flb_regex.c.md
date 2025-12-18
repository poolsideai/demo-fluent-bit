# flb_regex.c

## Overview

The `flb_regex.c` file implements regular expression functionality for Fluent Bit using the Onigmo library. This component provides a high-level API for compiling, matching, and parsing regular expressions with named capture groups.

The implementation wraps the Onigmo library to provide:
- Pattern compilation with Ruby-style syntax support
- String matching with capture group extraction
- Named capture group parsing with callback support
- Memory-safe interface for regex operations

This functionality is used throughout Fluent Bit for pattern matching in parsers, filters, and routing conditions.

## Key Functions/Components

### Core Data Structures

#### `struct flb_regex`
Main regex pattern context:
- `regex`: Pointer to the compiled Onigmo regex pattern

#### `struct flb_regex_search`
Search results context:
- `last_pos`: Last matched position
- `region`: Onigmo region data for capture groups
- `str`: Input string being searched
- `cb_match`: Callback function for named captures
- `data`: User data for callbacks

### Main Functions

#### `flb_regex_init()`
Initializes the Onigmo library. Should be called before any other regex operations.

#### `flb_regex_create(const char *pattern)`
Compiles a regular expression pattern string into a regex context. Supports Ruby-style syntax with options like `/pattern/i` for case-insensitive matching.

#### `flb_regex_destroy(struct flb_regex *r)`
Destroys a regex context and frees associated resources.

#### `flb_regex_do(...)`
Performs a regex search on a string and populates a search results structure with capture group information.

#### `flb_regex_match(...)`
Tests if a regex pattern matches a string without capturing groups.

#### `flb_regex_results_get(...)`
Retrieves the start and end positions of a specific capture group from search results.

#### `flb_regex_results_release(...)`
Frees the memory associated with search results.

#### `flb_regex_results_size(...)`
Returns the number of capture groups in search results.

#### `flb_regex_parse(...)`
Parses named capture groups from a regex pattern and invokes a callback function for each named group.

#### `flb_regex_exit()`
Shuts down the Onigmo library. Should be called when regex functionality is no longer needed.

## Important Variables/Constants

### Pattern Syntax
- Standard Onigmo/Ruby regex syntax is supported
- Options can be specified after the pattern: `/pattern/i` (case-insensitive), `/pattern/m` (multiline), `/pattern/x` (extended)
- Named capture groups: `(?<name>pattern)`

### Supported Options
- `ONIG_OPTION_MULTILINE`: Multiline mode
- `ONIG_OPTION_IGNORECASE`: Case-insensitive matching
- `ONIG_OPTION_EXTEND`: Extended syntax

## Dependencies and Relationships

This module depends on:
- `onigmo`: The Onigmo regular expression library
- `flb_mem`: Fluent Bit memory management functions
- `flb_log`: Logging functionality for error reporting

It's used by:
- Parser plugins for log pattern matching
- Filter plugins for conditional processing
- Router conditions for routing decisions
- Record accessor for regex-based field extraction

## Implementation Details

The implementation provides several key features:

1. **Ruby-style Pattern Support**: Patterns can be specified with Ruby-style delimiters and options (e.g., `/pattern/i`).

2. **Named Capture Group Parsing**: The `flb_regex_parse()` function allows iterating through named capture groups with callback functions.

3. **Memory Safety**: Proper allocation and deallocation of Onigmo resources with error checking.

4. **UTF-8 Encoding**: All regex operations use UTF-8 encoding for proper international character support.

5. **Error Handling**: Comprehensive error checking with appropriate return codes.

The pattern compilation process extracts options from the pattern string and passes them to Onigmo for proper compilation.

## Usage Examples

### Basic Pattern Matching
```c
// Initialize regex subsystem
flb_regex_init();

// Create a regex pattern
struct flb_regex *regex = flb_regex_create("^([0-9]{4}-[0-9]{2}-[0-9]{2}) ([\w\s]+)$");

// Test if pattern matches a string
unsigned char *test_str = "2023-01-15 Hello World";
int match = flb_regex_match(regex, test_str, strlen((char*)test_str));

if (match) {
    printf("Pattern matched!\n");
}

// Clean up
flb_regex_destroy(regex);
flb_regex_exit();
```

### Capture Group Extraction
```c
// Create a regex with capture groups
struct flb_regex *regex = flb_regex_create("^(?<date>[0-9]{4}-[0-9]{2}-[0-9]{2}) (?<message>[\w\s]+)$");

// Search string and get results
const char *test_str = "2023-01-15 Hello World";
struct flb_regex_search result;
ssize_t groups = flb_regex_do(regex, test_str, strlen(test_str), &result);

if (groups > 0) {
    // Extract first capture group (date)
    ptrdiff_t start, end;
    if (flb_regex_results_get(&result, 1, &start, &end) == 0) {
        char date[32];
        strncpy(date, test_str + start, end - start);
        date[end - start] = '\0';
        printf("Date: %s\n", date);
    }
    
    // Extract second capture group (message)
    if (flb_regex_results_get(&result, 2, &start, &end) == 0) {
        char message[128];
        strncpy(message, test_str + start, end - start);
        message[end - start] = '\0';
        printf("Message: %s\n", message);
    }
}

// Clean up results
flb_regex_results_release(&result);
```

### Named Capture Group Parsing
```c
// Callback function for named groups
void print_named_group(const char *name, const char *value, size_t len, void *data) {
    printf("Named group '%s': %.*s\n", name, (int)len, value);
}

// Parse named capture groups
struct flb_regex_search result;
struct flb_regex *regex = flb_regex_create("^(?<date>[0-9]{4}-[0-9]{2}-[0-9]{2}) (?<message>[\w\s]+)$");

const char *test_str = "2023-01-15 Hello World";
int ret = flb_regex_do(regex, test_str, strlen(test_str), &result);

if (ret > 0) {
    // Parse named groups
    flb_regex_parse(regex, &result, print_named_group, NULL);
}

flb_regex_results_release(&result);
```