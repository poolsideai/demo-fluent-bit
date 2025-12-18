# Uptime API Header (v1)

## Overview

This header file declares the public interface for the v1 Uptime API implementation in Fluent Bit's HTTP server. It provides the function prototype for registering the uptime API endpoint with the HTTP server.

## Key Functions

### `api_v1_uptime(struct flb_hs *hs)`

Registers the uptime API endpoint with the HTTP server:
- `/api/v1/uptime` - Returns uptime information

Parameters:
- `hs`: Pointer to the HTTP server context

Returns:
- 0 on success

## Dependencies

- Includes `flb_info.h` for basic Fluent Bit definitions
- Includes `flb_http_server.h` for HTTP server structures

## Implementation Details

This header is included by the HTTP server initialization code to register the uptime API endpoint. The actual implementation is in `uptime.c`.