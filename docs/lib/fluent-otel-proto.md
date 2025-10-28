# Fluent OTel Proto

## Overview

Fluent OTel Proto is a library that builds a static library providing C interfaces for OpenTelemetry proto files data model and includes helper utilities. The project exposes build options for different OpenTelemetry components and can regenerate C interfaces from .proto files.

## Key Methods/Functions

### Library Information
- `fluent_otel_info()` - Provides information about the library and available features

## Supported OpenTelemetry Components

The library supports the following OpenTelemetry proto components:

### Common (Enabled by default)
- Provides common data structures used across OpenTelemetry
- Includes AnyValue, ArrayValue, KeyValueList, etc.

### Resource (Enabled by default)
- Defines resources in OpenTelemetry
- Includes Resource, InstrumentationLibrary, etc.

### Trace (Enabled by default)
- Provides trace data model
- Includes Span, SpanEvent, SpanLink, etc.

### Logs (Enabled by default)
- Provides logs data model
- Includes LogRecord, etc.

### Metrics (Disabled by default)
- Provides metrics data model
- Can be enabled with `-DFLUENT_PROTO_METRICS`

## Usage Notes

1. The library provides C interfaces generated from OpenTelemetry proto files
2. Different components can be enabled/disabled during build time
3. The library can regenerate C files from .proto files using specific build options
4. Dependencies required for regeneration:
   - fluent/protobuf-c (fork with proto3 options support)
   - open-telemetry/opentelemetry-proto

## Build Options

| Variable Name | Description | Default |
|---------------|-------------|---------|
| FLUENT_PROTO_REGENERATE | Enable C source file regeneration | OFF |
| PROTOBUF_C_SOURCE_DIR | Path to protobuf-c source directory | - |
| OTEL_PROTO_DIR | Path to opentelemetry-proto source directory | - |
| FLUENT_PROTO_COMMON | Enable common.proto interface | ON |
| FLUENT_PROTO_RESOURCE | Enable resource.proto interface | ON |
| FLUENT_PROTO_TRACE | Enable trace.proto interfaces | ON |
| FLUENT_PROTO_LOGS | Enable logs.proto interfaces | ON |
| FLUENT_PROTO_METRICS | Enable metrics.proto interfaces | OFF |

## Regeneration Process

To regenerate C files from .proto files:

1. Download dependencies:
   - protobuf-c (fluent fork)
   - opentelemetry-proto

2. Set build variables:
   ```bash
   cmake -DFLUENT_PROTO_REGENERATE=ON \
         -DPROTOBUF_C_SOURCE_DIR=/path/to/protobuf-c \
         -DOTEL_PROTO_DIR=/path/to/opentelemetry-proto \
         ../
   ```

3. Build with `make`

## Example Usage

```c
#include <fluent-otel-proto/fluent-otel.h>

int main() {
    // Check what components are available
    fluent_otel_info();
    
    // Example using trace components (if enabled)
#ifdef FLUENT_OTEL_HAVE_TRACE
    // Create a new trace span
    Opentelemetry__Proto__Trace__V1__Span *span = 
        opentelemetry__proto__trace__v1__span__init_zero;
    
    // Set span name
    span->name = "example-span";
    
    // Set span kind
    span->kind = OPENTELEMETRY__PROTO__TRACE__V1__SPAN__SPAN_KIND__SPAN_KIND_INTERNAL;
    
    // Use the span...
    
    // Free the span
    opentelemetry__proto__trace__v1__span__free_unpacked(span, NULL);
#endif
    
    return 0;
}
```