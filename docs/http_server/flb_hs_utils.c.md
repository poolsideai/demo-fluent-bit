# http_server/flb_hs_utils.c

## Overview

The `flb_hs_utils.c` file contains utility functions for the Fluent Bit HTTP server. This file provides helper functions that simplify common tasks such as setting HTTP response headers, particularly content type headers for different response formats.

## Key Functions

### Main Utility Function

#### `flb_hs_add_content_type_to_req`

```c
int flb_hs_add_content_type_to_req(mk_request_t *request, int type)
```

Adds a Content-Type HTTP header to a Monkey HTTP request based on the specified content type.

**Parameters:**
- `request`: Monkey HTTP request context
- `type`: Content type identifier (see constants below)

**Returns:**
- 0 on success
- -1 on failure (invalid request or unknown content type)

**Implementation Details:**
1. Validates that the request pointer is not NULL
2. Uses a switch statement to handle different content types
3. Calls `mk_http_header()` to set the appropriate Content-Type header
4. Logs an error and returns -1 for unknown content types

**Supported Content Types:**

| Type Constant | Value | Content-Type Header |
|---------------|-------|---------------------|
| `FLB_HS_CONTENT_TYPE_JSON` | 1 | `application/json` |
| `FLB_HS_CONTENT_TYPE_PROMETHEUS` | 2 | `text/plain; version=0.0.4` |

## Dependencies

This module depends on:

1. **Fluent Bit Core**: For logging functionality and HTTP server constants
2. **Monkey HTTP Server Library**: For HTTP request manipulation
3. **Standard C Library**: For basic operations

## Implementation Details

### Error Handling

The implementation follows robust error handling practices:

1. **Null Pointer Check**: Validates that the request parameter is not NULL
2. **Unknown Type Handling**: Logs an error and returns -1 for unsupported content types
3. **Function Return Values**: Uses standard Fluent Bit return value conventions

### Performance Considerations

The function is designed for optimal performance:

1. **Direct Header Setting**: Uses Monkey's direct header setting API
2. **Minimal Processing**: Simple switch statement with no complex logic
3. **Constant Time Operations**: O(1) execution regardless of content type

### Thread Safety

The utility function is thread-safe:

1. **Reentrant Design**: No static or global state
2. **Immutable Parameters**: Only reads from input parameters
3. **Stateless Operation**: No side effects beyond setting headers

## Content Type Constants

The file works with the following content type constants defined elsewhere:

### `FLB_HS_CONTENT_TYPE_JSON`

- **Value**: 1
- **Purpose**: Sets Content-Type to `application/json`
- **Usage**: For JSON formatted responses

### `FLB_HS_CONTENT_TYPE_PROMETHEUS`

- **Value**: 2
- **Purpose**: Sets Content-Type to `text/plain; version=0.0.4`
- **Usage**: For Prometheus metrics formatted responses

## Integration with HTTP Server

The utility function integrates with the HTTP server components as follows:

1. **Endpoint Handlers**: Called by individual endpoint handlers to set response headers
2. **Content Negotiation**: Used to signal the format of the response body
3. **API Consistency**: Ensures consistent Content-Type headers across all endpoints

## Usage Examples

The function is typically used in endpoint handlers like this:

```c
void my_endpoint_handler(mk_request_t *request, void *data)
{
    // Set JSON content type
    flb_hs_add_content_type_to_req(request, FLB_HS_CONTENT_TYPE_JSON);
    
    // Send JSON response
    mk_http_status(request, 200);
    mk_http_send(request, json_data, json_size, NULL);
    mk_http_done(request);
}
```

For Prometheus metrics:

```c
void metrics_endpoint_handler(mk_request_t *request, void *data)
{
    // Set Prometheus content type
    flb_hs_add_content_type_to_req(request, FLB_HS_CONTENT_TYPE_PROMETHEUS);
    
    // Send Prometheus metrics
    mk_http_status(request, 200);
    mk_http_send(request, metrics_data, metrics_size, NULL);
    mk_http_done(request);
}
```

## Error Conditions

The function returns an error (-1) in the following conditions:

1. **NULL Request**: When the request parameter is NULL
2. **Unknown Type**: When the content type parameter doesn't match known values

## Logging

Error conditions are logged using Fluent Bit's error logging facility:

```c
flb_error("[%s] unknown type=%d", __FUNCTION__, type);
```

## Extensibility

The design allows for easy extension with new content types:

1. **Add New Constants**: Define new content type constants
2. **Extend Switch Statement**: Add new cases to the switch statement
3. **Update Documentation**: Document new content types

Example of adding a new content type:

```c
case FLB_HS_CONTENT_TYPE_XML:
    mk_http_header(request,
                   FLB_HS_CONTENT_TYPE_KEY_STR, FLB_HS_CONTENT_TYPE_KEY_LEN,
                   FLB_HS_CONTENT_TYPE_XML_STR, FLB_HS_CONTENT_TYPE_XML_LEN);
    break;
```

## Performance Characteristics

The utility function has excellent performance characteristics:

1. **Constant Time**: O(1) execution time
2. **Minimal Memory**: No dynamic allocations
3. **Low Overhead**: Direct API calls to Monkey HTTP server
4. **Cache Friendly**: No complex data structures

## Security Considerations

The implementation includes basic security measures:

1. **Input Validation**: Checks for NULL request parameter
2. **Type Validation**: Ensures only known content types are processed
3. **No Buffer Operations**: Doesn't handle user-controlled data directly

## API Design Principles

The utility function follows these design principles:

1. **Simplicity**: Single responsibility - only sets content type headers
2. **Consistency**: Uses same pattern for all content types
3. **Extensibility**: Easy to add new content types
4. **Error Handling**: Clear error reporting and return values
5. **Documentation**: Well-documented parameters and return values