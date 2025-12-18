# Uptime API Implementation (v1)

## Overview

This file implements the HTTP API endpoint for retrieving Fluent Bit's uptime information. The uptime API provides both raw seconds and human-readable formatted uptime information about how long Fluent Bit has been running.

The implementation registers a single endpoint:
- `/api/v1/uptime` - Returns uptime information in JSON format

## Key Functions

### `api_v1_uptime(struct flb_hs *hs)`

Main registration function that registers the uptime API endpoint with the HTTP server.

### `cb_uptime(mk_request_t *request, void *data)`

HTTP callback handler for uptime requests. Calculates and returns uptime information:
- Raw uptime in seconds since initialization
- Human-readable formatted uptime string

### `uptime_hr(time_t uptime, msgpack_packer *mp_pck)`

Generates a human-readable uptime string with days, hours, minutes, and seconds.

## Important Variables and Constants

- `FLB_UPTIME_ONEDAY`: 86400 seconds (1 day)
- `FLB_UPTIME_ONEHOUR`: 3600 seconds (1 hour)
- `FLB_UPTIME_ONEMINUTE`: 60 seconds (1 minute)

## Dependencies and Relationships

- Integrates with HTTP server framework through `mk_vhost_handler`
- Uses `flb_config` structure to access initialization time
- Uses MessagePack for serializing response data
- Depends on system time functions for calculating uptime

## Notable Implementation Details

1. **Uptime Calculation**: Computes uptime by subtracting initialization time from current time
2. **Human-readable Formatting**: Converts raw seconds to days/hours/minutes/seconds format
3. **Proper Pluralization**: Correctly formats singular/plural forms (e.g., "1 day" vs "2 days")
4. **JSON Response**: Returns structured JSON with both raw and formatted uptime information
5. **Memory Management**: Proper allocation and deallocation of SDS strings

## Usage Example

```bash
GET /api/v1/uptime
```

Response:
```json
{
  "uptime_sec": 12345,
  "uptime_hr": "Fluent Bit has been running: 0 days, 3 hours, 25 minutes and 45 seconds"
}
```