# flb_ml_stream.c

## Overview

This file implements the core streaming functionality for Fluent Bit's multiline processing system. It manages streams of log data that require multiline parsing, including grouping mechanisms, buffer management, and stream lifecycle operations. The implementation handles multiple concurrent streams and provides efficient memory management for buffering multiline content.

## Key Functions

### `flb_ml_stream_create`

Creates a new multiline stream with the specified name and callback function.

**Parameters:**
- `ml`: Multiline context
- `name`: Stream name
- `name_len`: Length of the stream name
- `cb_flush`: Callback function for flushing completed multiline records
- `cb_data`: Opaque data for the callback function
- `stream_id`: Output parameter for the generated stream ID

**Returns:**
- 0 on success
- -1 on failure

### `flb_ml_stream_get`

Retrieves an existing stream by its ID from a parser instance.

### `flb_ml_stream_destroy`

Destroys a stream and frees all associated resources.

### `flb_ml_stream_group_get`

Gets or creates a stream group for a specific parser instance.

### `flb_ml_stream_id_destroy_all`

Destroys all streams with a specific ID across all parser instances.

## Important Variables/Constants

- `FLB_ML_BUF_SIZE`: Initial buffer size for multiline stream groups
- `FLB_ML_MAX_GROUPS`: Maximum number of groups allowed per stream
- `ANSI_GREEN`, `ANSI_RESET`: ANSI color codes for debug output

## Dependencies

- `flb_ml.h`: Main multiline header
- `flb_ml_rule.h`: Multiline rule definitions
- `flb_mem.h`: Memory management utilities
- `flb_log.h`: Logging utilities
- `flb_pack.h`: MessagePack utilities
- `cfl.h`: Common Fluent Library

## Implementation Details

### Stream Management

The multiline stream system implements a hierarchical structure:

1. **Streams**: Top-level entities representing distinct log sources
2. **Groups**: Subdivisions within streams for handling different content types
3. **Buffers**: Memory buffers for accumulating multiline content

Each stream maintains:
- A unique identifier (generated from the stream name)
- References to associated parser instances
- Callback functions for handling flushed content
- Lists of stream groups for content organization

### Group Management

Stream groups provide a mechanism for organizing multiline content:

- Groups can be created dynamically based on content patterns
- Each group maintains its own buffer and state
- Default groups are created automatically for parsers without explicit grouping
- Groups support MessagePack serialization for structured data

### Buffer Management

The system uses efficient buffer management:

- SDS (Simple Dynamic Strings) for flexible string handling
- MessagePack buffers for structured data serialization
- Automatic buffer resizing as needed
- Proper cleanup of all allocated resources

### Lifecycle Management

Streams follow a well-defined lifecycle:

1. **Creation**: Streams are created with unique IDs and associated parsers
2. **Usage**: Content is accumulated in group buffers until flush conditions are met
3. **Flushing**: Completed multiline records are passed to callback functions
4. **Destruction**: All resources are properly freed when streams are destroyed

## Usage

This module is used internally by the multiline processing system. External components interact with it through the public API functions:

```c
// Create a new stream
uint64_t stream_id;
int ret = flb_ml_stream_create(ml_context, "my_stream", 10, 
                                my_flush_callback, NULL, &stream_id);

// Get an existing stream
struct flb_ml_stream *stream = flb_ml_stream_get(parser_instance, stream_id);

// Destroy a stream
int result = flb_ml_stream_destroy(stream);
```

The stream system is particularly important for handling high-volume log sources where multiple concurrent streams need to be processed efficiently while maintaining proper resource isolation.