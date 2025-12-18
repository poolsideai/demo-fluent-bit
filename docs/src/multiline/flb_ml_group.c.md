# flb_ml_group.c Documentation

## Overview

This file contains the implementation for managing groups within the multiline processing system. Groups allow for categorizing and separating different types of log streams, particularly useful in containerized environments where stdout and stderr streams need to be handled separately. This module provides the core functionality for creating, managing, and destroying groups, as well as operations for working with stream groups within those groups.

## Purpose

The primary purpose of this file is to provide functions for creating, managing, and destroying groups within the multiline processing context. Groups serve as containers for organizing related log streams and applying consistent processing rules to them. This allows for more sophisticated multiline processing where different categories of logs can be handled with different rules or configurations.

## Key Data Structures

### Group Context (`struct flb_ml_group`)
- Represents a logical group of streams
- Contains a list of parser instances that operate on streams in this group
- Maintains timing information for flush operations
- Stores flush callbacks and associated data
- Tracks the Least Recently Used (LRU) parser for optimization
- Manages the lifecycle of associated parser instances

### Parser Instance (`struct flb_ml_parser_ins`)
- Represents a running instance of a multiline parser
- Contains references to the parser definition and runtime state
- Manages stream associations and last processed stream IDs
- Maintains parser-specific configuration and state

### Stream Group (`struct flb_ml_stream_group`)
- Represents a specific grouping of related log entries within a stream
- Maintains buffers for accumulating multiline content
- Tracks timing information for flush operations
- Stores metadata for context preservation
- Manages truncation flags for oversized messages

## Key Functions

### Group Management
- `flb_ml_group_create()` - Create a new group context with default settings
- `flb_ml_group_destroy()` - Clean up a group and all associated resources including parser instances
- `flb_ml_group_add_parser()` - Add a parser instance to a group for processing

### Stream Group Operations
- `flb_ml_stream_group_get()` - Retrieve or create a stream group for organizing log entries
- `flb_ml_group_cat()` - Concatenate content to a group's buffer with size limit checking

### Flush Management
- `flb_ml_group_flush_all()` - Flush all streams in a group (referenced in documentation but not in source)

## Important Variables

### Group Identification
- `id` - Unique identifier for the group, assigned sequentially
- `name` - Human-readable name for the group (not present in source but mentioned in documentation)

### Parser Management
- `parsers` - List of parser instances in this group for processing log data
- `lru_parser` - Least Recently Used parser reference for optimization of sequential processing

### Flush Configuration
- `flush_ms` - Automatic flush timeout for this group (referenced but not in source)
- `cb_flush` - Callback function for flushing completed messages

## Dependencies

This module depends on:
- Core Fluent Bit memory management (`flb_mem.h`) for allocation and deallocation
- String data structures (`flb_sds.h`) for efficient string operations
- Linked list utilities (`mk_list.h`) for data structure management
- Time handling (`flb_time.h`) for timestamp operations
- Main multiline engine (`flb_ml.h`) for integration with core functionality
- Parser definitions (`flb_ml_parser.h`) for parser instance management

## Notable Implementation Details

### LRU Parser Optimization
The system maintains a reference to the most recently used parser to optimize processing of sequential log entries from the same source, reducing lookup overhead and improving performance for common scenarios.

### Group-Based Stream Organization
Groups allow for logical separation of different stream types (like stdout vs stderr in containers), enabling different processing rules for different categories of log data. This is particularly useful in containerized environments where different streams may have different multiline characteristics.

### Automatic Resource Management
Groups automatically manage the lifecycle of associated parser instances and streams, ensuring proper cleanup when a group is destroyed. This prevents memory leaks and ensures consistent resource management.

### Buffer Size Management
The `flb_ml_group_cat()` function implements intelligent buffer size management with configurable limits and truncation handling to prevent memory exhaustion while still providing useful log data.

### Default Group Creation
When adding a parser to a context with no existing groups, a default group is automatically created, simplifying the setup process for basic multiline configurations.

### Safe String Operations
All string concatenation operations use safe functions that handle memory allocation and reallocation automatically, preventing buffer overflows and memory corruption.

## Algorithm Overview

The group management follows this process:
1. When a new multiline context is created, groups are created as needed
2. Parser instances are added to appropriate groups
3. Log streams are associated with specific groups based on metadata
4. Content is accumulated in group buffers until flush conditions are met
5. Completed messages are flushed through the group's callback mechanism
6. Resources are cleaned up when groups are destroyed

## Memory Management

The implementation uses Fluent Bit's memory management utilities (`flb_calloc`, `flb_free`) for consistent memory handling. Buffer management uses the SDS (String Data Structure) library for efficient string operations and automatic resizing. All allocated resources are properly tracked and freed during cleanup operations.

## Thread Safety

The multiline group processor is designed to be thread-safe in multi-threaded environments, using appropriate locking mechanisms where necessary to protect shared data structures. However, the specific locking implementation details would depend on the broader Fluent Bit threading model.

## Error Handling

The functions return specific error codes:
- `0` indicates success
- `-1` indicates general failure
- `FLB_MULTILINE_TRUNCATED` indicates the message was truncated due to size limits

Resource allocation failures are handled gracefully with proper cleanup of partially allocated resources.

## Usage Examples

### Creating a Group
```c
struct flb_ml_group *group = flb_ml_group_create(ml);
```

### Adding a Parser to a Group
```c
int result = flb_ml_group_add_parser(ml, parser_instance);
```

### Concatenating Content to a Group Buffer
```c
int result = flb_ml_group_cat(stream_group, data, length);
```

### Destroying a Group
```c
flb_ml_group_destroy(group);
```

## Configuration and Customization

Groups can be customized through:
- Different parser configurations for different processing rules
- Custom flush callbacks for specialized output handling
- Buffer size limits for memory management
- Stream grouping strategies for logical organization

## Performance Considerations

For optimal performance:
1. Use appropriate buffer sizes to minimize allocations
2. Configure flush timeouts based on log volume and latency requirements
3. Leverage LRU caching by maintaining consistent stream IDs
4. Monitor memory usage to prevent excessive buffering

## Integration Points

This module integrates with:
- The main multiline engine (`flb_ml.c`) for context management
- Parser definitions (`flb_ml_parser.c`) for parser instance creation
- Stream management (`flb_ml_stream.c`) for stream group operations
- Rule processing (`flb_ml_rule.c`) for multiline pattern matching

## Testing and Debugging

Debugging can be enabled through Fluent Bit's logging system. The group management functions include error checking and logging for troubleshooting issues with group creation, parser addition, and resource management.