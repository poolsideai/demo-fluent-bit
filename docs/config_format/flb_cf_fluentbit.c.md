# flb_cf_fluentbit.c

## Overview

This file implements the classic Fluent Bit configuration format parser. It provides functionality to parse traditional `.conf` files with bracket-style sections and key-value pairs, supporting features like file inclusion, indentation validation, and metadata handling.

## Key Functions

### Configuration Parser

- `flb_cf_fluentbit_create()`: Main entry point to create and parse a Fluent Bit configuration
- `read_config()`: Core function to read and parse configuration files
- `local_init()`: Initializes the local parsing context
- `local_exit()`: Cleans up the local parsing context

### File Operations

- `read_glob()`: Handles glob pattern matching for included files (cross-platform implementation)
- `is_file_included()`: Checks if a file has already been included to prevent circular references

### Indentation and Structure Validation

- `check_indent()`: Validates indentation levels in configuration files
- `char_search()`: Helper function to find characters in strings

### Error Handling

- `config_error()`: Reports configuration errors with file and line information
- `config_warn()`: Reports configuration warnings with file and line information

### String Utilities

- `static_fgets()`: Custom fgets implementation for static configuration buffers
- `strtok_concurrent()`: Cross-platform concurrent-safe string tokenizer

## Important Constants

### File Limits
- `FLB_CF_FILE_NUM_LIMIT`: 1000 - Maximum number of configuration files that can be processed

### Indentation Return Codes
- `INDENT_ERROR`: -1 - Invalid indentation detected
- `INDENT_OK`: 0 - Valid indentation level
- `INDENT_GROUP_CONTENT`: 1 - Group content indentation level

### Buffer Sizes
- `FLB_DEFAULT_CF_BUF_SIZE`: Default buffer size for reading configuration lines

### Line Hard Limit
- `line_hard_limit`: 32 * 1024 * 1024 (32MiB) - Maximum line size limit

## Data Structures

### `struct local_file`
Represents an included configuration file with:
- File path (`path`)
- Linked list entry (`_head`)

### `struct local_ctx`
Local parsing context with:
- Current nesting level (`level`)
- Current file name (`file`)
- Root path for relative file resolution (`root_path`)
- List of included files (`includes`)
- List of metadata properties (`metas`)
- List of configuration sections (`sections`)

## Dependencies

- `<fluent-bit/flb_info.h>`: General information and utilities
- `<fluent-bit/flb_config_format.h>`: Core configuration format functionality
- `<fluent-bit/flb_sds.h>`: String data structures
- `<fluent-bit/flb_log.h>`: Logging functions
- `<fluent-bit/flb_mem.h>`: Memory management functions
- `<fluent-bit/flb_kv.h>`: Key-value pair functionality
- `<fluent-bit/flb_compat.h>`: Compatibility layer
- `<monkey/mk_core.h>`: Monkey core utilities
- `<ctype.h>`: Character type functions
- `<sys/types.h>`: System type definitions
- `<sys/stat.h>`: File status functions
- `<glob.h>`: Glob pattern matching (Unix/Linux)
- `<Windows.h>`: Windows API functions (Windows)
- `<strsafe.h>`: Windows string safety functions (Windows)

## Implementation Details

### Configuration File Format

The parser supports the classic Fluent Bit configuration format:

```ini
[SERVICE]
    Flush 1
    Log_Level info

[INPUT]
    Name cpu
    Tag cpu.local

[OUTPUT]
    Name stdout
    Match *
```

Key features:
- Bracket-style section definitions `[SECTION_NAME]`
- Indentation-based grouping of key-value pairs
- Support for nested groups with `[GROUP_NAME]` syntax
- Comment support with `#` prefix
- File inclusion with `@INCLUDE path` directive
- Glob pattern support for included files

### Indentation Validation

The parser enforces strict indentation rules:
- Consistent use of tabs or spaces (not mixed)
- Proper nesting levels for grouped properties
- Validation of group content indentation

### File Inclusion

Supports including other configuration files:
- Relative and absolute path resolution
- Glob pattern matching for multiple files
- Circular reference detection
- File system inode tracking to prevent duplicate processing

### Cross-Platform Compatibility

- Windows and Unix/Linux glob pattern implementations
- Path separator handling for different operating systems
- File system operations adapted for each platform

### Memory Management

- Uses SDS (Simple Dynamic Strings) for efficient string handling
- Proper cleanup of allocated resources
- Buffer resizing for long configuration lines
- Linked list management for sections and properties

### Error Handling

Comprehensive error reporting:
- Line-specific error messages
- File path identification
- Warning levels for non-critical issues
- Graceful degradation for recoverable errors

## Usage Example

```c
// Parse a Fluent Bit configuration file
struct flb_cf *cf = flb_cf_fluentbit_create(NULL, "/path/to/fluent-bit.conf", NULL, 0);

if (cf) {
    // Access configuration sections
    struct flb_cf_section *section;
    struct mk_list *head;
    
    mk_list_foreach(head, &cf->sections) {
        section = mk_list_entry(head, struct flb_cf_section, _head);
        printf("Section: %s\n", section->name);
        
        // Access properties in the section
        struct flb_cf_property *prop;
        struct mk_list *prop_head;
        
        mk_list_foreach(prop_head, &section->properties) {
            prop = mk_list_entry(prop_head, struct flb_cf_property, _head);
            printf("  %s = %s\n", prop->key, prop->val);
        }
    }
    
    // Clean up
    flb_cf_destroy(cf);
} else {
    flb_error("Failed to parse configuration file");
}

// Example configuration file content:
/*
[SERVICE]
    Flush 1
    Log_Level info
    Daemon off

[INPUT]
    Name cpu
    Tag cpu.local

[OUTPUT]
    Name stdout
    Match *
*/
```