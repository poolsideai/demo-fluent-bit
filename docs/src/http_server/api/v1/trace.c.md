# src/http_server/api/v1/trace.c Documentation

## Overview

The `src/http_server/api/v1/trace.c` file implements the Fluent Bit HTTP server API v1 trace endpoints. This module provides functionality for enabling and disabling tracing of input plugins, which is essential for debugging and monitoring data flow through the Fluent Bit pipeline.

Tracing allows administrators to capture detailed information about how data flows through input plugins, including timing information, record counts, and error conditions. This is particularly useful for diagnosing performance issues and understanding data processing behavior.

## Key Features

- Input plugin tracing functionality
- REST API endpoints for trace management
- Support for enabling/disabling traces
- Configurable trace parameters
- Integration with Fluent Bit's chunk tracing system
- Thread-safe operation

## Constants

### HTTP Field Definitions

```c
#define HTTP_FIELD_MESSAGE        "message"
#define HTTP_FIELD_STATUS         "status"
#define HTTP_FIELD_RETURNCODE     "returncode"
```

### HTTP Result Codes

```c
#define HTTP_RESULT_OK                   "ok"
#define HTTP_RESULT_ERROR                "error"
#define HTTP_RESULT_NOTFOUND             "not found"
#define HTTP_RESULT_METHODNOTALLOWED     "method not allowed"
#define HTTP_RESULT_UNKNOWNERROR         "unknown error"
```

## Key Functions

### api_v1_trace()

```c
int api_v1_trace(struct flb_hs *hs);
```

Initializes and registers the trace endpoints.

**Parameters:**
- `hs`: HTTP server context

**Returns:**
- `0` on success
- Error code on failure

### cb_trace()

HTTP callback function for individual trace endpoints (`/api/v1/trace/*`).

**Parameters:**
- `request`: HTTP request object
- `data`: HTTP server context

### cb_traces()

HTTP callback function for batch trace operations (`/api/v1/traces/`).

**Parameters:**
- `request`: HTTP request object
- `data`: HTTP server context

### enable_trace_input()

Enables tracing for a specific input plugin.

**Parameters:**
- `hs`: HTTP server context
- `name`: Input plugin name
- `nlen`: Length of input plugin name
- `prefix`: Trace prefix
- `output_name`: Output destination for trace data
- `props`: Additional properties

### disable_trace_input()

Disables tracing for a specific input plugin.

**Parameters:**
- `hs`: HTTP server context
- `name`: Input plugin name
- `nlen`: Length of input plugin name

## Implementation Details

### Chunk Tracing Integration

The implementation integrates with Fluent Bit's chunk tracing system:

```c
struct flb_input_instance *in;
flb_chunk_trace_context_new(in, output_name, prefix, NULL, props);
```

This allows capturing detailed information about data chunks as they flow through the pipeline.

### REST API Endpoints

The module exposes two REST endpoints:

1. **Individual Trace**: `/api/v1/trace/{input_name}`
   - `GET` - Enable tracing with default settings
   - `POST` - Enable tracing with custom parameters
   - `DELETE` - Disable tracing

2. **Batch Trace**: `/api/v1/traces/`
   - `POST` - Enable tracing for multiple inputs
   - `DELETE` - Disable tracing for multiple inputs

### JSON Response Format

The endpoints return status information in JSON format:

```json
{
  "status": "ok"
}
```

Or error responses:

```json
{
  "status": "error",
  "message": "unable to find input: [cpu]"
}
```

### Built-in Parameters

The module supports several configurable parameters:

1. **prefix**: String prefix for trace output
2. **output**: Destination for trace data (default: stdout)
3. **params**: Additional output parameters
4. **limit**: Time or count limits for tracing

## Usage Examples

### Initializing Trace Endpoints

```c
// Initialize trace endpoints
int init_trace_endpoints(struct flb_hs *hs) {
    return api_v1_trace(hs);
}
```

### Enabling Tracing via HTTP

