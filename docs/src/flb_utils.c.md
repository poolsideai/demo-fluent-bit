# flb_utils.c and flb_utils.h Documentation

## Overview

The `flb_utils` module provides a collection of utility functions for Fluent Bit. These utilities cover a wide range of functionality including string manipulation, file operations, URL parsing, system information retrieval, and more.

This module serves as a foundational component that many other parts of Fluent Bit depend on for common operations.

## Key Features

- String splitting and manipulation utilities
- File reading and directory creation functions
- URL parsing and splitting capabilities
- System information retrieval (OS name, machine ID)
- Size conversion functions (human-readable to bytes)
- UUID generation
- Cross-platform compatibility utilities

## Data Structures

### struct flb_split_entry

Represents an entry in a split string list:

```c
struct flb_split_entry {
    char *value;     /* The string value */
    int len;         /* Length of the string value */
    off_t last_pos;  /* Position in the original string */
    struct mk_list _head; /* Link for the list */
};
```

## Key Functions

### flb_utils_split()

```c
struct mk_list *flb_utils_split(const char *line, int separator, int max_split);
```

Splits a string into a list of substrings based on a separator character.

**Parameters:**
- `line`: Input string to split
- `separator`: Character to use as separator
- `max_split`: Maximum number of splits (0 for unlimited)

**Returns:**
- Pointer to a linked list of `flb_split_entry` structures
- `NULL` on error

### flb_utils_split_quoted()

```c
struct mk_list *flb_utils_split_quoted(const char *line, int separator, int max_split);
```

Splits a string into a list of substrings, respecting quoted sections.

**Parameters:**
- `line`: Input string to split
- `separator`: Character to use as separator
- `max_split`: Maximum number of splits (0 for unlimited)

**Returns:**
- Pointer to a linked list of `flb_split_entry` structures
- `NULL` on error

### flb_utils_split_free()

```c
void flb_utils_split_free(struct mk_list *list);
```

Frees a list of split string entries.

**Parameters:**
- `list`: List of split entries to free

### flb_utils_size_to_bytes()

```c
int64_t flb_utils_size_to_bytes(const char *size);
```

Converts a human-readable size string to bytes.

**Parameters:**
- `size`: String representing size (e.g., "100", "1K", "1M", "1G")

**Returns:**
- Number of bytes on success
- `-1` on error

### flb_utils_size_to_binary_bytes()

```c
int64_t flb_utils_size_to_binary_bytes(const char *size);
```

Converts a human-readable size string to bytes using binary units (KiB, MiB, GiB).

**Parameters:**
- `size`: String representing size (e.g., "100", "1KiB", "1MiB", "1GiB")

**Returns:**
- Number of bytes on success
- `-1` on error

### flb_utils_hex2int()

```c
int64_t flb_utils_hex2int(char *hex, int len);
```

Converts a hex string to an integer.

**Parameters:**
- `hex`: Hex string to convert
- `len`: Length of the hex string

**Returns:**
- Integer value on success
- `-1` on error

### flb_utils_time_to_seconds()

```c
int flb_utils_time_to_seconds(const char *time);
```

Converts a time string to seconds.

**Parameters:**
- `time`: Time string (e.g., "10d", "10h", "10m", "10")

**Returns:**
- Number of seconds

### flb_utils_bool()

```c
int flb_utils_bool(const char *val);
```

Converts a string to a boolean value.

**Parameters:**
- `val`: String to convert ("true", "on", "yes", "false", "off", "no")

**Returns:**
- `FLB_TRUE` for true values
- `FLB_FALSE` for false values
- `-1` for invalid values

### flb_utils_bytes_to_human_readable_size()

```c
void flb_utils_bytes_to_human_readable_size(size_t bytes,
                                            char *out_buf, size_t size);
```

Converts bytes to a human-readable size string.

**Parameters:**
- `bytes`: Number of bytes
- `out_buf`: Output buffer for the result
- `size`: Size of the output buffer

### flb_utils_time_split()

```c
int flb_utils_time_split(const char *time, int *sec, long *nsec);
```

Splits a time string into seconds and nanoseconds.

**Parameters:**
- `time`: Time string (e.g., "10", "10.123")
- `sec`: Pointer to store seconds
- `nsec`: Pointer to store nanoseconds

