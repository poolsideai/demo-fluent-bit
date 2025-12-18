# flb_ml_group.c Documentation

## Overview

This file contains the implementation for managing groups within the multiline processing system. Groups allow for categorizing and separating different types of log streams, particularly useful in containerized environments where stdout and stderr streams need to be handled separately.

## Purpose

The primary purpose of this file is to provide functions for creating, managing, and destroying groups within the multiline processing context. Groups serve as containers for organizing related log streams and applying consistent processing rules to them.

## Key Data Structures

### Group Context (`struct flb_ml_group`)
- Represents a logical group of streams
- Contains a list of parser instances that operate on streams in this group
- Maintains timing information for flush operations
- Stores flush callbacks and associated data

### Parser Instance (`struct flb_ml_parser_ins`)
- Represents a running instance of a multiline parser
- Contains references to the parser definition and runtime state
- Manages stream associations and last processed stream IDs

## Key Functions

### Group Management
- `flb_ml_group_create()` - Create a new group context
- `flb_ml_group_destroy()` - Clean up a group and all associated resources
- `flb_ml_group_add_parser()` - Add a parser instance to a group

### Stream Group Operations
- `flb_ml_stream_group_get()` - Retrieve or create a stream group
- `flb_ml_group_cat()` - Concatenate content to a group's buffer

### Flush Management
- `flb_ml_group_flush_all()` - Flush all streams in a group

## Important Variables

### Group Identification
- `id` - Unique identifier for the group
- `name` - Human-readable name for the group

### Parser Management
- `parsers` - List of parser instances in this group
- `lru_parser` - Least Recently Used parser for optimization

### Flush Configuration
- `flush_ms` - Automatic flush timeout for this group
- `cb_flush` - Callback function for flushing completed messages

## Dependencies

This module depends on:
- Core Fluent Bit memory management (`flb_mem.h`)
- String data structures (`flb_sds.h`)
- Linked list utilities (`mk_list.h`)
- Time handling (`flb_time.h`)
- Main multiline engine (`flb_ml.h`)

## Notable Implementation Details

### LRU Parser Optimization
The system maintains a reference to the most recently used parser to optimize processing of sequential log entries from the same source, reducing lookup overhead.

### Group-Based Stream Organization
Groups allow for logical separation of different stream types (like stdout vs stderr in containers), enabling different processing rules for different categories of log data.

### Automatic Resource Management
Groups automatically manage the lifecycle of associated parser instances and streams, ensuring proper cleanup when a group is destroyed.

## Usage Examples

### Creating a Group
```c
struct flb_ml_group *group = flb_ml_group_create(ml, "container_logs");
```

### Adding a Parser to a Group
```c
int result = flb_ml_group_add_parser(group, parser_instance);
```

### Retrieving a Stream Group
```c
struct flb_ml_stream_group *sg = flb_ml_stream_group_get(parser_instance, stream, group_name);
```