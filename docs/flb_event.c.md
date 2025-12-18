# flb_event.c

## Overview

This file implements the event chunk management system for Fluent Bit. It provides functionality for creating, updating, and destroying event chunks that represent units of data processed by Fluent Bit.

Event chunks are fundamental data structures in Fluent Bit that encapsulate records with associated metadata like tags, types, and event counts. They serve as the primary data containers passed between input plugins, filters, and output plugins.

## Key Functions

### `flb_event_chunk_create()`
Creates a new event chunk structure with the specified type, tag, data, and event count. This is the primary constructor for event chunks.

### `flb_event_chunk_update()`
Updates the data buffer reference and size of an existing event chunk. Used when modifying chunk content without creating a new chunk.

### `flb_event_chunk_destroy()`
Cleans up and destroys an event chunk, freeing all associated memory resources including the tag string and chunk structure itself.

## Important Variables/Constants

### Event Chunk Structure (`struct flb_event_chunk`)
The main event chunk structure contains:
- `type`: Type of events contained in the chunk (log, metric, trace)
- `total_events`: Count of individual events in the chunk
- `tag`: Tag string identifying the source/origin of events
- `data`: Raw data buffer containing serialized events
- `size`: Size of the data buffer in bytes
- `trace`: Optional tracing information (when enabled)

### Event Types
- Log events: Standard log record chunks
- Metric events: Telemetry and monitoring data chunks
- Trace events: Distributed tracing data chunks

## Dependencies

- `fluent-bit/flb_info.h`: Fluent Bit core information
- `fluent-bit/flb_mem.h`: Memory management utilities
- `fluent-bit/flb_log.h`: Logging utilities
- `fluent-bit/flb_event.h`: Event interface
- `fluent-bit/flb_sds.h`: Simple Dynamic String utilities

## Implementation Details

1. **Memory Management**: Uses Fluent Bit's memory allocation functions and SDS strings for efficient memory handling.

2. **Data Encapsulation**: Event chunks encapsulate all necessary metadata along with raw data for complete self-description.

3. **Type Safety**: Supports different event types (log, metric, trace) with appropriate type tracking.

4. **Resource Cleanup**: Provides comprehensive cleanup functions to prevent memory leaks.

5. **Conditional Compilation**: Supports optional tracing features through conditional compilation.

## Usage Example

```c
// Create an event chunk for log data
char *tag = "app.logs";
char *log_data = "[1609459200.000000] Hello World";
size_t data_size = strlen(log_data);

struct flb_event_chunk *evc = flb_event_chunk_create(FLB_EVENT_TYPE_LOG, 
                                                      1, 
                                                      tag, strlen(tag), 
                                                      log_data, data_size);

if (!evc) {
    flb_error("Failed to create event chunk");
    return -1;
}

// Update the chunk with new data
char *new_data = "[1609459260.000000] Updated message";
size_t new_size = strlen(new_data);
flb_event_chunk_update(evc, new_data, new_size);

// Process the event chunk...
process_event_chunk(evc);

// Clean up
flb_event_chunk_destroy(evc);
```