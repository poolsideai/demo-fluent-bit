# http_server/api/v1/plugins.c

## Overview

The `http_server/api/v1/plugins.c` file implements the plugins endpoint for Fluent Bit's HTTP server API. This endpoint provides information about the currently loaded plugins in the Fluent Bit instance, categorized by type (inputs, filters, and outputs).

The implementation uses MessagePack to efficiently serialize plugin information and convert it to JSON format for HTTP response.

## Key Functions

### Plugins Endpoint Handler

```c
static void cb_plugins(mk_request_t *request, void *data)
```

Handles requests to the plugins endpoint:
- Enumerates all loaded input, filter, and output plugins
- Serializes plugin information using MessagePack
- Converts MessagePack to JSON format for HTTP response
- Returns formatted plugin information with HTTP 200 status

### Plugins Endpoint Registration

```c
int api_v1_plugins(struct flb_hs *hs)
```

Registers the plugins endpoint with the HTTP server:
- Associates the endpoint path `/api/v1/plugins` with the handler function
- Links the handler with the HTTP server context

## Implementation Details

### Plugin Enumeration

The implementation enumerates plugins by iterating through the plugin lists maintained by Fluent Bit:

1. **Input Plugins**: Retrieved from `config->in_plugins` list
2. **Filter Plugins**: Retrieved from `config->filter_plugins` list
3. **Output Plugins**: Retrieved from `config->out_plugins` list

Each plugin type is processed to extract the plugin name and serialize it into the response.

### Data Serialization

The plugin information is serialized using MessagePack with the following structure:

```json
{
  "plugins": {
    "inputs": ["plugin1", "plugin2", ...],
    "filters": ["plugin1", "plugin2", ...],
    "outputs": ["plugin1", "plugin2", ...]
  }
}
```

### Memory Management

Memory management is handled through:
- MessagePack sbuffer for efficient serialization
- Automatic cleanup of MessagePack buffers
- Proper destruction of SDS strings after HTTP response

## Dependencies

This file depends on:

1. **Fluent Bit Core**: Provides core data structures and plugin management
2. **Monkey HTTP Server**: Provides HTTP server functionality
3. **MessagePack**: For efficient data serialization
4. **String Data Structures**: For handling serialized data (`flb_sds_t`)

## Usage Examples

### Retrieving Plugin Information

```bash
# Get information about loaded plugins
curl http://localhost:2020/api/v1/plugins
```

Response:
```json
{
  "plugins": {
    "inputs": ["cpu", "mem", "disk"],
    "filters": ["grep", "parser", "record_modifier"],
    "outputs": ["stdout", "http", "forward"]
  }
}
```

### Configuration Example

```ini
[SERVICE]
    HTTP_Server On
    HTTP_Listen 0.0.0.0
    HTTP_Port 2020
```

With this configuration, the plugins endpoint is available at `/api/v1/plugins`.

## Integration with Fluent Bit

The plugins endpoint integrates with Fluent Bit as follows:

1. **Registration**: Registered during HTTP server initialization via `api_v1_plugins()`
2. **Plugin Access**: Uses Fluent Bit's internal plugin lists for enumeration
3. **Endpoint Exposure**: Exposed at the standard REST API path `/api/v1/plugins`
4. **Data Format**: Returns information in JSON format for easy consumption
5. **Resource Management**: Properly manages memory during request processing