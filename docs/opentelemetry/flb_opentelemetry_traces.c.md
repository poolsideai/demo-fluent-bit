# flb_opentelemetry_traces.c

## Overview

This file implements the OpenTelemetry traces processing functionality for Fluent Bit. It provides the core logic for converting OpenTelemetry Protocol (OTLP) JSON traces into Fluent Bit's internal CTraces format. The implementation handles the complex nested structure of OTLP traces, including resource spans, scope spans, and individual span data, while preserving all metadata, attributes, events, and links.

## Key Functions

### `flb_opentelemetry_json_traces_to_ctrace`

Converts OTLP JSON traces to Fluent Bit's internal CTraces format.

**Parameters:**
- `body`: Raw JSON trace data
- `len`: Length of the JSON data
- `error_status`: Output parameter for detailed error codes

**Returns:**
- Pointer to the created CTraces context on success
- NULL on failure

### `process_root_msgpack`

Processes the root OTLP JSON payload structure.

### `process_resource_span`

Processes individual resource span entries.

### `process_scope_span`

Processes scope span entries within resource spans.

### `process_spans`

Processes individual span entries.

## Important Variables/Constants

- Error codes: Various error constants for different failure conditions
- `CTRACE_SPAN_STATUS_CODE_*`: Span status codes

## Dependencies

- `flb_info.h`: Fluent Bit core information
- `flb_log.h`: Logging utilities
- `flb_mem.h`: Memory management utilities
- `flb_pack.h`: Data packing utilities
- `flb_sds.h`: Simple Dynamic Strings
- `flb_opentelemetry.h`: OpenTelemetry core functionality
- `ctraces/ctraces.h`: CTraces library for trace processing

## Implementation Details

### OTLP Structure Processing

The implementation follows the OpenTelemetry Protocol specification for traces:

1. **Root Level**: Processes the top-level `resourceSpans` array
2. **Resource Spans**: Handles resource-level metadata and attributes
3. **Scope Spans**: Processes instrumentation scope information
4. **Spans**: Converts individual span entries with full metadata

### Data Transformation

Key transformations performed:

- **Attribute Conversion**: Transforms OTLP key-value lists to CTraces format
- **Timestamp Handling**: Converts Unix nanoseconds timestamps
- **ID Processing**: Validates and converts hexadecimal trace and span identifiers
- **Event Processing**: Handles span events with their own attributes
- **Link Processing**: Processes span links with trace state information
- **Status Mapping**: Converts span status codes and messages

### Validation and Error Handling

The implementation includes comprehensive validation:

- **Type Checking**: Ensures all fields match expected types per OTLP specification
- **Format Validation**: Validates hexadecimal trace/span IDs and timestamp formats
- **Structure Validation**: Verifies required fields and nested structures
- **Detailed Error Codes**: Provides specific error codes for different failure scenarios

### Memory Management

Efficient memory handling through:

- **CTraces Integration**: Uses the CTraces library for trace data management
- **Buffer Management**: Proper allocation and cleanup of messagepack buffers
- **Resource Cleanup**: Ensures all allocated memory is properly freed

## Usage

This module is used internally by Fluent Bit's OpenTelemetry input plugins. External usage typically involves:

```c
// Convert OTLP JSON traces to CTraces format
int error_status = 0;
struct ctrace *ctr = flb_opentelemetry_json_traces_to_ctrace(
    json_data,
    json_length,
    &error_status
);

if (ctr != NULL) {
    // Successfully converted, use ctr for trace processing
    // Don't forget to call ctr_destroy(ctr) when done
}
```

The function is particularly important for the OpenTelemetry receiver plugin, which uses it to process incoming OTLP traces and convert them to Fluent Bit's internal format for further processing and export.