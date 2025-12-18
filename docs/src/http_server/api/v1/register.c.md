# src/http_server/api/v1/register.c Documentation

## Overview

The `src/http_server/api/v1/register.c` file implements the Fluent Bit HTTP server API v1 registration system. This module serves as the central coordinator for registering all v1 API endpoints, ensuring they are properly initialized and made available through the HTTP server.

The registration system is responsible for orchestrating the initialization of various API endpoints based on configuration settings, making it a critical component for the overall functionality of the Fluent Bit HTTP server.

## Key Features

- Centralized API endpoint registration
- Conditional endpoint initialization
- Configuration-driven endpoint activation
- Integration with all v1 API modules
- Thread-safe operation

## Key Functions

### api_v1_registration()

```c
int api_v1_registration(struct flb_hs *hs);
```

Coordinates the registration of all v1 API endpoints.

**Parameters:**
- `hs`: HTTP server context

**Returns:**
- `0` on success
- Error code on failure

## Implementation Details

### Endpoint Registration Flow

The registration function orchestrates the initialization of all v1 API endpoints in a specific order:

1. **Uptime Endpoint**: Always registered for basic service information
2. **Metrics Endpoint**: Always registered for performance monitoring
3. **Plugins Endpoint**: Always registered for plugin discovery
4. **Trace Endpoint**: Conditionally registered based on chunk tracing support
5. **Health Endpoint**: Conditionally registered based on health check configuration
6. **Storage Metrics Endpoint**: Conditionally registered based on storage metrics configuration

### Conditional Registration

Some endpoints are only registered when specific conditions are met:

```c
#ifdef FLB_HAVE_CHUNK_TRACE
    api_v1_trace(hs);
#endif /* FLB_HAVE_CHUNK_TRACE */

if (hs->config->health_check == FLB_TRUE) {
    api_v1_health(hs);
}

if (hs->config->storage_metrics == FLB_TRUE) {
    api_v1_storage_metrics(hs);
}
```

This approach ensures that only relevant endpoints are initialized, reducing memory footprint and improving performance.

### Integration Points

The registration system integrates with all v1 API modules:

- **Uptime**: `api_v1_uptime()`
- **Metrics**: `api_v1_metrics()`
- **Plugins**: `api_v1_plugins()`
- **Trace**: `api_v1_trace()` (conditional)
- **Health**: `api_v1_health()` (conditional)
- **Storage**: `api_v1_storage_metrics()` (conditional)

## Usage Examples

### Initializing All V1 Endpoints

```c
// Register all v1 API endpoints
int init_v1_api_endpoints(struct flb_hs *hs) {
    return api_v1_registration(hs);
}
```

### Conditional Endpoint Registration

```c
// Check configuration and register endpoints accordingly
void register_endpoints_conditionally(struct flb_hs *hs) {
    // Always register these endpoints
    api_v1_uptime(hs);
    api_v1_metrics(hs);
    api_v1_plugins(hs);
    
    // Conditionally register others
#ifdef FLB_HAVE_CHUNK_TRACE
    api_v1_trace(hs);
#endif
    
    if (hs->config->health_check == FLB_TRUE) {
        api_v1_health(hs);
    }
    
    if (hs->config->storage_metrics == FLB_TRUE) {
        api_v1_storage_metrics(hs);
    }
}
```

## Integration with Fluent Bit

The registration module integrates with other Fluent Bit components:

1. **HTTP Server**: Coordinates endpoint registration with the main HTTP server
2. **Configuration**: Respects service configuration parameters
3. **Logging**: Integrates with Fluent Bit's logging system
4. **All V1 Modules**: Connects to every v1 API module
5. **Build System**: Uses compile-time flags for conditional compilation

## Error Handling

The implementation includes robust error handling:

- **Individual Endpoint Errors**: Failures in one endpoint don't affect others
- **Resource Cleanup**: Proper cleanup of partially initialized components
- **Thread Safety**: Safe concurrent access patterns
- **HTTP Status Codes**: Appropriate status codes for different scenarios

## Performance Considerations

The implementation is optimized for:

- **Minimal Overhead**: Lightweight coordination logic
- **Cache Efficiency**: Efficient endpoint initialization
- **Memory Efficiency**: Only initializes required endpoints
- **Fast Startup**: Quick registration of all endpoints

## Security Considerations

The implementation follows security best practices:

- **Input Validation**: Strict validation of configuration parameters
- **Access Control**: Respects HTTP server security model
- **Memory Safety**: Safe allocation/deallocation patterns
- **Minimal Exposure**: Only necessary functions are public

## Extensibility

The module design supports future enhancements:

- **Additional Endpoints**: Easy addition of new API modules
- **Enhanced Features**: Advanced registration capabilities
- **Configuration Options**: Extensible configuration parameters
- **Monitoring Integration**: Ready for enhanced observability

## Version Compatibility

The registration module maintains compatibility with:

- **Fluent Bit 1.x**: Full backward compatibility
- **Fluent Bit 2.x**: Full forward compatibility
- **Future Versions**: Designed for extensibility
- **API Evolution**: Compatible with new endpoint versions

## Best Practices

When using this module, follow these best practices:

1. **Memory Management**: Follow Fluent Bit's allocation patterns
2. **Error Handling**: Check return values from all functions
3. **Resource Cleanup**: Always call cleanup functions on shutdown
4. **Performance**: Monitor memory usage and initialization time
5. **Security**: Validate all configuration data

## Configuration

The registration system respects various service configuration options:

```ini
[SERVICE]
    http_server  On
    http_listen  0.0.0.0
    http_port    2020
    health_check On
    storage_metrics On
```

Based on these settings, different endpoints will be registered:
- **Always Registered**: uptime, metrics, plugins
- **Conditionally Registered**: trace (build-dependent), health (config-dependent), storage (config-dependent)