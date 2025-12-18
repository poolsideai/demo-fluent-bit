# flb_sp_stream.c

## Overview

This file implements stream creation and management functionality for the Fluent Bit Stream Processor. It provides the core mechanisms for creating virtual streams that can ingest processed data back into the Fluent Bit pipeline.

## Key Functions

### `flb_sp_stream_create`

The primary function for creating a new stream processor stream, registering it as an input plugin instance within Fluent Bit.

### `flb_sp_stream_append_data`

Appends processed data to a stream, making it available for further processing in the Fluent Bit pipeline.

### `flb_sp_stream_destroy`

Cleans up all resources associated with a stream, including the underlying input plugin instance.

## Important Variables and Constants

- `struct flb_sp_stream`: Main stream data structure
- `FLB_SP_STREAM`: Stream type identifier
- `FLB_SP_TAG`: Tag-based stream source identifier

## Dependencies

This file depends on:
- `<fluent-bit/flb_info.h>`: Core Fluent Bit information
- `<fluent-bit/flb_log.h>`: Logging utilities
- `<fluent-bit/flb_mem.h>`: Memory management utilities
- `<fluent-bit/flb_input.h>`: Input plugin interface
- `<fluent-bit/flb_metrics.h>`: Metrics collection utilities
- `<fluent-bit/flb_storage.h>`: Storage management utilities
- `<fluent-bit/flb_utils.h>`: Utility functions
- `<fluent-bit/stream_processor/flb_sp.h>`: Stream processor core definitions
- `<fluent-bit/stream_processor/flb_sp_parser.h>`: Stream processor parser definitions
- `<fluent-bit/stream_processor/flb_sp_stream.h>`: Stream-specific definitions

## Implementation Details

### Stream Creation Process

The stream creation involves several key steps:

1. **Name Validation**: Ensures the stream name doesn't conflict with existing input plugin instances

2. **Input Plugin Registration**: Creates an instance of the `in_stream_processor` input plugin, which serves as the gateway for processed data back into the Fluent Bit pipeline

3. **Property Configuration**: Sets stream properties such as:
   - Alias (custom name for the stream)
   - Tag (routing identifier for output)
   - Routability (whether the stream can be routed to outputs)
   - Storage type (memory vs file-based storage)

4. **Instance Initialization**: Initializes the input plugin instance and starts the data collector

5. **Metrics Setup**: Configures metrics collection for the stream

6. **Storage Context**: Sets up storage for the stream data

### Data Flow Architecture

```
Processed Data
    ↓
Stream Processor
    ↓
Stream Instance (in_stream_processor)
    ↓
Fluent Bit Pipeline
    ↓
Output Plugins
```

### Resource Management

The implementation carefully manages resources:
- SDS strings for names and tags
- Input plugin instances
- Storage contexts
- Metrics collectors
- Memory allocations

All resources are properly cleaned up during stream destruction.

### Integration with Fluent Bit Core

Streams integrate seamlessly with Fluent Bit's core architecture:
- Appear as regular input plugins in the configuration
- Can be routed to any output plugin
- Support all standard Fluent Bit features (metrics, storage, etc.)
- Follow Fluent Bit's naming conventions and lifecycle management

## Usage Examples

Streams are created through SQL-like commands:
```sql
CREATE STREAM processed_data WITH(tag='processed', routable='true') AS SELECT key1, COUNT(*) FROM STREAM:input_stream GROUP BY key1;
```

The created stream appears as an input plugin in the Fluent Bit pipeline and can be configured like any other input:
```ini
[INPUT]
    Name    processed_data
    Tag     processed.*
```