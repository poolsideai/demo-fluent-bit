# flb_utils.c

## Overview

The `flb_utils.c` file provides a collection of utility functions for Fluent Bit. This module contains various helper functions for string manipulation, file operations, URL parsing, time handling, and system utilities.

## Key Functions

### Error Handling Functions

#### `flb_utils_error`

```c
void flb_utils_error(int err)
```

Handles standardized error messages for common Fluent Bit errors.

- **Parameters**: 
  - `err`: Error code constant
- **Notes**: Exits the program with failure for critical errors

#### `flb_utils_error_c`

```c
void flb_utils_error_c(const char *msg)
```

Handles custom error messages.

- **Parameters**: 
  - `msg`: Custom error message string
- **Notes**: Exits the program with failure

#### `flb_utils_warn_c`

```c
void flb_utils_warn_c(const char *msg)
```

Prints warning messages to stderr.

- **Parameters**: 
  - `msg`: Warning message string

### Daemon Mode

#### `flb_utils_set_daemon`

```c
int flb_utils_set_daemon(struct flb_config *config)
```

Runs the current process in background mode (daemon mode).

- **Parameters**: 
  - `config`: Fluent Bit configuration context
- **Returns**: 0 on success, -1 on failure
- **Notes**: Uses fork() and sets up a new session

### Configuration Printing

#### `flb_utils_print_setup`

```c
void flb_utils_print_setup(struct flb_config *config)
```

Prints the current Fluent Bit configuration setup to stdout.

- **Parameters**: 
  - `config`: Fluent Bit configuration context

### String Splitting Functions

#### `flb_utils_split`

```c
struct mk_list *flb_utils_split(const char *line, int separator, int max_split)
```

Splits a string by a separator character.

- **Parameters**: 
  - `line`: Input string to split
  - `separator`: Character to split on
  - `max_split`: Maximum number of splits (0 for unlimited)
- **Returns**: Linked list of split entries, or NULL on failure

#### `flb_utils_split_quoted`

```c
struct mk_list *flb_utils_split_quoted(const char *line, int separator, int max_split)
```

Splits a string by a separator character, respecting quoted strings.

- **Parameters**: 
  - `line`: Input string to split
  - `separator`: Character to split on
  - `max_split`: Maximum number of splits (0 for unlimited)
- **Returns**: Linked list of split entries, or NULL on failure

### Timer Functions

#### `flb_utils_timer_consume`

```c
int flb_utils_timer_consume(flb_pipefd_t fd)
```

Consumes a timer event from a pipe.

- **Parameters**: 
  - `fd`: Pipe file descriptor
- **Returns**: 0 on success, -1 on failure

### Size Conversion Functions

#### `flb_utils_size_to_bytes`

```c
int64_t flb_utils_size_to_bytes(const char *size)
```

Converts a human-readable size string to bytes.

- **Parameters**: 
  - `size`: Size string (e.g., "1K", "2M", "3G")
- **Returns**: Size in bytes, or -1 on failure
- **Examples**: "1K" → 1000, "1M" → 1000000, "1G" → 1000000000

#### `flb_utils_size_to_binary_bytes`

```c
int64_t flb_utils_size_to_binary_bytes(const char *size)
```

Converts a human-readable size string to binary bytes.

- **Parameters**: 
  - `size`: Size string (e.g., "1Ki", "2Mi", "3Gi")
- **Returns**: Size in bytes, or -1 on failure
- **Examples**: "1Ki" → 1024, "1Mi" → 1048576, "1Gi" → 1073741824

### Hexadecimal Conversion

#### `flb_utils_hex2int`

```c
int64_t flb_utils_hex2int(char *hex, int len)
```

Converts a hexadecimal string to an integer.

- **Parameters**: 
  - `hex`: Hexadecimal string
  - `len`: Length of the string
- **Returns**: Integer value, or -1 on failure

### Time Functions

#### `flb_utils_time_to_seconds`

```c
int flb_utils_time_to_seconds(const char *time)
```

Converts a time string to seconds.

- **Parameters**: 
  - `time`: Time string (e.g., "1D", "2H", "30M")
- **Returns**: Time in seconds
- **Examples**: "1D" → 86400, "1H" → 3600, "30M" → 1800

#### `flb_utils_time_split`

