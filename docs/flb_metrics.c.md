# flb_metrics.c

## Overview

This file implements the metrics collection system for Fluent Bit. It provides utilities for creating, managing, and exporting metrics from the core engine and plugins. The system supports both legacy metrics and modern cmetrics (Prometheus-style) metrics.

## Key Functions

### flb_metrics_create

Creates a new metrics context with a given title.

**Parameters:**
- `title`: Title for the metrics context

**Returns:** Pointer to the created metrics context, or NULL on failure

### flb_metrics_add

Adds a new metric to the metrics context.

**Parameters:**
- `id`: Unique identifier for the metric (-1 to auto-generate)
- `title`: Descriptive title for the metric
- `metrics`: Parent metrics context

**Returns:** Assigned metric ID, or -1 on failure

### flb_metrics_get_id

Retrieves a metric by its ID.

**Parameters:**
- `id`: Metric ID to look up
- `metrics`: Parent metrics context

**Returns:** Pointer to the metric, or NULL if not found

### flb_metrics_sum

Adds a value to a metric's current value.

**Parameters:**
- `id`: Metric ID
- `val`: Value to add
- `metrics`: Parent metrics context

**Returns:** 0 on success, -1 on failure

### flb_metrics_destroy

Destroys a metrics context and frees all associated resources.

**Parameters:**
- `metrics`: Metrics context to destroy

**Returns:** Number of metrics destroyed

### flb_metrics_print

Prints metrics to stdout for debugging purposes.

**Parameters:**
- `metrics`: Metrics context to print

**Returns:** 0 on success

### flb_metrics_dump_values

Exports metrics in MessagePack format.

**Parameters:**
- `out_buf`: Buffer to store serialized metrics
- `out_size`: Size of the serialized data
- `me`: Metrics context

**Returns:** 0 on success

### flb_metrics_fluentbit_add

Adds internal Fluent Bit metrics to a cmetrics context.

**Parameters:**
- `ctx`: Fluent Bit configuration context
- `cmt`: cmetrics context

**Returns:** 0 on success, -1 on failure

## Dependencies

- `<fluent-bit/flb_info.h>`: Core Fluent Bit header
- `<fluent-bit/flb_mem.h>`: Memory management utilities
- `<fluent-bit/flb_version.h>`: Version information
- `<fluent-bit/flb_utils.h>`: Utility functions
- `<fluent-bit/flb_metrics.h>`: Metrics interface header
- `<msgpack.h>`: MessagePack serialization library

## Important Variables

### FLB_METRIC_LENGTH_LIMIT

Defines the maximum length for metric titles to prevent excessive memory usage.

## Implementation Details

The metrics system maintains a linked list of metrics within a metrics context. Each metric has an ID, title, and value. The system supports automatic ID generation and ensures uniqueness of IDs within a context.

The MessagePack export functionality serializes metrics into a map format where keys are metric titles and values are metric values.

Internal Fluent Bit metrics include:
- Uptime: Number of seconds Fluent Bit has been running
- Process start time: Unix timestamp of when the process started
- Build info: Version and OS information
- Hot reload count: Number of times hot reloading has occurred

## Usage Examples

```c
// Create a metrics context
struct flb_metrics *metrics = flb_metrics_create("my_plugin");

// Add metrics
int id1 = flb_metrics_add(1, "records_processed", metrics);
int id2 = flb_metrics_add(2, "errors_count", metrics);

// Update metrics
flb_metrics_sum(id1, 10, metrics);
flb_metrics_sum(id2, 1, metrics);

// Export metrics
char *buffer;
size_t size;
flb_metrics_dump_values(&buffer, &size, metrics);

// Clean up
flb_metrics_destroy(metrics);
```