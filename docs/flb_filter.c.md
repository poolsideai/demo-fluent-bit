# flb_filter.c

## Overview

This file implements the filter plugin management system for Fluent Bit. It provides functionality for creating, initializing, configuring, and executing filter plugins that process data between input and output plugins.

Filter plugins are responsible for transforming, enriching, or filtering data records as they pass through the Fluent Bit pipeline. This module manages the lifecycle of filter instances and coordinates their execution.

## Key Functions

### `flb_filter_do()`
The main filter execution function that processes data chunks through all configured filter plugins. It handles routing decisions, invokes filter callbacks, and manages the flow of data through the filter chain.

### `flb_filter_new()`
Creates a new filter instance for a specified filter plugin, initializing its basic structure and adding it to the configuration.

### `flb_filter_init()`
Initializes a filter instance, including property validation, metric registration, and calling the plugin's initialization callback.

### `flb_filter_set_property()`
Sets configuration properties for a filter instance, handling special properties like `match`, `alias`, `log_level`, and `log_suppress_interval`.

### `flb_filter_get_property()`
Retrieves the value of a configuration property for a filter instance.

### `flb_filter_init_all()`
Initializes all configured filter instances in the system.

### `flb_filter_exit()`
Shuts down all filter instances and cleans up their resources.

## Important Variables/Constants

### Filter Instance Structure (`struct flb_filter_instance`)
The main filter instance structure contains:
- `id`: Unique identifier for the instance
- `name`: Instance name (plugin name + sequence number)
- `alias`: User-defined alias for the instance
- `p`: Pointer to the filter plugin definition
- `context`: Plugin-specific context data
- `match`: Tag matching pattern for routing
- `match_regex`: Regular expression for advanced matching
- `properties`: Configuration properties list
- `event_type`: Type of events the filter processes
- `log_level`: Logging level for the instance
- `log_suppress_interval`: Interval for suppressing repetitive logs
- `cmt`: CMetrics context for metrics collection
- `metrics`: Legacy metrics context

### Global Properties
- `match`: Tag pattern for record matching
- `match_regex`: Regular expression for tag matching
- `alias`: Instance alias
- `log_level`: Logging level
- `log_suppress_interval`: Log suppression interval

### Filter Return Codes
- `FLB_FILTER_NOTOUCH`: No changes made to data
- `FLB_FILTER_MODIFIED`: Data was modified
- `FLB_FILTER_NEW_RECORDS`: New records were added

## Dependencies

- `fluent-bit/flb_config.h`: Configuration management
- `fluent-bit/flb_filter.h`: Filter plugin interface
- `fluent-bit/flb_str.h`: String utilities
- `fluent-bit/flb_env.h`: Environment variable handling
- `fluent-bit/flb_router.h`: Routing functionality
- `fluent-bit/flb_mp.h`: MessagePack utilities
- `fluent-bit/flb_kv.h`: Key-value pair utilities
- `fluent-bit/flb_pack.h`: Data packing utilities
- `fluent-bit/flb_metrics.h`: Metrics collection
- `fluent-bit/flb_utils.h`: General utilities
- `chunkio/chunkio.h`: Chunk I/O operations
- `fluent-bit/flb_chunk_trace.h`: Chunk tracing (conditional)
- `fluent-bit/flb_regex.h`: Regular expression support (conditional)

## Implementation Details

1. **Plugin Lifecycle Management**: Handles complete lifecycle from creation to destruction, including initialization, execution, and cleanup.

2. **Routing Integration**: Works with the router to determine which records should be processed by each filter instance.

3. **Property Management**: Provides comprehensive property handling with environment variable substitution and special property recognition.

4. **Metrics Collection**: Integrates with both legacy metrics and CMetrics systems for performance monitoring.

5. **Error Handling**: Implements robust error handling with proper resource cleanup and meaningful error messages.

6. **Conditional Compilation**: Supports optional features like regular expressions and chunk tracing through conditional compilation.

7. **Memory Management**: Uses Fluent Bit's memory allocation functions and SDS strings for efficient memory handling.

## Usage Example

```c
// Create a new filter instance
struct flb_filter_instance *filter_ins = flb_filter_new(config, "grep", NULL);

// Set configuration properties
flb_filter_set_property(filter_ins, "match", "app.logs");
flb_filter_set_property(filter_ins, "grep", "ERROR");
flb_filter_set_property(filter_ins, "alias", "error_filter");

// Initialize the filter
int ret = flb_filter_init(config, filter_ins);
if (ret == -1) {
    flb_error("Failed to initialize filter");
    return -1;
}

// Process data through filters
struct flb_input_chunk *ic = get_input_chunk();
void *filtered_data = NULL;
size_t filtered_size = 0;

flb_filter_do(ic, ic->data, ic->size, &filtered_data, &filtered_size, 
                ic->tag, flb_sds_len(ic->tag), config);

// Clean up
flb_filter_exit(config);
```