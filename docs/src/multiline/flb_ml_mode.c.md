# flb_ml_mode.c Documentation

## Overview

This file contains the implementation for managing different multiline parsing modes in Fluent Bit. It provides factory functions for creating multiline contexts based on predefined modes and handles the creation of multiline parser definitions. This module serves as the entry point for configuring multiline processing with different built-in modes.

## Purpose

The primary purpose of this file is to:
1. Provide a unified interface for creating multiline contexts based on predefined modes
2. Handle the creation and initialization of multiline parser definitions
3. Route mode-specific requests to appropriate implementation functions
4. Manage the lifecycle of multiline mode configurations

## Key Functions

### Mode Creation Factory
- `flb_ml_mode_create()` - Creates a multiline context based on a named mode with configurable parameters

### Mode Definition Creation
- `flb_ml_parser_create()` - Creates a new multiline mode definition with specified parameters and configuration options

## Supported Built-in Modes

### Docker Mode
- Handles multiline logs from Docker containers
- Uses ENDSWITH pattern matching on the 'log' key
- Groups by 'stream' (stdout/stderr) for proper separation
- Designed for Docker's JSON log format specifications

### CRI Mode
- Handles multiline logs from Container Runtime Interface
- Specialized for Kubernetes container logs
- Optimized for CRI log format requirements

### Python Mode
- Handles Python stack traces
- Configurable key for pattern matching
- Designed to recognize Python exception formatting

### Java Mode
- Handles Java stack traces
- Configurable key for pattern matching
- Recognizes Java exception and stack trace patterns

### Go Mode
- Handles Go stack traces
- Configurable key for pattern matching
- Optimized for Go runtime error formatting

## Key Data Structures

### Multiline Mode (`struct flb_ml_mode`)
- Represents a multiline parsing mode definition
- Contains configuration parameters for the mode
- Links to parser context and rule definitions
- Manages stream and regex rule lists
- Maintains string references for key names and match patterns

## Important Parameters

### Mode Configuration
- `mode` - Name of the built-in mode to use (docker, cri, python, java, go)
- `flush_ms` - Automatic flush timeout in milliseconds for pending messages
- `key` - Key name for pattern matching (varies by mode and usage)

### Parser Definition Parameters
- `type` - Matching type (REGEX, ENDSWITH, EQ) for determining multiline boundaries
- `match_str` - String to match against (for ENDSWITH/EQ matching strategies)
- `negate` - Whether to negate the match condition for inverse logic
- `key_content` - Key containing the multiline content to be processed
- `key_group` - Key for grouping streams to separate different log categories
- `key_pattern` - Key containing the pattern for regex-based matching
- `parser_ctx` - Parser context for preprocessing log entries before multiline processing
- `parser_name` - Name of parser for delayed initialization (resolved at runtime)

## Dependencies

This module depends on:
- Core Fluent Bit logging (`flb_log.h`) for error reporting and debugging
- Main multiline engine (`flb_ml.h`) for integration with core functionality
- Multiline mode definitions (`flb_ml_mode.h`) for data structure definitions
- Memory management utilities (`flb_mem.h`) for allocation and deallocation
- String data structures (`flb_sds.h`) for efficient string operations
- Linked list utilities (`mk_list.h`) for data structure management

## Notable Implementation Details

### Mode Routing
The `flb_ml_mode_create()` function acts as a router, directing requests to mode-specific implementation functions based on the requested mode name. This design allows for easy extension with new built-in modes without modifying the routing logic.

### Parser Configuration
The `flb_ml_parser_create()` function provides a flexible way to define multiline modes with various configuration options, supporting different matching strategies and customization points. It handles memory allocation for all string parameters and integrates with the main Fluent Bit configuration system.

### Memory Management
Proper memory allocation and cleanup is handled for all string data and list structures. The implementation uses Fluent Bit's memory management utilities to ensure consistency with the broader codebase.

### Error Handling
Invalid mode names are reported through the logging system, and memory allocation failures are handled gracefully with proper cleanup of partially allocated resources.

### Integration with Configuration System
Parser definitions are automatically added to the main Fluent Bit configuration's multiline parsers list, ensuring they are available for use by input plugins and other components.

## Algorithm Overview

The mode creation process follows these steps:
1. Validate the requested mode name against supported built-in modes
2. Route to the appropriate mode-specific implementation function
3. Create and configure the multiline context with mode-specific settings
4. Return the initialized context for use by the calling code

## Thread Safety

The mode creation functions are designed to be thread-safe in multi-threaded environments, using appropriate locking mechanisms where necessary to protect shared configuration data structures.

## Error Handling

The functions return specific error codes:
- Valid pointer to multiline context indicates success
- NULL indicates failure due to invalid mode name or resource allocation issues

## Usage Examples

### Creating a Docker Mode Context
```c
struct flb_ml *ml = flb_ml_mode_create(config, "docker", 500, NULL);
```

### Creating a Custom Mode Definition
```c
struct flb_ml_mode *parser = flb_ml_parser_create(config,
    "custom_mode",
    FLB_ML_ENDSWITH,
    "\n",
    FLB_FALSE,
    1000,
    "message",
    "stream",
    NULL,
    parser_ctx,
    NULL);
    "custom_mode",
    FLB_ML_ENDSWITH,
    "\n",
    FLB_FALSE,
    1000,
    "message",
    "stream",
    NULL,
    parser_ctx,
    NULL);
```

### Creating a Python Mode Context with Custom Key
```c
struct flb_ml *ml = flb_ml_mode_create(config, "python", 1000, "log_message");
```

## Configuration and Customization

Multiline modes can be customized through:
- Different flush timeouts based on log volume expectations
- Custom key names for matching and grouping
- Parser contexts for preprocessing log entries
- Delayed parser initialization using parser names

## Performance Considerations

For optimal performance:
1. Use appropriate flush timeouts to balance latency and resource usage
2. Configure keys correctly to match the actual log format
3. Leverage parser contexts for efficient preprocessing
4. Monitor memory usage for high-volume log processing

## Integration Points

This module integrates with:
- The main multiline engine (`flb_ml.c`) for context creation
- Built-in mode implementations (`flb_ml_parser_*.c`) for mode-specific processing
- The Fluent Bit configuration system for mode registration
- Input plugins for multiline processing integration

## Testing and Debugging

Debugging can be enabled through Fluent Bit's logging system. Invalid mode names are reported with descriptive error messages to aid in troubleshooting configuration issues.