# http_server/api/v1/metrics.h

## Overview

The `http_server/api/v1/metrics.h` file defines the public interface for the metrics functionality in Fluent Bit's HTTP server API. This header file declares the functions needed to implement and interact with the metrics endpoints.

The header provides declarations for initializing the metrics endpoints and a helper function for generating Prometheus HELP text.

## Key Functions

### Metrics Endpoint Initialization

```c
int api_v1_metrics(struct flb_hs *hs);
```

Initializes the metrics endpoints:
- Creates pthread key for thread-local storage
- Sets up message queue for metrics reception
- Registers HTTP endpoints for JSON and Prometheus metrics

### Prometheus HELP Text Generation

```c
flb_sds_t metrics_help_txt(char *metric_name, flb_sds_t *metric_helptxt);
```

Generates appropriate HELP text for Prometheus metrics based on the metric name:
- Maps metric names to descriptive text
- Returns the generated HELP text
- Supports various metric types including input/output records, bytes, errors, and retries

## Dependencies

This header file depends on:

1. **Fluent Bit Core**: Provides core data structures and HTTP server interfaces
2. **String Data Structures**: For efficient string manipulation (`flb_sds_t`)

## Usage in Implementation

The header is used in the implementation file (`metrics.c`) to:

1. Declare the initialization function for metrics endpoints
2. Declare the helper function for generating Prometheus HELP text
3. Define the interface for integrating with Fluent Bit's HTTP server framework

## Integration with Fluent Bit HTTP Server

The metrics endpoints integrate with the Fluent Bit HTTP server as follows:

1. **Registration**: The endpoints are registered during HTTP server initialization
2. **Message Queue**: Uses Monkey's message queue system to receive metrics data
3. **HTTP Endpoints**: Exposed at standard REST API paths
4. **Data Format**: Supports multiple output formats (JSON, Prometheus)
5. **Resource Management**: Properly cleans up resources during shutdown