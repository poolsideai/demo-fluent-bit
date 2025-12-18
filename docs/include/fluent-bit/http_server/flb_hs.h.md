# include/fluent-bit/http_server/flb_hs.h

## Overview

The `flb_hs.h` file contains the header definitions for Fluent Bit's HTTP server main functionality. This header defines the core data structures and function prototypes for the HTTP server implementation that provides monitoring and control endpoints for Fluent Bit instances.

## Header Guards

```c
#ifndef FLB_HS_MAIN_H
#define FLB_HS_MAIN_H

/* ... */

#endif
```

Standard header guards prevent multiple inclusion of the header file.

## Included Dependencies

### Core Fluent Bit Headers

```c
#include <fluent-bit/flb_info.h>
#include <fluent-bit/flb_config.h>
#include <fluent-bit/flb_sds.h>
```

These headers provide essential Fluent Bit functionality for configuration, string handling, and system information.

### External Libraries

```c
#include <monkey/mk_lib.h>
```

This header provides the Monkey HTTP server library which serves as the foundation for Fluent Bit's HTTP server implementation.

## Data Structures

### `struct flb_hs_buf`

Represents a cached buffer for HTTP endpoint data.

**Fields:**

```c
struct flb_hs_buf {
    int users;
    flb_sds_t data;
    void *raw_data;
    size_t raw_size;
    struct mk_list _head;
};
```

**Key Fields:**
- `users`: Number of users referencing this buffer
- `data`: Cached data in SDS format
- `raw_data`: Raw data pointer
- `raw_size`: Size of raw data
- `_head`: List entry for buffer management

### `struct flb_hs`

Main HTTP server context structure that holds all server configuration and state.

**Fields:**

```c
struct flb_hs {
    mk_ctx_t *ctx;             /* Monkey HTTP Context */
    int vid;                   /* Virtual Host ID     */
    int qid_metrics;           /* Metrics Message Queue ID    */
    int qid_metrics_v2;        /* Metrics Message Queue ID for /api/v2 */
    int qid_storage;           /* Storage Message Queue ID    */
    int qid_health;            /* health Message Queue ID    */

    pthread_t tid;             /* Server Thread */
    struct flb_config *config; /* Fluent Bit context */

    /* end-point: root */
    size_t ep_root_size;
    char *ep_root_buf;
};
```

**Key Fields:**
- `ctx`: Monkey HTTP server context
- `vid`: Virtual host identifier
- `qid_metrics`: Message queue ID for metrics data
- `qid_metrics_v2`: Message queue ID for v2 metrics data
- `qid_storage`: Message queue ID for storage data
- `qid_health`: Message queue ID for health data
- `tid`: Server thread identifier
- `config`: Fluent Bit configuration context
- `ep_root_size`: Size of root endpoint response buffer
- `ep_root_buf`: Root endpoint response buffer

## Function Prototypes

### Server Lifecycle Functions

#### `flb_hs_create`

```c
struct flb_hs *flb_hs_create(const char *listen, const char *tcp_port,
                             struct flb_config *config);
```

Creates a new HTTP server instance with the specified network configuration.

**Parameters:**
- `listen`: Network interface to bind to (e.g., "0.0.0.0" or "127.0.0.1")
- `tcp_port`: TCP port number to listen on
- `config`: Fluent Bit configuration context

**Returns:**
- Pointer to new HTTP server context on success
- NULL on failure

#### `flb_hs_destroy`

```c
int flb_hs_destroy(struct flb_hs *ctx);
```
Determines an HTTP server instance and frees all associated resources.

**Parameters:**
- `ctx`: HTTP server context to destroy

**Returns:**
- 0 on success
- Negative value on failure

#### `flb_hs_start`

```c
int flb_hs_start(struct flb_hs *hs);
```

Starts the HTTP server to begin accepting connections.

**Parameters:**
- `hs`: HTTP server context

**Returns:**
- 0 on success
- Negative value on failure

### Metrics Push Functions

#### `flb_hs_push_health_metrics`

```c
int flb_hs_push_health_metrics(struct flb_hs *hs, void *data, size_t size);
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
int flb_hs_push_pipeline_metrics(struct flb_hs *hs, void *data, size_t size);
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
int flb_hs_push_metrics(struct flb_hs *hs, void *data, size_t size);
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
int flb_hs_push_storage_metrics(struct flb_hs *hs, void *data, size_t size);
```

Pushes storage metrics data to the HTTP server context through a message queue.

