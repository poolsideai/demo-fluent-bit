# flb_csv.c

## Overview

The `flb_csv.c` file implements a CSV (Comma-Separated Values) parser for Fluent Bit. This module provides efficient parsing of CSV-formatted data streams, supporting the full RFC 4180 specification including quoted fields, escaped quotes, and proper handling of line terminators.

The CSV parser is designed to work with streaming data, allowing partial parsing of large CSV files or network streams. It uses a state machine approach to handle complex CSV formatting rules while maintaining high performance.

## Key Functions

### `flb_csv_init`
Initializes a CSV parsing context:
- Allocates internal buffers for parsing
- Sets up field callback function
- Initializes parser state machine
- Prepares for streaming parsing operations

### `flb_csv_parse_record`
Parses a single CSV record from a data stream:
- Processes input buffer incrementally
- Handles multi-byte records spanning buffer boundaries
- Invokes field callback for each parsed field
- Returns field count and parsing status
- Supports both simple and complex CSV formatting

### `flb_csv_destroy`
Cleans up a CSV parsing context:
- Frees all allocated buffers
- Resets parser state
- Prevents memory leaks

## Data Structures

### `struct flb_csv_state`
Represents a CSV parsing context with:
- `field_callback`: Function called for each parsed field
- `buffered_data`: Buffer for incomplete records
- `escape_buffer`: Buffer for unescaped field content
- `offset`: Current parsing position
- `start`: Start position of current field
- `length`: Length of current field
- `field_count`: Count of fields in current record
- `state`: Current parser state (state machine)
- `field_parsed`: Flag indicating field completion
- `has_dquote`: Flag for quoted field detection
- `data`: User data passed to callback

## State Machine

The parser uses a state machine with these states:
- `FLB_CSV_STATE_INITIAL`: Initial state, waiting for field start
- `FLB_CSV_STATE_STARTED_SIMPLE`: Parsing unquoted field
- `FLB_CSV_STATE_STARTED_DQUOTE`: Parsing quoted field
- `FLB_CSV_STATE_FOUND_DQUOTE`: Found quote character in field
- `FLB_CSV_STATE_FOUND_CR`: Found carriage return

## Features

### RFC 4180 Compliance
- Proper handling of quoted fields
- Support for escaped quotes within fields
- Correct line terminator processing (\r\n, \n, \r)
- Empty field handling
- Multi-line field support

### Streaming Support
- Incremental parsing of large datasets
- Buffer boundary handling
- Partial record buffering
- Memory-efficient operation

### Field Callback System
- Custom field processing via callback
- Field length information provided
- User data context support

## Dependencies

This module depends on:
- `flb_sds`: Safe dynamic string management
- `flb_mem`: Memory allocation utilities
- Standard C library functions

## Implementation Details

The CSV parser implements several key features:

1. **State Machine Parsing**: Efficient state tracking for complex CSV rules
2. **Streaming Buffer Management**: Handles records spanning multiple buffers
3. **Quote Escaping**: Proper handling of escaped quotes within fields
4. **Memory Efficiency**: Minimal buffer allocation with reuse
5. **Error Handling**: Comprehensive error codes for different failure modes

### Field Processing Flow
1. Detect field start (quote or simple)
2. Parse field content according to rules
3. Handle quote escaping within fields
4. Process field termination (comma or newline)
5. Invoke callback with parsed field
6. Reset state for next field

### Multi-Buffer Handling
- Incomplete records are buffered
- State preserved between buffer boundaries
- Seamless continuation of parsing
- Proper memory management for buffers

## Usage Example

```c
struct my_csv_context {
    struct mk_list fields;
    int record_count;
};

void field_callback(void *data, const char *field, size_t field_len)
{
    struct my_csv_context *ctx = (struct my_csv_context *) data;
    struct flb_kv *kv;
    
    // Store each field
    kv = flb_malloc(sizeof(struct flb_kv));
    kv->key = flb_sds_create_len(field, field_len);
    mk_list_add(&kv->_head, &ctx->fields);
}

int parse_csv_data(const char *csv_data, size_t data_len)
{
    struct flb_csv_state parser;
    struct my_csv_context ctx;
    char *bufptr;
    size_t buflen;
    size_t field_count;
    int result;
    
    // Initialize context
    mk_list_init(&ctx.fields);
    ctx.record_count = 0;
    
    // Initialize parser
    flb_csv_init(&parser, field_callback, &ctx);
    
    // Parse data
    bufptr = (char *) csv_data;
    buflen = data_len;
    
    while (buflen > 0) {
        result = flb_csv_parse_record(&parser, &bufptr, &buflen, &field_count);
        if (result == FLB_CSV_EOF) {
            // No more data
            break;
        }
        else if (result != FLB_CSV_SUCCESS) {
            flb_error("CSV parsing error: %d", result);
            flb_csv_destroy(&parser);
            return -1;
        }
        
        // Process record
        ctx.record_count++;
        // ... handle record with field_count fields ...
    }
    
    // Cleanup
    flb_csv_destroy(&parser);
    
    return 0;
}

// Example usage
const char *sample_csv = "name,age,city\"John Doe\",30,\"New York\"\nAlice,25,\"Los Angeles\"";
parse_csv_data(sample_csv, strlen(sample_csv));
```