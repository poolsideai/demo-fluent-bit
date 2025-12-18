# Trace API Implementation (v1)

## Overview

This file implements the HTTP API endpoints for enabling and disabling tracing functionality in Fluent Bit. Tracing allows users to capture detailed information about data processing within specific input plugins, which is useful for debugging and performance analysis.

The implementation provides two main endpoints:
- `/api/v1/trace/{input_name}` - For managing tracing on individual inputs
- `/api/v1/traces/` - For bulk operations on multiple inputs

## Key Functions

### `api_v1_trace(struct flb_hs *hs)`

Main registration function that registers the trace API endpoints with the HTTP server.

### `cb_trace(mk_request_t *request, void *data)`

HTTP callback handler for individual trace requests. Handles GET, POST, and DELETE methods:
- GET: Enables tracing with default settings
- POST: Enables tracing with custom parameters
- DELETE: Disables tracing

### `cb_traces(mk_request_t *request, void *data)`

HTTP callback handler for bulk trace operations. Processes JSON payloads to enable/disable tracing on multiple inputs simultaneously.

### `enable_trace_input()`

Enables tracing on a specific input plugin with configurable parameters.

### `disable_trace_input()`

Disables tracing on a specific input plugin.

## Important Variables and Constants

- `HTTP_FIELD_*` constants: Define standard HTTP response field names
- `HTTP_RESULT_*` constants: Define standard HTTP response status messages
- `STR_INPUTS`: Constant string for "inputs" field in JSON responses

## Dependencies and Relationships

- Uses `flb_chunk_trace_*` functions for actual tracing implementation
- Integrates with HTTP server framework through `mk_vhost_handler`
- Depends on input plugin infrastructure for finding and managing inputs
- Uses MessagePack for serialization/deserialization of request/response data

## Notable Implementation Details

1. **Input Resolution**: The `find_input()` function searches for input instances by name or alias
2. **Parameter Parsing**: Complex JSON parameter parsing for custom tracing configurations
3. **Error Handling**: Comprehensive error handling with appropriate HTTP status codes
4. **Memory Management**: Proper allocation and deallocation of SDS strings and lists
5. **Bulk Operations**: Support for enabling/disabling tracing on multiple inputs in a single request

## Usage Examples

### Enable tracing on a specific input:
```bash
# Simple enable
GET /api/v1/trace/cpu

# Enable with custom parameters
POST /api/v1/trace/cpu
Content-Type: application/json
{
  "prefix": "trace.",
  "output": "stdout",
  "params": {
    "format": "json"
  },
  "limit": {
    "seconds": 30
  }
}
```

### Disable tracing:
```bash
DELETE /api/v1/trace/cpu
```

### Bulk operations:
```bash
POST /api/v1/traces/
Content-Type: application/json
{
  "inputs": ["cpu", "mem"]
}
```