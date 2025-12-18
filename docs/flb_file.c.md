# flb_file.c

## Overview

This file implements basic file I/O operations for Fluent Bit. It provides functionality for reading files into memory buffers, which is essential for various Fluent Bit operations such as loading configuration files, reading environment variable values from files, and processing file-based inputs.

The file I/O system is designed to be simple and efficient, focusing on reading entire files into memory buffers that can then be processed by other Fluent Bit components.

## Key Functions

### `flb_file_read()`
Reads an entire file into a memory buffer and returns it as an SDS (Simple Dynamic String). This is the primary function for file reading operations in Fluent Bit.

## Important Variables/Constants

### File Reading Process
The file reading operation follows these steps:
1. Open the file in binary read mode
2. Seek to the end to determine file size
3. Return to the beginning of the file
4. Allocate an SDS buffer of appropriate size
5. Read the entire file content into the buffer
6. Null-terminate the buffer and set SDS length

### Error Handling
- Returns NULL on failure with appropriate error logging
- Properly cleans up resources (file handles, memory) on error
- Uses `goto err` pattern for centralized error handling

## Dependencies

- `fluent-bit/flb_file.h`: File I/O interface
- `fluent-bit/flb_log.h`: Logging utilities
- `fluent-bit/flb_mem.h`: Memory management utilities
- `fluent-bit/flb_sds.h`: Simple Dynamic String utilities
- `stdio.h`: Standard I/O operations

## Implementation Details

1. **Binary Mode Reading**: Files are opened in binary mode (`"rb"`) to ensure consistent behavior across different platforms.

2. **Complete File Reading**: The implementation reads the entire file content rather than streaming, which is appropriate for configuration files and small data files.

3. **Memory Efficiency**: Uses SDS strings which provide efficient memory management and automatic length tracking.

4. **Robust Error Handling**: Comprehensive error checking at each step of the file reading process with proper resource cleanup.

5. **Null Termination**: Ensures the returned buffer is null-terminated for safe string operations.

## Usage Example

```c
// Read a configuration file
const char *config_path = "/etc/fluent-bit/fluent-bit.conf";
flb_sds_t config_content = flb_file_read(config_path);

if (!config_content) {
    flb_error("Failed to read configuration file: %s", config_path);
    return -1;
}

// Process the configuration content
int ret = flb_config_load_buffer(config, config_content);

// Clean up
flb_sds_destroy(config_content);

// Read environment variable from file
const char *env_file = "/etc/fluent-bit/api-key.txt";
flb_sds_t api_key = flb_file_read(env_file);
if (api_key) {
    flb_env_set(env, "API_KEY", api_key);
    flb_sds_destroy(api_key);
}
```