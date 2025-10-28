# CTraces

## Overview

CTraces is a tiny library to create and maintain Traces contexts and provide utilities for data manipulation, including encoding/decoding for compatibility with OpenTelemetry and other formats. This project is a core library for Fluent Bit: agent and aggregator for Observability.

## Key Methods/Functions

### Context Management
- `ctr_create(struct ctrace_opts *opts)` - Creates a new CTrace context
- `ctr_destroy(struct ctrace *ctx)` - Destroys a CTrace context and frees all associated resources
- `ctr_opts_init(struct ctrace_opts *opts)` - Initializes a CTrace options structure
- `ctr_opts_exit(struct ctrace_opts *opts)` - Cleans up a CTrace options structure

### Resource Management
- `ctr_resource_span_create(struct ctrace *ctx)` - Creates a new resource span
- `ctr_resource_span_get_resource(struct ctrace_resource_span *resource_span)` - Gets the resource associated with a resource span
- `ctr_resource_set_dropped_attr_count(struct ctrace_resource *resource, uint32_t count)` - Sets the dropped attribute count for a resource

### Scope Management
- `ctr_scope_span_create(struct ctrace_resource_span *resource_span)` - Creates a new scope span
- `ctr_scope_span_set_schema_url(struct ctrace_scope_span *scope_span, char *url)` - Sets the schema URL for a scope span
- `ctr_scope_span_set_instrumentation_scope(struct ctrace_scope_span *scope_span, struct ctrace_instrumentation_scope *instrumentation_scope)` - Sets the instrumentation scope for a scope span
- `ctr_instrumentation_scope_create(char *name, char *version, int32_t dropped_attr_count, char *schema_url)` - Creates a new instrumentation scope

### Span Management
- `ctr_span_create(struct ctrace *ctx, struct ctrace_scope_span *scope_span, char *name, struct ctrace_span *parent)` - Creates a new span
- `ctr_span_set_span_id_with_cid(struct ctrace_span *span, struct ctrace_id *cid)` - Sets the span ID using a CTrace ID
- `ctr_span_set_trace_id_with_cid(struct ctrace_span *span, struct ctrace_id *cid)` - Sets the trace ID using a CTrace ID
- `ctr_span_set_parent_span_id_with_cid(struct ctrace_span *span, struct ctrace_id *cid)` - Sets the parent span ID using a CTrace ID
- `ctr_span_kind_set(struct ctrace_span *span, int kind)` - Sets the kind of the span

### Attribute Management
- `ctr_span_set_attribute_string(struct ctrace_span *span, char *key, char *value)` - Sets a string attribute on a span
- `ctr_span_set_attribute_int64(struct ctrace_span *span, char *key, int64_t value)` - Sets an int64 attribute on a span
- `ctr_span_set_attribute_bool(struct ctrace_span *span, char *key, int value)` - Sets a boolean attribute on a span
- `ctr_span_set_attribute_double(struct ctrace_span *span, char *key, double value)` - Sets a double attribute on a span
- `ctr_span_set_attribute_array(struct ctrace_span *span, char *key, struct cfl_array *value)` - Sets an array attribute on a span
- `ctr_span_set_attribute_kvlist(struct ctrace_span *span, char *key, struct cfl_kvlist *value)` - Sets a key-value list attribute on a span

### Event Management
- `ctr_span_event_add(struct ctrace_span *span, char *name)` - Adds a new event to a span
- `ctr_span_event_set_attribute_string(struct ctrace_span_event *event, char *key, char *value)` - Sets a string attribute on an event

### Link Management
- `ctr_link_create_with_cid(struct ctrace_span *span, struct ctrace_id *trace_id, struct ctrace_id *span_id)` - Creates a new link with trace and span IDs
- `ctr_link_set_trace_state(struct ctrace_link *link, char *state)` - Sets the trace state for a link
- `ctr_link_set_dropped_attr_count(struct ctrace_link *link, uint32_t count)` - Sets the dropped attribute count for a link

### ID Management
- `ctr_id_create_random(size_t size)` - Creates a new random ID of specified size
- `ctr_id_destroy(struct ctrace_id *id)` - Destroys an ID and frees its memory

### Encoding/Decoding
- `ctr_encode_text_create(struct ctrace *ctx)` - Encodes a trace context as a readable text string
- `ctr_encode_text_destroy(char *text)` - Destroys encoded text and frees memory
- `ctr_encode_msgpack_create(struct ctrace *ctx)` - Encodes a trace context as MessagePack
- `ctr_encode_opentelemetry_create(struct ctrace *ctx)` - Encodes a trace context as OpenTelemetry format
- `ctr_decode_opentelemetry_create(struct ctrace *ctx, void *data, size_t size)` - Decodes OpenTelemetry data into a trace context

## Usage Notes

1. CTraces provides a comprehensive API for creating and managing distributed traces in C applications.
2. The library supports OpenTelemetry compatibility for encoding and decoding trace data.
3. Memory management is handled through explicit creation and destruction functions.
4. The library uses CFL (C Fluent Library) for data structures like arrays and key-value lists.
5. Error handling is done through return values (NULL for failure in most cases).

## Example Usage

```c
#include <ctraces/ctraces.h>

int main() {
    struct ctrace *ctx;
    struct ctrace_opts opts;
    struct ctrace_span *span_root;
    struct ctrace_resource_span *resource_span;
    struct ctrace_scope_span *scope_span;
    struct ctrace_id *trace_id;
    struct ctrace_id *span_id;
    
    // Initialize options
    ctr_opts_init(&opts);
    
    // Create trace context
    ctx = ctr_create(&opts);
    if (!ctx) {
        ctr_opts_exit(&opts);
        exit(EXIT_FAILURE);
    }
    
    // Create resource span
    resource_span = ctr_resource_span_create(ctx);
    
    // Create scope span
    scope_span = ctr_scope_span_create(resource_span);
    
    // Generate random IDs
    trace_id = ctr_id_create_random(CTR_ID_OTEL_TRACE_SIZE);
    span_id = ctr_id_create_random(CTR_ID_OTEL_SPAN_SIZE);
    
    // Create root span
    span_root = ctr_span_create(ctx, scope_span, "main", NULL);
    if (!span_root) {
        ctr_destroy(ctx);
        ctr_opts_exit(&opts);
        exit(EXIT_FAILURE);
    }
    
    // Set IDs
    ctr_span_set_span_id_with_cid(span_root, span_id);
    ctr_span_set_trace_id_with_cid(span_root, trace_id);
    
    // Add attributes
    ctr_span_set_attribute_string(span_root, "agent", "Fluent Bit");
    ctr_span_set_attribute_int64(span_root, "year", 2022);
    
    // Encode as text
    char *text = ctr_encode_text_create(ctx);
    printf("%s\n", text);
    ctr_encode_text_destroy(text);
    
    // Cleanup
    ctr_id_destroy(span_id);
    ctr_id_destroy(trace_id);
    ctr_destroy(ctx);
    ctr_opts_exit(&opts);
    
    return 0;
}
```