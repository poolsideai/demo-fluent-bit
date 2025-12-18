# flb_msgpack_append_message.c

## Overview

This file implements utilities for appending messages to MessagePack-encoded records. It provides functions for dynamically adding key-value pairs to existing MessagePack maps, which is particularly useful for enriching log records with additional metadata or messages.

## Key Functions

### flb_msgpack_append_message_to_record

Appends a message to an existing MessagePack-encoded record by expanding the map structure.

**Parameters:**
- `result_buffer`: Pointer to store the resulting buffer with the appended message
- `result_size`: Pointer to store the size of the resulting buffer
- `message_key_name`: Key name for the message in the record (SDS string)
- `base_object_buffer`: Buffer containing the original MessagePack-encoded record
- `base_object_size`: Size of the original record buffer
- `message_buffer`: Buffer containing the message data to append
- `message_size`: Size of the message data
- `message_type`: Type of the message data (MSGPACK_OBJECT_BIN or MSGPACK_OBJECT_STR)

**Returns:** 
- `FLB_MAP_EXPAND_SUCCESS`: Success
- `FLB_MAP_NOT_MODIFIED`: No modification was made
- `FLB_MAP_EXPANSION_INVALID_VALUE_TYPE`: Invalid message type
- `FLB_MAP_EXPANSION_ERROR`: Error during expansion

## Dependencies

- `<fluent-bit/flb_msgpack_append_message.h>`: Header file for MessagePack append utilities

## Implementation Details

This utility function works by:

1. Creating a new map entry with the specified key name and message data
2. Using the `flb_msgpack_expand_map` function to add this entry to the existing MessagePack map
3. Returning the modified buffer with the appended message

The function supports two message types:
- Binary data (`MSGPACK_OBJECT_BIN`): Raw binary data
- String data (`MSGPACK_OBJECT_STR`): UTF-8 string data

If the message key name is NULL, no modification is made to the original record.

## Usage Examples

```c
// Append a string message to a log record
char *result_buffer;
size_t result_size;

int result = flb_msgpack_append_message_to_record(
    &result_buffer,
    &result_size,
    "message",  // Key name
    original_record_buffer,  // Original record
    original_record_size,
    "Important log message",  // Message data
    21,  // Message size
    MSGPACK_OBJECT_STR  // Message type
);

if (result == FLB_MAP_EXPAND_SUCCESS) {
    // Use the modified record
    // ...
    
    // Don't forget to free the result buffer when done
    flb_free(result_buffer);
}

// Append binary data to a record
char binary_data[] = {0x01, 0x02, 0x03, 0x04};
result = flb_msgpack_append_message_to_record(
    &result_buffer,
    &result_size,
    "binary_data",
    original_record_buffer,
    original_record_size,
    binary_data,
    sizeof(binary_data),
    MSGPACK_OBJECT_BIN
);
```