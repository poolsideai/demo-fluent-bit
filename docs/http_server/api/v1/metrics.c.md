# http_server/api/v1/metrics.c

## Overview

The `http_server/api/v1/metrics.c` file implements the metrics endpoints for Fluent Bit's HTTP server API. This module provides two primary endpoints:

1. **JSON Metrics Endpoint** (`/api/v1/metrics`): Returns raw metrics data in JSON format
2. **Prometheus Metrics Endpoint** (`/api/v1/metrics/prometheus`): Returns metrics in Prometheus exposition format

The implementation handles metrics collection, storage, and formatting for various monitoring systems. It receives metrics data through a message queue and makes it available via HTTP endpoints.

## Key Functions

### Metrics Endpoint Initialization

```c
int api_v1_metrics(struct flb_hs *hs)
```

Initializes the metrics endpoints by:
- Creating a pthread key for thread-local storage of metrics
- Setting up a message queue for receiving metrics data
- Registering both JSON and Prometheus metrics endpoints

### JSON Metrics Handler

```c
static void cb_metrics(mk_request_t *request, void *data)
```

Handles requests to the JSON metrics endpoint:
- Retrieves the latest metrics buffer
- Returns metrics data in JSON format with appropriate content type
- Manages reference counting to prevent premature deallocation

### Prometheus Metrics Handler

```c
void cb_metrics_prometheus(mk_request_t *request, void *data)
```

Handles requests to the Prometheus metrics endpoint:
- Formats metrics data according to Prometheus exposition format
- Adds HELP and TYPE annotations for each metric
- Includes additional system metrics like uptime and build information
- Returns properly formatted Prometheus metrics with appropriate content type

### Metrics Message Queue Callback

```c
static void cb_mq_metrics(mk_mq_t *queue, void *data, size_t size)
```

Processes incoming metrics data from the message queue:
- Converts MessagePack data to JSON format
- Stores metrics in thread-local buffers
- Manages memory allocation and cleanup
- Maintains a queue of recent metrics snapshots

## Important Variables

### Thread-Local Storage Key

```c
pthread_key_t hs_metrics_key;
```

A pthread key used for thread-local storage of metrics buffers, ensuring each HTTP worker thread maintains its own metrics queue.

### Metrics Buffer Structure

While not explicitly defined in this file, the implementation uses a buffer structure (defined in the implementation) to store metrics data:

- `users`: Reference count to manage concurrent access
- `data`: JSON-formatted metrics data
- `raw_data`: Raw MessagePack metrics data
- `raw_size`: Size of raw metrics data
- `_head`: Linked list head for queue management

## Dependencies

This file depends on:

1. **Fluent Bit Core**: Provides core data structures, utilities, and metrics system
2. **Monkey HTTP Server**: Provides HTTP server functionality and message queues
3. **MessagePack**: For parsing and converting metrics data
4. **POSIX Threads**: For thread-local storage management
5. **Standard C Library**: For string manipulation and sorting functions

## Implementation Details

### Metrics Data Flow

The metrics system works as follows:

1. **Data Reception**: Metrics are received through a message queue every second
2. **Data Conversion**: MessagePack data is converted to JSON format for storage
3. **Buffer Management**: Recent metrics snapshots are maintained in thread-local queues
4. **Memory Management**: Reference counting prevents premature deallocation of buffers
5. **Cleanup**: Old metrics data is periodically cleaned up to manage memory usage

### Prometheus Format Generation

The Prometheus endpoint generates metrics in the standard exposition format:

```
# HELP metric_name Metric description
# TYPE metric_name counter
metric_name{label="value"} value timestamp
```

The implementation:
- Extracts metric names and values from the raw data
- Generates appropriate HELP and TYPE annotations
- Sorts metrics alphabetically for consistent output
- Groups related metrics together
- Adds system-level metrics like uptime and build information

### Thread Safety

The implementation ensures thread safety through:

- Thread-local storage for metrics buffers
- Reference counting to manage concurrent access
- Proper cleanup of thread-local data using pthread key destructors

### Memory Management

Memory management is handled through:

- Manual allocation and deallocation of metrics buffers
- Thread-local storage cleanup via pthread key destructors
- Reference counting to prevent premature deallocation
- Periodic cleanup of old metrics data

## Configuration

The metrics endpoints are automatically available when the HTTP server is enabled. No specific configuration parameters are required for basic functionality.

## Usage Examples

### Retrieving JSON Metrics

```bash
# Get metrics in JSON format
curl http://localhost:2020/api/v1/metrics
```

Response:
```json
{
  "input": {
    "cpu0": {
      "records": 1234,
      "bytes": 5678
    }
  },
  "output": {
    "stdout": {
      "records": 1234,
      "bytes": 5678,
      "errors": 0
    }
  }
}
```

### Retrieving Prometheus Metrics

```bash
# Get metrics in Prometheus format
curl http://localhost:2020/api/v1/metrics/prometheus
```

Response:
```
# HELP fluentbit_input_records_total Number of input records.
# TYPE fluentbit_input_records_total counter
fluentbit_input_records_total{name="cpu0"} 1234 1620000000000
# HELP fluentbit_output_records_total Number of output records.
# TYPE fluentbit_output_records_total counter
fluentbit_output_records_total{name="stdout"} 1234 1620000000000
# HELP fluentbit_uptime Number of seconds that Fluent Bit has been running.
# TYPE fluentbit_uptime counter
fluentbit_uptime 3600
```

### Configuration Example

```ini
[SERVICE]
    HTTP_Server On
    HTTP_Listen 0.0.0.0
    HTTP_Port 2020
```

This configuration enables the HTTP server with metrics endpoints available at:
- `/api/v1/metrics` (JSON format)
- `/api/v1/metrics/prometheus` (Prometheus format)

## Integration with Fluent Bit

The metrics endpoints integrate with Fluent Bit as follows:

1. **Registration**: Registered during HTTP server initialization via `api_v1_metrics()`
2. **Metrics Flow**: Receives metrics data through Fluent Bit's metrics system
3. **Endpoint Exposure**: Exposed at standard REST API paths
4. **Data Format**: Supports both JSON and Prometheus formats for flexibility
5. **Resource Management**: Properly cleans up resources during shutdown