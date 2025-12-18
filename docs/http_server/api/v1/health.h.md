# http_server/api/v1/health.h

## Overview

The `http_server/api/v1/health.h` file defines the public interface for the health check functionality in Fluent Bit's HTTP server API. This header file declares the data structures and functions needed to implement and interact with the health check endpoint.

The header provides declarations for the health check metrics counter structure, buffer structures for storing metrics data, and function prototypes for initializing and cleaning up the health check functionality.

## Key Data Structures

### Health Check Metrics Counter

```c
struct flb_health_check_metrics_counter {
    int error_limit;
    int error_counter;
    int retry_failure_limit;
    int retry_failure_counter;
    int period_limit;
    int period_counter;
};
```

A structure that tracks health check metrics:

- `error_limit`: Maximum allowed errors per period (configured via `HC_Errors_Count`)
- `error_counter`: Current cumulative error count from metrics
- `retry_failure_limit`: Maximum allowed retry failures per period (configured via `HC_Retry_Failure_Count`)
- `retry_failure_counter`: Current cumulative retry failure count from metrics
- `period_limit`: Time period length in seconds (configured via `HC_Period`)
- `period_counter`: Current position within the period

### Health Check Buffer

```c
struct flb_hs_hc_buf {
    int users;
    int error_count;
    int retry_failure_count;
    struct mk_list _head;
};
```

A buffer structure for storing metrics snapshots:

- `users`: Reference count to prevent premature deallocation
- `error_count`: Error count at the time of this snapshot
- `retry_failure_count`: Retry failure count at the time of this snapshot
- `_head`: Linked list head for queue management

## Key Functions

### Health Endpoint Initialization

```c
int api_v1_health(struct flb_hs *hs);
```

Initializes the health check endpoint:
- Creates pthread key for thread-local storage
- Initializes metrics counters
- Sets up message queue for metrics reception
- Registers HTTP endpoint at `/api/v1/health`

### Resource Cleanup

```c
void flb_hs_health_destroy();
```

Cleans up health check resources during shutdown:
- Frees the metrics counter structure
- Handles thread-local storage cleanup via pthread key destructor

## Configuration Parameters

The health check functionality supports the following configuration parameters:

- `HC_Errors_Count`: Sets the maximum allowed errors per health check period
- `HC_Retry_Failure_Count`: Sets the maximum allowed retry failures per health check period
- `HC_Period`: Sets the duration of the health check evaluation period in seconds

## Dependencies

This header file depends on:

1. **Fluent Bit Core**: Provides core data structures and configuration system
2. **Monkey HTTP Server**: Provides HTTP server data structures and message queue interfaces

## Usage in Implementation

The header is used in the implementation file (`health.c`) to:

1. Access the health check metrics counter structure
2. Define the buffer structure for metrics storage
3. Declare the initialization and cleanup functions
4. Integrate with Fluent Bit's HTTP server framework

## Thread Safety

The health check implementation uses thread-local storage to ensure thread safety:

- Each HTTP worker thread maintains its own metrics queue
- The `pthread_key_t` provides thread-local storage for metrics data
- Reference counting prevents race conditions during cleanup

## Integration with Fluent Bit HTTP Server

The health check endpoint integrates with the Fluent Bit HTTP server as follows:

1. **Registration**: The endpoint is registered during HTTP server initialization
2. **Message Queue**: Uses Monkey's message queue system to receive metrics data
3. **HTTP Endpoint**: Exposes functionality at the standard REST API path
4. **Resource Management**: Properly cleans up resources during shutdown