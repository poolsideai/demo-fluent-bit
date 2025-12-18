# src/http_server/api/v1/uptime.h Documentation

## Overview

The `src/http_server/api/v1/uptime.h` file is the header file for the Fluent Bit HTTP server API v1 uptime endpoint. This header defines the data structures, constants, and function declarations needed for implementing the uptime functionality.

Uptime information is essential for monitoring and observability of the Fluent Bit service, allowing administrators to understand how long the service has been running.

## Key Features

- Header definitions for uptime functionality
- Function prototypes
- API endpoint declarations
- Integration with Fluent Bit's HTTP server

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

## Key Function Declarations

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

## Implementation Details

### Header Organization

The header file follows standard C header conventions:

1. **Include Guards**: Prevents multiple inclusion
2. **Dependencies**: Includes required Fluent Bit headers
3. **Function Prototypes**: Declares external functions
4. **API Declarations**: Defines the public API

### Include Dependencies

Required headers for uptime functionality:

```c
#include <fluent-bit/flb_info.h>
#include <fluent-bit/flb_http_server.h>
```

### API Design

The public API is minimal and focused:

1. **Initialization**: `api_v1_uptime()` for endpoint registration
2. **No Internal Functions**: Implementation details are private

## Usage Examples

### Header Inclusion

```c
#include "uptime.h"
#include <fluent-bit/flb_http_server.h>
```

### Function Usage

```c
// Initialize uptime endpoint
int init_uptime_endpoint(struct flb_hs *hs) {
    return api_v1_uptime(hs);
}
```

## Integration with Fluent Bit

The header integrates with other Fluent Bit components:

1. **HTTP Server**: Part of the v1 API endpoint system
2. **Configuration**: Uses service configuration parameters
3. **Logging**: Integrates with Fluent Bit's logging system

## Error Handling

The header design supports robust error handling:

- **Null Pointer Checks**: Functions handle NULL parameters
- **Memory Allocation**: Proper error checking for allocations
- **Resource Cleanup**: Cleanup functions for proper shutdown

## Performance Considerations

The header design is optimized for:

- **Minimal Overhead**: Lightweight interface
- **Fast Access**: Direct function calls

## Security Considerations

The header design implements security best practices:

- **Minimal Exposure**: Only necessary functions are public
- **Data Validation**: Functions assume valid data
- **Memory Safety**: Proper allocation/deallocation patterns
- **Access Control**: Respects Fluent Bit's security model

## Extensibility

The header design supports future enhancements:

- **Additional Endpoints**: Compatible with new API versions
- **Enhanced Features**: Support for advanced uptime reporting
- **Configuration Options**: Extensible configuration parameters

## Version Compatibility

The header maintains compatibility with:

- **Fluent Bit 1.x**: Full backward compatibility
- **Fluent Bit 2.x**: Full forward compatibility
- **Future Versions**: Designed for extensibility
- **API Evolution**: Compatible with new endpoint versions

## Best Practices

When using this header, follow these best practices:

1. **Include Guards**: Always use proper include guards
2. **Memory Management**: Follow Fluent Bit's allocation patterns
3. **Error Handling**: Check return values from all functions
4. **Resource Cleanup**: Always call cleanup functions on shutdown