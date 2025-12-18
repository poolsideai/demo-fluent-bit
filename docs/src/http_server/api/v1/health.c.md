# src/http_server/api/v1/health.c Documentation

## Overview

The `src/http_server/api/v1/health.c` file implements the health check endpoint for Fluent Bit's HTTP server API v1. This module provides functionality to monitor the health status of the Fluent Bit instance by analyzing error metrics and determining if the system is operating within acceptable parameters.

Health checks are crucial for containerized deployments and cloud-native environments where automated systems need to determine if Fluent Bit is functioning properly and should continue receiving traffic or be restarted.

## Key Features

- Health check endpoint implementation
- Metrics-based health assessment
- Thread-local storage for metrics caching
- Message queue integration for real-time metrics
- Configurable health thresholds
- RESTful HTTP endpoint

## Data Structures

### struct flb_health_check_metrics_counter

Tracks health check metrics counters:

```c
struct flb_health_check_metrics_counter {
    int error_limit;           /* Maximum allowed errors per period */
    int error_counter;         /* Current error count */
    int retry_failure_limit;   /* Maximum allowed retry failures per period */
    int retry_failure_counter; /* Current retry failure count */
    int period_limit;          /* Health check period in seconds */
    int period_counter;        /* Current period counter */
};
```

### struct flb_hs_hc_buf

Buffer structure for cached health check metrics:

```c
struct flb_hs_hc_buf {
    int users;                   /* Reference count for cleanup safety */
    int error_count;             /* Cached error count */
    int retry_failure_count;     /* Cached retry failure count */
    struct mk_list _head;       /* Link for the metrics list */
};
```

## Key Functions

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

### cb_health()

```c
static void cb_health(mk_request_t *request, void *data);
```

HTTP callback function for the health check endpoint.

**Parameters:**
- `request`: HTTP request context
- `data`: Endpoint-specific data

### cb_mq_health()

```c
static void cb_mq_health(mk_mq_t *queue, void *data, size_t size);
```

Message queue callback for processing metrics data.

**Parameters:**
- `queue`: Message queue context
- `data`: Metrics data
- `size`: Size of metrics data

### is_healthy()

```c
static int is_healthy();
```

Determines if Fluent Bit is healthy based on current metrics.

**Returns:**
- `FLB_TRUE` if healthy
- `FLB_FALSE` if unhealthy

### read_metrics()

```c
static void read_metrics(void *data, size_t size, int* error_count,
                         int* retry_failure_count);
```

Extracts error and retry failure counts from metrics data.

**Parameters:**
- `data`: Metrics data
- `size`: Size of metrics data
- `error_count`: Pointer to store error count
- `retry_failure_count`: Pointer to store retry failure count

### cleanup_metrics()

```c
static int cleanup_metrics();
```

Removes outdated metrics from the cache.

**Returns:**
- Number of metrics entries removed

### hs_health_key_create()

```c
static struct mk_list *hs_health_key_create();
```

Creates thread-local storage for health check metrics.

**Returns:**
- Pointer to metrics list on success
- `NULL` on error

### hs_health_key_destroy()

```c
static void hs_health_key_destroy(void *data);
```

Destroys thread-local storage for health check metrics.

**Parameters:**
- `data`: Metrics list to destroy

### counter_init()

```c
static void counter_init(struct flb_hs *hs);
```

Initializes health check metrics counters.

**Parameters:**
- `hs`: HTTP server context

## Implementation Details

### Health Check Algorithm

The health check determines system health by analyzing error metrics over a configurable time period:

1. **Metrics Collection**: Receives metrics data through a message queue
2. **Error Counting**: Tracks errors and retry failures in real-time
3. **Period Management**: Maintains metrics for a configurable period
4. **Threshold Comparison**: Compares current metrics against configured limits
5. **Status Determination**: Returns healthy/unhealthy based on thresholds

### Thread-Local Storage

The module uses thread-local storage to maintain metrics state:

- Each HTTP worker thread has its own metrics cache
- Metrics data is stored in linked lists for efficient access
- Reference counting prevents premature cleanup
- Automatic cleanup when threads terminate

