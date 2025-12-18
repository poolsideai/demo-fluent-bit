# src/http_server/api/v1/uptime.c Documentation

## Overview

The `src/http_server/api/v1/uptime.c` file implements the Fluent Bit HTTP server API v1 uptime endpoint. This module provides functionality for exposing the uptime information of the Fluent Bit service in both seconds and human-readable formats.

Uptime information is essential for monitoring and observability of the Fluent Bit service, allowing administrators to understand how long the service has been running.

## Key Features

- Uptime reporting functionality
- Seconds and human-readable format support
- JSON format response
- Integration with Fluent Bit's HTTP server
- MessagePack to JSON conversion
- Thread-safe operation

## Constants

### FLB_UPTIME_ONEDAY

```c
#define FLB_UPTIME_ONEDAY  86400
```

Number of seconds in one day.

### FLB_UPTIME_ONEHOUR

```c
#define FLB_UPTIME_ONEHOUR  3600
```

Number of seconds in one hour.

### FLB_UPTIME_ONEMINUTE

```c
#define FLB_UPTIME_ONEMINUTE  60
```

Number of seconds in one minute.

## Key Functions

### api_v1_uptime()

```c
int api_v1_uptime(struct flb_hs *hs);
```

Initializes and registers the uptime endpoint.

**Parameters:**
- `hs`: HTTP server context

**Returns:**
- `0` on success
- Error code on failure

### cb_uptime()

HTTP callback function for `/api/v1/uptime` endpoint.

**Parameters:**
- `request`: HTTP request object
- `data`: HTTP server context

### uptime_hr()

Converts uptime in seconds to human-readable format.

**Parameters:**
- `uptime`: Uptime in seconds
- `mp_pck`: MessagePack packer for output

## Implementation Details

### MessagePack Integration

The endpoint uses MessagePack for internal data representation:

```c
msgpack_sbuffer mp_sbuf;
msgpack_packer mp_pck;
```

This allows efficient serialization of uptime data before converting to JSON for the HTTP response.

### JSON Response Format

The endpoint returns uptime information in JSON format:

```json
{
  "uptime_sec": 12345,
  "uptime_hr": "Fluent Bit has been running: 0 days, 3 hours, 25 minutes and 45 seconds"
}
```

### Thread Safety

The implementation accesses configuration data that is initialized during startup and remains static, ensuring thread safety for concurrent HTTP requests.

## Usage Examples

### Initializing Uptime Endpoint

```c
// Initialize uptime endpoint
int init_uptime_endpoint(struct flb_hs *hs) {
    return api_v1_uptime(hs);
}
```

### Accessing Uptime via HTTP

```bash
# Get uptime information
curl http://localhost:2020/api/v1/uptime
```

### Processing Uptime Data

```c
// Access uptime information programmatically
time_t get_service_uptime(struct flb_config *config) {
    return time(NULL) - config->init_time;
}

// Convert to human readable format
char* uptime_to_string(time_t uptime) {
    // Implementation similar to uptime_hr()
}
```

## Integration with Fluent Bit

The uptime module integrates with other Fluent Bit components:

1. **HTTP Server**: Part of the v1 API endpoint system
2. **Configuration**: Uses service configuration parameters
3. **Logging**: Integrates with Fluent Bit's logging system
4. **MessagePack**: Uses Fluent Bit's serialization library

## Error Handling

The implementation includes robust error handling:

- **Null Pointer Checks**: Functions handle NULL parameters gracefully
- **Memory Allocation**: Proper error checking for allocations
- **Resource Cleanup**: Cleanup functions ensure no resource leaks
- **HTTP Status Codes**: Proper HTTP status codes for different scenarios

## Performance Considerations

The implementation is optimized for:

- **Minimal Overhead**: Lightweight data structures
- **Cache Efficiency**: Uses existing configuration data
- **Memory Efficiency**: Proper sizing of buffers
- **Fast Access**: Direct access to configuration data

## Security Considerations

The implementation follows security best practices:

- **Read-only Access**: Only exposes uptime information, no sensitive data
- **Data Validation**: Proper input validation
- **Memory Safety**: Safe allocation/deallocation patterns
- **Access Control**: Respects HTTP server security model

## Extensibility

The module design supports future enhancements:

- **Additional Metrics**: Easy addition of uptime-related metrics
- **Enhanced Features**: Advanced uptime reporting features
- **Configuration Options**: Extensible configuration parameters

## Version Compatibility

The uptime module maintains compatibility with:

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

The uptime module can be configured through the HTTP server configuration:

```ini
[SERVICE]
    http_server  On
    http_listen  0.0.0.0
    http_port    2020
```

Once enabled, the uptime endpoint will be available at:
- `/api/v1/uptime` (JSON format)