```c
int flb_utils_time_split(const char *time, int *sec, long *nsec)
```

Splits a time string into seconds and nanoseconds.

- **Parameters**: 
  - `time`: Time string (e.g., "10.500")
  - `sec`: Output parameter for seconds
  - `nsec`: Output parameter for nanoseconds
- **Returns**: 0 on success, -1 on failure

### Boolean Conversion

#### `flb_utils_bool`

```c
int flb_utils_bool(const char *val)
```

Converts a string to a boolean value.

- **Parameters**: 
  - `val`: String value to convert
- **Returns**: FLB_TRUE, FLB_FALSE, or -1 on invalid input
- **Valid True Values**: "true", "on", "yes"
- **Valid False Values**: "false", "off", "no"

### Human Readable Size

#### `flb_utils_bytes_to_human_readable_size`

```c
void flb_utils_bytes_to_human_readable_size(size_t bytes, char *out_buf, size_t size)
```

Converts bytes to a human-readable size string.

- **Parameters**: 
  - `bytes`: Size in bytes
  - `out_buf`: Output buffer
  - `size`: Size of output buffer
- **Examples**: 1024 → "1.0K", 1048576 → "1.0M"

### String Writing Functions

#### `flb_utils_write_str`

```c
int flb_utils_write_str(char *buf, int *off, size_t size, const char *str, size_t str_len, int escape_unicode)
```

Writes a string to a buffer with optional Unicode escaping.

- **Parameters**: 
  - `buf`: Destination buffer
  - `off`: Current offset in buffer
  - `size`: Total buffer size
  - `str`: Source string
  - `str_len`: Length of source string
  - `escape_unicode`: Whether to escape Unicode characters
- **Returns**: FLB_TRUE on success, FLB_FALSE on failure

#### `flb_utils_write_str_buf`

```c
int flb_utils_write_str_buf(const char *str, size_t str_len, char **out, size_t *out_size, int escape_unicode)
```

Writes a string to a dynamically allocated buffer.

- **Parameters**: 
  - `str`: Source string
  - `str_len`: Length of source string
  - `out`: Pointer to output buffer
  - `out_size`: Pointer to output buffer size
  - `escape_unicode`: Whether to escape Unicode characters
- **Returns**: 0 on success, -1 on failure

### URL Parsing Functions

#### `flb_utils_url_split`

```c
int flb_utils_url_split(const char *in_url, char **out_protocol, char **out_host, char **out_port, char **out_uri)
```

Splits a URL into its components.

- **Parameters**: 
  - `in_url`: Input URL string
  - `out_protocol`: Output protocol
  - `out_host`: Output host
  - `out_port`: Output port
  - `out_uri`: Output URI path
- **Returns**: 0 on success, -1 on failure

#### `flb_utils_proxy_url_split`

```c
int flb_utils_proxy_url_split(const char *in_url, char **out_protocol, char **out_username, char **out_password, char **out_host, char **out_port)
```

Splits a proxy URL into its components.

- **Parameters**: 
  - `in_url`: Input proxy URL string
  - `out_protocol`: Output protocol
  - `out_username`: Output username (optional)
  - `out_password`: Output password (optional)
  - `out_host`: Output host
  - `out_port`: Output port
- **Returns**: 0 on success, -1 on failure

### File Operations

#### `flb_utils_read_file`

```c
int flb_utils_read_file(char *path, char **out_buf, size_t *out_size)
```

Reads the entire contents of a file.

- **Parameters**: 
  - `path`: File path
  - `out_buf`: Pointer to output buffer
  - `out_size`: Pointer to output buffer size
- **Returns**: 0 on success, -1 on failure

#### `flb_utils_read_file_offset`

```c
int flb_utils_read_file_offset(char *path, off_t offset_start, off_t offset_end, char **out_buf, size_t *out_size)
```

Reads a portion of a file.

- **Parameters**: 
  - `path`: File path
  - `offset_start`: Start offset
  - `offset_end`: End offset (0 for end of file)
  - `out_buf`: Pointer to output buffer
  - `out_size`: Pointer to output buffer size
- **Returns**: 0 on success, -1 on failure

### System Information

#### `flb_utils_get_os_name`

```c
char *flb_utils_get_os_name()
```

