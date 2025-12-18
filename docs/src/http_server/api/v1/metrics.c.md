# src/http_server/api/v1/metrics.c Documentation

## Overview

The `src/http_server/api/v1/metrics.c` file implements the Fluent Bit HTTP server API v1 metrics endpoints. This module provides functionality for exposing internal metrics in both JSON and Prometheus formats, which are essential for monitoring and observability of the Fluent Bit service.

Fluent Bit collects various metrics from its input, filter, and output plugins, and this module makes those metrics available through HTTP endpoints for external monitoring systems.

## Key Features

- Metrics collection and exposure
- JSON and Prometheus format support
- Thread-safe metrics storage
- Message queue integration
- Memory-efficient buffer management
- HELP and TYPE annotations for Prometheus metrics
- Uptime and build information metrics

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

## Key Functions

### api_v1_metrics()

```c
int api_v1_metrics(struct flb_hs *hs);
```

Initializes the metrics endpoints and registers them with the HTTP server.

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

### cb_metrics()

HTTP callback function for `/api/v1/metrics` endpoint.

**Parameters:**
- `request`: HTTP request object
- `data`: HTTP server context

### cb_metrics_prometheus()

HTTP callback function for `/api/v1/metrics/prometheus` endpoint.

**Parameters:**
- `request`: HTTP request object
- `data`: HTTP server context

### cb_mq_metrics()

Message queue callback for processing incoming metrics data.

**Parameters:**
- `queue`: Message queue object
- `data`: Raw metrics data
- `size`: Size of metrics data

## Implementation Details

### Thread Safety

The implementation uses thread-local storage to ensure thread safety:

```c
pthread_key_t hs_metrics_key;
```

Each HTTP worker thread maintains its own metrics cache to avoid contention.

### Memory Management

The module implements efficient memory management:

1. **Buffer Pooling**: Metrics data is cached in thread-local buffers
2. **Reference Counting**: Buffers are reference-counted to prevent premature cleanup
3. **Automatic Cleanup**: Unused buffers are automatically cleaned up
4. **Memory Limits**: Prevents unbounded memory growth

### Message Queue Integration

Metrics data flows through a message queue system:

```c
hs->qid_metrics = mk_mq_create(hs->ctx, "/metrics", cb_mq_metrics, NULL);
```

This decouples metrics collection from HTTP serving, improving performance.

### Prometheus Format Generation

The module generates Prometheus-compatible metrics with proper annotations:

- HELP lines for metric descriptions
- TYPE lines for metric types (counter, gauge)
- Proper metric naming conventions
- Timestamp information
- Label support

### Built-in Metrics

The module exposes several built-in metrics:

1. **Plugin Metrics**: Input, filter, and output plugin metrics
2. **Uptime**: Service uptime in seconds
3. **Process Start Time**: Process start time since Unix epoch
4. **Build Information**: Version and edition information

## Usage Examples

### Initializing Metrics Endpoints

```c
// Initialize metrics endpoints
int init_metrics_endpoints(struct flb_hs *hs) {
    return api_v1_metrics(hs);
}
```

### Accessing Metrics via HTTP

```bash
# Get metrics in JSON format
curl http://localhost:2020/api/v1/metrics

# Get metrics in Prometheus format
curl http://localhost:2020/api/v1/metrics/prometheus
```

### Processing Metrics Data

```c
// Process incoming metrics data
void process_metrics_data(void *raw_data, size_t size) {
    // Send to message queue for processing
    mk_mq_send(hs->qid_metrics, raw_data, size);
}
```

## Integration with Fluent Bit

The metrics module integrates with other Fluent Bit components:

1. **HTTP Server**: Part of the v1 API endpoint system
2. **Configuration**: Uses service configuration parameters
3. **Logging**: Integrates with Fluent Bit's logging system
4. **Threading**: Uses thread-local storage for concurrent access
5. **Message Queues**: Integrates with Fluent Bit's MQ system
6. **Plugin System**: Collects metrics from all plugin types

## Error Handling

The implementation includes robust error handling:

- **Null Pointer Checks**: Functions handle NULL parameters gracefully
- **Memory Allocation**: Proper error checking for allocations
- **Resource Cleanup**: Cleanup functions ensure no resource leaks
- **Thread Safety**: Safe concurrent access patterns
- **HTTP Status Codes**: Proper HTTP status codes for different scenarios

## Performance Considerations

The implementation is optimized for:

- **Minimal Overhead**: Lightweight data structures
- **Cache Efficiency**: Compact structure layouts
- **Thread Safety**: Per-thread storage reduces contention
- **Memory Efficiency**: Proper sizing and cleanup
- **Fast Access**: Direct field access without indirection
- **Asynchronous Processing**: Message queue decouples collection from serving

## Security Considerations

The implementation follows security best practices:

- **Minimal Exposure**: Only necessary functions are public
- **Data Validation**: Proper input validation
- **Memory Safety**: Safe allocation/deallocation patterns
- **Access Control**: Respects HTTP server security model
- **Input Sanitization**: Proper handling of metric data

## Extensibility

The module design supports future enhancements:

- **New Metrics**: Easy addition of new metric types
- **Additional Formats**: Support for new export formats
- **Enhanced Features**: Advanced filtering and aggregation
- **Configuration Options**: Extensible configuration parameters
- **Monitoring Integration**: Ready for enhanced observability

## Version Compatibility

The metrics module maintains compatibility with:

- **Fluent Bit 1.x**: Full backward compatibility
- **Fluent Bit 2.x**: Full forward compatibility
- **Future Versions**: Designed for extensibility
- **API Evolution**: Compatible with new endpoint versions

## Best Practices

When using this module, follow these best practices:

1. **Memory Management**: Follow Fluent Bit's allocation patterns
2. **Error Handling**: Check return values from all functions
3. **Thread Safety**: Respect thread-local storage boundaries
4. **Resource Cleanup**: Always call cleanup functions on shutdown
5. **Performance**: Monitor memory usage and buffer sizes
6. **Security**: Validate all input data

## Configuration

The metrics module can be configured through the HTTP server configuration:

```ini
[SERVICE]
    http_server  On
    http_listen  0.0.0.0
    http_port    2020
```

Once enabled, the metrics endpoints will be available at:
- `/api/v1/metrics` (JSON format)
- `/api/v1/metrics/prometheus` (Prometheus format)