# flb_ml_mode.c Documentation

## Overview

This file contains the implementation for managing different multiline parsing modes in Fluent Bit. It provides factory functions for creating multiline contexts based on predefined modes and handles the creation of multiline parser definitions.

## Purpose

The primary purpose of this file is to:
1. Provide a unified interface for creating multiline contexts based on predefined modes
2. Handle the creation and initialization of multiline parser definitions
3. Route mode-specific requests to appropriate implementation functions

## Key Functions

### Mode Creation Factory
- `flb_ml_mode_create()` - Creates a multiline context based on a named mode

### Parser Definition Creation
- `flb_ml_parser_create()` - Creates a new multiline parser definition with specified parameters

## Supported Built-in Modes

### Docker Mode
- Handles multiline logs from Docker containers
- Uses ENDSWITH pattern matching on the 'log' key
- Groups by 'stream' (stdout/stderr)

### CRI Mode
- Handles multiline logs from Container Runtime Interface
- Specialized for Kubernetes container logs

### Python Mode
- Handles Python stack traces
- Configurable key for pattern matching

### Java Mode
- Handles Java stack traces
- Configurable key for pattern matching

### Go Mode
- Handles Go stack traces
- Configurable key for pattern matching

## Key Data Structures

### Multiline Mode (`struct flb_ml_mode`)
- Represents a multiline parsing mode definition
- Contains configuration parameters for the mode
- Links to parser context and rule definitions

## Important Parameters

### Mode Configuration
- `mode` - Name of the built-in mode to use
- `flush_ms` - Automatic flush timeout in milliseconds
- `key` - Key name for pattern matching (varies by mode)

### Parser Definition Parameters
- `type` - Matching type (REGEX, ENDSWITH, EQ)
- `match_str` - String to match against (for ENDSWITH/EQ)
- `negate` - Whether to negate the match condition
- `key_content` - Key containing the multiline content
- `key_group` - Key for grouping streams
- `key_pattern` - Key containing the pattern for matching
- `parser_ctx` - Parser context for preprocessing
- `parser_name` - Name of parser for delayed initialization

## Dependencies

This module depends on:
- Core Fluent Bit logging (`flb_log.h`)
- Main multiline engine (`flb_ml.h`)
- Multiline mode definitions (`flb_ml_mode.h`)
- Memory management utilities

## Notable Implementation Details

### Mode Routing
The `flb_ml_mode_create()` function acts as a router, directing requests to mode-specific implementation functions based on the requested mode name.

### Parser Configuration
The `flb_ml_parser_create()` function provides a flexible way to define multiline parsers with various configuration options, supporting different matching strategies and customization points.

### Memory Management
Proper memory allocation and cleanup is handled for all string data and list structures.

## Usage Examples

### Creating a Docker Mode Context
```c
struct flb_ml *ml = flb_ml_mode_create(config, "docker", 500, NULL);
```

### Creating a Custom Parser Definition
```c
struct flb_ml_parser *parser = flb_ml_parser_create(config,
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