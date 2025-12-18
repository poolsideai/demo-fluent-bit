# Metrics API Implementation (v2)

## Overview

This file implements the HTTP API endpoints for exposing Fluent Bit's internal metrics in the v2 API. The implementation provides two main endpoints for accessing metrics:
- `/api/v2/metrics` - Returns metrics in plain text format
- `/api/v2/metrics/prometheus` - Returns metrics in Prometheus format

The implementation uses CMetrics (CMT) library for metric collection and storage, and integrates with the HTTP server through message queues for efficient data transfer.

## Key Functions

### `api_v2_metrics(struct flb_hs *hs)`

Main registration function that registers the metrics API endpoints with the HTTP server and sets up the message queue infrastructure.

### `cb_metrics_prometheus(mk_request_t *request, void *data)`

HTTP callback handler for Prometheus metrics requests. Retrieves the latest metrics data and converts it to Prometheus format.

### `cb_metrics(mk_request_t *request, void *data)`

HTTP callback handler for plain text metrics requests. Retrieves the latest metrics data and converts it to plain text format.

### `cb_mq_metrics(mk_mq_t *queue, void *data, size_t size)`

Message queue callback that receives metrics data from the core Fluent Bit engine and stores it for HTTP endpoint access.

### `metrics_get_latest()`

Retrieves the most recent metrics buffer from thread-local storage.

### `cleanup_metrics()`

Garbage collection function that removes unused metrics buffers to prevent memory leaks.

### `hs_metrics_v2_key_create()`

Creates thread-local storage for metrics buffers.

### `hs_metrics_v2_key_destroy(void *data)`

Destroys thread-local storage and cleans up associated metrics buffers.

## Important Variables and Constants

- `hs_metrics_v2_key`: Thread-specific key for storing metrics buffers
- `null_check(x)`: Macro for safe null pointer checking

## Dependencies and Relationships

- Integrates with HTTP server framework through `mk_vhost_handler`
- Uses CMetrics (CMT) library for metric storage and encoding
- Communicates with core Fluent Bit engine through message queues (`mk_mq_*` functions)
- Uses thread-local storage for efficient metrics buffering
- Depends on input/filter/output plugin infrastructure for metric collection

## Notable Implementation Details

1. **Thread-Local Storage**: Uses pthread-specific data to store metrics buffers per thread
2. **Message Queue Integration**: Receives metrics data asynchronously through Monkey HTTP message queues
3. **Reference Counting**: Implements user reference counting to prevent premature cleanup of metrics buffers
4. **Automatic Cleanup**: Garbage collection system removes unused metrics buffers
5. **Multiple Formats**: Supports both plain text and Prometheus metric formats
6. **Memory Management**: Proper allocation and deallocation of CMetrics contexts and buffers
7. **Error Handling**: Comprehensive error handling with appropriate HTTP status codes

## Usage Examples

### Get plain text metrics:
```bash
GET /api/v2/metrics
```

### Get Prometheus-formatted metrics:
```bash
GET /api/v2/metrics/prometheus
```

Response (Prometheus format):
```
fluentbit_input_records_total{name="cpu",type="cpu"} 1234
fluentbit_output_proc_bytes_total{name="stdout",type="stdout"} 5678
```