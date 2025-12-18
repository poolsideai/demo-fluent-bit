# http_server/flb_hs_endpoints.c

## Overview

The `flb_hs_endpoints.c` file contains the implementation for HTTP server endpoint data generation and management. This file is responsible for creating and maintaining the pre-formatted response buffers used by various HTTP endpoints, particularly the root endpoint that provides information about the Fluent Bit instance.

## Key Functions

### Main Interface Functions

#### `flb_hs_endpoints`

```c
int flb_hs_endpoints(struct flb_hs *hs)
```

Initializes endpoint-specific data for the HTTP server. This function is called during HTTP server creation to set up pre-formatted response buffers.

**Parameters:**
- `hs`: HTTP server context

**Returns:**
- 0 on success
- Negative value on failure

**Implementation Details:**
1. Calls `endpoint_root()` to create the root endpoint response buffer
2. Returns success status

#### `flb_hs_endpoints_free`

```c
int flb_hs_endpoints_free(struct flb_hs *hs)
```

Releases cached data from HTTP endpoints to free memory resources.

**Parameters:**
- `hs`: HTTP server context

**Returns:**
- 0 on success

**Implementation Details:**
1. Frees the root endpoint response buffer if it exists
2. Returns success status

### Internal Endpoint Functions

#### `endpoint_root`

```c
static int endpoint_root(struct flb_hs *hs)
```

Creates a JSON buffer with informational data about the running Fluent Bit service. This buffer is used to respond to requests to the HTTP server root path.

**Parameters:**
- `hs`: HTTP server context

**Returns:**
- Always returns -1 (indicating the buffer was created)

**Implementation Details:**
1. Initializes MessagePack buffers for efficient data serialization
2. Creates a structured data representation of Fluent Bit information:
   - Version information
   - Edition (Community vs Enterprise)
   - Build flags
3. Serializes the data to JSON format using Fluent Bit's MessagePack utilities
4. Stores the resulting buffer in the HTTP server context for later use
5. Returns -1 to indicate successful creation

**Data Structure:**
The root endpoint response contains a JSON object with the following structure:

```json
{
  "fluent-bit": {
    "version": "x.x.x",
    "edition": "Community|Enterprise",
    "flags": [
      "FLB_FLAG1",
      "FLB_FLAG2",
      ...
    ]
  }
}
```

## Dependencies

This module depends on:

1. **Fluent Bit Core**: For memory management, string utilities, and version information
2. **MessagePack**: For efficient data serialization
3. **HTTP Server Context**: To store and manage endpoint response buffers
4. **Standard C Library**: For basic string and memory operations

## Implementation Details

### Memory Management

The implementation follows Fluent Bit's memory management conventions:

1. Uses `flb_calloc()` for memory allocation
2. Uses `flb_sds_destroy()` for freeing string buffers
3. Includes proper error checking for memory operations
4. Cleans up resources in error paths

### Data Serialization

The module uses MessagePack for efficient data serialization:

1. Creates MessagePack buffers using `msgpack_sbuffer_init()`
2. Initializes a MessagePack packer using `msgpack_packer_init()`
3. Packs structured data using MessagePack API functions
4. Converts MessagePack to JSON using `flb_msgpack_raw_to_json_sds()`

### Performance Optimization

The design optimizes for performance by:

1. Pre-formatting response data during initialization
2. Avoiding repeated serialization during HTTP requests
3. Using efficient MessagePack serialization
4. Caching response buffers for reuse

## Integration with HTTP Server

The endpoint functions integrate with the HTTP server as follows:

1. **Initialization**: `flb_hs_endpoints()` is called during HTTP server creation (`flb_hs_create()`)
2. **Usage**: Pre-formatted buffers are used by endpoint handlers (like `cb_root()` in `flb_hs.c`)
3. **Cleanup**: `flb_hs_endpoints_free()` is called during HTTP server destruction (`flb_hs_destroy()`)

## Data Content

The root endpoint provides information about the running Fluent Bit instance:

### Version Information

- **Field**: `version`
- **Content**: Current Fluent Bit version string
- **Source**: `FLB_VERSION_STR` macro

### Edition Information

- **Field**: `edition`
- **Content**: "Community" or "Enterprise" depending on build configuration
- **Source**: Conditional compilation with `FLB_ENTERPRISE` macro

### Build Flags

- **Field**: `flags`
- **Content**: Array of build-time feature flags
- **Source**: `FLB_INFO_FLAGS` macro, filtered to include only FLB_* flags

## Memory Layout

The HTTP server context stores endpoint data in the following fields:

- `ep_root_buf`: Pre-formatted JSON response buffer for root endpoint
- `ep_root_size`: Size of the root endpoint response buffer

These buffers are managed throughout the HTTP server lifecycle:

1. **Creation**: Allocated and populated during `flb_hs_endpoints()`
2. **Usage**: Referenced by endpoint handlers during HTTP requests
3. **Destruction**: Freed during `flb_hs_endpoints_free()`

## Error Handling

The implementation handles errors gracefully:

1. Memory allocation failures are checked and handled
2. Resource cleanup is performed in error paths
3. Functions return appropriate error codes
4. Logging is used for debugging purposes

## Thread Safety

The endpoint data is designed to be thread-safe:

1. Data is created during initialization (single-threaded)
2. Data is read-only during HTTP request handling
3. No mutable state is shared between requests
4. Cleanup occurs during shutdown (single-threaded)

## Extensibility

The design allows for easy extension:

1. New endpoint data can be added by extending `flb_hs_endpoints()`
2. Additional buffers can be added to the HTTP server context
3. New serialization formats can be supported
4. Conditional compilation can be used for optional features

## Usage Examples

The root endpoint response can be accessed via HTTP GET request:

```bash
curl http://localhost:2020/
```

Expected response:

```json
{
  "fluent-bit": {
    "version": "1.9.0",
    "edition": "Community",
    "flags": [
      "FLB_HAVE_TLS",
      "FLB_HAVE_ZLIB",
      "FLB_HAVE_SQLDB"
    ]
  }
}
```

## Performance Characteristics

The endpoint implementation is optimized for:

1. **Low Latency**: Pre-formatted responses avoid runtime serialization
2. **Memory Efficiency**: Single buffer allocation per endpoint
3. **CPU Efficiency**: Minimal processing during HTTP requests
4. **Scalability**: Thread-safe design supports concurrent requests

## Configuration Impact

The endpoint data reflects the Fluent Bit build configuration:

1. **Version**: Matches the compiled version
2. **Edition**: Depends on build flags
3. **Flags**: Shows available features at compile time
4. **Availability**: Only present when HTTP server is enabled