# flb_ml_parser.c

## Overview

This file implements the parser management functionality for the multiline processing system in Fluent Bit. It handles creation, initialization, and destruction of multiline parsers, including both built-in and custom parsers.

## Key Functions

### Parser Creation

- `flb_ml_parser_create_params()` - Creates a multiline parser using parameter structure (preferred method)
- `flb_ml_parser_create()` - Legacy function for creating multiline parsers
- `flb_ml_parser_get()` - Retrieves a registered multiline parser by name

### Parser Instance Management

- `flb_ml_parser_instance_create()` - Creates a runtime instance of a multiline parser
- `flb_ml_parser_instance_set()` - Overrides parser properties for a specific instance
- `flb_ml_parser_instance_destroy()` - Destroys a parser instance and its resources

### Parser Lifecycle

- `flb_ml_parser_init()` - Initializes a parser with its rules
- `flb_ml_parser_destroy()` - Destroys a parser and its resources
- `flb_ml_parser_destroy_all()` - Destroys all parsers in a list

### Built-in Parser Initialization

- `flb_ml_parser_builtin_create()` - Creates all built-in multiline parsers

### Data Structure Management

- `flb_ml_parser_params_default()` - Creates default parameter structure for parser creation
- `flb_ml_parser_instance_has_data()` - Checks if a parser instance has buffered data

## Important Data Structures

### flb_ml_parser
Represents a multiline parser definition with:
- Parser name and type (REGEX, ENDSWITH, EQ)
- Pattern matching configuration
- Key field names for content, pattern, and grouping
- Flush timeout settings
- Associated parser context
- List of regex rules for complex pattern matching

### flb_ml_parser_ins
Represents a runtime instance of a multiline parser with:
- Reference to the parent parser definition
- Runtime-specific key overrides
- Last stream processing information
- List of associated streams

### flb_ml_parser_params
Parameter structure for creating parsers with:
- Parser name and type
- Matching string and negation settings
- Flush timeout
- Key field names for different processing modes
- Associated parser context

## Dependencies

This module depends on:
- Fluent Bit core libraries (flb_mem, flb_log, flb_sds)
- Multiline processing headers
- Rule processing functionality (flb_ml_rule.c)
- Group processing functionality (flb_ml_group.c)
- Stream processing functionality (flb_ml_stream.c)

## Implementation Details

The parser management system provides:
1. **Flexible Parser Creation**: Support for both legacy and modern parameter-based creation
2. **Runtime Instances**: Ability to create multiple instances of the same parser with different configurations
3. **Property Overrides**: Instance-specific customization of parser properties
4. **Resource Management**: Comprehensive cleanup of all parser resources
5. **Built-in Parser Support**: Factory functions for common multiline scenarios
6. **Rule Integration**: Proper initialization and mapping of regex rules

## Usage Examples

```c
// Create a multiline parser using modern parameter approach
struct flb_ml_parser_params params = flb_ml_parser_params_default("my_parser");
params.type = FLB_ML_REGEX;
params.match_str = "pattern";
params.flush_ms = 5000;
struct flb_ml_parser *parser = flb_ml_parser_create_params(config, &params);

// Create a parser instance
struct flb_ml_parser_ins *instance = flb_ml_parser_instance_create(ml_context, "my_parser");

// Override instance properties
flb_ml_parser_instance_set(instance, "key_content", "message");

// Check if instance has buffered data
if (flb_ml_parser_instance_has_data(instance)) {
    // Process buffered data
}

// Clean up
flb_ml_parser_instance_destroy(instance);
flb_ml_parser_destroy(parser);
```