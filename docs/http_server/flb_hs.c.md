# http_server/flb_hs.c

## Overview

The `flb_hs.c` file contains the main implementation of the Fluent Bit HTTP server functionality. This file provides the core API for creating, starting, and managing the HTTP server that exposes Fluent Bit's monitoring and control endpoints.

## Key Functions

### Main Interface Functions

#### `flb_hs_create`

```c
struct flb_hs *flb_hs_create(const char *listen, const char *tcp_port,
                             struct flb_config *config)
```

Creates and initializes a new HTTP server instance with the specified network configuration.

**Parameters:**
- `listen`: Network interface to bind to (e.g., "0.0.0.0" or "127.0.0.1")
- `tcp_port`: TCP port number to listen on
- `config`: Fluent Bit configuration context

**Returns:**
- Pointer to new HTTP server context on success
- NULL on failure

**Implementation Details:**
1. Allocates memory for the HTTP server context
2. Sets up endpoint-specific data buffers
3. Creates Monkey HTTP server context
4. Configures network binding address
5. Creates virtual host for Fluent Bit
6. Registers API endpoints for both v1 and v2
7. Sets up root endpoint handler

#### `flb_hs_start`

```c
int flb_hs_start(struct flb_hs *hs)
```

Starts the HTTP server to begin accepting connections.

**Parameters:**
- `hs`: HTTP server context

**Returns:**
- 0 on success
- Negative value on failure

**Implementation Details:**
1. Starts the Monkey HTTP server event loop
2. Logs successful startup with interface and port information

#### `flb_hs_destroy`

```c
int flb_hs_destroy(struct flb_hs *hs)
```

Shuts down and destroys the HTTP server instance.

**Parameters:**
- `hs`: HTTP server context

**Returns:**
- 0 on success

**Implementation Details:**
1. Destroys health endpoint resources
2. Stops the Monkey HTTP server
3. Cleans up Monkey context
4. Frees endpoint data buffers
5. Releases HTTP server context memory

### Metrics Push Functions

#### `flb_hs_push_health_metrics`

```c
int flb_hs_push_health_metrics(struct flb_hs *hs, void *data, size_t size)
```

Pushes health metrics data to the HTTP server context through a message queue.

**Parameters:**
- `hs`: HTTP server context
- `data`: Health metrics data buffer
- `size`: Size of the data buffer

**Returns:**
- 0 on success
- Negative value on failure

#### `flb_hs_push_pipeline_metrics`

```c
int flb_hs_push_pipeline_metrics(struct flb_hs *hs, void *data, size_t size)
```

Pushes pipeline metrics data to the HTTP server context through a message queue.

**Parameters:**
- `hs`: HTTP server context
- `data`: Pipeline metrics data buffer
- `size`: Size of the data buffer

**Returns:**
- 0 on success
- Negative value on failure

#### `flb_hs_push_metrics`

```c
int flb_hs_push_metrics(struct flb_hs *hs, void *data, size_t size)
```

Pushes general metrics data to the HTTP server context through a message queue (v2 API).

**Parameters:**
- `hs`: HTTP server context
- `data`: Metrics data buffer
- `size`: Size of the data buffer

**Returns:**
- 0 on success
- Negative value on failure

#### `flb_hs_push_storage_metrics`

```c
int flb_hs_push_storage_metrics(struct flb_hs *hs, void *data, size_t size)
```

Pushes storage metrics data to the HTTP server context through a message queue.

**Parameters:**
- `hs`: HTTP server context
- `data`: Storage metrics data buffer
- `size`: Size of the data buffer

**Returns:**
- 0 on success
- Negative value on failure

### Internal Helper Functions

#### `cb_root`

```c
static void cb_root(mk_request_t *request, void *data)
```

Root endpoint callback that serves the initial JSON response when accessing the HTTP server root path.

**Parameters:**
- `request`: Monkey HTTP request context
- `data`: HTTP server context data

**Implementation Details:**
1. Sets HTTP status to 200 (OK)
2. Adds JSON content type header
3. Sends pre-formatted root response buffer
4. Completes the HTTP request

## Data Structures

### `struct flb_hs`

The main HTTP server context structure that holds all necessary state information.

**Fields:**
- `ctx`: Monkey HTTP server context
- `vid`: Virtual host identifier
- `config`: Fluent Bit configuration context
- `ep_root_buf`: Pre-formatted root endpoint response buffer
- `ep_root_size`: Size of root endpoint response buffer
- Various message queue identifiers for different metric types

## Dependencies

This module depends on:

1. **Monkey HTTP Server Library**: Provides the underlying HTTP server functionality
2. **Fluent Bit Core**: Accesses configuration and internal state
3. **API Endpoint Modules**: Links with v1 and v2 API implementations
4. **Standard C Library**: Memory allocation, string formatting, etc.

## Implementation Details

### Architecture

The HTTP server follows a layered architecture:

1. **Core Layer**: `flb_hs.c` provides the main interface and lifecycle management
2. **Monkey Integration**: Uses Monkey HTTP server as the underlying transport
3. **API Layers**: Separate modules for v1 and v2 REST APIs
4. **Endpoint Handlers**: Individual functions for each API endpoint

### Message Queue Integration

The server uses Monkey's message queue system to communicate between:

- Fluent Bit core components that generate metrics
- HTTP server endpoints that serve the metrics

This design allows asynchronous communication and prevents blocking of the HTTP server thread.

### API Versioning

The server supports both v1 and v2 APIs through separate registration functions:

- `api_v1_registration()`: Registers all v1 endpoints
- `api_v2_registration()`: Registers all v2 endpoints

### Error Handling

The implementation follows Fluent Bit's error handling conventions:

1. Memory allocation failures are checked and handled gracefully
2. Monkey library errors are logged appropriately
3. Function failures return negative values or NULL pointers
4. Resource cleanup is performed in error paths

## Usage in Fluent Bit

The HTTP server is typically initialized in the main Fluent Bit startup sequence:

1. Configuration parsing determines if HTTP server should be enabled
2. `flb_hs_create()` is called with configured network settings
3. `flb_hs_start()` begins serving HTTP requests
4. During shutdown, `flb_hs_destroy()` cleans up resources

## Configuration Integration

The HTTP server reads its configuration from the main Fluent Bit configuration:

- `http_listen`: Network interface to bind to
- `http_port`: TCP port to listen on
- `http_server`: Boolean flag to enable/disable the feature

## Security Considerations

The HTTP server implementation includes:

1. Configurable network binding to limit access
2. Separation of API versions for backward compatibility
3. Integration with Fluent Bit's authentication mechanisms
4. Proper resource cleanup to prevent leaks

## Performance Characteristics

The server is designed for:

1. Low latency response to HTTP requests
2. Efficient memory usage through pre-formatted response buffers
3. Asynchronous metrics updates via message queues
4. Minimal impact on Fluent Bit's core processing pipeline