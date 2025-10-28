# flb_cf_yaml.c

## Overview

This file implements the YAML configuration format parser for Fluent Bit. It provides functionality to parse modern YAML-based configuration files, supporting features like file inclusion, complex data structures, and advanced configuration patterns.

## Key Functions

### Configuration Parser

- `flb_cf_yaml_create()`: Main entry point to create and parse a Fluent Bit YAML configuration
- `read_config()`: Core function to read and parse YAML configuration files
- `consume_event()`: Processes YAML events and maintains parser state
- `local_init()`: Initializes the local parsing context
- `local_exit()`: Cleans up the local parsing context

### State Management

- `state_start()`: Creates the initial parser state
- `state_push()`: Pushes a new state onto the parser stack
- `state_pop()`: Pops the current state from the parser stack
- `state_create()`: Allocates a new parser state
- `state_destroy()`: Frees a parser state

### File Operations

- `read_glob()`: Handles glob pattern matching for included files (cross-platform implementation)
- `is_file_included()`: Checks if a file has already been included to prevent circular references

### YAML Event Processing

- `consume_event()`: Main event processing function that handles all YAML events
- `print_current_state()`: Debug function to print current parser state
- `print_current_properties()`: Debug function to print current properties
- `yaml_error_event()`: Reports YAML parsing errors
- `yaml_error_definition()`: Reports duplicated definition errors
- `yaml_error_plugin_category()`: Reports invalid plugin category errors

### State Transition Functions

- `state_push_section()`: Pushes a new section state
- `state_push_key()`: Pushes a new key state
- `state_push_withvals()`: Pushes a new state with key-value list
- `state_push_witharr()`: Pushes a new state with array
- `state_push_variant()`: Pushes a new variant state
- `state_move_into_config_group()`: Moves properties into a configuration group
- `state_copy_into_properties()`: Copies properties into a properties list

### Variant Handling

- `state_variant_parse_scalar()`: Parses scalar values into appropriate variant types
- `state_variant_set_child()`: Sets a child variant in the current variant
- `parse_uint64()`: Parses unsigned 64-bit integers
- `parse_int64()`: Parses signed 64-bit integers
- `parse_double()`: Parses double precision floating point numbers

### Section and Group Creation

- `state_create_section()`: Creates a new configuration section
- `state_create_group()`: Creates a new configuration group
- `add_section_type()`: Adds a section with a specific type

## Important Constants

### Status Codes
- `YAML_SUCCESS`: 1 - Successful operation
- `YAML_FAILURE`: 0 - Failed operation

### Parser States
- `STATE_START`: Initial parser state
- `STATE_STREAM`: YAML stream state
- `STATE_DOCUMENT`: YAML document state
- `STATE_SECTION`: Top-level section state
- `STATE_SECTION_KEY`: Section key state
- `STATE_SECTION_VAL`: Section value state
- `STATE_SERVICE`: Service section state
- `STATE_INCLUDE`: Include section state
- `STATE_OTHER`: Other section state
- `STATE_CUSTOM`: Custom plugins state
- `STATE_PIPELINE`: Pipeline groups state
- `STATE_PLUGIN_INPUT`: Input plugins state
- `STATE_PLUGIN_FILTER`: Filter plugins state
- `STATE_PLUGIN_OUTPUT`: Output plugins state
- `STATE_PLUGIN_START`: Plugin start state
- `STATE_PLUGIN_KEY`: Plugin key state
- `STATE_PLUGIN_VAL`: Plugin value state
- `STATE_PLUGIN_VAL_LIST`: Plugin value list state
- `STATE_PLUGIN_VARIANT`: Plugin variant state
- `STATE_GROUP_KEY`: Group key state
- `STATE_GROUP_VAL`: Group value state
- `STATE_INPUT_PROCESSORS`: Input processors state
- `STATE_INPUT_PROCESSOR`: Input processor state
- `STATE_PARSER`: Parser section state
- `STATE_PARSER_ENTRY`: Parser entry state
- `STATE_PARSER_KEY`: Parser key state
- `STATE_PARSER_VALUE`: Parser value state
- `STATE_MULTILINE_PARSER`: Multiline parser section state
- `STATE_MULTILINE_PARSER_ENTRY`: Multiline parser entry state
- `STATE_MULTILINE_PARSER_VALUE`: Multiline parser value state
- `STATE_MULTILINE_PARSER_RULE`: Multiline parser rule state
- `STATE_STREAM_PROCESSOR`: Stream processor section state
- `STATE_STREAM_PROCESSOR_ENTRY`: Stream processor entry state
- `STATE_STREAM_PROCESSOR_KEY`: Stream processor key state
- `STATE_PLUGINS`: Plugins section state
- `STATE_UPSTREAM_SERVERS`: Upstream servers section state
- `STATE_UPSTREAM_SERVER`: Upstream server state
- `STATE_UPSTREAM_SERVER_VALUE`: Upstream server value state
- `STATE_UPSTREAM_NODE_GROUP`: Upstream node group state
- `STATE_UPSTREAM_NODE`: Upstream node state
- `STATE_UPSTREAM_NODE_VALUE`: Upstream node value state
- `STATE_ENV`: Environment variables state
- `STATE_STOP`: End parser state

