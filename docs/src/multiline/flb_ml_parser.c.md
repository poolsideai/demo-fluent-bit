# flb_ml_parser.c Documentation

## Overview

This file contains the implementation for creating and managing multiline parser definitions in Fluent Bit. It provides the core functionality for defining how multiline log entries should be processed, including pattern matching, rule definitions, and parser initialization. This module serves as the foundation for all multiline processing functionality in Fluent Bit.

## Purpose

The primary purpose of this file is to provide functions for creating, configuring, and managing multiline parser definitions. These parsers define the rules and patterns used to identify when a multiline log entry is complete or when additional lines should be accumulated. The module also handles the lifecycle management of parser instances and their associated resources.

## Key Functions

### Parser Creation and Management
- `flb_ml_parser_create()` - Creates a new multiline parser definition (legacy API)
- `flb_ml_parser_create_params()` - Creates a new multiline parser definition using parameter structure (modern API)
- `flb_ml_parser_destroy()` - Cleans up a multiline parser definition
- `flb_ml_parser_destroy_all()` - Destroys all parsers in a list
- `flb_ml_parser_params_default()` - Initializes default parser parameters

### Parser Instance Management
- `flb_ml_parser_instance_create()` - Creates a runtime instance of a parser
- `flb_ml_parser_instance_destroy()` - Cleans up a parser instance
- `flb_ml_parser_instance_set()` - Sets properties on a parser instance
- `flb_ml_parser_instance_has_data()` - Checks if a parser instance has buffered data

### Parser Lookup and Initialization
- `flb_ml_parser_get()` - Retrieves a parser by name from the configuration
- `flb_ml_parser_init()` - Initializes a parser with its rules

### Built-in Parser Creation
- `flb_ml_parser_builtin_create()` - Creates all built-in multiline parsers

## Key Data Structures

### Multiline Parser (`struct flb_ml_parser`)
- Defines the configuration for a multiline parsing mode
- Contains matching rules and pattern definitions
- Links to parser context for preprocessing
- Manages key mappings for content, grouping, and pattern matching
- Maintains references to configuration and rule lists

### Multiline Parser Instance (`struct flb_ml_parser_ins`)
- Represents a runtime instance of a multiline parser
- Contains references to the parser definition and runtime state
- Manages stream associations and last processed stream IDs
- Maintains parser-specific configuration and state

### Parser Parameters (`struct flb_ml_parser_params`)
- Defines the parameter structure for creating parsers
- Provides a modern API for parser creation with better extensibility
- Contains all configuration options for a multiline parser

## Important Parameters

### Parser Definition Parameters
- `type` - Matching type (REGEX, ENDSWITH, EQ) for determining multiline boundaries
- `match_str` - String to match against (for ENDSWITH/EQ matching strategies)
- `negate` - Whether to negate the match condition for inverse logic
- `flush_ms` - Automatic flush timeout in milliseconds for pending messages
- `key_content` - Key containing the multiline content to be processed
- `key_group` - Key for grouping streams to separate different log categories
- `key_pattern` - Key containing the pattern for regex-based matching
- `parser_ctx` - Parser context for preprocessing log entries before multiline processing
- `parser_name` - Name of parser for delayed initialization (resolved at runtime)

### Parser Parameters Structure
- `size` - Size of the parameter structure for version checking
- `name` - Name of the parser
- `type` - Matching type for the parser
- `match_str` - Match string for ENDSWITH/EQ types
- `negate` - Negation flag for match logic
- `flush_ms` - Flush timeout in milliseconds
- `key_content` - Key for content extraction
- `key_group` - Key for stream grouping
- `key_pattern` - Key for pattern matching
- `parser_ctx` - Immediate parser context
- `parser_name` - Name for delayed parser initialization

## Dependencies

This module depends on:
- Core Fluent Bit libraries (`flb_info.h`, `flb_mem.h`, `flb_log.h`) for basic functionality
- String data structures (`flb_sds.h`) for efficient string operations
- Regular expression processing (`flb_regex.h`) for pattern matching
- Linked list utilities (`mk_list.h`) for data structure management
- Main multiline engine (`flb_ml.h`) for integration with core functionality
- Parser definitions (`flb_parser.h`) for preprocessing capabilities
- Rule processing (`flb_ml_rule.h`) for regex-based multiline patterns
- Group management (`flb_ml_group.h`) for stream grouping
- Mode definitions (`flb_ml_mode.h`) for mode-specific functionality

## Notable Implementation Details

### Dual API Design
The module provides both a legacy positional-arguments API (`flb_ml_parser_create`) and a modern parameter-structure API (`flb_ml_parser_create_params`). The legacy API is implemented as a thin wrapper around the modern API for backward compatibility.

### Parameter Validation
The `flb_ml_parser_create_params` function includes comprehensive parameter validation to ensure proper initialization and prevent common configuration errors.

### Rule-Based Processing
For REGEX-type parsers, the system uses a state machine approach where rules define transitions between states. This allows for complex multiline patterns where different parts of a message may have different characteristics.

