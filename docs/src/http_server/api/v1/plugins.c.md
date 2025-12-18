# src/http_server/api/v1/plugins.c Documentation

## Overview

The `src/http_server/api/v1/plugins.c` file implements the Fluent Bit HTTP server API v1 plugins endpoint. This module provides functionality for listing all built-in plugins (inputs, filters, and outputs) available in the Fluent Bit service.

Plugin discovery is essential for users and administrators who need to understand what functionality is available in their Fluent Bit installation.

## Key Features

- Plugin listing functionality
- JSON format response
- Support for all plugin types (input, filter, output)
- Integration with Fluent Bit's HTTP server
- MessagePack to JSON conversion
- Thread-safe operation

## Key Functions

### api_v1_plugins()

```c
int api_v1_plugins(struct flb_hs *hs);
```

Initializes and registers the plugins endpoint.

**Parameters:**
- `hs`: HTTP server context

**Returns:**
- `0` on success
- Error code on failure

### cb_plugins()

HTTP callback function for `/api/v1/plugins` endpoint.

**Parameters:**
- `request`: HTTP request object
- `data`: HTTP server context

## Implementation Details

### Data Structure

The implementation works with Fluent Bit's plugin registry structures:

- `struct flb_input_plugin`: Input plugin definitions
- `struct flb_filter_plugin`: Filter plugin definitions
- `struct flb_output_plugin`: Output plugin definitions

### MessagePack Integration

The endpoint uses MessagePack for internal data representation:

```c
msgpack_sbuffer mp_sbuf;
msgpack_packer mp_pck;
```

This allows efficient serialization of plugin data before converting to JSON for the HTTP response.

### JSON Response Format

The endpoint returns plugin information in JSON format:

```json
{
  "plugins": {
    "inputs": ["cpu", "disk", "mem", ...],
    "filters": ["grep", "kubernetes", "parser", ...],
    "outputs": ["es", "forward", "http", ...]
  }
}
```

### Thread Safety

The implementation accesses plugin registries that are initialized during startup and remain static, ensuring thread safety for concurrent HTTP requests.

## Usage Examples

### Initializing Plugins Endpoint

```c
// Initialize plugins endpoint
int init_plugins_endpoint(struct flb_hs *hs) {
    return api_v1_plugins(hs);
}
```

### Accessing Plugins via HTTP

```bash
# Get list of available plugins
curl http://localhost:2020/api/v1/plugins
```

### Processing Plugin Data

```c
// Access plugin information programmatically
void list_available_plugins(struct flb_config *config) {
    struct mk_list *head;
    struct flb_input_plugin *in;
    
    // List input plugins
    mk_list_foreach(head, &config->in_plugins) {
        in = mk_list_entry(head, struct flb_input_plugin, _head);
        printf("Input plugin: %s\n", in->name);
    }
}
```

## Integration with Fluent Bit

The plugins module integrates with other Fluent Bit components:

1. **HTTP Server**: Part of the v1 API endpoint system
2. **Plugin Registry**: Accesses built-in plugin definitions
3. **Configuration**: Uses service configuration parameters
4. **Logging**: Integrates with Fluent Bit's logging system
5. **MessagePack**: Uses Fluent Bit's serialization library

## Error Handling

The implementation includes robust error handling:

- **Null Pointer Checks**: Functions handle NULL parameters gracefully
- **Memory Allocation**: Proper error checking for allocations
- **Resource Cleanup**: Cleanup functions ensure no resource leaks
- **HTTP Status Codes**: Proper HTTP status codes for different scenarios

## Performance Considerations

The implementation is optimized for:

- **Minimal Overhead**: Lightweight data structures
- **Cache Efficiency**: Uses existing plugin registry data
- **Memory Efficiency**: Proper sizing of buffers
- **Fast Access**: Direct access to plugin registry

## Security Considerations

The implementation follows security best practices:

- **Read-only Access**: Only exposes plugin names, no sensitive data
- **Data Validation**: Proper input validation
- **Memory Safety**: Safe allocation/deallocation patterns
- **Access Control**: Respects HTTP server security model

## Extensibility

The module design supports future enhancements:

- **Additional Metadata**: Easy addition of plugin metadata
- **Filtering Options**: Support for plugin category filtering
- **Enhanced Features**: Advanced plugin discovery features
- **Configuration Options**: Extensible configuration parameters

## Version Compatibility

The plugins module maintains compatibility with:

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

The plugins module can be configured through the HTTP server configuration:

```ini
[SERVICE]
    http_server  On
    http_listen  0.0.0.0
    http_port    2020
```

Once enabled, the plugins endpoint will be available at:
- `/api/v1/plugins` (JSON format)