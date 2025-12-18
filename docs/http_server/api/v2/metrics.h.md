# Metrics API Header (v2)

## Overview

This header file declares the public interface for the v2 Metrics API implementation in Fluent Bit's HTTP server. It provides the function prototype for registering the metrics API endpoints with the HTTP server.

## Key Functions

### `api_v2_metrics(struct flb_hs *hs)`

Registers the metrics API endpoints with the HTTP server:
- `/api/v2/metrics` - Returns metrics in plain text format
- `/api/v2/metrics/prometheus` - Returns metrics in Prometheus format

Parameters:
- `hs`: Pointer to the HTTP server context

Returns:
- 0 on success

## Dependencies

- Includes `flb_info.h` for basic Fluent Bit definitions
- Includes `flb_http_server.h` for HTTP server structures

## Implementation Details

This header is included by the HTTP server initialization code to register the metrics API endpoints. The actual implementation is in `metrics.c`.