### Flexible Matching Strategies
The parser supports three matching types:
- REGEX: Full regular expression pattern matching for complex patterns
- ENDSWITH: Simple string suffix matching for straightforward cases
- EQ: Exact string matching for precise boundary detection

### Delayed Parser Initialization
Parsers can be defined with a parser name rather than an immediate parser context, allowing for deferred initialization when the parser is actually needed. This is useful for configuration scenarios where parser dependencies may not be immediately available.

### Key Mapping Flexibility
The system supports mapping different keys for content, grouping, and pattern matching, providing flexibility for various log formats and structures.

### Built-in Parser Registration
The `flb_ml_parser_builtin_create` function initializes all built-in multiline parsers and registers them with the configuration system, making them available for use by input plugins.

### Instance Property Override
Parser instances can override specific properties (key_content, key_pattern, key_group) at runtime using the `flb_ml_parser_instance_set` function, allowing for dynamic configuration adjustments.

### Automatic Resource Management
All allocated resources are properly tracked and freed during cleanup operations, preventing memory leaks and ensuring consistent resource management.

## Algorithm Overview

The parser creation and management follows this process:
1. Parameters are validated and processed
2. Memory is allocated for the parser structure
3. String data is duplicated and stored
4. Parser is linked to the configuration registry
5. Built-in parsers are created during initialization
6. Runtime instances are created as needed
7. Resources are cleaned up during destruction

## Memory Management

The implementation uses Fluent Bit's memory management utilities (`flb_calloc`, `flb_free`) for consistent memory handling. String data is managed using the SDS (String Data Structure) library for efficient operations and automatic resizing. All allocated resources are properly tracked and freed during cleanup operations.

## Thread Safety

The parser management functions are designed to be thread-safe in multi-threaded environments, using appropriate locking mechanisms where necessary to protect shared configuration data structures.

## Error Handling

The functions return specific error codes:
- Valid pointer to parser/instance indicates success
- NULL indicates failure due to invalid parameters or resource allocation issues
- `-1` indicates general failure for integer-returning functions

Resource allocation failures are handled gracefully with proper cleanup of partially allocated resources.

## Usage Examples

### Creating a Simple ENDSWITH Parser (Legacy API)
```c
struct flb_ml_parser *parser = flb_ml_parser_create(config,
    "simple_mode",
    FLB_ML_ENDSWITH,
    "\n",
    FLB_FALSE,
    1000,
    "message",
    NULL,
    NULL,
    NULL,
    NULL);
```

### Creating a Parser with Parameters (Modern API)
```c
struct flb_ml_parser_params p = flb_ml_parser_params_default("regex_mode");
p.type = FLB_ML_REGEX;
p.flush_ms = 2000;
p.key_content = "log";
p.key_group = "stream";

struct flb_ml_parser *parser = flb_ml_parser_create_params(config, &p);
```

### Creating a REGEX-Based Parser with Rules
```c
struct flb_ml_parser *parser = flb_ml_parser_create(config,
    "regex_mode",
    FLB_ML_REGEX,
    NULL,
    FLB_FALSE,
    2000,
    "log",
    "stream",
    NULL,
    NULL,
    NULL);

// Add rules for the parser
struct flb_ml_rule *start_rule = flb_ml_rule_create(parser, "start");
struct flb_ml_rule *continue_rule = flb_ml_rule_create(parser, "continue");
struct flb_ml_rule *end_rule = flb_ml_rule_create(parser, "end");

flb_ml_parser_add_rule(parser, start_rule);
```

### Creating a Parser Instance
```c
struct flb_ml_parser_ins *instance = flb_ml_parser_instance_create(ml, "docker");
```

### Setting Instance Properties
```c
int result = flb_ml_parser_instance_set(instance, "key_content", "custom_message");
```

## Configuration and Customization

Multiline parsers can be customized through:
- Different matching types for various log formats
- Custom flush timeouts based on log volume expectations
- Parser contexts for preprocessing log entries
- Delayed parser initialization using parser names
- Key mappings for different log structures
- Rule definitions for complex multiline patterns

## Performance Considerations

For optimal performance:
1. Use appropriate matching types (ENDSWITH for simple cases, REGEX for complex patterns)
2. Configure flush timeouts based on log volume and latency requirements
3. Use parser contexts for efficient preprocessing
4. Monitor memory usage for high-volume log processing
5. Leverage key mappings to minimize string operations

## Integration Points

This module integrates with:
- The main multiline engine (`flb_ml.c`) for context creation
- Rule processing (`flb_ml_rule.c`) for regex-based multiline patterns
- Group management (`flb_ml_group.c`) for stream grouping
- Mode definitions (`flb_ml_mode.c`) for mode-specific functionality
- The Fluent Bit configuration system for parser registration
- Input plugins for multiline processing integration

## Testing and Debugging

Debugging can be enabled through Fluent Bit's logging system. Invalid parameters are reported with descriptive error messages to aid in troubleshooting configuration issues. The built-in parser creation function provides detailed error reporting for initialization failures.