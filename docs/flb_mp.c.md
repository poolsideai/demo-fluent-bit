# flb_mp.c

## Overview

This file implements MessagePack utilities for Fluent Bit. It provides functions for working with MessagePack-encoded data, including counting records, validating chunks, and manipulating MessagePack headers. The file also includes utilities for working with record accessors in MessagePack contexts.

## Key Functions

### flb_mp_count

Counts the number of MessagePack serialized events in a buffer.

**Parameters:**
- `data`: Pointer to the MessagePack data
- `bytes`: Size of the data buffer

**Returns:** Number of serialized events

### flb_mp_count_remaining

Counts MessagePack serialized events and reports remaining bytes.

**Parameters:**
- `data`: Pointer to the MessagePack data
- `bytes`: Size of the data buffer
- `remaining_bytes`: Pointer to store remaining bytes count (optional)

**Returns:** Number of serialized events

### flb_mp_validate_metric_chunk

Validates a chunk of metric data encoded in MessagePack format.

**Parameters:**
- `data`: Pointer to the MessagePack data
- `bytes`: Size of the data buffer
- `out_series`: Pointer to store the number of valid series
- `processed_bytes`: Pointer to store the number of processed bytes

**Returns:** 0 on success, -1 on failure

### flb_mp_validate_log_chunk

Validates a chunk of log data encoded in MessagePack format.

**Parameters:**
- `data`: Pointer to the MessagePack data
- `bytes`: Size of the data buffer
- `out_records`: Pointer to store the number of valid records
- `processed_bytes`: Pointer to store the number of processed bytes

**Returns:** 0 on success, -1 on failure

### flb_mp_set_map_header_size

Adjusts the size of a MessagePack map header.

**Parameters:**
- `buf`: Buffer containing the map header
- `size`: New size for the map

### flb_mp_set_array_header_size

Adjusts the size of a MessagePack array header.

**Parameters:**
- `buf`: Buffer containing the array header
- `size`: New size for the array

### flb_mp_map_header_init

Initializes a map header context for dynamic map creation.

**Parameters:**
- `mh`: Map header context
- `mp_pck`: MessagePack packer

**Returns:** 0 on success

### flb_mp_array_header_init

Initializes an array header context for dynamic array creation.

**Parameters:**
- `mh`: Map header context
- `mp_pck`: MessagePack packer

**Returns:** 0 on success

### flb_mp_map_header_append

Registers a new entry in a dynamic map.

**Parameters:**
- `mh`: Map header context

**Returns:** Current entry count

### flb_mp_array_header_append

Registers a new entry in a dynamic array.

**Parameters:**
- `mh`: Map header context

**Returns:** Current entry count

### flb_mp_map_header_end

Finalizes a dynamic map by adjusting the header size.

**Parameters:**
- `mh`: Map header context

### flb_mp_array_header_end

Finalizes a dynamic array by adjusting the header size.

**Parameters:**
- `mh`: Map header context

### flb_mp_accessor_create

Creates an MP accessor context from a list of record accessor patterns.

**Parameters:**
- `slist_patterns`: List of pattern strings

**Returns:** Pointer to the created MP accessor context, or NULL on failure

### flb_mp_accessor_set_active

Sets the active status for all record accessor patterns in an MP accessor context.

**Parameters:**
- `mpa`: MP accessor context
- `status`: Active status (FLB_TRUE/FLB_FALSE)

### flb_mp_accessor_set_active_by_pattern

Sets the active status for a specific record accessor pattern.

**Parameters:**
- `mpa`: MP accessor context
- `pattern`: Pattern string to match
- `status`: Active status (FLB_TRUE/FLB_FALSE)

**Returns:** 0 on success, -1 if pattern not found

## Dependencies

- `<fluent-bit/flb_info.h>`: Core Fluent Bit header
- `<fluent-bit/flb_utils.h>`: Utility functions
- `<fluent-bit/flb_mem.h>`: Memory management utilities
- `<fluent-bit/flb_log.h>`: Logging utilities
- `<fluent-bit/flb_mp.h>`: MessagePack utilities header
- `<fluent-bit/flb_mp_chunk.h>`: MessagePack chunk utilities
- `<fluent-bit/flb_slist.h>`: String list utilities
- `<fluent-bit/flb_record_accessor.h>`: Record accessor utilities
- `<fluent-bit/flb_metrics.h>`: Metrics interface
- `<fluent-bit/flb_conditionals.h>`: Conditional utilities
- `<fluent-bit/flb_log_event_encoder.h>`: Log event encoder
- `<fluent-bit/flb_log_event_decoder.h>`: Log event decoder
- `<msgpack.h>`: MessagePack library
- `<mpack/mpack.h>`: MPack library for MessagePack operations

## Important Constants

### FLB_MP_MAP

Constant representing a map type in MP header contexts.

### FLB_MP_ARRAY

Constant representing an array type in MP header contexts.

## Implementation Details

The MessagePack utilities in this file address several challenges in working with MessagePack data:

1. **Dynamic Map/Array Creation**: Provides utilities to create maps and arrays when the exact number of entries is unknown at creation time. This works by initially creating a large map/array (65536 entries) and then adjusting the header size to match the actual number of entries.

2. **Chunk Validation**: Implements validation functions for both metric and log chunks to ensure data integrity.

3. **Header Manipulation**: Provides functions to adjust MessagePack header sizes after the fact, which is necessary for dynamic data structures.

4. **Record Accessor Integration**: Integrates with the record accessor system to work with complex nested data structures in MessagePack format.

The validation functions check for proper MessagePack structure and handle edge cases like trailing zero bytes that might occur due to abrupt termination of previous Fluent Bit processes.

## Usage Examples

```c
// Dynamic map creation
struct flb_mp_map_header mh;
msgpack_sbuffer sbuf;
msgpack_packer pck;

msgpack_sbuffer_init(&sbuf);
msgpack_packer_init(&pck, &sbuf, msgpack_sbuffer_write);

flb_mp_map_header_init(&mh, &pck);

// Add first key/value pair
flb_mp_map_header_append(&mh);
msgpack_pack_str(&pck, 4);
msgpack_pack_str_body(&pck, "key1", 4);
msgpack_pack_int(&pck, 123);

// Add second key/value pair
flb_mp_map_header_append(&mh);
msgpack_pack_str(&pck, 4);
msgpack_pack_str_body(&pck, "key2", 4);
msgpack_pack_str(&pck, 5);
msgpack_pack_str_body(&pck, "value", 5);

// Finalize the map
flb_mp_map_header_end(&mh);

// Count records in a buffer
int count = flb_mp_count(buffer, buffer_size);

// Validate a log chunk
int records;
size_t processed;
int result = flb_mp_validate_log_chunk(buffer, buffer_size, &records, &processed);
```