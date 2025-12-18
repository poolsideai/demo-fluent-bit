# flb_ml.c Documentation

## Overview

This file contains the core implementation of the multiline processing engine in Fluent Bit. It handles the main logic for processing multiline log entries, managing streams, groups, and flushing completed messages. This is the central component that orchestrates all multiline functionality.

## Purpose

The primary purpose of this file is to provide the central processing logic for multiline log aggregation. It manages:
- Stream creation and management for different log sources
- Group handling for different log categories and contexts
- Rule-based processing for determining when a multiline message is complete
- Automatic flushing of pending messages based on time or size constraints
- Integration with various multiline parsing modes
- Memory management for buffer allocation and cleanup
- Error handling and recovery mechanisms

## Key Data Structures

### Main Multiline Context (`struct flb_ml`)
- Manages the overall multiline processing environment
- Contains lists of groups and parsers for organization
- Handles automatic flush timers for timeout-based flushing
- Maintains buffer limits and configuration settings
- Tracks last flush timestamps for timing operations
- Manages log event encoders/decoders for data processing

### Stream Context (`struct flb_ml_stream`)
- Represents a logical stream of log data from a specific source
- Contains multiple groups for categorization of log entries
- Manages flush callbacks for completed messages
- Tracks the last used stream group for optimization
- Maintains parser instance references for processing

### Stream Group (`struct flb_ml_stream_group`)
- Groups related log entries together based on metadata
- Maintains buffers for accumulating multiline content
- Tracks timing information for flush operations
- Stores metadata for context preservation
- Manages truncation flags for oversized messages

## Key Functions

### Core Processing Functions
- `flb_ml_append_text()` - Process raw text input from log sources
- `flb_ml_append_object()` - Process structured log objects with metadata
- `flb_ml_append_event()` - Process Fluent Bit log events for standardized input

### Stream Management
- `flb_ml_stream_create()` - Create a new stream with specified parameters
- `flb_ml_stream_get()` - Retrieve an existing stream by ID
- `flb_ml_stream_destroy()` - Clean up a stream and release associated resources

### Flush Operations
- `flb_ml_flush_pending()` - Flush pending messages based on time thresholds
- `flb_ml_flush_pending_now()` - Force immediate flush of all pending messages
- `flb_ml_flush_stream_group()` - Flush a specific group's buffer to output

### Initialization and Cleanup
- `flb_ml_create()` - Create a new multiline context with configuration
- `flb_ml_destroy()` - Clean up a multiline context and release all resources
- `flb_ml_init()` - Initialize the multiline subsystem globally
- `flb_ml_exit()` - Clean up the multiline subsystem globally

### Parser Management
- `flb_ml_parsers_init()` - Initialize all configured multiline parsers
- `flb_ml_auto_flush_init()` - Set up automatic flush timer mechanism

## Important Variables

### Buffer Management
- `buffer_limit` - Maximum size for concatenated multiline messages (default: 2MB)
- `flush_ms` - Automatic flush timeout in milliseconds (default: 4000ms)

### Timing
- `last_flush` - Timestamp of the last flush operation for timeout calculations

### Configuration
- `name` - Identifier for the multiline context
- `config` - Reference to the main Fluent Bit configuration

## Dependencies

This module integrates with several core Fluent Bit components:
- `flb_time.h` - Time handling utilities for timestamp management
- `flb_regex.h` - Regular expression processing for pattern matching
- `flb_parser.h` - Log parsing functionality for data transformation
- `flb_log_event_encoder.h` - Event encoding for output formatting
- `flb_log_event_decoder.h` - Event decoding for input processing
- `flb_mem.h` - Memory management utilities
- `flb_sds.h` - String data structure utilities
- `flb_utils.h` - General utility functions

## Notable Implementation Details

### LRU Parser Caching
The system maintains a Least Recently Used (LRU) cache of parsers to optimize performance when processing sequential log entries from the same source. This reduces the overhead of repeatedly selecting the appropriate parser for consecutive messages.

### Stream Grouping
Streams can be divided into groups based on metadata (like container streams), allowing different handling of stdout vs stderr in containerized environments. This enables more precise control over multiline processing for different log categories.

### Automatic Flush Mechanism
A timer-based flush mechanism ensures that incomplete multiline messages are not held indefinitely, preventing memory issues and ensuring timely delivery of log data. The flush timer is configurable and defaults to 4 seconds.

### Metadata Preservation
The system preserves metadata from the first line of a multiline message and applies it to the completed message, maintaining important contextual information such as timestamps and source identifiers.

### Truncation Handling
Messages that exceed buffer limits are truncated with appropriate markers to prevent memory exhaustion while still providing useful log data.

### Error Recovery
The implementation includes robust error handling to recover gracefully from parsing failures or memory allocation issues without losing track of pending messages.

## Algorithm Overview

The multiline processing follows this general flow:
1. Incoming log data is appended to the appropriate stream
2. The system determines which parser should handle the data
3. Parser rules are applied to determine if the message is complete
4. If complete, the message is flushed to output
5. If incomplete, the message is buffered for subsequent lines
6. Periodic automatic flushes ensure no messages are held too long

## Memory Management

The implementation uses Fluent Bit's memory management utilities (`flb_calloc`, `flb_free`) for consistent memory handling. Buffer management uses the SDS (String Data Structure) library for efficient string operations and automatic resizing.

## Thread Safety

The multiline processor is designed to be thread-safe in multi-threaded environments, using appropriate locking mechanisms where necessary to protect shared data structures.

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

### Initializing Global Subsystem
```c
int result = flb_ml_init(config);
```

## Error Handling

The functions return specific error codes:
- `0` or positive values indicate success
- `-1` indicates general failure
- `FLB_MULTILINE_TRUNCATED` indicates the message was truncated due to size limits

## Performance Considerations

For optimal performance:
1. Use appropriate buffer sizes to minimize allocations
2. Configure flush timeouts based on log volume and latency requirements
3. Leverage LRU caching by maintaining consistent stream IDs
4. Monitor memory usage to prevent excessive buffering

## Configuration Options

The multiline processor can be configured through:
- Buffer size limits via `multiline_buffer_limit`
- Flush timeouts via `flush_ms`
- Parser configurations through the main Fluent Bit configuration system

## Testing and Debugging

Debugging output can be enabled through Fluent Bit's logging system. The `flb_ml_flush_stdout` function provides a debugging callback for examining flushed content during development.