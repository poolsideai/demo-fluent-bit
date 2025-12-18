# flb_http_client_debug.c

## Overview

This file implements debugging functionality for the HTTP client in Fluent Bit. It provides detailed logging of HTTP requests and responses, which is invaluable for troubleshooting network issues and understanding the communication flow between Fluent Bit plugins and external HTTP services.

The module serves as a debugging aid that can be enabled through configuration properties to log various aspects of HTTP communication including request headers, request payloads, response headers, and response payloads.

## Key Functions

### `flb_http_client_debug_setup()`
Configures and enables HTTP client debugging based on configuration properties.

### `flb_http_client_debug_cb()`
Executes registered debugging callbacks for specific HTTP events.

### `flb_http_client_debug_property_is_valid()`
Validates whether a given HTTP debug property is valid and properly configured.

### `flb_http_client_debug_enable()`
Enables debugging for a specific HTTP client instance.

## Important Variables/Constants

### Debug Callbacks
- `_debug.http.request_headers`: Logs outgoing HTTP request headers
- `_debug.http.request_payload`: Logs outgoing HTTP request payload/body
- `_debug.http.response_headers`: Logs incoming HTTP response headers
- `_debug.http.response_payload`: Logs incoming HTTP response payload/body

### Callback Structure
- `struct flb_http_callback`: Defines a debugging callback with a name and function pointer

## Dependencies

- `fluent-bit/flb_http_client_debug.h`: Header file defining the interface
- `fluent-bit/flb_info.h`: Core Fluent Bit information
- `fluent-bit/flb_log.h`: Logging utilities
- `fluent-bit/flb_mem.h`: Memory management
- `fluent-bit/flb_utils.h`: Utility functions
- `fluent-bit/flb_callback.h`: Callback system
- `fluent-bit/flb_http_client.h`: HTTP client interface

## Implementation Details

1. **Callback Registration**: Debug functionality is implemented through a callback system that allows custom debug handlers to be registered.

2. **Configuration Integration**: Debug properties can be enabled through standard Fluent Bit configuration properties.

3. **Selective Logging**: Different aspects of HTTP communication can be logged independently (headers vs. payloads).

4. **Binary Content Detection**: Automatically detects and appropriately handles binary content (like GZIP) in payloads to avoid corrupting logs.

5. **Property Validation**: Validates debug configuration properties to ensure they are properly formatted.

6. **Thread Safety**: Uses Fluent Bit's callback system which handles thread safety appropriately.

## Usage Example

```c
// Enable HTTP debugging in plugin configuration
/*
[OUTPUT]
    Name http
    Match *
    Host example.com
    Port 80
    URI /api/data
    _debug.http.request_headers true
    _debug.http.request_payload true
    _debug.http.response_headers true
    _debug.http.response_payload true
*/

// In plugin code, set up debugging callbacks
struct flb_callback *cb_ctx = flb_callback_create();
struct mk_list *props = get_plugin_properties(); // Get properties from config

// Set up HTTP debugging
flb_http_client_debug_setup(cb_ctx, props);

// Create HTTP client with debugging enabled
struct flb_http_client *c = flb_http_client(u_conn,
                                            FLB_HTTP_POST, "/api/data",
                                            "Hello World", 11,
                                            "example.com", 80,
                                            NULL, FLB_HTTP_11);

// Enable debugging for this client
flb_http_client_debug_enable(c, cb_ctx);

// When making requests, debug callbacks will automatically log details
int ret = flb_http_do(c, &bytes);

// Clean up
flb_http_client_destroy(c);
flb_callback_destroy(cb_ctx);
```