```bash
# Enable tracing for a single input
curl -X GET http://localhost:2020/api/v1/trace/cpu

# Enable tracing with custom parameters
curl -X POST http://localhost:2020/api/v1/trace/cpu \
  -H "Content-Type: application/json" \
  -d '{"prefix": "debug.", "output": "file", "params": {"path": "/tmp/trace.log"}}'

# Disable tracing
curl -X DELETE http://localhost:2020/api/v1/trace/cpu

# Enable tracing for multiple inputs
curl -X POST http://localhost:2020/api/v1/traces/ \
  -H "Content-Type: application/json" \
  -d '{"inputs": ["cpu", "disk", "mem"]}'
```

### Processing Trace Data

```c
// Find input plugin by name
struct flb_input_instance *find_input_by_name(struct flb_hs *hs, const char *name) {
    struct mk_list *head;
    struct flb_input_instance *in;
    
    mk_list_foreach(head, &hs->config->inputs) {
        in = mk_list_entry(head, struct flb_input_instance, _head);
        if (strcmp(in->name, name) == 0) {
            return in;
        }
    }
    return NULL;
}

// Enable tracing programmatically
int enable_tracing_for_input(struct flb_hs *hs, const char *input_name) {
    return enable_trace_input(hs, input_name, strlen(input_name), 
                              "trace.", "stdout", NULL);
}
```

## Integration with Fluent Bit

The trace module integrates with other Fluent Bit components:

1. **HTTP Server**: Part of the v1 API endpoint system
2. **Input Plugins**: Works with all input plugin types
3. **Chunk Tracing**: Uses Fluent Bit's chunk tracing infrastructure
4. **Configuration**: Respects service configuration parameters
5. **Logging**: Integrates with Fluent Bit's logging system
6. **MessagePack**: Uses Fluent Bit's serialization library

## Error Handling

The implementation includes robust error handling:

- **Plugin Not Found**: Returns 404 for non-existent inputs
- **Invalid Parameters**: Returns 503 for malformed requests
- **Resource Limits**: Proper handling of memory constraints
- **Thread Safety**: Safe concurrent access patterns
- **HTTP Status Codes**: Appropriate status codes for different scenarios

## Performance Considerations

The implementation is optimized for:

- **Minimal Overhead**: Lightweight data structures
- **Cache Efficiency**: Efficient plugin lookup
- **Memory Efficiency**: Proper sizing and cleanup
- **Fast Access**: Direct access to plugin registry

## Security Considerations

The implementation follows security best practices:

- **Input Validation**: Strict validation of request parameters
- **Plugin Access Control**: Only allows tracing of registered inputs
- **Memory Safety**: Safe allocation/deallocation patterns
- **Access Control**: Respects HTTP server security model
- **Input Sanitization**: Proper handling of JSON data

## Extensibility

The module design supports future enhancements:

- **Additional Parameters**: Easy addition of new trace options
- **Enhanced Features**: Advanced filtering and aggregation
- **Configuration Options**: Extensible configuration parameters
- **Monitoring Integration**: Ready for enhanced observability

## Version Compatibility

The trace module maintains compatibility with:

- **Fluent Bit 1.x**: Full backward compatibility
- **Fluent Bit 2.x**: Full forward compatibility
- **Future Versions**: Designed for extensibility
- **API Evolution**: Compatible with new endpoint versions

## Best Practices

When using this module, follow these best practices:

1. **Memory Management**: Follow Fluent Bit's allocation patterns
2. **Error Handling**: Check return values from all functions
3. **Resource Cleanup**: Always call cleanup functions on shutdown
4. **Performance**: Monitor memory usage and buffer sizes
5. **Security**: Validate all input data

## Configuration

The trace module requires enabling in the service configuration:

```ini
[SERVICE]
    http_server  On
    http_listen  0.0.0.0
    http_port    2020
    enable_chunk_trace On
```

Once enabled, the trace endpoints will be available at:
- `/api/v1/trace/{input_name}` (individual trace)
- `/api/v1/traces/` (batch trace)