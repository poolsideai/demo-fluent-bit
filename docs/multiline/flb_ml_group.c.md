# flb_ml_group.c

## Overview

This file implements the group management functionality for the multiline processing system in Fluent Bit. It handles the creation, management, and destruction of processing groups that organize related log streams.

## Key Functions

### Group Management

- `flb_ml_group_create()` - Creates a new processing group within a multiline context
- `flb_ml_group_add_parser()` - Links a parser instance to an active group
- `flb_ml_group_destroy()` - Destroys a processing group and its associated resources

### Group Content Operations

- `flb_ml_group_cat()` - Appends content to a group's buffer with size limiting

## Important Data Structures

### flb_ml_group
Represents a processing group that contains:
- Unique group identifier
- List of parser instances
- LRU (Least Recently Used) parser reference for optimization
- Flush configuration and callbacks
- Reference to parent multiline context

## Dependencies

This module depends on:
- Fluent Bit core libraries (flb_mem, flb_log)
- Multiline processing headers
- Stream processing functionality (flb_ml_stream.c)
- Parser management functionality (flb_ml_parser.c)

## Implementation Details

The group management system provides:
1. **Dynamic Group Creation**: Groups are created automatically when needed
2. **Parser Association**: Multiple parser instances can be linked to the same group
3. **LRU Optimization**: Tracks the most recently used parser for performance
4. **Resource Management**: Proper cleanup of all group resources during destruction
5. **Content Buffering**: Safe appending of content with buffer limit enforcement

## Usage Examples

```c
// Create a new processing group
struct flb_ml_group *group = flb_ml_group_create(ml_context);

// Add a parser instance to the group
flb_ml_group_add_parser(ml_context, parser_instance);

// Append content to a group buffer with size checking
int result = flb_ml_group_cat(stream_group, data, length);

// Clean up the group
flb_ml_group_destroy(group);
```