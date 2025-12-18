# src/http_server/api/v1/health.h Documentation

## Overview

The `src/http_server/api/v1/health.h` file is the header file for the Fluent Bit HTTP server API v1 health check endpoint. This header defines the data structures, constants, and function declarations needed for implementing the health check functionality.

Health checks are essential for containerized deployments and cloud-native environments where automated systems need to determine if Fluent Bit is functioning properly and should continue receiving traffic or be restarted.

## Key Features

- Header definitions for health check functionality
- Data structure declarations
- Function prototypes
- Constant definitions
- API endpoint declarations
- Integration with Fluent Bit's HTTP server

## Data Structures

### struct flb_health_check_metrics_counter

Tracks health check metrics counters:

```c
struct flb_health_check_metrics_counter {
    /*
     * health check error limit,
     * setup by customer through config: HC_Errors_Count
     */
    int error_limit;

    /* counter the error number in metrics*/
    int error_counter;

    /*
    * health check retry failed limit,
    * setup by customer through config: HC_Retry_Failure_Count
    */
    int retry_failure_limit;

    /* count the retry failed number in metrics*/
    int retry_failure_counter;

    /*period limit, setup by customer through config: HC_Period*/
    int period_limit;

    /* count the seconds in one period*/
    int period_counter;
};
```

### struct flb_hs_hc_buf

Buffer structure for cached health check metrics:

```c
/*
 * error and retry failure buffers that contains certain cached data to be used
 * by health check.
 */
struct flb_hs_hc_buf {
    int users;
    int error_count;
    int retry_failure_count;
    struct mk_list _head;
};
```

## Constants

No specific constants are defined in this header file. Configuration parameters are handled through Fluent Bit's configuration system.

## Key Function Declarations

### api_v1_health()

```c
int api_v1_health(struct flb_hs *hs);
```

Initializes and registers the health check endpoint.

**Parameters:**
- `hs`: HTTP server context

**Returns:**
- `0` on success
- Error code on failure

### flb_hs_health_destroy()

```c
void flb_hs_health_destroy();
```

Cleans up health check resources when shutting down.

## Implementation Details

### Header Organization

The header file follows standard C header conventions:

1. **Include Guards**: Prevents multiple inclusion
2. **Dependencies**: Includes required Fluent Bit headers
3. **Data Structures**: Defines health-related structures
4. **Function Prototypes**: Declares external functions
5. **API Declarations**: Defines the public API

### Include Dependencies

Required headers for health check functionality:

```c
#include <fluent-bit/flb_info.h>
#include <fluent-bit/flb_http_server.h>
```

### Data Structure Design

The data structures are designed for:

1. **Metrics Tracking**: Efficient error and retry failure counting
2. **Period Management**: Time-based health assessment
3. **Memory Safety**: Proper reference counting for cleanup
4. **Thread Safety**: Per-thread storage for concurrent access
5. **Extensibility**: Easy addition of new metrics

### API Design

The public API is minimal and focused:

1. **Initialization**: `api_v1_health()` for endpoint registration
2. **Cleanup**: `flb_hs_health_destroy()` for resource cleanup
3. **No Internal Functions**: Implementation details are private

### Memory Management

The header defines structures that require careful memory management:

- **Dynamic Allocation**: Structures are allocated at runtime
- **Reference Counting**: `users` field prevents premature cleanup
- **Linked Lists**: Integration with Fluent Bit's list system
- **Thread-Local Storage**: Per-thread metrics caching

## Usage Examples

### Header Inclusion

```c
#include "health.h"
#include <fluent-bit/flb_http_server.h>
```

### Function Usage

```c
// Initialize health check endpoint
int init_health_endpoint(struct flb_hs *hs) {
    return api_v1_health(hs);
}

// Clean up on shutdown
void cleanup_health_resources() {
    flb_hs_health_destroy();
}
```

### Data Structure Usage

```c
// Access health check counters
struct flb_health_check_metrics_counter *get_health_counters() {
    extern struct flb_health_check_metrics_counter *metrics_counter;
    return metrics_counter;
}

// Create metrics buffer
struct flb_hs_hc_buf *create_metrics_buffer() {
    struct flb_hs_hc_buf *buf = flb_malloc(sizeof(struct flb_hs_hc_buf));
    if (buf) {
        buf->users = 0;
        buf->error_count = 0;
        buf->retry_failure_count = 0;
        mk_list_init(&buf->_head);
    }
    return buf;
}
```

## Integration with Fluent Bit

The header integrates with other Fluent Bit components:

1. **HTTP Server**: Part of the v1 API endpoint system
2. **Configuration**: Uses service configuration parameters
3. **Logging**: Integrates with Fluent Bit's logging system
4. **Threading**: Uses thread-local storage for per-thread state
5. **Lists**: Integrates with Fluent Bit's linked list system

## Error Handling

The header design supports robust error handling:

- **Null Pointer Checks**: Functions handle NULL parameters
- **Memory Allocation**: Proper error checking for allocations
- **Resource Cleanup**: Cleanup functions for proper shutdown
- **Thread Safety**: Safe concurrent access patterns

## Performance Considerations

The header design is optimized for:

- **Minimal Overhead**: Lightweight data structures
- **Cache Efficiency**: Compact structure layouts
- **Thread Safety**: Per-thread storage reduces contention
- **Memory Efficiency**: Proper sizing of integer fields
- **Fast Access**: Direct field access without indirection

## Security Considerations

The header design implements security best practices:

- **Minimal Exposure**: Only necessary functions are public
- **Data Validation**: Structures assume valid data
- **Memory Safety**: Proper allocation/deallocation patterns
- **Access Control**: Respects Fluent Bit's security model
- **Input Sanitization**: Assumes upstream validation

## Extensibility

The header design supports future enhancements:

- **New Metrics**: Easy addition of new counter fields
- **Additional Endpoints**: Compatible with new API versions
- **Enhanced Features**: Support for advanced health checks
- **Configuration Options**: Extensible configuration parameters
- **Monitoring Integration**: Ready for enhanced observability

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
4. **Thread Safety**: Respect thread-local storage boundaries
5. **Resource Cleanup**: Always call cleanup functions on shutdown