### Section Types
- `SECTION_ENV`: Environment variables section
- `SECTION_INCLUDE`: Include files section
- `SECTION_SERVICE`: Service configuration section
- `SECTION_PIPELINE`: Pipeline configuration section
- `SECTION_CUSTOM`: Custom plugins section
- `SECTION_INPUT`: Input plugins section
- `SECTION_FILTER`: Filter plugins section
- `SECTION_OUTPUT`: Output plugins section
- `SECTION_PROCESSOR`: Processor plugins section
- `SECTION_PARSER`: Parser definitions section
- `SECTION_MULTILINE_PARSER`: Multiline parser definitions section
- `SECTION_MULTILINE_PARSER_RULE`: Multiline parser rule section
- `SECTION_STREAM_PROCESSOR`: Stream processor definitions section
- `SECTION_PLUGINS`: External plugin paths section
- `SECTION_UPSTREAM_SERVERS`: Upstream servers section
- `SECTION_OTHER`: Other sections

### Allocation Flags
- `HAS_KEY`: Key has been allocated
- `HAS_KEYVALS`: Key-value list has been allocated

## Data Structures

### `struct file_state`
Represents a file state with:
- File name (`name`)
- File root path (`path`)
- Parent file state (`parent`)

### `struct local_ctx`
Local parsing context with:
- Current nesting level (`level`)
- List of parser states (`states`)
- List of included files (`includes`)
- Service section flag (`service_set`)

### `struct parser_state`
Parser state with:
- Current state (`state`)
- Nesting level (`level`)
- Active section type (`section`)
- Active configuration section (`cf_section`)
- Active configuration group (`cf_group`)
- Current key (`key`)
- Key-value list (`keyvals`)
- Current values array (`values`)
- Current variant (`variant`)
- Variant key for kvlist (`variant_kvlist_key`)
- Allocation flags (`allocation_flags`)
- File state (`file`)
- Linked list entry (`_head`)

## Dependencies

- `<fluent-bit/flb_info.h>`: General information and utilities
- `<fluent-bit/flb_config_format.h>`: Core configuration format functionality
- `<fluent-bit/flb_sds.h>`: String data structures
- `<fluent-bit/flb_log.h>`: Logging functions
- `<fluent-bit/flb_mem.h>`: Memory management functions
- `<fluent-bit/flb_kv.h>`: Key-value pair functionality
- `<fluent-bit/flb_slist.h>`: String list functionality
- `<cfl/cfl.h>`: CFL core functionality
- `<cfl/cfl_sds.h>`: CFL string data structures
- `<cfl/cfl_variant.h>`: CFL variant types
- `<cfl/cfl_kvlist.h>`: CFL key-value list functionality
- `<yaml.h>`: YAML parsing library
- `<ctype.h>`: Character type functions
- `<sys/types.h>`: System type definitions
- `<sys/stat.h>`: File status functions
- `<glob.h>`: Glob pattern matching (Unix/Linux)
- `<Windows.h>`: Windows API functions (Windows)
- `<strsafe.h>`: Windows string safety functions (Windows)
- `<stdio.h>`: Standard input/output functions

## Implementation Details

### Configuration File Format

The parser supports the modern Fluent Bit YAML configuration format:

```yaml
service:
  flush: 1
  log_level: info

inputs:
  - name: cpu
    tag: cpu.local

outputs:
  - name: stdout
    match: '*'
```

Key features:
- Modern YAML syntax with indentation-based structure
- Support for sequences and mappings
- Complex data structures with nested properties
- File inclusion with glob pattern support
- Multiple configuration sections (inputs, filters, outputs, etc.)
- Pipeline grouping of components
- Parser and multiline parser definitions
- Stream processor definitions
- Upstream server configurations
- Environment variable definitions
- External plugin path specifications

### State Machine Design

The parser uses a state machine approach to handle YAML events:
- Each YAML event transitions the parser to a new state
- States are pushed and popped from a stack to maintain context
- Complex nested structures are handled through state transitions
- Error recovery is implemented through state validation

### File Inclusion

Supports including other configuration files:
- Relative and absolute path resolution
- Glob pattern matching for multiple files
- Circular reference detection
- File tracking to prevent duplicate processing

### Cross-Platform Compatibility

- Windows and Unix/Linux glob pattern implementations
- Path separator handling for different operating systems
- File system operations adapted for each platform

### Memory Management

- Uses CFL (Common Fluent Library) data structures for efficient memory handling
- Proper cleanup of allocated resources
- Stack-based state management
- Linked list management for sections and properties

### Error Handling

Comprehensive error reporting:
- Line-specific error messages with file information
- Contextual hints for common parsing errors
- State validation to prevent invalid transitions
- Graceful degradation for recoverable errors

### Data Type Support

Supports various data types through CFL variants:
- Strings
- Integers (signed and unsigned)
- Floating point numbers
- Booleans
- Null values
- Arrays
- Key-value lists

## Usage Example

```c
// Parse a Fluent Bit YAML configuration file
struct flb_cf *cf = flb_cf_yaml_create(NULL, "/path/to/fluent-bit.yaml", NULL, 0);

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
    flb_error("Failed to parse YAML configuration file");
}

// Example configuration file content:
/*
service:
  flush: 1
  log_level: info
  daemon: off

inputs:
  - name: cpu
    tag: cpu.local

outputs:
  - name: stdout
    match: '*'
*/
```