# http_server/api/v1/health.c

## Overview

The `http_server/api/v1/health.c` file implements the health check endpoint for Fluent Bit's HTTP server API. This endpoint provides a mechanism to monitor the health status of the Fluent Bit instance by analyzing metrics data and determining if the system is operating within acceptable parameters.

The health check functionality monitors error rates and retry failures over a configurable time period, allowing administrators to detect when Fluent Bit is experiencing issues that may affect its operation.

## Key Functions

### Health Check Initialization

```c
int api_v1_health(struct flb_hs *hs)
```

Initializes the health check endpoint by:
- Creating a pthread key for thread-local storage of metrics
- Initializing health check metrics counters
- Creating a message queue for receiving metrics data
- Registering the health endpoint at `/api/v1/health`

### Health Status Determination

```c
static int is_healthy()
```

Determines the current health status by:
- Retrieving thread-local metrics data
- Calculating error and retry failure rates over the current period
- Comparing against configured limits
- Returning `FLB_TRUE` if within limits, `FLB_FALSE` otherwise

### Metrics Processing

```c
static void cb_mq_health(mk_mq_t *queue, void *data, size_t size)
```

Callback function that processes incoming metrics data:
- Maintains a queue of metrics snapshots
- Updates error and retry failure counters
- Cleans up old metrics data outside the configured period

### Health Endpoint Handler

```c
static void cb_health(mk_request_t *request, void *data)
```

HTTP endpoint handler that responds to health check requests:
- Calls `is_healthy()` to determine current status
- Returns HTTP 200 with "ok" if healthy
- Returns HTTP 500 with "error" if unhealthy

## Important Variables

### Metrics Counter Structure

```c
struct flb_health_check_metrics_counter *metrics_counter;
```

A global pointer to the health check metrics counter structure that tracks:
- Error limit and current error count
- Retry failure limit and current retry failure count
- Period limit and current period counter

### Thread-Local Storage Key

```c
pthread_key_t hs_health_key;
```

A pthread key used for thread-local storage of metrics data, ensuring each HTTP worker thread maintains its own metrics queue.

## Dependencies

This file depends on:

1. **Fluent Bit Core**: Provides core data structures and utilities
2. **Monkey HTTP Server**: Provides HTTP server functionality and message queues
3. **MessagePack**: For parsing metrics data
4. **POSIX Threads**: For thread-local storage management

## Implementation Details

### Health Check Algorithm

The health check algorithm works as follows:

1. **Metrics Collection**: Metrics data is received through a message queue every second
2. **Period Tracking**: A period counter tracks time within the configured health check period
3. **Data Accumulation**: Error and retry failure counts are accumulated over time
4. **Rate Calculation**: Current error and retry failure rates are calculated by comparing current totals with period-start values
5. **Threshold Comparison**: Calculated rates are compared against configured limits
6. **Status Determination**: Health status is determined based on whether limits are exceeded

### Thread Safety

The implementation uses thread-local storage to ensure each HTTP worker thread maintains its own metrics queue, preventing race conditions when multiple threads access the health check functionality simultaneously.

### Memory Management

Memory management is handled through:
- Thread-local storage cleanup using pthread key destructors
- Manual allocation and deallocation of metrics buffer structures
- Cleanup of old metrics data outside the configured period

## Configuration

Health check behavior can be configured through Fluent Bit's configuration system:

- `HC_Errors_Count`: Maximum allowed errors per period
- `HC_Retry_Failure_Count`: Maximum allowed retry failures per period
- `HC_Period`: Time period (in seconds) over which metrics are evaluated

## Usage Examples

### Checking Health Status

```bash
# Check if Fluent Bit is healthy
curl http://localhost:2020/api/v1/health
```

Response when healthy:
```
HTTP/1.1 200 OK
ok
```

Response when unhealthy:
```
HTTP/1.1 500 Internal Server Error
error
```

### Configuration Example

```ini
[SERVICE]
    HTTP_Server On
    HTTP_Listen 0.0.0.0
    HTTP_Port 2020
    HC_Errors_Count 10
    HC_Retry_Failure_Count 5
    HC_Period 60
```

This configuration enables the HTTP server and sets health check thresholds:
- Maximum 10 errors per 60-second period
- Maximum 5 retry failures per 60-second period

## Integration with Fluent Bit

The health check endpoint integrates with Fluent Bit as follows:

1. **Registration**: Registered during HTTP server initialization via `api_v1_health()`
2. **Metrics Flow**: Receives metrics data through Fluent Bit's metrics system
3. **Endpoint Exposure**: Exposed at `/api/v1/health` via the HTTP server
4. **Cleanup**: Resources are cleaned up during shutdown via `flb_hs_health_destroy()`