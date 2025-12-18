# flb_meta.c

## Overview

This file implements the meta command system for Fluent Bit configuration. Meta commands are special configuration directives that extend the configuration capabilities beyond standard plugin configurations. These commands are prefixed with '@' in configuration files.

## Key Functions

### meta_cmd_set

Handles the `@SET` meta command which registers key/value pairs as configuration variables. This allows setting environment variables or configuration parameters that can be referenced elsewhere in the configuration.

**Parameters:**
- `ctx`: Fluent Bit configuration context
- `params`: String containing key=value pair

**Returns:** 0 on success, -1 on failure

### flb_meta_run

Main entry point for executing meta commands. It routes commands to their respective handlers based on the command name.

**Parameters:**
- `ctx`: Fluent Bit configuration context
- `cmd`: Command name (e.g., "SET")
- `params`: Command parameters

**Returns:** 0 on success, -1 on failure

## Dependencies

- `<fluent-bit/flb_info.h>`: Core Fluent Bit header
- `<fluent-bit/flb_env.h>`: Environment variable management
- `<fluent-bit/flb_mem.h>`: Memory management utilities
- `<fluent-bit/flb_meta.h>`: Meta command interface

## Important Variables

None specific to this file beyond standard Fluent Bit structures.

## Implementation Details

The meta command system parses configuration lines that start with '@' and routes them to appropriate handlers. Currently, only the `@SET` command is implemented, which allows setting key/value pairs in the environment.

The parsing logic extracts the key and value from the parameters string by looking for the '=' separator. Both key and value are dynamically allocated and then passed to the environment management system.

## Usage Examples

In Fluent Bit configuration files:

```ini
@SET my_key=my_value
@SET log_level=debug
```

These meta commands can then be referenced in other parts of the configuration using the `${my_key}` syntax.