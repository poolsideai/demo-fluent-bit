# src/http_server/api/v1/metrics.h Documentation

## Overview

The `src/http_server/api/v1/metrics.h` file is the header file for the Fluent Bit HTTP server API v1 metrics endpoints. This header defines the data structures, constants, and function declarations needed for implementing the metrics functionality.

Metrics are essential for monitoring and observability of the Fluent Bit service, providing insights into input/output plugin performance, error rates, and system health.

## Key Features

- Header definitions for metrics functionality
- Data structure declarations
- Function prototypes
- Constant definitions
- API endpoint declarations
- Integration with Fluent Bit's HTTP server

## Data Structures

### struct flb_hs_buf

Buffer structure for cached metrics data:

```c
struct flb_hs_buf {
    int users;              /* Reference counter */
    flb_sds_t data;         /* JSON formatted metrics data */
    void *raw_data;        /* Raw MessagePack data */
    size_t raw_size;       /* Size of raw data */
    struct mk_list _head;  /* Linked list header */
};
```

This structure is used to cache metrics data for efficient retrieval by HTTP endpoints.

## Constants

No specific constants are defined in this header file. Configuration parameters are handled through Fluent Bit's configuration system.

## Key Function Declarations

### api_v1_metrics()

```c
int api_v1_metrics(struct flb_hs *hs);
```

Initializes and registers the metrics endpoints.

**Parameters:**
- `hs`: HTTP server context

**Returns:**
- `0` on success
- Error code on failure

### metrics_help_txt()

```c
flb_sds_t metrics_help_txt(char *metric_name, flb_sds_t *metric_helptxt);
```

Generates HELP text for Prometheus metrics based on metric name.

**Parameters:**
- `metric_name`: Name of the metric
- `metric_helptxt`: Pointer to SDS buffer for HELP text

**Returns:**
- Updated SDS buffer with HELP text

## Implementation Details

### Header Organization

The header file follows standard C header conventions:

1. **Include Guards**: Prevents multiple inclusion
2. **Dependencies**: Includes required Fluent Bit headers
3. **Data Structures**: Defines metrics-related structures
4. **Function Prototypes**: Declares external functions
5. **API Declarations**: Defines the public API

### Include Dependencies

Required headers for metrics functionality:

```c
#include <fluent-bit/flb_info.h>
#include <fluent-bit/flb_http_server.h>
#include <fluent-bit/flb_sds.h>
```

### Data Structure Design

The data structures are designed for:

1. **Metrics Storage**: Efficient caching of metrics data
2. **Memory Safety**: Proper reference counting and cleanup
3. **Thread Safety**: Per-thread storage for concurrent access
4. **Extensibility**: Easy addition of new fields

### API Design

The public API is minimal and focused:

1. **Initialization**: `api_v1_metrics()` for endpoint registration
2. **Utility Functions**: `metrics_help_txt()` for Prometheus formatting
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
#include "metrics.h"
#include <fluent-bit/flb_http_server.h>
```

### Function Usage

```c
// Initialize metrics endpoints
int init_metrics_endpoints(struct flb_hs *hs) {
    return api_v1_metrics(hs);
}

// Generate HELP text for Prometheus metrics
flb_sds_t generate_help_text(char *metric_name) {
    flb_sds_t helptxt = flb_sds_create_size(128);
    return metrics_help_txt(metric_name, &helptxt);
}
```

### Data Structure Usage

```c
// Create metrics buffer
struct flb_hs_buf *create_metrics_buffer() {
    struct flb_hs_buf *buf = flb_malloc(sizeof(struct flb_hs_buf));
    if (buf) {
        buf->users = 0;
        buf->data = NULL;
        buf->raw_data = NULL;
        mk_list_init(&buf->_head);
    }
    return buf;
}

// Access metrics data
struct flb_hs_buf *get_latest_metrics() {
    extern struct flb_hs_buf *latest_metrics;
    return latest_metrics;
}
```

## Integration with Fluent Bit

The header integrates with other Fluent Bit components:

1. **HTTP Server**: Part of the v1 API endpoint system
2. **Configuration**: Uses service configuration parameters
3. **Logging**: Integrates with Fluent Bit's logging system
4. **Threading**: Uses thread-local storage for per-thread state
5. **Lists**: Integrates with Fluent Bit's linked list system
6. **SDS**: Uses Fluent Bit's String Data Structure library

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
- **Enhanced Features**: Support for advanced metrics
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