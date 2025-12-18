# flb_ml_stream.c Documentation

## Overview

This file contains the implementation for multiline stream management in Fluent Bit. It handles the creation, management, and destruction of logical streams that represent sources of log data, along with their associated groups for organizing log entries.

## Purpose

The primary purpose of this file is to provide the core functionality for managing logical streams in the multiline processing system. Streams represent sources of log data (such as container logs, application logs, etc.) and contain groups that categorize log entries based on metadata. This file manages:
- Stream creation and destruction
- Stream group management
- Stream lookup and retrieval
- Stream-specific buffer management
- Integration with multiline parsers and rules

## Key Data Structures

### Stream Context (`struct flb_ml_stream`)
- Represents a logical stream of log data from a specific source
- Contains multiple groups for categorization of log entries
- Manages flush callbacks for completed messages
- Tracks the last used stream group for optimization
- Maintains references to parent parser instances

### Stream Group (`struct flb_ml_stream_group`)
- Groups related log entries together based on metadata
- Maintains buffers for accumulating multiline content
- Tracks timing information for flush operations
- Stores metadata for context preservation
- Manages truncation flags for oversized messages

## Key Functions

### Stream Management
- `flb_ml_stream_create()` - Creates a new stream with specified parameters and callback functions
- `flb_ml_stream_destroy()` - Cleans up a stream and releases associated resources
- `flb_ml_stream_get()` - Retrieves an existing stream by its unique identifier
- `flb_ml_stream_id_destroy_all()` - Destroys all streams associated with a specific stream ID

### Group Management
- `flb_ml_stream_group_get()` - Retrieves or creates a stream group based on metadata
- `stream_group_create()` - Creates a new stream group with specified name
- `stream_group_destroy()` - Cleans up a stream group and releases its resources
- `stream_group_destroy_all()` - Destroys all groups associated with a stream

### Initialization
- `stream_group_init()` - Initializes the default group for a stream

## Important Variables

### Stream Identification
- `id` - Unique identifier for the stream (typically a hash of the stream name)
- `name` - Human-readable name for the stream (mostly for debugging purposes)

### Stream Configuration
- `groups` - List of groups contained within the stream
- `last_stream_group` - Reference to the last used group for optimization
- `forced_flush` - Flag indicating if a forced flush is pending

### Callback Functions
- `cb_flush` - Function pointer for the flush callback
- `cb_data` - Opaque data passed to the flush callback

### Parent References
- `ml` - Reference to the parent multiline context
- `parser` - Reference to the parent parser instance

## Dependencies

This module integrates with several core Fluent Bit components:
- `flb_mem.h` - Memory management utilities
- `flb_log.h` - Logging utilities
- `flb_pack.h` - MessagePack utilities for data serialization
- `flb_sds.h` - String data structure utilities
- `flb_ml.h` - Core multiline functionality
- `flb_ml_rule.h` - Multiline rule processing
- `cfl/cfl.h` - Core utilities library

## Notable Implementation Details

### Stream Identification
Streams are identified by a unique hash-based ID derived from their names, ensuring consistent identification across different processing sessions. This approach allows for efficient stream lookup without requiring string comparisons.

### Group-Based Organization
Streams can contain multiple groups based on metadata (such as container streams), allowing different handling of stdout vs stderr in containerized environments. This enables more precise control over multiline processing for different log categories.

### Default Group Creation
Each stream automatically gets a default group created during initialization, ensuring that there's always at least one group available for log processing even when no specific grouping metadata is provided.

### Buffer Management
Stream groups maintain their own buffers for accumulating multiline content, with automatic resizing and management using the SDS (String Data Structure) library for efficient string operations.

### Stream Lifecycle Management
The implementation carefully manages the lifecycle of streams and their associated groups, ensuring proper cleanup of all allocated resources and preventing memory leaks.

## Algorithm Overview

The stream management follows this general flow:
1. Stream creation based on unique identifiers
2. Default group initialization for new streams
3. Stream lookup during log processing
4. Group selection based on metadata
5. Content buffering in appropriate groups
6. Flushing of completed messages
7. Cleanup of unused streams and groups

## Memory Management

The implementation uses Fluent Bit's memory management utilities (`flb_calloc`, `flb_free`) for consistent memory handling. Buffer management uses the SDS library for efficient string operations and automatic resizing. All allocated resources are properly tracked and freed during cleanup operations.

## Thread Safety

The stream management functions are designed to be thread-safe in multi-threaded environments, using appropriate locking mechanisms where necessary to protect shared stream data structures.

## Usage Examples

### Creating a Multiline Stream
```c
uint64_t stream_id;
int ret = flb_ml_stream_create(ml,
                               "application_logs",
                               16,
                               my_flush_callback,
                               my_callback_data,
                               &stream_id);
```

### Retrieving a Stream
```c
struct flb_ml_stream *stream = flb_ml_stream_get(parser, stream_id);
```

### Getting a Stream Group
```c
struct flb_ml_stream_group *group = flb_ml_stream_group_get(parser_i, stream, group_name);
```

## Error Handling

The functions return specific error codes:
- `0` indicates success
- `-1` indicates general failure
- Functions may return NULL for pointer-returning functions to indicate failure

Stream creation failures are reported through Fluent Bit's logging system with descriptive error messages.

## Configuration Options

Streams can be configured through:
- Custom flush callback functions
- Opaque callback data
- Stream naming conventions
- Group creation policies

## Performance Considerations

For optimal performance:
1. Use consistent stream naming to leverage hash-based identification
2. Minimize the number of groups per stream (limited to FLB_ML_MAX_GROUPS)
3. Use efficient flush callbacks that don't block processing
4. Monitor memory usage for high-volume stream processing
5. Leverage the last_stream_group optimization for sequential processing