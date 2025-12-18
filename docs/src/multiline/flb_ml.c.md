# flb_ml.c Documentation

## Overview

This file contains the core implementation of the multiline processing engine in Fluent Bit. It handles the main logic for processing multiline log entries, managing streams, groups, and flushing completed messages.

## Purpose

The primary purpose of this file is to provide the central processing logic for multiline log aggregation. It manages:
- Stream creation and management
- Group handling for different log categories
- Rule-based processing for determining when a multiline message is complete
- Automatic flushing of pending messages
- Integration with various multiline parsing modes

## Key Data Structures

### Main Multiline Context (`struct flb_ml`)
- Manages the overall multiline processing environment
- Contains lists of groups and parsers
- Handles automatic flush timers
- Maintains buffer limits and configuration

### Stream Context (`struct flb_ml_stream`)
- Represents a logical stream of log data
- Contains multiple groups for categorization
- Manages flush callbacks for completed messages

### Stream Group (`struct flb_ml_stream_group`)
- Groups related log entries together
- Maintains buffers for accumulating multiline content
- Tracks timing information for flush operations

## Key Functions

### Core Processing Functions
- `flb_ml_append_text()` - Process raw text input
- `flb_ml_append_object()` - Process structured log objects
- `flb_ml_append_event()` - Process Fluent Bit log events

### Stream Management
- `flb_ml_stream_create()` - Create a new stream
- `flb_ml_stream_get()` - Retrieve an existing stream
- `flb_ml_stream_destroy()` - Clean up a stream

### Flush Operations
- `flb_ml_flush_pending()` - Flush pending messages based on time
- `flb_ml_flush_pending_now()` - Force immediate flush of all pending messages
- `flb_ml_flush_stream_group()` - Flush a specific group's buffer

### Initialization and Cleanup
- `flb_ml_create()` - Create a new multiline context
- `flb_ml_destroy()` - Clean up a multiline context

## Important Variables

### Buffer Management
- `buffer_limit` - Maximum size for concatenated multiline messages (default: 2MB)
- `flush_ms` - Automatic flush timeout in milliseconds (default: 4000ms)

### Timing
- `last_flush` - Timestamp of the last flush operation

## Dependencies

This module integrates with several core Fluent Bit components:
- `flb_time.h` - Time handling utilities
- `flb_regex.h` - Regular expression processing
- `flb_parser.h` - Log parsing functionality
- `flb_log_event_encoder.h` - Event encoding for output
- `flb_log_event_decoder.h` - Event decoding for input

## Notable Implementation Details

### LRU Parser Caching
The system maintains a Least Recently Used (LRU) cache of parsers to optimize performance when processing sequential log entries from the same source.

### Stream Grouping
Streams can be divided into groups based on metadata (like container streams), allowing different handling of stdout vs stderr in containerized environments.

### Automatic Flush Mechanism
A timer-based flush mechanism ensures that incomplete multiline messages are not held indefinitely, preventing memory issues and ensuring timely delivery of log data.

### Metadata Preservation
The system preserves metadata from the first line of a multiline message and applies it to the completed message, maintaining important contextual information.

## Usage Examples

### Creating a Multiline Context
```c
struct flb_ml *ml = flb_ml_create(config, "my_multiline_context");
```

### Appending Text Data
```c
int result = flb_ml_append_text(ml, stream_id, &timestamp, buffer, size);
```

### Appending Structured Data
```c
int result = flb_ml_append_object(ml, stream_id, &timestamp, metadata, object);
```

### Forcing Immediate Flush
```c
flb_ml_flush_pending_now(ml);
```