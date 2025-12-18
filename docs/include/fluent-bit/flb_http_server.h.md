# include/fluent-bit/flb_http_server.h

## Overview

The `flb_http_server.h` file is the main header file for Fluent Bit's HTTP server functionality. This header serves as the primary interface for including HTTP server components in the Fluent Bit codebase.

## Header Guards

```c
#ifndef FLB_HTTP_SERVER_H
#define FLB_HTTP_SERVER_H

/* ... */

#endif
```

Standard header guards prevent multiple inclusion of the header file.

## Conditional Compilation

```c
#ifdef FLB_HAVE_HTTP_SERVER

/* ... */

#endif /* !FLB_HAVE_HTTP_SERVER */
```

The HTTP server functionality is conditionally compiled based on the `FLB_HAVE_HTTP_SERVER` macro. This allows the HTTP server to be enabled or disabled at build time.

## Included Headers

### `http_server/flb_hs.h`

Includes the main HTTP server implementation header which provides:
- Core HTTP server data structures
- Main interface functions for creating and managing HTTP servers
- Integration with Fluent Bit's event loop system

### `http_server/flb_hs_utils.h`

Includes utility functions for HTTP server operations:
- Content type handling functions
- Helper functions for HTTP response generation
- Utility functions for HTTP server operations

### `http_server/flb_hs_endpoints.c`

Includes endpoint management functions:
- Functions for creating and managing HTTP endpoint data
- Pre-formatted response buffer management
- Endpoint initialization and cleanup functions

## Dependencies

This header depends on:

1. **Fluent Bit Core**: For basic types and configuration
2. **HTTP Server Implementation**: For all HTTP server functionality

## Usage

To use the HTTP server functionality in Fluent Bit code:

```c
#include <fluent-bit/flb_http_server.h>

// All HTTP server functions and data structures are now available
```

## Build Configuration

The HTTP server functionality is controlled by the `FLB_HAVE_HTTP_SERVER` macro:

1. **Enabled**: When `FLB_HAVE_HTTP_SERVER` is defined, all HTTP server headers are included
2. **Disabled**: When `FLB_HAVE_HTTP_SERVER` is not defined, the HTTP server functionality is excluded from the build

## Integration Points

This header integrates with the broader Fluent Bit codebase by:

1. **Providing Unified Interface**: Single header for all HTTP server functionality
2. **Conditional Compilation**: Allows HTTP server to be optional at build time
3. **Modular Design**: Separates HTTP server components into logical modules

## Related Components

The HTTP server functionality consists of several key components:

### Core Server (`flb_hs.c`)

- Main HTTP server implementation
- Session management
- Protocol version handling
- Integration with Fluent Bit's event loop

### Utilities (`flb_hs_utils.c`)

- Content type handling
- Response header management
- Utility functions for HTTP operations

### Endpoints (`flb_hs_endpoints.c`)

- Pre-formatted response generation
- Endpoint data management
- Static content serving

### Protocol Implementations

- HTTP/1.x support (`flb_http_server_http1.c`)
- HTTP/2 support (`flb_http_server_http2.c`)
- Protocol autodetection

## Configuration Integration

The HTTP server integrates with Fluent Bit's configuration system:

1. **Runtime Configuration**: Reads HTTP server settings from Fluent Bit configuration
2. **Feature Flags**: Can be enabled/disabled through build configuration
3. **Network Settings**: Integrates with Fluent Bit's networking configuration

## Event Loop Integration

The HTTP server integrates with Fluent Bit's event loop system:

1. **Asynchronous Operations**: Non-blocking HTTP server operations
2. **Event Registration**: Proper registration of HTTP server events
3. **Resource Management**: Integration with Fluent Bit's resource management

## Security Considerations

The HTTP server implementation includes several security features:

1. **Conditional Compilation**: HTTP server can be completely disabled
2. **Buffer Limits**: Enforces maximum buffer sizes to prevent DoS attacks
3. **Input Validation**: Validates all HTTP input
4. **Resource Limits**: Enforces reasonable resource usage limits

## Thread Safety

The HTTP server implementation is designed to be thread-safe:

1. **Reentrant Functions**: No static or global state
2. **Immutable Parameters**: Functions don't modify input parameters
3. **Session Isolation**: Each connection has isolated resources
4. **Event Loop Integration**: Uses Fluent Bit's thread-safe event system

## Performance Characteristics

The HTTP server is optimized for performance:

1. **Asynchronous I/O**: Non-blocking operations
2. **Efficient Memory**: Reuses buffers where possible
3. **Protocol Optimization**: HTTP/2 multiplexing
4. **Event-Driven**: Minimal CPU usage when idle

## Extensibility

The design allows for easy extension:

1. **New Protocols**: Can add support for additional HTTP versions
2. **Custom Handlers**: Request callback allows custom processing
3. **Feature Flags**: Server flags enable optional features
4. **Buffer Management**: Configurable buffer sizes

## Resource Management

The HTTP server carefully manages all resources:

1. **Memory**: Uses Fluent Bit's memory management
2. **File Descriptors**: Proper cleanup of network connections
3. **Event Resources**: Cleans up event registrations
4. **Protocol Resources**: Frees protocol-specific data