### Message Queue Integration

Health metrics are processed through Fluent Bit's message queue system:

1. **Queue Creation**: Creates a dedicated queue for health metrics
2. **Callback Registration**: Registers `cb_mq_health` for processing
3. **Real-time Processing**: Processes metrics as they arrive
4. **State Updates**: Updates health counters with new metrics

### HTTP Endpoint

The health check is exposed as a RESTful HTTP endpoint:

- **URL**: `/api/v1/health`
- **Method**: GET
- **Response Codes**: 
  - 200 OK (healthy)
  - 500 Internal Server Error (unhealthy)
- **Response Body**: Simple text (`ok` or `error`)

### Configuration Parameters

Health check behavior is controlled by these configuration options:

- **HC_Errors_Count**: Maximum errors allowed per period
- **HC_Retry_Failure_Count**: Maximum retry failures allowed per period
- **Health_Check_Period**: Time period for health assessment

### Metrics Extraction

The `read_metrics()` function parses MessagePack-encoded metrics data:

1. **Format Parsing**: Extracts data from MessagePack format
2. **Field Identification**: Locates error and retry failure fields
3. **Accumulation**: Sums errors across all output plugins
4. **Count Updates**: Updates global counters with new values

## Usage Examples

### HTTP Request

```bash
# Check health status
curl http://localhost:2020/api/v1/health

# Expected responses:
# Healthy: HTTP 200 OK
# Unhealthy: HTTP 500 Internal Server Error
```

### Configuration

```ini
[SERVICE]
    # Health check configuration
    HC_Errors_Count 10
    HC_Retry_Failure_Count 5
    Health_Check_Period 60
```

### Programmatic Usage

```c
#include "health.h"
#include <fluent-bit/flb_http_server.h>

// Initialize health check endpoint
int init_health_endpoint(struct flb_hs *hs) {
    return api_v1_health(hs);
}

// Check current health status
int check_health_status() {
    return is_healthy();
}

// Process incoming metrics (called by message queue)
void process_health_metrics(void *data, size_t size) {
    int error_count, retry_failure_count;
    read_metrics(data, size, &error_count, &retry_failure_count);
    
    // Update global counters
    metrics_counter->error_counter = error_count;
    metrics_counter->retry_failure_counter = retry_failure_count;
}
```

## Integration with Fluent Bit

The health check module integrates with other Fluent Bit components:

1. **HTTP Server**: Registered as an API v1 endpoint
2. **Metrics System**: Consumes metrics data from the metrics subsystem
3. **Configuration**: Uses service configuration parameters
4. **Logging**: Integrates with Fluent Bit's logging system
5. **Threading**: Uses thread-local storage for per-thread state

## Error Handling

The module implements robust error handling:

- **Memory Allocation**: Checks for allocation failures
- **Message Queue**: Handles queue processing errors gracefully
- **Metrics Parsing**: Validates metrics data format
- **Thread Safety**: Ensures safe concurrent access
- **Resource Cleanup**: Proper cleanup on shutdown

## Performance Considerations

The implementation is optimized for:

- **Low Latency**: Fast health check responses
- **Memory Efficiency**: Efficient metrics caching
- **Thread Safety**: Lock-free operations where possible
- **Scalability**: Handles multiple concurrent requests
- **Real-time Processing**: Immediate metrics processing

## Security Considerations

The health check endpoint implements security best practices:

- **Simple Response**: Minimal information disclosure
- **No Authentication**: Designed for internal monitoring
- **Rate Limiting**: Inherits HTTP server rate limiting
- **Access Control**: Respects HTTP server access controls
- **Input Validation**: Validates all incoming data

## Monitoring and Observability

The health check provides observability features:

- **Metrics Integration**: Works with Fluent Bit's metrics system
- **Logging**: Detailed logging for debugging
- **Status Reporting**: Clear health status indicators
- **Configuration Visibility**: Exposes health check parameters
- **Performance Monitoring**: Tracks health check response times