# flb_input_trace.c

## Overview

This file contains the implementation for handling trace data in Fluent Bit input plugins. It provides functionality for appending trace contexts to input chunks, processing trace data through the processor pipeline, and managing trace-specific operations.

The module serves as the primary interface for input plugins to submit trace data to the Fluent Bit engine. It handles conversion of trace contexts to MessagePack format, integrates with the processor system for data transformation, and manages the storage of trace data in input chunks.

Trace data flow through this module from input collection to chunk storage, with optional processing stages applied to transform the data before storage. This is particularly useful for distributed tracing data and other structured tracing information.

## Key Functions

### Trace Data Appending

#### `flb_input_trace_append()`
Appends trace data (in CTraces format) to an input chunk. This is the primary function used by input plugins to submit trace records. It processes the traces through the processor pipeline if active.

#### `flb_input_trace_append_skip_processor_stages()`
Appends trace data starting from a specific processor stage, allowing selective processing of trace records.

### Internal Processing

#### `input_trace_append()`
Internal function that handles the core logic of trace appending, including processor integration, buffer management, and chunk storage.

## Important Variables/Constants

### Data Structures
- No specific data structures defined in this file as it primarily provides utility functions

## Dependencies

- `fluent-bit/flb_info.h`: Core Fluent Bit information
- `fluent-bit/flb_input.h`: Input plugin interface
- `fluent-bit/flb_input_chunk.h`: Input chunk management
- `fluent-bit/flb_input_plugin.h`: Plugin interface definitions
- `fluent-bit/flb_input_trace.h`: Header file defining the interface
- `ctraces/ctraces.h`: CTraces library interface
- `ctraces/ctr_decode_msgpack.h`: MessagePack encoding for CTraces

## Implementation Details

1. **Processor Integration**: Seamless integration with the processor pipeline to transform trace data before storage. The processor can modify, filter, or enrich trace records as they pass through.

2. **Buffer Management**: Efficient handling of trace encoding buffers, including automatic buffer allocation and deallocation.

3. **Tag Management**: Proper handling of trace tags, falling back to instance-level tags when record-specific tags are not provided.

4. **Error Handling**: Comprehensive error detection and propagation throughout the trace appending process.

5. **Memory Management**: Proper allocation and deallocation of encoding buffers and trace contexts.

6. **Chunk Integration**: Direct integration with the input chunk system for persistent storage of trace data.

7. **Context Lifecycle**: Proper management of trace context lifecycle with automatic destruction when appropriate.

## Usage Example

```c
// Simple trace appending example
struct flb_input_instance *instance;
struct ctrace *trace_context;
// ... initialize instance and trace context ...

// Append trace data
int ret = flb_input_trace_append(
    instance,           // Input plugin instance
    "my.traces.tag",    // Tag for the trace records
    15,                 // Tag length
    trace_context       // Trace context
);

if (ret == 0) {
    printf("Trace data appended successfully\n");
} else {
    printf("Failed to append trace data\n");
}

// Example with processor stages skipping
struct flb_input_instance *instance;
struct ctrace *trace_context;
// ... initialize instance with processor and trace context ...

// Skip first processor stage
int ret = flb_input_trace_append_skip_processor_stages(
    instance,           // Input plugin instance
    1,                  // Skip first processor stage
    "my.processed.traces.tag", // Tag for the trace records
    26,                 // Tag length
    trace_context       // Trace context
);

if (ret == 0) {
    printf("Trace data processed and appended successfully\n");
} else {
    printf("Failed to process and append trace data\n");
}

// Complete example creating and appending traces
struct flb_input_instance *instance;
struct ctrace *trace_context;
struct ctrace_span *span;
// ... initialize instance ...

// Create a new trace context
trace_context = ctr_create();
if (trace_context == NULL) {
    printf("Failed to create trace context\n");
    return -1;
}

// Create a span in the trace
span = ctr_span_create(trace_context, "main_operation");
if (span == NULL) {
    printf("Failed to create span\n");
    ctr_destroy(trace_context);
    return -1;
}

// Add attributes to the span
ctr_span_set_attr_string(span, "operation", "database_query");
ctr_span_set_attr_int(span, "duration_ms", 150);

// Set span status
ctr_span_status_set(span, CTRACE_SPAN_STATUS_OK, "Success");

// Append the trace context to the input chunk
int ret = flb_input_trace_append(
    instance,           // Input plugin instance
    "application.traces", // Tag for the trace records
    17,                 // Tag length
    trace_context       // Trace context
);

if (ret == 0) {
    printf("Application traces appended successfully\n");
} else {
    printf("Failed to append application traces\n");
}

// Note: The trace context is automatically destroyed by flb_input_trace_append
// when successful, so we don't need to manually destroy it in that case.
```