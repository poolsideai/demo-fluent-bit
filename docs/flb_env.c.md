# flb_env.c

## Overview

This file implements the environment variable management system for Fluent Bit. It provides functionality for setting, getting, and translating environment variables within the Fluent Bit context.

The environment system allows Fluent Bit to work with both system environment variables and custom variables defined within the Fluent Bit configuration. It also supports advanced features like file-based variable values and variable interpolation in configuration strings.

## Key Functions

### `flb_env_create()`
Creates a new environment context structure and initializes it with preset useful variables.

### `flb_env_destroy()`
Cleans up and destroys an environment context, freeing all associated resources.

### `flb_env_set()`
Sets an environment variable in the Fluent Bit context, supporting both direct values and file-based values (using `file://` prefix).

### `flb_env_get()`
Retrieves the value of an environment variable, first checking the Fluent Bit context and then falling back to system environment variables.

### `flb_env_var_translate()`
Translates a string containing variable references (in `${VAR}` format) into a new string with the actual variable values substituted.

## Important Variables/Constants

### Environment Structure (`struct flb_env`)
The main environment structure contains:
- `ht`: Hash table for storing environment variables
- `warn_unused`: Flag to control warnings for unused variables

### Preset Variables
The system automatically presets several useful variables:
- `HOSTNAME`: System hostname (resolved if not available as environment variable)

### File Reference Prefix
- `file://`: Prefix used to indicate that a variable value should be read from a file

## Dependencies

- `fluent-bit/flb_info.h`: Fluent Bit core information
- `fluent-bit/flb_hash_table.h`: Hash table implementation
- `fluent-bit/flb_mem.h`: Memory management utilities
- `fluent-bit/flb_log.h`: Logging utilities
- `fluent-bit/flb_str.h`: String utilities
- `fluent-bit/flb_env.h`: Environment interface
- `fluent-bit/flb_file.h`: File operations

## Implementation Details

1. **Dual Lookup System**: Variables are first looked up in the Fluent Bit context hash table, then in system environment variables if not found.

2. **File-Based Values**: Supports reading variable values from files using the `file://` prefix, with proper error handling for missing or unreadable files.

3. **Variable Interpolation**: Provides sophisticated variable substitution in strings using the `${VAR}` syntax.

4. **Memory Management**: Uses Fluent Bit's SDS (Simple Dynamic String) system for efficient string operations.

5. **Preset Variables**: Automatically sets useful variables like `HOSTNAME` for common use cases.

6. **Unused Variable Warnings**: Optionally warns when variables are referenced but not defined.

7. **Robust Error Handling**: Gracefully handles various error conditions including file access issues and memory allocation failures.

## Usage Example

```c
// Create environment context
struct flb_env *env = flb_env_create();

// Set custom variables
flb_env_set(env, "MY_API_KEY", "secret123");
flb_env_set(env, "LOG_LEVEL", "file:///etc/fluent-bit/log-level.txt");

// Retrieve variables
const char *api_key = flb_env_get(env, "MY_API_KEY");
const char *hostname = flb_env_get(env, "HOSTNAME");

// Translate strings with variables
const char *template = "Server ${HOSTNAME} running with key ${MY_API_KEY}";
flb_sds_t translated = flb_env_var_translate(env, template);
// Result: "Server myserver running with key secret123"

// Clean up
flb_env_destroy(env);
```