Returns the operating system name.

- **Returns**: OS name string

#### `flb_utils_uuid_v4_gen`

```c
int flb_utils_uuid_v4_gen(char *buf)
```

Generates a UUID v4.

- **Parameters**: 
  - `buf`: Output buffer (must be at least 37 bytes)
- **Returns**: 0 on success, -1 on failure

### Data Structures

#### `flb_split_entry`

Structure representing a split string entry.

```c
struct flb_split_entry {
    char *value;     /* Entry value */
    int len;         /* Length of value */
    off_t last_pos;  /* Last position in original string */
    struct mk_list _head; /* Linked list node */
};
```

### Constants

#### Error Codes

Various error codes are defined for different error conditions:
- `FLB_ERR_CFG_FILE`: Could not open configuration file
- `FLB_ERR_CFG_FILE_FORMAT`: Configuration file contains format errors
- `FLB_ERR_INPUT_UNDEF`: No input(s) have been defined
- And many others...

### Dependencies

- `<stdio.h>`: Standard I/O functions
- `<stdlib.h>`: Standard library functions
- `<string.h>`: String manipulation functions
- `<time.h>`: Time functions
- `<ctype.h>`: Character type functions
- `<sys/types.h>`: System types
- `<sys/stat.h>`: File status
- `<msgpack.h>`: MessagePack library
- `<monkey/mk_core.h>`: Monkey HTTP server core utilities
- `<fluent-bit/flb_macros.h>`: Fluent Bit macros
- `<fluent-bit/flb_config.h>`: Fluent Bit configuration
- `<fluent-bit/flb_error.h>`: Fluent Bit error handling
- `<fluent-bit/flb_input.h>`: Fluent Bit input plugins
- `<fluent-bit/flb_output.h>`: Fluent Bit output plugins
- `<fluent-bit/flb_utils.h>`: Utility header definitions
- `<fluent-bit/flb_utf8.h>`: UTF-8 utilities
- `<fluent-bit/flb_simd.h>`: SIMD utilities
- `<fluent-bit/calyptia/calyptia_constants.h>`: Calyptia constants
- `<fluent-bit/aws/flb_aws_error_reporter.h>`: AWS error reporting (conditional)
- `<openssl/rand.h>`: OpenSSL random functions (conditional)
- Platform-specific headers for macOS, Windows, etc.

### Implementation Details

1. **String Splitting**: Implements both basic and quoted string splitting with proper escape sequence handling

2. **Memory Management**: Uses Fluent Bit's custom memory allocation functions for consistency

3. **URL Parsing**: Handles both standard URLs and proxy URLs with authentication support

4. **Size Conversion**: Supports both decimal (SI) and binary (IEC) prefixes

5. **Unicode Handling**: Provides both escaped and raw Unicode string writing capabilities

6. **Platform Support**: Includes conditional compilation for different operating systems

7. **Performance Optimizations**: Uses SIMD instructions where available for string processing

## Usage Examples

### Splitting a string

```c
// Split a string by commas
struct mk_list *list = flb_utils_split("apple,banana,cherry", ',', 0);

struct mk_list *head;
struct flb_split_entry *entry;

mk_list_foreach(head, list) {
    entry = mk_list_entry(head, struct flb_split_entry, _head);
    printf("Entry: %.*s\n", entry->len, entry->value);
}

// Cleanup
flb_utils_split_free(list);
```

### Parsing a URL

```c
char *protocol, *host, *port, *uri;

if (flb_utils_url_split("https://example.com:8080/path", 
                        &protocol, &host, &port, &uri) == 0) {
    printf("Protocol: %s\n", protocol);
    printf("Host: %s\n", host);
    printf("Port: %s\n", port);
    printf("URI: %s\n", uri);
    
    // Cleanup
    flb_free(protocol);
    flb_free(host);
    flb_free(port);
    flb_free(uri);
}
```

### Converting size strings

```c
// Convert human-readable sizes to bytes
int64_t bytes = flb_utils_size_to_bytes("2.5M");
printf("2.5M = %ld bytes\n", bytes);  // Outputs: 2500000

bytes = flb_utils_size_to_binary_bytes("2.5Mi");
printf("2.5Mi = %ld bytes\n", bytes);  // Outputs: 2621440
```