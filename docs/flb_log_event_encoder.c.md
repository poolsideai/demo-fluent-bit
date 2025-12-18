# flb_log_event_encoder.c

## Overview

The `flb_log_event_encoder.c` file implements a sophisticated encoder for Fluent Bit log events. It provides functionality to create MessagePack-encoded log events with support for both legacy Forward format and the newer Fluent Bit v2 format. The encoder offers a high-level API for constructing log events with metadata, body content, and timestamps, while abstracting the complexities of MessagePack serialization.

This module is essential for generating standardized log events that can be processed by Fluent Bit's pipeline components. It supports advanced features like dynamic field construction, group records, and various data type encodings.

## Key Functions

### `flb_log_event_encoder_init`
Initializes a log event encoder context with the specified format.

### `flb_log_event_encoder_create`
Creates and initializes a new log event encoder context.

### `flb_log_event_encoder_destroy`
Destroys a log event encoder context and releases all associated resources.

### `flb_log_event_encoder_reset`
Resets an encoder context, clearing all accumulated data.

### `flb_log_event_encoder_begin_record`
Begins construction of a new log event record.

### `flb_log_event_encoder_commit_record`
Finalizes and serializes a log event record.

### `flb_log_event_encoder_rollback_record`
Aborts construction of a log event record.

### `flb_log_event_encoder_emit_record`
Serializes and emits a completed log event record.

### `flb_log_event_encoder_set_timestamp`
Sets the timestamp for the current log event.

### `flb_log_event_encoder_append_metadata_values`
Appends key-value pairs to the event metadata.

### `flb_log_event_encoder_append_body_values`
Appends key-value pairs to the event body.

## Data Structures

### `struct flb_log_event_encoder`
Represents the encoder context with the following fields:
- `dynamically_allocated`: Flag indicating if context was dynamically allocated
- `output_buffer`: Pointer to the serialized output buffer
- `output_length`: Length of the serialized output
- `initialized`: Initialization flag
- `timestamp`: Current event timestamp
- `metadata`: Dynamic field for metadata construction
- `body`: Dynamic field for body construction
- `root`: Dynamic field for root structure construction
- `packer`: MessagePack packer instance
- `buffer`: MessagePack string buffer
- `format`: Output format specification

## Supported Formats

- `FLB_LOG_EVENT_FORMAT_FORWARD`: Legacy Forward format `[timestamp, record]`
- `FLB_LOG_EVENT_FORMAT_FLUENT_BIT_V2`: Enhanced format `[header, record]` where header contains `[timestamp, metadata]`

## Error Codes

- `FLB_EVENT_ENCODER_SUCCESS` (0): Operation successful
- `FLB_EVENT_ENCODER_ERROR_UNSPECIFIED` (-1): Unspecified error
- `FLB_EVENT_ENCODER_ERROR_ALLOCATION_ERROR` (-2): Memory allocation failed
- `FLB_EVENT_ENCODER_ERROR_INVALID_CONTEXT` (-3): Invalid encoder context
- `FLB_EVENT_ENCODER_ERROR_INVALID_ARGUMENT` (-4): Invalid argument provided
- `FLB_EVENT_ENCODER_ERROR_SERIALIZATION_FAILURE` (-5): Serialization failed
- `FLB_EVENT_ENCODER_ERROR_INVALID_VALUE_TYPE` (-6): Invalid value type specified

## Dependencies

- `<fluent-bit/flb_log_event_encoder.h>`: Header file with declarations
- `<fluent-bit/flb_log_event_encoder_primitives.h>`: Primitive encoding functions
- `<stdarg.h>`: Variable argument lists
- `<msgpack.h>`: MessagePack C library
- `<fluent-bit/flb_time.h>`: Time handling functions
- `<fluent-bit/flb_sds.h>`: Simple Dynamic Strings
- `<fluent-bit/flb_mp.h>`: MessagePack utilities
- `<fluent-bit/flb_log_event.h>`: Log event definitions
- `<fluent-bit/flb_log_event_encoder_dynamic_field.h>`: Dynamic field management

## Implementation Details

### Dynamic Field Construction
The encoder uses dynamic fields for efficient construction of complex data structures:
- Metadata field for event metadata
- Body field for event content
- Root field for the final serialized structure

Each field maintains its own buffer and can be independently managed, allowing for flexible construction of log events.

### Format Support
The encoder supports two log event formats:

1. **Forward Format**: Simple `[timestamp, record]` structure
2. **Fluent Bit v2 Format**: Enhanced `[header, record]` structure where header contains `[timestamp, metadata]`

