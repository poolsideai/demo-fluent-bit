# http_server/api/v1/register.c

## Overview

The `http_server/api/v1/register.c` file implements the registration mechanism for Fluent Bit's HTTP server v1 API endpoints. This file serves as the central coordinator that registers all the individual v1 API endpoints with the HTTP server.

The implementation provides a single function that orchestrates the registration of all v1 API endpoints based on configuration settings and compile-time features.

## Key Functions

### API Registration Coordinator

```c
int api_v1_registration(struct flb_hs *hs)
```

Central registration function that coordinates the registration of all v1 API endpoints:
- Registers the uptime endpoint
- Registers the metrics endpoints
- Registers the plugins endpoint
- Conditionally registers the trace endpoint (when chunk tracing is enabled)
- Conditionally registers the health check endpoint (when health checking is enabled)
- Conditionally registers the storage metrics endpoint (when storage metrics are enabled)

## Implementation Details

### Conditional Registration

The registration process includes conditional logic for feature-specific endpoints:

1. **Trace Endpoint**: Only registered when `FLB_HAVE_CHUNK_TRACE` is defined
2. **Health Check Endpoint**: Only registered when `hs->config->health_check` is `FLB_TRUE`
3. **Storage Metrics Endpoint**: Only registered when `hs->config->storage_metrics` is `FLB_TRUE`

### Registration Order

Endpoints are registered in the following order:
1. Uptime endpoint
2. Metrics endpoints
3. Plugins endpoint
4. Trace endpoint (conditional)
5. Health check endpoint (conditional)
6. Storage metrics endpoint (conditional)

### Error Handling

The registration function returns 0 on successful registration of all applicable endpoints. Individual endpoint registration functions are expected to handle their own error conditions.

## Dependencies

This file depends on:

1. **Fluent Bit Core**: Provides core data structures and HTTP server interfaces
2. **v1 API Modules**: Includes all individual v1 API endpoint implementations
3. **Conditional Compilation**: Uses preprocessor directives for feature-specific endpoints

## Configuration

The registration behavior is influenced by the following configuration settings:

- **Health Check**: Enabled via `health_check` configuration option
- **Storage Metrics**: Enabled via `storage_metrics` configuration option
- **Chunk Tracing**: Enabled via compile-time `FLB_HAVE_CHUNK_TRACE` definition

## Usage Examples

### Configuration Example

```ini
[SERVICE]
    HTTP_Server On
    HTTP_Listen 0.0.0.0
    HTTP_Port 2020
    Health_Check On
    Storage_Metrics On
```

With this configuration, the following endpoints would be registered:
- `/api/v1/uptime`
- `/api/v1/metrics` and `/api/v1/metrics/prometheus`
- `/api/v1/plugins`
- `/api/v1/health`
- `/api/v1/storage`

### Compile-Time Features

If compiled with chunk tracing support:
```bash
cmake -DFLB_CHUNK_TRACE=On .
```

The trace endpoint would also be registered at `/api/v1/trace`.

## Integration with Fluent Bit

The registration system integrates with Fluent Bit as follows:

1. **Initialization**: Called during HTTP server initialization
2. **Endpoint Coordination**: Central point for registering all v1 API endpoints
3. **Feature Management**: Handles conditional registration based on configuration
4. **Resource Management**: Delegates resource management to individual endpoint modules
5. **Error Propagation**: Returns success/failure status for overall registration