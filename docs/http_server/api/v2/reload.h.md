# Reload API Header (v2)

## Overview

This header file declares the public interface for the v2 Reload API implementation in Fluent Bit's HTTP server. It provides the function prototype for registering the reload API endpoint with the HTTP server.

## Key Functions

### `api_v2_reload(struct flb_hs *hs)`

Registers the reload API endpoint with the HTTP server:
- `/api/v2/reload` - Triggers configuration reload or returns reload status

Parameters:
- `hs`: Pointer to the HTTP server context

Returns:
- 0 on success

## Dependencies

- Includes `flb_info.h` for basic Fluent Bit definitions
- Includes `flb_http_server.h` for HTTP server structures

## Implementation Details

This header is included by the HTTP server initialization code to register the reload API endpoint. The actual implementation is in `reload.c`.