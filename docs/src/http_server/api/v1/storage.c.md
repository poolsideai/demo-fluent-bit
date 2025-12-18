# src/http_server/api/v1/storage.c Documentation

## Overview

The `src/http_server/api/v1/storage.c` file implements the Fluent Bit HTTP server API v1 storage metrics endpoint. This module provides functionality for exposing storage-related metrics from the Fluent Bit service, which are essential for monitoring disk usage, buffer states, and storage performance.

Storage metrics are crucial for understanding how Fluent Bit manages data persistence and buffering, especially in production environments where disk space and I/O performance are critical factors.

## Key Features

- Storage metrics collection and exposure
- JSON format response
- Thread-safe metrics storage
- Message queue integration
- Memory-efficient buffer management
- Integration with Fluent Bit's HTTP server

## Data Structures

### struct flb_hs_buf

Buffer structure for cached storage metrics data:

```c
struct flb_hs_buf {
    int users;              /* Reference counter */
    flb_sds_t data;         /* JSON formatted storage metrics data */
    void *raw_data;        /* Raw MessagePack data */
    size_t raw_size;       /* Size of raw data */
    struct mk_list _head;  /* Linked list header */
};
```

This structure is used to cache storage metrics data for efficient retrieval by HTTP endpoints.

## Key Functions

### api_v1_storage_metrics()

```c
int api_v1_storage_metrics(struct flb_hs *hs);
```

Initializes the storage metrics endpoints and registers them with the HTTP server.

**Parameters:**
- `hs`: HTTP server context

**Returns:**
- `0` on success
- Error code on failure

### cb_storage()

HTTP callback function for `/api/v1/storage` endpoint.

**Parameters:**
- `request`: HTTP request object
- `data`: HTTP server context

### cb_mq_storage_metrics()

Message queue callback for processing incoming storage metrics data.

**Parameters:**
- `queue`: Message queue object
- `data`: Raw storage metrics data
- `size`: Size of storage metrics data

## Implementation Details

### Thread Safety

The implementation uses thread-local storage to ensure thread safety:

```c
pthread_key_t hs_storage_metrics_key;
```

Each HTTP worker thread maintains its own storage metrics cache to avoid contention.

### Memory Management

The module implements efficient memory management:

1. **Buffer Pooling**: Storage metrics data is cached in thread-local buffers
2. **Reference Counting**: Buffers are reference-counted to prevent premature cleanup
3. **Automatic Cleanup**: Unused buffers are automatically cleaned up
4. **Memory Limits**: Prevents unbounded memory growth

### Message Queue Integration

Storage metrics data flows through a message queue system:

```c
hs->qid_storage = mk_mq_create(hs->ctx, "/storage",
                               cb_mq_storage_metrics,
                               NULL);
```

This decouples storage metrics collection from HTTP serving, improving performance.

### JSON Response Format

The endpoint returns storage metrics in JSON format:

```json
{
  "storage": {
    "chunks": {
      "total": 1000,
      "mem": 500,
      "fs": 500
    },
    "records": {
      "total": 1000000,
      "mem": 500000,
      "fs": 500000
    },
    "bytes": {
      "total": 104857600,
      "mem": 52428800,
      "fs": 52428800
    }
  }
}
```

### Built-in Metrics

The module exposes several built-in storage metrics:

1. **Chunk Metrics**: Total, memory, and filesystem chunks
2. **Record Metrics**: Total, memory, and filesystem records
3. **Byte Metrics**: Total, memory, and filesystem bytes

## Usage Examples

### Initializing Storage Metrics Endpoints

```c
// Initialize storage metrics endpoints
int init_storage_metrics_endpoints(struct flb_hs *hs) {
    return api_v1_storage_metrics(hs);
}
```

### Accessing Storage Metrics via HTTP

```bash
# Get storage metrics in JSON format
curl http://localhost:2020/api/v1/storage
```

### Processing Storage Metrics Data

```c
// Process incoming storage metrics data
void process_storage_metrics_data(void *raw_data, size_t size) {
    // Send to message queue for processing
    mk_mq_send(hs->qid_storage, raw_data, size);
}
```

## Integration with Fluent Bit

The storage metrics module integrates with other Fluent Bit components:

1. **HTTP Server**: Part of the v1 API endpoint system
2. **Configuration**: Uses service configuration parameters
3. **Logging**: Integrates with Fluent Bit's logging system
4. **Threading**: Uses thread-local storage for concurrent access
5. **Message Queues**: Integrates with Fluent Bit's MQ system
6. **Storage Layer**: Collects metrics from Fluent Bit's storage subsystem

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

- **New Metrics**: Easy addition of new storage metric types
- **Additional Formats**: Support for new export formats
- **Enhanced Features**: Advanced filtering and aggregation
- **Configuration Options**: Extensible configuration parameters
- **Monitoring Integration**: Ready for enhanced observability

## Version Compatibility

The storage metrics module maintains compatibility with:

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

The storage metrics module can be configured through the HTTP server configuration:

```ini
[SERVICE]
    http_server  On
    http_listen  0.0.0.0
    http_port    2020
```

Once enabled, the storage metrics endpoint will be available at:
- `/api/v1/storage` (JSON format)