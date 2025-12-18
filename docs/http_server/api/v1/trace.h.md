# Trace API Header (v1)

## Overview

This header file declares the public interface for the v1 Trace API implementation in Fluent Bit's HTTP server. It provides the function prototype for registering the trace API endpoints with the HTTP server.

## Key Functions

### `api_v1_trace(struct flb_hs *hs)`

Registers the trace API endpoints with the HTTP server:
- `/api/v1/trace/{input_name}` - Individual input trace management
- `/api/v1/traces/` - Bulk trace operations

Parameters:
- `hs`: Pointer to the HTTP server context

Returns:
- 0 on success

## Dependencies

- Includes `flb_info.h` for basic Fluent Bit definitions
- Includes `flb_http_server.h` for HTTP server structures

## Implementation Details

This header is included by the HTTP server initialization code to register the trace API endpoints. The actual implementation is in `trace.c`.