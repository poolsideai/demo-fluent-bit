# flb_opentelemetry_logs.c

## Overview

This file implements the OpenTelemetry logs processing functionality for Fluent Bit. It provides the core logic for converting OpenTelemetry Protocol (OTLP) JSON logs into Fluent Bit's internal log event format. The implementation handles the complex nested structure of OTLP logs, including resource logs, scope logs, and individual log records, while preserving all metadata and attributes.

## Key Functions

### `flb_opentelemetry_logs_json_to_msgpack`

Converts OTLP JSON logs to Fluent Bit's internal msgpack format.

**Parameters:**
- `encoder`: Log event encoder for output
- `body`: Raw JSON log data
- `len`: Length of the JSON data
- `logs_body_key`: Custom key for log body content
- `error_status`: Output parameter for detailed error codes

**Returns:**
- 0 on success
- Negative value on failure

### `process_json_payload_root`

Processes the root OTLP JSON payload structure.

### `process_json_payload_resource_logs_entry`

Processes individual resource logs entries.

### `process_json_payload_scope_logs_entry`

Processes scope logs entries within resource logs.

### `process_json_payload_log_records_entry`

Processes individual log record entries.

## Important Variables/Constants

- `FLB_OTEL_LOGS_METADATA_KEY`: Metadata key for OTLP logs
- Error codes: Various error constants for different failure conditions

## Dependencies

- `flb_info.h`: Fluent Bit core information
- `flb_sds.h`: Simple Dynamic Strings
- `flb_pack.h`: Data packing utilities
- `flb_log_event_encoder.h`: Log event encoding
- `flb_time.h`: Time utilities
- `flb_opentelemetry.h`: OpenTelemetry core functionality
- `fluent-otel-proto/fluent-otel.h`: OpenTelemetry protocol definitions

## Implementation Details

### OTLP Structure Processing

The implementation follows the OpenTelemetry Protocol specification for logs:

1. **Root Level**: Processes the top-level `resourceLogs` array
2. **Resource Logs**: Handles resource-level metadata and attributes
3. **Scope Logs**: Processes instrumentation scope information
4. **Log Records**: Converts individual log entries with full metadata

### Data Transformation

Key transformations performed:

- **Timestamp Handling**: Supports both `timeUnixNano` and `observedTimeUnixNano` fields
- **Severity Mapping**: Preserves both numeric (`severityNumber`) and text (`severityText`) severity levels
- **Trace/Span IDs**: Validates and converts hexadecimal trace and span identifiers
- **Attribute Conversion**: Transforms OTLP key-value lists to Fluent Bit format
- **Schema Preservation**: Maintains resource and scope schema URLs

### Validation and Error Handling

The implementation includes comprehensive validation:

- **Type Checking**: Ensures all fields match expected types per OTLP specification
- **Format Validation**: Validates hexadecimal trace/span IDs and timestamp formats
- **Structure Validation**: Verifies required fields and nested structures
- **Detailed Error Codes**: Provides specific error codes for different failure scenarios

### Memory Management

Efficient memory handling through:

- **Temporary Encoders**: Uses local encoders for intermediate processing
- **Buffer Management**: Proper allocation and cleanup of messagepack buffers
- **Resource Cleanup**: Ensures all allocated memory is properly freed

## Usage

This module is used internally by Fluent Bit's OpenTelemetry input plugins. External usage typically involves:

```c
// Convert OTLP JSON to Fluent Bit format
struct flb_log_event_encoder *encoder = flb_log_event_encoder_create(FLB_LOG_EVENT_FORMAT_FLUENT_BIT_V2);
int error_status = 0;

int result = flb_opentelemetry_logs_json_to_msgpack(
    encoder,
    json_data,
    json_length,
    "log",  // Custom body key
    &error_status
);

if (result == 0) {
    // Successfully converted, use encoder->output_buffer for the result
}
```

The function is particularly important for the OpenTelemetry receiver plugin, which uses it to process incoming OTLP logs and convert them to Fluent Bit's internal format for further processing.