**Returns:**
- `0` on success
- `-1` on error

### flb_utils_url_split()

```c
int flb_utils_url_split(const char *in_url, char **out_protocol,
                        char **out_host, char **out_port, char **out_uri);
```

Parses a URL into its components.

**Parameters:**
- `in_url`: Input URL string
- `out_protocol`: Pointer to store protocol
- `out_host`: Pointer to store host
- `out_port`: Pointer to store port
- `out_uri`: Pointer to store URI

**Returns:**
- `0` on success
- `-1` on error

### flb_utils_proxy_url_split()

```c
int flb_utils_proxy_url_split(const char *in_url, char **out_protocol,
                              char **out_username, char **out_password,
                              char **out_host, char **out_port);
```

Parses a proxy URL into its components.

**Parameters:**
- `in_url`: Input proxy URL string
- `out_protocol`: Pointer to store protocol
- `out_username`: Pointer to store username (optional)
- `out_password`: Pointer to store password (optional)
- `out_host`: Pointer to store host
- `out_port`: Pointer to store port

**Returns:**
- `0` on success
- `-1` on error

### flb_utils_read_file()

```c
int flb_utils_read_file(char *path, char **out_buf, size_t *out_size);
```

Reads a file into a buffer.

**Parameters:**
- `path`: Path to the file
- `out_buf`: Pointer to store the file contents
- `out_size`: Pointer to store the file size

**Returns:**
- `0` on success
- `-1` on error

### flb_utils_get_os_name()

```c
char *flb_utils_get_os_name();
```

Returns the name of the operating system.

**Returns:**
- OS name string ("win64", "win32", "macos", "linux", "freebsd", "unix", "other")

### flb_utils_uuid_v4_gen()

```c
int flb_utils_uuid_v4_gen(char *buf);
```

Generates a UUID v4 string.

**Parameters:**
- `buf`: Buffer to store the UUID (must be at least 38 bytes)

**Returns:**
- `0` on success
- `-1` on error

### flb_utils_get_machine_id()

```c
int flb_utils_get_machine_id(char **out_id, size_t *out_size);
```

Retrieves the machine ID.

**Parameters:**
- `out_id`: Pointer to store the machine ID
- `out_size`: Pointer to store the ID size

**Returns:**
- `0` on success
- `1` on success with fallback to random UUID
- `-1` on error

### flb_utils_mkdir()

```c
int flb_utils_mkdir(const char *dir, int perms);
```

Recursively creates directories.

**Parameters:**
- `dir`: Directory path to create
- `perms`: Permissions for the directories

**Returns:**
- `0` on success
- `-1` on error

## Utility Functions

### flb_utils_error()

```c
void flb_utils_error(int err);
```

Prints an error message and exits.

**Parameters:**
- `err`: Error code

### flb_utils_error_c()

```c
void flb_utils_error_c(const char *msg);
```

Prints a custom error message and exits.

**Parameters:**
- `msg`: Error message

### flb_utils_warn_c()

```c
void flb_utils_warn_c(const char *msg);
```

Prints a warning message.

**Parameters:**
- `msg`: Warning message

### flb_utils_print_setup()

```c
void flb_utils_print_setup(struct flb_config *config);
```

Prints the Fluent Bit configuration setup.

**Parameters:**
- `config`: Fluent Bit configuration

### flb_utils_timer_consume()

```c
int flb_utils_timer_consume(flb_pipefd_t fd);
```

Consumes data from a timer pipe.

**Parameters:**
- `fd`: Pipe file descriptor

**Returns:**
- `0` on success
- `-1` on error

### flb_utils_pipe_byte_consume()

```c
int flb_utils_pipe_byte_consume(flb_pipefd_t fd);
```

Consumes a byte from a pipe.

**Parameters:**
- `fd`: Pipe file descriptor

**Returns:**
- `0` on success
- `-1` on error

### flb_utils_write_str()

```c
int flb_utils_write_str(char *buf, int *off, size_t size,
                        const char *str, size_t str_len, int escape_unicode);
```

Writes a string to a buffer with optional Unicode escaping.

