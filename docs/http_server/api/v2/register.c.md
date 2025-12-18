# API Registration Implementation (v2)

## Overview

This file implements the registration function for the v2 HTTP API endpoints in Fluent Bit. It serves as the central registration point that initializes all v2 API components by calling their individual registration functions.

The implementation provides a single function that registers all v2 API endpoints:
- Metrics endpoints (via `api_v2_metrics()`)
- Reload endpoints (via `api_v2_reload()`)

## Key Functions

### `api_v2_registration(struct flb_hs *hs)`

Central registration function that initializes all v2 API endpoints by calling the individual registration functions for each component.

Parameters:
- `hs`: Pointer to the HTTP server context

Returns:
- 0 on success

## Dependencies and Relationships

- Integrates with HTTP server framework through the `flb_hs` structure
- Calls registration functions for individual API components:
  - `api_v2_metrics()` - Registers metrics endpoints
  - `api_v2_reload()` - Registers reload endpoints
- Depends on the HTTP server infrastructure for endpoint registration

## Notable Implementation Details

1. **Centralized Registration**: Single function to register all v2 API endpoints
2. **Modular Design**: Delegates to individual component registration functions
3. **Error Propagation**: Returns error codes from individual registration functions
4. **Future Extensibility**: Easy to add new v2 API components by adding registration calls

## Usage Context

This function is called during HTTP server initialization to set up all v2 API endpoints. It ensures that all v2 API functionality is properly registered and available for HTTP requests.