### Value Type System
The encoder provides a rich set of value types for encoding different data types:
- String values with separate length and body specifications
- Binary data encoding
- Extension types for custom data
- Numeric types (signed/unsigned integers, floating point)
- Boolean values
- Null values
- Complex types (MessagePack objects, raw MessagePack data)
- Timestamp values in various formats

### Group Records
Support for group records that allow associating metadata with multiple log events:
- `FLB_LOG_EVENT_GROUP_START`: Marks the beginning of a group
- `FLB_LOG_EVENT_GROUP_END`: Marks the end of a group

### Memory Management
The encoder manages memory efficiently by:
- Using MessagePack's string buffer for serialization
- Providing both static and dynamic allocation options
- Supporting ownership transfer of internal buffers
- Properly cleaning up resources in the destroy function

## Usage Examples

### Basic Event Encoding
```c
struct flb_log_event_encoder *encoder;
const char *output_buffer;
size_t output_length;

// Create encoder with Fluent Bit v2 format
encoder = flb_log_event_encoder_create(FLB_LOG_EVENT_FORMAT_FLUENT_BIT_V2);
if (!encoder) {
    fprintf(stderr, "Failed to create encoder\n");
    return -1;
}

// Begin a new record
flb_log_event_encoder_begin_record(encoder);

// Set timestamp
flb_log_event_encoder_set_current_timestamp(encoder);

// Add metadata
flb_log_event_encoder_append_metadata_values(
    encoder,
    FLB_LOG_EVENT_CSTRING_VALUE("source"),
    FLB_LOG_EVENT_CSTRING_VALUE("application"),
    FLB_LOG_EVENT_CSTRING_VALUE("severity"),
    FLB_LOG_EVENT_CSTRING_VALUE("INFO")
);

// Add body content
flb_log_event_encoder_append_body_values(
    encoder,
    FLB_LOG_EVENT_CSTRING_VALUE("message"),
    FLB_LOG_EVENT_CSTRING_VALUE("User login successful"),
    FLB_LOG_EVENT_CSTRING_VALUE("user_id"),
    FLB_LOG_EVENT_INT64_VALUE(12345)
);

// Commit and emit the record
if (flb_log_event_encoder_commit_record(encoder) != FLB_EVENT_ENCODER_SUCCESS) {
    fprintf(stderr, "Failed to commit record\n");
    flb_log_event_encoder_destroy(encoder);
    return -1;
}

// Get the serialized output
output_buffer = encoder->output_buffer;
output_length = encoder->output_length;

// Use the serialized data...
// ...

// Clean up
flb_log_event_encoder_destroy(encoder);
```

### Working with Different Data Types
```c
// Encode various data types
flb_log_event_encoder_append_body_values(
    encoder,
    // String value
    FLB_LOG_EVENT_CSTRING_VALUE("name"),
    FLB_LOG_EVENT_CSTRING_VALUE("John Doe"),
    
    // Integer values
    FLB_LOG_EVENT_CSTRING_VALUE("age"),
    FLB_LOG_EVENT_INT32_VALUE(30),
    
    // Boolean value
    FLB_LOG_EVENT_CSTRING_VALUE("active"),
    FLB_LOG_EVENT_BOOLEAN_VALUE(FLB_TRUE),
    
    // Float value
    FLB_LOG_EVENT_CSTRING_VALUE("score"),
    FLB_LOG_EVENT_DOUBLE_VALUE(95.5),
    
    // Null value
    FLB_LOG_EVENT_CSTRING_VALUE("optional_field"),
    FLB_LOG_EVENT_NULL_VALUE()
);
```

### Group Record Handling
```c
// Start a group
flb_log_event_encoder_group_init(encoder);

// Add group metadata
flb_log_event_encoder_append_metadata_values(
    encoder,
    FLB_LOG_EVENT_CSTRING_VALUE("group_id"),
    FLB_LOG_EVENT_CSTRING_VALUE("batch_123")
);

// Finalize group header
flb_log_event_encoder_group_header_end(encoder);

// Add events to the group
// ... add multiple events ...

// End the group
flb_log_event_encoder_group_end(encoder);
```

### Error Handling
```c
int result = flb_log_event_encoder_commit_record(encoder);
if (result != FLB_EVENT_ENCODER_SUCCESS) {
    const char *error_desc = flb_log_event_encoder_get_error_description(result);
    fprintf(stderr, "Encoder error: %s\n", error_desc);
    
    // Handle specific error cases
    switch (result) {
        case FLB_EVENT_ENCODER_ERROR_SERIALIZATION_FAILURE:
            // Handle serialization issues
            break;
        case FLB_EVENT_ENCODER_ERROR_INVALID_VALUE_TYPE:
            // Handle invalid value types
            break;
        // ... handle other error cases
    }
}
```