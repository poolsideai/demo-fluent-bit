# Reload API Implementation (v2)

## Overview

This file implements the HTTP API endpoint for triggering Fluent Bit configuration reloads in the v2 API. The implementation provides a single endpoint that allows users to trigger hot reloads of the Fluent Bit configuration without restarting the service.

The implementation registers one endpoint:
- `/api/v2/reload` - Triggers configuration reload (POST/PUT) or returns reload status (GET)

## Key Functions

### `api_v2_reload(struct flb_hs *hs)`

Main registration function that registers the reload API endpoint with the HTTP server.

### `cb_reload(mk_request_t *request, void *data)`

HTTP callback handler for reload requests. Handles different HTTP methods:
- POST/PUT: Triggers a configuration reload
- GET: Returns reload status information

### `handle_reload_request(mk_request_t *request, struct flb_config *config)`

Processes reload requests by sending appropriate signals to trigger configuration reloading:
- On Unix/Linux: Sends SIGHUP signal to the process
- On Windows: Generates console control event

### `handle_get_reload_status(mk_request_t *request, struct flb_config *config)`

Handles GET requests to return reload status information, including the count of successful hot reloads.

## Important Variables and Constants

None specifically defined in this file, but relies on system constants:
- `SIGHUP`: Unix signal for hangup (configuration reload)
- `CTRL_BREAK_EVENT`: Windows console control event

## Dependencies and Relationships

- Integrates with HTTP server framework through `mk_vhost_handler`
- Uses Fluent Bit configuration structure for reload state management
- Depends on system signal handling for Unix/Linux platforms
- Uses Windows console control events for Windows platforms
- Relies on MessagePack for serializing response data
- Integrates with Fluent Bit's hot reload mechanism

## Notable Implementation Details

1. **Cross-platform Support**: Implements different reload mechanisms for Unix/Linux and Windows
2. **State Management**: Tracks reload status and prevents concurrent reloads
3. **Error Handling**: Comprehensive error handling with appropriate HTTP status codes
4. **Memory Management**: Proper allocation and deallocation of SDS strings
5. **Signal Safety**: Uses appropriate system calls for safe signal generation
6. **Status Reporting**: Provides reload count and status information
7. **Configuration Validation**: Checks if hot reload is enabled before attempting reload

## Usage Examples

### Trigger a configuration reload:
```bash
POST /api/v2/reload
```

### Check reload status:
```bash
GET /api/v2/reload
```

Response:
```json
{
  "hot_reload_count": 5
}
```

### Reload response:
```json
{
  "reload": "done",
  "status": 0
}
```