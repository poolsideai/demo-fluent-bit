# flb_input_log.c

## Overview

This file contains the implementation for handling log data in Fluent Bit input plugins. It provides functionality for appending log records to input chunks, processing log data through the processor pipeline, and managing log-specific operations.

The module serves as the primary interface for input plugins to submit log data to the Fluent Bit engine. It handles MessagePack serialization of log records, integrates with the processor system for data transformation, and manages the storage of log data in input chunks.

Log data flow through this module from input collection to chunk storage, with optional processing stages applied to transform the data before storage.

## Key Functions

### Log Data Appending

#### `flb_input_log_append()`
Appends raw log data (in MessagePack format) to an input chunk. This is the primary function used by input plugins to submit log records. It automatically counts the number of records in the buffer and processes them through the processor pipeline if active.

#### `flb_input_log_append_records()`
Appends log data with a pre-calculated record count to an input chunk. This function is useful when the caller already knows the number of records to avoid recounting.

#### `flb_input_log_append_skip_processor_stages()`
Appends log data starting from a specific processor stage, allowing selective processing of log records.

### Internal Processing

#### `input_log_append()`
Internal function that handles the core logic of log appending, including processor integration, buffer management, and chunk storage.

## Important Variables/Constants

### Data Structures
- No specific data structures defined in this file as it primarily provides utility functions

## Dependencies

- `fluent-bit/flb_info.h`: Core Fluent Bit information
- `fluent-bit/flb_input.h`: Input plugin interface
- `fluent-bit/flb_input_chunk.h`: Input chunk management
- `fluent-bit/flb_input_plugin.h`: Plugin interface definitions
- `fluent-bit/flb_processor.h`: Processor pipeline interface
- `fluent-bit/flb_input_log.h`: Header file defining the interface

## Implementation Details

1. **Processor Integration**: Seamless integration with the processor pipeline to transform log data before storage. The processor can modify, filter, or enrich log records as they pass through.

2. **Buffer Management**: Efficient handling of input buffers, including automatic buffer reallocation when processors generate new buffers.

3. **Record Counting**: Automatic counting of records in MessagePack buffers using `flb_mp_count()`, with special handling when processors modify the buffer content.

4. **Tag Management**: Proper handling of log tags, falling back to instance-level tags when record-specific tags are not provided.

5. **Error Handling**: Comprehensive error detection and propagation throughout the log appending process.

6. **Memory Management**: Proper allocation and deallocation of buffers, especially when processors create new buffers.

7. **Chunk Integration**: Direct integration with the input chunk system for persistent storage of log data.

## Usage Example

```c
// Simple log appending example
struct flb_input_instance *instance;
// ... initialize instance ...

// Serialized log data in MessagePack format
char log_data[] = { 0x92, 0xcb, 0x41, 0xd2, 0x65, 0x80, 0xb4, 0x87, 0x5a, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x81, 0xa3, 0x6d, 0x73, 0x67, 0xa5, 0x48, 0x65, 0x6c, 0x6c, 0x6f };

// Append log data with automatic record counting
int ret = flb_input_log_append(
    instance,           // Input plugin instance
    "my.log.tag",       // Tag for the log records
    12,                 // Tag length
    log_data,           // Serialized log data
    sizeof(log_data)    // Data size
);

if (ret == 0) {
    printf("Log data appended successfully\n");
} else {
    printf("Failed to append log data\n");
}

// Pre-counted log appending example
struct flb_input_instance *instance;
// ... initialize instance ...

// Serialized log data with known record count
char log_data_multiple[] = { /* ... multiple log records ... */ };
size_t record_count = 5; // Known number of records

// Append log data with pre-calculated record count
int ret = flb_input_log_append_records(
    instance,           // Input plugin instance
    record_count,       // Pre-calculated record count
    "my.logs.tag",      // Tag for the log records
    13,                 // Tag length
    log_data_multiple,  // Serialized log data
    sizeof(log_data_multiple) // Data size
);

if (ret == 0) {
    printf("Multiple log records appended successfully\n");
} else {
    printf("Failed to append multiple log records\n");
}

// Example with processor stages skipping
struct flb_input_instance *instance;
// ... initialize instance with processor ...

// Serialized log data
char log_data[] = { /* ... log data ... */ };

// Skip first 2 processor stages
int ret = flb_input_log_append_skip_processor_stages(
    instance,           // Input plugin instance
    2,                  // Skip first 2 processor stages
    "my.processed.tag", // Tag for the log records
    17,                 // Tag length
    log_data,           // Serialized log data
    sizeof(log_data)    // Data size
);

if (ret == 0) {
    printf("Log data processed and appended successfully\n");
} else {
    printf("Failed to process and append log data\n");
}
```