**Parameters:**
- `buf`: Output buffer
- `off`: Pointer to current offset in buffer
- `size`: Buffer size
- `str`: String to write
- `str_len`: Length of the string
- `escape_unicode`: Whether to escape Unicode characters

**Returns:**
- `FLB_TRUE` on success
- `FLB_FALSE` on error

### flb_utils_write_str_buf()

```c
int flb_utils_write_str_buf(const char *str, size_t str_len, char **out, size_t *out_size, int escape_unicode);
```

Writes a string to a dynamically allocated buffer.

**Parameters:**
- `str`: String to write
- `str_len`: Length of the string
- `out`: Pointer to store the output buffer
- `out_size`: Pointer to store the output size
- `escape_unicode`: Whether to escape Unicode characters

**Returns:**
- `0` on success
- `-1` on error

### flb_utils_url_split_sds()

```c
int flb_utils_url_split_sds(const flb_sds_t in_url, flb_sds_t *out_protocol,
                            flb_sds_t *out_host, flb_sds_t *out_port, flb_sds_t *out_uri);
```

Parses a URL into SDS string components.

**Parameters:**
- `in_url`: Input URL SDS string
- `out_protocol`: Pointer to store protocol SDS string
- `out_host`: Pointer to store host SDS string
- `out_port`: Pointer to store port SDS string
- `out_uri`: Pointer to store URI SDS string

**Returns:**
- `0` on success
- `-1` on error

### flb_utils_set_plugin_string_property()

```c
void flb_utils_set_plugin_string_property(const char *name,
                                          flb_sds_t *field_storage,
                                          flb_sds_t  new_value);
```

Sets a plugin string property, handling overwrites.

**Parameters:**
- `name`: Property name
- `field_storage`: Pointer to the storage field
- `new_value`: New value to set

## Implementation Details

### String Splitting

The string splitting functions (`flb_utils_split` and `flb_utils_split_quoted`) provide:
- Support for quoted strings in `flb_utils_split_quoted`
- Configurable maximum splits
- Proper memory management with `flb_utils_split_free`

### URL Parsing

URL parsing functions handle:
- Protocol detection (http/https)
- Host and port extraction
- IPv6 address support with brackets
- Default port assignment for HTTP/HTTPS
- Proxy URL parsing with authentication support

### Cross-Platform Compatibility

The utilities handle platform-specific differences:
- Directory creation with proper path separators
- OS-specific machine ID retrieval
- Platform-specific UUID generation

### Memory Management

All functions follow Fluent Bit's memory management patterns:
- Use of `flb_malloc`, `flb_calloc`, `flb_realloc`, and `flb_free`
- Proper error handling with `flb_errno()`
- Resource cleanup on failure

## Usage Example

```c
#include <fluent-bit/flb_utils.h>
#include <fluent-bit/flb_mem.h>
#include <fluent-bit/flb_log.h>

// Split a string
struct mk_list *list = flb_utils_split("hello,world,test", ',', 0);
if (list) {
    struct mk_list *head;
    struct flb_split_entry *entry;
    
    mk_list_foreach(head, list) {
        entry = mk_list_entry(head, struct flb_split_entry, _head);
        flb_info("Split part: %.*s", entry->len, entry->value);
    }
    
    flb_utils_split_free(list);
}

// Convert size string to bytes
int64_t bytes = flb_utils_size_to_bytes("10M");
if (bytes > 0) {
    flb_info("10M equals %ld bytes", (long) bytes);
}

// Parse URL
char *protocol, *host, *port, *uri;
if (flb_utils_url_split("http://example.com:8080/path", 
                        &protocol, &host, &port, &uri) == 0) {
    flb_info("Protocol: %s, Host: %s, Port: %s, URI: %s", 
             protocol, host, port, uri);
    
    flb_free(protocol);
    flb_free(host);
    flb_free(port);
    flb_free(uri);
}

// Generate UUID
char uuid_buf[38];
if (flb_utils_uuid_v4_gen(uuid_buf) == 0) {
    flb_info("Generated UUID: %s", uuid_buf);
}

// Read file
char *file_content;
size_t file_size;
if (flb_utils_read_file("/etc/passwd", &file_content, &file_size) == 0) {
    flb_info("File content (first 100 chars): %.100s", file_content);
    flb_free(file_content);
}
```