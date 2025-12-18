# flb_ml_mode.c

## Overview

This file implements the built-in multiline processing modes for Fluent Bit. It provides factory functions for creating predefined multiline parsers for common use cases like Docker, CRI, Python, Java, and Go application logs.

## Key Functions

### Mode Creation Factory

- `flb_ml_mode_create()` - Creates a multiline context based on a named mode
- `flb_ml_parser_create()` - Legacy function for creating multiline parsers (deprecated)

### Built-in Mode Creators

- `flb_ml_mode_docker()` - Creates a Docker-specific multiline parser
- `flb_ml_mode_cri()` - Creates a Container Runtime Interface (CRI) multiline parser
- `flb_ml_mode_python()` - Creates a Python traceback multiline parser
- `flb_ml_mode_java()` - Creates a Java exception multiline parser
- `flb_ml_mode_go()` - Creates a Go panic/stacktrace multiline parser

## Dependencies

This module depends on:
- Fluent Bit core libraries
- Multiline processing headers
- Parser management functionality (flb_ml_parser.c)
- Built-in parser implementations

## Implementation Details

The mode system provides:
1. **Predefined Configurations**: Ready-to-use multiline parsers for common scenarios
2. **Mode Selection**: Factory pattern for creating appropriate parsers by name
3. **Backward Compatibility**: Support for legacy parser creation API
4. **Error Handling**: Proper error reporting for invalid mode names

## Usage Examples

```c
// Create a multiline context using a built-in mode
struct flb_ml *ml = flb_ml_mode_create(config, "docker", 5000, NULL);

// Or create specific modes directly
struct flb_ml *ml_docker = flb_ml_mode_docker(config, 5000);
struct flb_ml *ml_java = flb_ml_mode_java(config, 5000, "message");

// Use the multiline context
flb_ml_append_text(ml, stream_id, &timestamp, buffer, size);
```