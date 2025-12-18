# flb_log_event_decoder.c

## Overview

The `flb_log_event_decoder.c` file implements a decoder for Fluent Bit log events. It provides functionality to parse MessagePack-encoded log events and extract structured data including timestamps, metadata, and body content. The decoder supports both legacy Forward format and the newer Fluent Bit v2 format with enhanced metadata support.

This module is essential for processing incoming log data in Fluent Bit, allowing plugins and components to efficiently decode and work with log events regardless of their source format.

## Key Functions

### `flb_log_event_decoder_init`
Initializes a log event decoder context with the provided input buffer and length.

### `flb_log_event_decoder_create`
Creates and initializes a new log event decoder context.

### `flb_log_event_decoder_destroy`
Destroys a log event decoder context and releases all associated resources.

### `flb_log_event_decoder_reset`
Resets a decoder context with new input data.

### `flb_log_event_decoder_next`
Decodes the next log event from the input buffer.

### `flb_log_event_decoder_decode_timestamp`
Decodes a timestamp from a MessagePack object into a `flb_time` structure.

### `flb_log_event_decoder_get_error_description`
Returns a human-readable description of a decoder error code.

## Data Structures

### `struct flb_log_event_decoder`
Represents the decoder context with the following fields:
- `current_group_attributes`: Current group attributes
- `unpacked_group_record`: Unpacked group record data
- `dynamically_allocated`: Flag indicating if context was dynamically allocated
- `current_group_metadata`: Current group metadata
- `unpacked_empty_map`: Unpacked empty map for default metadata
- `previous_offset`: Previous decoding offset
- `unpacked_event`: Unpacked event data
- `record_length`: Length of current record
- `record_base`: Base pointer to current record
- `initialized`: Initialization flag
- `empty_map`: Empty map object for default metadata
- `buffer`: Input buffer pointer
- `offset`: Current decoding offset
- `length`: Total buffer length
- `last_result`: Last operation result
- `read_groups`: Flag to control group record processing

## Error Codes

- `FLB_EVENT_DECODER_SUCCESS` (0): Operation successful
- `FLB_EVENT_DECODER_ERROR_INITIALIZATION_FAILURE` (-1): Initialization failed
- `FLB_EVENT_DECODER_ERROR_INVALID_CONTEXT` (-2): Invalid decoder context
- `FLB_EVENT_DECODER_ERROR_INVALID_ARGUMENT` (-3): Invalid argument provided
- `FLB_EVENT_DECODER_ERROR_WRONG_ROOT_TYPE` (-4): Root element is not an array
- `FLB_EVENT_DECODER_ERROR_WRONG_ROOT_SIZE` (-5): Root array has wrong size
- `FLB_EVENT_DECODER_ERROR_WRONG_HEADER_TYPE` (-6): Header is not an array
- `FLB_EVENT_DECODER_ERROR_WRONG_HEADER_SIZE` (-7): Header array has wrong size
- `FLB_EVENT_DECODER_ERROR_WRONG_TIMESTAMP_TYPE` (-8): Timestamp is of wrong type
- `FLB_EVENT_DECODER_ERROR_WRONG_METADATA_TYPE` (-9): Metadata is not a map
- `FLB_EVENT_DECODER_ERROR_WRONG_BODY_TYPE` (-10): Body is not a map
- `FLB_EVENT_DECODER_ERROR_DESERIALIZATION_FAILURE` (-11): Deserialization failed
- `FLB_EVENT_DECODER_ERROR_INSUFFICIENT_DATA` (-12): Insufficient data for decoding

## Dependencies

- `<fluent-bit/flb_log_event_decoder.h>`: Header file with declarations
- `<fluent-bit/flb_byteswap.h>`: Byte order conversion utilities
- `<fluent-bit/flb_compat.h>`: Compatibility layer
- `<msgpack.h>`: MessagePack C library
- `<fluent-bit/flb_time.h>`: Time handling functions
- `<fluent-bit/flb_sds.h>`: Simple Dynamic Strings
- `<fluent-bit/flb_mp.h>`: MessagePack utilities
- `<fluent-bit/flb_log_event.h>`: Log event definitions

## Implementation Details

### Format Support
The decoder supports two log event formats:

1. **Forward Format**: Legacy format with a simple `[timestamp, record]` structure
2. **Fluent Bit v2 Format**: Enhanced format with `[header, record]` where header contains `[timestamp, metadata]`

### Timestamp Handling
Timestamps can be represented in three ways:
- Positive integer: Unix timestamp in seconds
- Float: Unix timestamp with fractional seconds
- Extension type: Compact binary representation with seconds and nanoseconds

### Group Records
The decoder supports group records which allow associating metadata with multiple log events:
- `FLB_LOG_EVENT_GROUP_START`: Marks the beginning of a group
- `FLB_LOG_EVENT_GROUP_END`: Marks the end of a group
- Normal events within a group inherit the group's metadata

### Memory Management
The decoder manages memory efficiently by:
- Reusing MessagePack unpacked structures
- Providing both static and dynamic allocation options
- Properly cleaning up resources in the destroy function

## Usage Examples

### Basic Decoding
```c
struct flb_log_event_decoder *decoder;
struct flb_log_event event;
const char *buffer = /* MessagePack encoded log data */;
size_t buffer_size = /* size of buffer */;

// Create decoder
decoder = flb_log_event_decoder_create((char *) buffer, buffer_size);
if (!decoder) {
    fprintf(stderr, "Failed to create decoder\n");
    return -1;
}

// Decode events
while (flb_log_event_decoder_next(decoder, &event) == FLB_EVENT_DECODER_SUCCESS) {
    // Process the decoded event
    flb_info("Decoded event with timestamp: %ld.%09ld", 
             event.timestamp.tm.tv_sec, 
             event.timestamp.tm.tv_nsec);
    
    // Access metadata and body
    // event.metadata and event.body are msgpack_object pointers
}

// Clean up
flb_log_event_decoder_destroy(decoder);
```

### Error Handling
```c
int result = flb_log_event_decoder_next(decoder, &event);
if (result != FLB_EVENT_DECODER_SUCCESS) {
    const char *error_desc = flb_log_event_decoder_get_error_description(result);
    fprintf(stderr, "Decoder error: %s\n", error_desc);
    
    if (result == FLB_EVENT_DECODER_ERROR_INSUFFICIENT_DATA) {
        // Handle incomplete data scenario
    }
}
```

### Working with Groups
```c
// Enable group processing
flb_log_event_decoder_read_groups(decoder, FLB_TRUE);

// Process events, including group markers
while (flb_log_event_decoder_next(decoder, &event) == FLB_EVENT_DECODER_SUCCESS) {
    int32_t record_type;
    if (flb_log_event_decoder_get_record_type(&event, &record_type) == 0) {
        switch (record_type) {
            case FLB_LOG_EVENT_GROUP_START:
                flb_info("Group started");
                break;
            case FLB_LOG_EVENT_GROUP_END:
                flb_info("Group ended");
                break;
            case FLB_LOG_EVENT_NORMAL:
                // Process normal event with inherited group metadata
                break;
        }
    }
}
```