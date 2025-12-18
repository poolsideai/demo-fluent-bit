# http_server/api/v1/storage.h

## Overview

The `http_server/api/v1/storage.h` file defines the public interface for the storage metrics functionality in Fluent Bit's HTTP server API. This header file declares the function needed to initialize and register the storage metrics endpoint.

The header provides declarations for the function that registers the storage metrics endpoint with the HTTP server.

## Key Functions

### Storage Metrics Endpoint Registration

```c
int api_v1_storage_metrics(struct flb_hs *hs);
```

Registers the storage metrics endpoint with the HTTP server:
- Creates pthread key for thread-local storage
- Sets up message queue for storage metrics reception
- Registers HTTP endpoint at `/api/v1/storage`

## Dependencies

This header file depends on:

1. **Fluent Bit Core**: Provides core data structures and HTTP server interfaces

## Usage in Implementation

The header is used in the implementation file (`storage.c`) to:

1. Declare the registration function for the storage metrics endpoint
2. Define the interface for integrating with Fluent Bit's HTTP server framework

## Integration with Fluent Bit HTTP Server

The storage metrics endpoint integrates with the Fluent Bit HTTP server as follows:

1. **Registration**: The endpoint is registered during HTTP server initialization
2. **Message Queue**: Uses Monkey's message queue system to receive storage metrics data
3. **HTTP Endpoint**: Exposed at the standard REST API path `/api/v1/storage`
4. **Data Format**: Returns information in JSON format for easy consumption
5. **Resource Management**: Properly manages resources during request processing