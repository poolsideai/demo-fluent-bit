# http_server/api/v1/register.h

## Overview

The `http_server/api/v1/register.h` file defines the public interface for the v1 API registration functionality in Fluent Bit's HTTP server. This header file declares the function that coordinates the registration of all v1 API endpoints.

The header provides declarations for the central registration function that orchestrates the registration of individual v1 API endpoints.

## Key Functions

### API Registration Coordinator

```c
int api_v1_registration(struct flb_hs *hs);
```

Central registration function that coordinates the registration of all v1 API endpoints:
- Registers the uptime endpoint
- Registers the metrics endpoints
- Registers the plugins endpoint
- Conditionally registers the trace endpoint (when chunk tracing is enabled)
- Conditionally registers the health check endpoint (when health checking is enabled)
- Conditionally registers the storage metrics endpoint (when storage metrics are enabled)

## Dependencies

This header file depends on:

1. **Fluent Bit Core**: Provides core data structures and HTTP server interfaces

## Usage in Implementation

The header is used in the implementation file (`register.c`) to:

1. Declare the central registration function
2. Define the interface for integrating with Fluent Bit's HTTP server framework
3. Coordinate the registration of all v1 API endpoints

## Integration with Fluent Bit HTTP Server

The registration system integrates with the Fluent Bit HTTP server as follows:

1. **Initialization**: Called during HTTP server initialization
2. **Endpoint Coordination**: Central point for registering all v1 API endpoints
3. **Feature Management**: Handles conditional registration based on configuration
4. **Resource Management**: Delegates resource management to individual endpoint modules
5. **Error Propagation**: Returns success/failure status for overall registration