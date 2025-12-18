# API Registration Header (v2)

## Overview

This header file declares the public interface for the v2 API registration implementation in Fluent Bit's HTTP server. It provides the function prototype for registering all v2 API endpoints with the HTTP server.

## Key Functions

### `api_v2_registration(struct flb_hs *hs)`

Registers all v2 API endpoints with the HTTP server:
- Metrics endpoints
- Reload endpoints

Parameters:
- `hs`: Pointer to the HTTP server context

Returns:
- 0 on success

## Dependencies

- Includes `flb_info.h` for basic Fluent Bit definitions
- Includes `flb_http_server.h` for HTTP server structures

## Implementation Details

This header is included by the HTTP server initialization code to register all v2 API endpoints. The actual implementation is in `register.c`.