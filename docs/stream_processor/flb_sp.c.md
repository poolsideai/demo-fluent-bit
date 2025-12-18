# flb_sp.c Documentation

## Overview

This file implements the core Stream Processor functionality for Fluent Bit. It provides the main entry points and core logic for processing log data streams using SQL-like syntax. The Stream Processor enables users to perform complex transformations, aggregations, and filtering operations on incoming log data.

## Key Functions

### flb_sp_create()
Creates a new Stream Processor instance and initializes it with configuration settings.

### flb_sp_destroy()
Destroys a Stream Processor instance, freeing all associated memory and resources.

### flb_sp_do()
Processes incoming data through the Stream Processor, applying configured transformations and aggregations.

### flb_sp_task_create()
Creates a new stream processing task from a SQL statement.

### flb_sp_task_destroy()
Destroys a stream processing task, cleaning up all associated resources.

### flb_sp_snapshot_create()
Creates a snapshot for a stream processing task, typically used for time-based operations.

### flb_sp_snapshot_destroy()
Destroys a snapshot, freeing associated memory.

### flb_sp_window_destroy()
Destroys windowing structures associated with a stream processing task.

### flb_sp_cmd_aggregated_keys()
Analyzes command keys to determine aggregation requirements and validate query semantics.

### sp_config_file()
Reads and processes configuration from a file, registering stream processing tasks.

### sp_task_to_instance()
Maps stream processing tasks to input instances for data flow.

### sp_info()
Outputs information about registered stream processing tasks.

### subkeys_compare()
Compares subkey lists for equality, used in key matching operations.

### string_to_number()
Converts string representations to numerical values (integers or floats).

## Important Constants

### FLB_STR_INT
Constant indicating a string represents an integer value.

### FLB_STR_FLOAT
Constant indicating a string represents a floating-point value.

## Dependencies

- `<fluent-bit/flb_info.h>` - Core Fluent Bit information
- `<fluent-bit/flb_log.h>` - Logging utilities
- `<fluent-bit/flb_sds.h>` - Simple Dynamic Strings implementation
- `<fluent-bit/flb_mem.h>` - Memory management utilities
- `<fluent-bit/flb_slist.h>` - Simple linked list implementation
- `<fluent-bit/flb_utils.h>` - Utility functions
- `<fluent-bit/flb_time.h>` - Time handling utilities
- `<fluent-bit/flb_input.h>` - Input plugin interface
- `<fluent-bit/flb_pack.h>` - Data packing utilities
- `<fluent-bit/flb_router.h>` - Routing utilities
- `<fluent-bit/flb_config_format.h>` - Configuration format handling
- `<fluent-bit/stream_processor/flb_sp.h>` - Stream processor header
- `<fluent-bit/stream_processor/flb_sp_key.h>` - Key handling utilities
- `<fluent-bit/stream_processor/flb_sp_stream.h>` - Stream handling utilities
- `<fluent-bit/stream_processor/flb_sp_snapshot.h>` - Snapshot handling utilities
- `<fluent-bit/stream_processor/flb_sp_parser.h>` - Parser utilities
- `<fluent-bit/stream_processor/flb_sp_func_time.h>` - Time functions
- `<fluent-bit/stream_processor/flb_sp_func_record.h>` - Record functions
- `<fluent-bit/stream_processor/flb_sp_aggregate_func.h>` - Aggregate functions
- `<fluent-bit/stream_processor/flb_sp_window.h>` - Windowing utilities
- `<fluent-bit/stream_processor/flb_sp_groupby.h>` - Group by utilities

## Relationships

This file is the core implementation of the Stream Processor and works closely with:
- `flb_sp_key.c` - Key handling functionality
- `flb_sp_func_time.c` - Time-related functions
- `flb_sp_func_record.c` - Record manipulation functions
- `flb_sp_aggregate_func.c` - Aggregate functions
- `flb_sp_stream.c` - Stream management
- `flb_sp_snapshot.c` - Snapshot functionality
- `flb_sp_window.c` - Windowing functionality
- `flb_sp_groupby.c` - Group by functionality
- Parser components for SQL statement processing

## Implementation Details

The implementation features:
1. Main entry points for Stream Processor lifecycle management
2. Task creation and management for individual processing operations
3. Configuration file parsing and task registration
4. Data processing pipeline with windowing and aggregation support
5. Memory-efficient handling of streaming data
6. Integration with Fluent Bit's input/output plugin system
7. Proper error handling and resource cleanup
8. Support for complex SQL-like operations including SELECT, CREATE STREAM, WHERE clauses, GROUP BY, and various windowing functions

## Usage Examples

```c
// Create a Stream Processor instance
struct flb_sp *sp = flb_sp_create(config);

// Process incoming data
int result = flb_sp_do(sp, input_instance, data_buffer, data_size);

// Destroy the Stream Processor when done
flb_sp_destroy(sp);
```

The Stream Processor enables powerful real-time analytics on log data streams using familiar SQL syntax, making it accessible to developers and analysts alike while providing high-performance processing capabilities.