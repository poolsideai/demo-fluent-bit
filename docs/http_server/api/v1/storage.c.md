# http_server/api/v1/storage.c

## Overview

The `http_server/api/v1/storage.c` file implements the storage metrics endpoint for Fluent Bit's HTTP server API. This endpoint provides information about the storage subsystem, including metrics related to chunk storage, memory usage, and disk space utilization.

The implementation uses a message queue system to receive storage metrics data and makes it available via an HTTP endpoint in JSON format. It maintains thread-local buffers to store recent metrics snapshots for efficient retrieval.

## Key Functions

### Storage Metrics Endpoint Handler

```c
static void cb_storage(mk_request_t *request, void *data)
```

Handles requests to the storage metrics endpoint:
- Retrieves the latest storage metrics buffer
- Returns metrics data in JSON format with appropriate content type
- Manages reference counting to prevent premature deallocation

### Storage Metrics Message Queue Callback

```c
static void cb_mq_storage_metrics(mk_mq_t *queue, void *data, size_t size)
```

Processes incoming storage metrics data from the message queue:
- Converts MessagePack data to JSON format
- Stores metrics in thread-local buffers
- Manages memory allocation and cleanup
- Maintains a queue of recent metrics snapshots

### Storage Metrics Endpoint Registration

```c
int api_v1_storage_metrics(struct flb_hs *hs)
```

Registers the storage metrics endpoint with the HTTP server:
- Creates pthread key for thread-local storage
- Sets up message queue for metrics reception
- Registers HTTP endpoint at `/api/v1/storage`

## Important Variables

### Thread-Local Storage Key

```c
pthread_key_t hs_storage_metrics_key;
```

A pthread key used for thread-local storage of storage metrics buffers, ensuring each HTTP worker thread maintains its own metrics queue.

### Storage Metrics Buffer Structure

While not explicitly defined in this file, the implementation uses a buffer structure (defined in the implementation) to store storage metrics data:

- `users`: Reference count to manage concurrent access
- `data`: JSON-formatted storage metrics data
- `raw_data`: Raw MessagePack storage metrics data
- `raw_size`: Size of raw metrics data
- `_head`: Linked list head for queue management

## Dependencies

This file depends on:

1. **Fluent Bit Core**: Provides core data structures, utilities, and storage subsystem
2. **Monkey HTTP Server**: Provides HTTP server functionality and message queues
3. **MessagePack**: For parsing and converting storage metrics data
4. **String Data Structures**: For handling serialized data (`flb_sds_t`)

## Implementation Details

### Storage Metrics Data Flow

The storage metrics system works as follows:

1. **Data Reception**: Storage metrics are received through a message queue
2. **Data Conversion**: MessagePack data is converted to JSON format for storage
3. **Buffer Management**: Recent metrics snapshots are maintained in thread-local queues
4. **Memory Management**: Reference counting prevents premature deallocation of buffers
5. **Cleanup**: Old metrics data is periodically cleaned up to manage memory usage

### Thread Safety

The implementation ensures thread safety through:

- Thread-local storage for metrics buffers
- Reference counting to manage concurrent access
- Proper cleanup of thread-local data using pthread key destructors

### Memory Management

Memory management is handled through:

- Manual allocation and deallocation of metrics buffers
- Thread-local storage cleanup via pthread key destructors
- Reference counting to prevent premature deallocation
- Periodic cleanup of old metrics data

## Configuration

The storage metrics endpoint is conditionally available based on the `storage_metrics` configuration option. When enabled, it provides detailed information about the storage subsystem.

## Usage Examples

### Retrieving Storage Metrics

```bash
# Get storage metrics information
curl http://localhost:2020/api/v1/storage
```

Response:
```json
{
  "storage": {
    "chunks": {
      "total": 15,
      "bytes": 1024000
    },
    "memory": {
      "used": 512000,
      "limit": 1048576
    },
    "disk": {
      "used": 2048000,
      "limit": 5242880
    }
  }
}
```

### Configuration Example

```ini
[SERVICE]
    HTTP_Server On
    HTTP_Listen 0.0.0.0
    HTTP_Port 2020
    Storage_Metrics On
```

With this configuration, the storage metrics endpoint is available at `/api/v1/storage`.

## Integration with Fluent Bit

The storage metrics endpoint integrates with Fluent Bit as follows:

1. **Registration**: Registered during HTTP server initialization via `api_v1_storage_metrics()`
2. **Metrics Flow**: Receives storage metrics data through Fluent Bit's storage subsystem
3. **Endpoint Exposure**: Exposed at the standard REST API path `/api/v1/storage`
4. **Data Format**: Returns information in JSON format for easy consumption
5. **Resource Management**: Properly manages memory during request processing