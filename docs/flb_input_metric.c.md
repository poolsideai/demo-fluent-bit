# flb_input_metric.c

## Overview

This file contains the implementation for handling metric data in Fluent Bit input plugins. It provides functionality for appending metric contexts to input chunks, processing metric data through the processor pipeline, and managing metric-specific operations.

The module serves as the primary interface for input plugins to submit metric data to the Fluent Bit engine. It handles conversion of metric contexts to MessagePack format, integrates with the processor system for data transformation, and manages the storage of metric data in input chunks.

Metric data flow through this module from input collection to chunk storage, with optional processing stages applied to transform the data before storage.

## Key Functions

### Metric Data Appending

#### `flb_input_metrics_append()`
Appends metric data (in CMetrics format) to an input chunk. This is the primary function used by input plugins to submit metric records. It processes the metrics through the processor pipeline if active.

#### `flb_input_metrics_append_skip_processor_stages()`
Appends metric data starting from a specific processor stage, allowing selective processing of metric records.

### Internal Processing

#### `input_metrics_append()`
Internal function that handles the core logic of metric appending, including processor integration, buffer management, and chunk storage.

## Important Variables/Constants

### Data Structures
- No specific data structures defined in this file as it primarily provides utility functions

## Dependencies

- `fluent-bit/flb_info.h`: Core Fluent Bit information
- `fluent-bit/flb_input.h`: Input plugin interface
- `fluent-bit/flb_input_chunk.h`: Input chunk management
- `fluent-bit/flb_input_plugin.h`: Plugin interface definitions
- `fluent-bit/flb_input_metric.h`: Header file defining the interface
- `cfl/cfl.h`: C Fluent Library
- `cmetrics/cmetrics.h`: CMetrics library interface
- `cmetrics/cmt_encode_msgpack.h`: MessagePack encoding for CMetrics

## Implementation Details

1. **Processor Integration**: Seamless integration with the processor pipeline to transform metric data before storage. The processor can modify, filter, or enrich metric records as they pass through.

2. **Buffer Management**: Efficient handling of metric encoding buffers, including automatic buffer allocation and deallocation.

3. **Tag Management**: Proper handling of metric tags, falling back to instance-level tags when record-specific tags are not provided.

4. **Error Handling**: Comprehensive error detection and propagation throughout the metric appending process.

5. **Memory Management**: Proper allocation and deallocation of encoding buffers and metric contexts.

6. **Chunk Integration**: Direct integration with the input chunk system for persistent storage of metric data.

7. **Empty Metric Handling**: Special handling for empty metric contexts to avoid unnecessary processing.

## Usage Example

```c
// Simple metric appending example
struct flb_input_instance *instance;
struct cmt *metric_context;
// ... initialize instance and metric context ...

// Append metric data
int ret = flb_input_metrics_append(
    instance,           // Input plugin instance
    "my.metrics.tag",   // Tag for the metric records
    16,                 // Tag length
    metric_context      // Metric context
);

if (ret == 0) {
    printf("Metric data appended successfully\n");
} else {
    printf("Failed to append metric data\n");
}

// Example with processor stages skipping
struct flb_input_instance *instance;
struct cmt *metric_context;
// ... initialize instance with processor and metric context ...

// Skip first processor stage
int ret = flb_input_metrics_append_skip_processor_stages(
    instance,           // Input plugin instance
    1,                  // Skip first processor stage
    "my.processed.metrics.tag", // Tag for the metric records
    26,                 // Tag length
    metric_context      // Metric context
);

if (ret == 0) {
    printf("Metric data processed and appended successfully\n");
} else {
    printf("Failed to process and append metric data\n");
}

// Complete example creating and appending metrics
struct flb_input_instance *instance;
struct cmt *metric_context;
struct cmt_counter *counter;
// ... initialize instance ...

// Create a new metric context
metric_context = cmt_create();
if (metric_context == NULL) {
    printf("Failed to create metric context\n");
    return -1;
}

// Create a counter metric
counter = cmt_counter_create(metric_context, "http_requests_total",
                              "Total HTTP requests", 1, (char *[]) {"method"});
if (counter == NULL) {
    printf("Failed to create counter metric\n");
    cmt_destroy(metric_context);
    return -1;
}

// Increment the counter
int ret = cmt_counter_add(counter, 1, 1, (char *[]) {"GET"});
if (ret != 0) {
    printf("Failed to increment counter\n");
    cmt_destroy(metric_context);
    return -1;
}

// Append the metric context to the input chunk
ret = flb_input_metrics_append(
    instance,           // Input plugin instance
    "http.metrics",     // Tag for the metric records
    12,                 // Tag length
    metric_context      // Metric context
);

if (ret == 0) {
    printf("HTTP metrics appended successfully\n");
} else {
    printf("Failed to append HTTP metrics\n");
}

// Clean up metric context
if (metric_context != NULL) {
    cmt_destroy(metric_context);
}
```