**Parameters:**
- `hs`: HTTP server context
- `data`: Storage metrics data buffer
- `size`: Size of the data buffer

**Returns:**
- 0 on success
- Negative value on failure

## Dependencies

This header depends on:

1. **Fluent Bit Core**: For memory management, configuration, and string handling
2. **Monkey HTTP Server**: For HTTP server core functionality
3. **POSIX Threads**: For thread management

## Integration with Fluent Bit

The HTTP server integrates with Fluent Bit's core systems:

1. **Configuration**: Reads HTTP server settings from Fluent Bit's configuration
2. **Metrics System**: Integrates with Fluent Bit's metrics collection
3. **Threading**: Uses Fluent Bit's threading model
4. **Memory Management**: Uses Fluent Bit's memory allocation functions
5. **Message Queues**: Uses Fluent Bit's message queue system for asynchronous communication

## Message Queue Integration

The HTTP server uses message queues for asynchronous communication:

1. **Metrics Queue**: `qid_metrics` for general metrics data
2. **V2 Metrics Queue**: `qid_metrics_v2` for v2 API metrics data
3. **Storage Queue**: `qid_storage` for storage metrics data
4. **Health Queue**: `qid_health` for health metrics data

## Thread Safety

The HTTP server implementation is designed to be thread-safe:

1. **Reentrant Functions**: No static or global state
2. **Immutable Parameters**: Functions don't modify input parameters
3. **Session Isolation**: Each connection has isolated resources
4. **Thread Management**: Proper thread creation and cleanup

## Performance Considerations

The HTTP server is optimized for performance:

1. **Asynchronous Communication**: Uses message queues for non-blocking operations
2. **Efficient Memory**: Reuses buffers and caches data where possible
3. **Event-Driven**: Minimal CPU usage when idle
4. **Pre-formatted Responses**: Caches commonly requested data

## Resource Management

The HTTP server carefully manages all resources:

1. **Memory**: Uses Fluent Bit's memory management
2. **Threads**: Proper thread creation and cleanup
3. **Message Queues**: Proper queue management
4. **Network Resources**: Proper cleanup of network connections

## Security Considerations

The HTTP server implementation includes several security features:

1. **Network Binding**: Configurable network interface binding
2. **Buffer Bounds**: Prevents buffer overflows
3. **Resource Limits**: Enforces reasonable size limits
4. **Memory Safety**: Proper cleanup of all resources

## API Endpoints

The HTTP server provides several REST API endpoints:

### Health Endpoint
- **Path**: `/api/v1/health`
- **Method**: GET
- **Purpose**: Health check for the Fluent Bit instance

### Metrics Endpoint
- **Path**: `/api/v1/metrics`
- **Method**: GET
- **Purpose**: Retrieve metrics data from Fluent Bit

### Storage Endpoint
- **Path**: `/api/v1/storage`
- **Method**: GET
- **Purpose**: Information about storage subsystem

### Plugins Endpoint
- **Path**: `/api/v1/plugins`
- **Method**: GET
- **Purpose**: List and information about loaded plugins

### Register Endpoint
- **Path**: `/api/v1/register`
- **Method**: POST
- **Purpose**: Registration and authentication for API access

### Uptime Endpoint
- **Path**: `/api/v1/uptime`
- **Method**: GET
- **Purpose**: System uptime information

### Trace Endpoint (Conditional)
- **Path**: `/api/v1/trace`
- **Method**: Various
- **Purpose**: Chunk tracing for debugging data flow
- **Condition**: Only included when `FLB_CHUNK_TRACE=On`

### Root Endpoint
- **Path**: `/`
- **Method**: GET
- **Purpose**: Basic information about the Fluent Bit instance

## Configuration Integration

The HTTP server integrates with Fluent Bit's configuration system:

1. **Network Settings**: Reads listen address and port from configuration
2. **Feature Flags**: Can be enabled/disabled through build configuration
3. **API Versions**: Supports multiple API versions

## Error Handling

The HTTP server implementation follows robust error handling practices:

1. **Null Pointer Checks**: Validates all input parameters
2. **Resource Cleanup**: Proper cleanup on error conditions
3. **Return Value Conventions**: Uses standard Fluent Bit return value conventions
4. **Logging**: Appropriate error logging

## Extensibility

The design allows for easy extension:

1. **New Endpoints**: Can add support for additional API endpoints
2. **Custom Handlers**: Request callback allows custom processing
3. **Feature Flags**: Server flags enable optional features
4. **Buffer Management**: Configurable cache sizes