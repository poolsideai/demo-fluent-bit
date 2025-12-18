# flb_ml.c

## Overview

This file contains the core implementation of the multiline processing engine in Fluent Bit. It provides the main functionality for detecting, buffering, and flushing multiline log messages based on various patterns and rules.

## Key Functions

### Core Processing Functions

- `flb_ml_append_text()` - Appends raw text content to the multiline processor
- `flb_ml_append_object()` - Appends structured log objects to the multiline processor
- `flb_ml_append_event()` - Appends decoded log events to the multiline processor
- `flb_ml_flush_stream_group()` - Flushes content from a specific stream group
- `flb_ml_flush_pending()` - Flushes pending content based on time intervals

### Context Management Functions

- `flb_ml_create()` - Creates a new multiline processing context
- `flb_ml_destroy()` - Destroys a multiline processing context
- `flb_ml_init()` - Initializes the multiline subsystem
- `flb_ml_exit()` - Cleans up the multiline subsystem

### Utility Functions

- `flb_ml_type_lookup()` - Maps string representations to multiline types
- `flb_ml_flush_stdout()` - Debug function for flushing to stdout

## Important Data Structures

### flb_ml
The main multiline context structure that holds:
- Context name and configuration
- List of processing groups
- Flush timing information
- Buffer limits
- Log event encoder/decoder

### flb_ml_stream
Represents a logical stream of log data with:
- Unique stream ID
- Stream name for debugging
- List of associated groups
- Flush callback and data

### flb_ml_stream_group
Groups related log entries by characteristics like stream type (stdout/stderr) with:
- Group name and identification
- Content buffer for accumulating multiline messages
- Timestamp information
- Metadata storage

## Dependencies

This module depends on:
- Fluent Bit core libraries (flb_mem, flb_log, flb_time, etc.)
- Multiline processing headers
- MessagePack serialization library
- Regular expression processing library
- Scheduler for automatic flushing

## Implementation Details

The multiline processor implements a state machine approach where:
1. Incoming log lines are analyzed against configured patterns
2. Matching lines are buffered together to form complete multiline messages
3. Non-matching lines trigger flushing of buffered content
4. Automatic flushing occurs based on time intervals to prevent indefinite buffering
5. Different processing modes (regex, endswith, equals) are supported for pattern matching

## Usage Examples

```c
// Create a multiline context
struct flb_ml *ml = flb_ml_create(ctx, "my_multiline_processor");

// Append log content
flb_ml_append_text(ml, stream_id, &timestamp, buffer, size);

// Flush pending content
flb_ml_flush_pending_now(ml);

// Clean up
flb_ml_destroy(ml);
```