# flb_storage.c

## Overview

The `flb_storage.c` file implements Fluent Bit's storage layer functionality, which manages persistent data storage for log records. This module provides a unified interface for handling data persistence across different storage backends (memory, filesystem, and ring buffer).

The storage layer is built on top of the Chunk I/O library (`chunkio`), which provides efficient chunk-based storage management. This implementation handles:
- Chunk creation and management
- Data persistence across restarts
- Memory and disk space optimization
- Concurrent access control
- Metrics collection and reporting
- Input plugin integration

Key features:
- Multi-backend storage support (memory, filesystem, ring buffer)
- Automatic chunk lifecycle management
- Integration with Chunk I/O for efficient storage operations
- Real-time metrics collection and reporting
- Configurable synchronization and checksum options
- Backlog processing for pending data

## Key Functions/Components

### Core Data Structures

#### `struct flb_storage_input`
Represents storage context for an input instance:
- `type`: Storage type (filesystem, memory, or ring buffer)
- `stream`: Associated Chunk I/O stream
- `cio`: Chunk I/O context reference

#### `struct flb_storage_metrics`
Storage metrics collection structure:
- `cmt`: CMetrics context for Prometheus-style metrics
- `cmt_chunks`: Total number of chunks gauge
- `cmt_mem_chunks`: Memory chunks gauge
- `cmt_fs_chunks`: Filesystem chunks gauge
- `cmt_fs_chunks_up`: Filesystem chunks in memory gauge
- `cmt_fs_chunks_down`: Filesystem chunks on disk gauge

### Main Functions

#### `flb_storage_create(struct flb_config *ctx)`
Initializes the storage subsystem:
1. Configures Chunk I/O options based on Fluent Bit configuration
2. Creates Chunk I/O context with appropriate flags
3. Sets maximum number of chunks that can be loaded in memory
4. Loads existing chunks from filesystem if applicable
5. Creates storage backlog input plugin for pending data
6. Initializes storage contexts for all input instances
7. Prints storage configuration information

#### `flb_storage_destroy(struct flb_config *ctx)`
Cleans up storage resources:
1. Destroys Chunk I/O context
2. Cleans up storage metrics resources
3. Frees associated memory

#### `flb_storage_input_create(struct cio_ctx *cio, struct flb_input_instance *in)`
Creates storage context for an input instance:
1. Determines appropriate storage type for the input
2. Creates or retrieves Chunk I/O stream for the input
3. Allocates storage input structure
4. Associates storage context with input instance

#### `flb_storage_input_destroy(struct flb_input_instance *in)`
Destroys storage context for an input instance:
1. Cleans up chunk references
2. Frees storage input structure
3. Removes association with input instance

#### `flb_storage_metrics_create(struct flb_config *ctx)`
Creates storage metrics collection context:
1. Allocates storage metrics structure
2. Initializes CMetrics context with storage-related gauges
3. Sets up periodic metrics collection timer
4. Returns metrics context for use

#### `flb_storage_metrics_update(struct flb_config *config, struct flb_storage_metrics *sm)`
Updates storage metrics with current values:
1. Retrieves current Chunk I/O statistics
2. Updates all storage-related gauges with current values
3. Provides real-time visibility into storage subsystem

#### `flb_storage_chunk_count(struct flb_config *ctx, int *mem_chunks, int *fs_chunks)`
Retrieves current chunk counts:
1. Gets Chunk I/O statistics
2. Populates memory and filesystem chunk counts
3. Provides quick access to chunk statistics

### Helper Functions

#### `metrics_context_create(struct flb_storage_metrics *sm)`
Creates CMetrics context with storage-specific gauges:
1. Creates base CMetrics context
2. Initializes all storage-related gauge metrics
3. Returns configured CMetrics context

#### `cb_storage_metrics_collect(struct flb_config *ctx, void *data)`
Periodic callback for collecting storage metrics:
1. Creates MessagePack buffer for metrics data
2. Appends general storage layer metrics
3. Appends input-specific storage metrics
4. Pushes metrics to HTTP server if enabled

#### `print_storage_info(struct flb_config *ctx, struct cio_ctx *cio)`
Prints storage configuration information:
1. Determines storage type (memory, filesystem, or hybrid)
2. Reports synchronization mode
3. Reports checksum configuration
4. Reports maximum chunks up limit
5. Reports backlog input plugin if configured

#### `log_cb(struct cio_ctx *ctx, int level, const char *file, int line, char *str)`
Chunk I/O logging callback:
1. Maps Chunk I/O log levels to Fluent Bit log levels
2. Routes log messages to appropriate Fluent Bit logging functions
3. Provides consistent logging interface

#### `sort_chunk_cmp(const void *a_arg, const void *b_arg)`
Chunk sorting comparison function:
1. Parses timestamp from chunk names
2. Compares chunks based on creation timestamps
3. Provides deterministic ordering for chunk processing

## Important Constants and Definitions

### Storage Types
- `FLB_STORAGE_FS`: Filesystem storage (memory + disk)
- `FLB_STORAGE_MEM`: Memory-only storage
- `FLB_STORAGE_MEMRB`: Memory ring buffer storage

### Storage Defaults
- `FLB_STORAGE_BL_MEM_LIMIT`: Default backlog memory limit ("100M")
- `FLB_STORAGE_MAX_CHUNKS_UP`: Default maximum chunks in memory (128)

### Chunk I/O Flags
- `CIO_FULL_SYNC`: Full synchronization mode
- `CIO_CHECKSUM`: Enable checksum validation
- `CIO_TRIM_FILES`: Enable file trimming
- `CIO_DELETE_IRRECOVERABLE`: Delete irrecoverable chunks

## Dependencies and Relationships

This module depends on:
- `chunkio`: Chunk-based I/O library for storage operations
- `cmetrics`: Metrics collection and reporting framework
- `msgpack`: MessagePack serialization format
- `flb_config`: Fluent Bit configuration management
- `flb_input`: Input plugin interface
- `flb_scheduler`: Periodic task scheduling
- `flb_http_server`: HTTP server for metrics exposure
- `flb_utils`: Utility functions

It integrates with:
- Input plugins for data ingestion
- Output plugins for data delivery
- Scheduler for periodic operations
- HTTP server for metrics exposure
- Configuration system for storage settings
- Logging system for error reporting

## Implementation Details

### Storage Backend Architecture
The storage layer supports three distinct storage backends:

1. **Memory Storage** (`FLB_STORAGE_MEM`):
   - Stores all data in memory
   - Fastest access but limited by available RAM
   - Suitable for high-throughput scenarios with sufficient memory

2. **Filesystem Storage** (`FLB_STORAGE_FS`):
   - Combines memory and disk storage
   - Frequently accessed chunks kept in memory
   - Older chunks moved to disk to conserve memory
   - Provides persistence across restarts
   - Best balance of performance and durability

3. **Ring Buffer Storage** (`FLB_STORAGE_MEMRB`):
   - Circular buffer in memory
   - Fixed-size storage with automatic overwrite
   - Optimized for scenarios where recent data is most important
   - Minimal memory overhead

### Chunk Lifecycle Management
The storage layer implements sophisticated chunk lifecycle management:

1. **Chunk Creation**: New chunks are created when needed for data buffering
2. **Chunk Loading**: Chunks are loaded from disk to memory as needed
3. **Chunk Eviction**: Least recently used chunks are moved to disk
4. **Chunk Deletion**: Successfully processed chunks are removed
5. **Chunk Recovery**: Corrupted chunks are detected and handled appropriately

### Memory Management Strategy
Efficient memory usage through:
- Configurable maximum chunks in memory (`storage_max_chunks_up`)
- Automatic chunk eviction to disk when limits are reached
- Memory pooling for chunk allocations
- Proper cleanup of unused chunks

### Synchronization and Consistency
Data consistency is maintained through:
- Configurable synchronization modes (normal vs. full)
- Optional checksum validation for data integrity
- Atomic chunk operations to prevent corruption
- Proper error handling for I/O failures

### Metrics Collection
Comprehensive metrics collection includes:
- Total number of chunks
- Memory chunks count
- Filesystem chunks count
- Up/down chunk statistics
- Input-specific storage metrics
- Memory usage statistics
- Overlimit status indicators

## Usage Examples

### Basic Storage Configuration
```ini
[SERVICE]
    # Enable filesystem storage
    storage.path /var/log/fluent-bit/storage
    storage.sync normal
    storage.checksum off
    storage.backlog.mem_limit 50M
    storage.max_chunks_up 128
    
[INPUT]
    name tail
    path /var/log/app.log
    # Data automatically stored in configured storage backend
    
[OUTPUT]
    name stdout
    match *
    # Data retrieved from storage layer
```

### Memory-Only Storage Configuration
```ini
[SERVICE]
    # Memory-only storage (default)
    storage.path 
    storage.sync normal
    storage.checksum off
    
[INPUT]
    name systemd
    tag systemd.*
    # Data stored only in memory
    
[OUTPUT]
    name forward
    host 127.0.0.1
    port 24224
    # Data retrieved from memory storage
```

### Ring Buffer Storage Configuration
```ini
[SERVICE]
    # Ring buffer storage
    storage.path 
    storage.type memrb
    storage.sync normal
    storage.max_chunks_up 100
    
[INPUT]
    name cpu
    tag cpu.*
    # Data stored in ring buffer
    
[OUTPUT]
    name prometheus_exporter
    port 2021
    # Data retrieved from ring buffer
```

### Programmatic Storage Usage
```c
// Initialize storage subsystem
struct flb_config *config = flb_config_init();

// Configure storage options
config->storage_path = flb_strdup("/tmp/fluent-bit-storage");
config->storage_sync = flb_strdup("normal");
config->storage_checksum = FLB_TRUE;

// Create storage subsystem
if (flb_storage_create(config) == -1) {
    flb_error("Failed to initialize storage subsystem");
    return -1;
}

// Storage is now ready for use by input plugins
// Input plugins will automatically use the configured storage

// Clean up when done
flb_storage_destroy(config);
flb_config_destroy(config);
```

### Storage Metrics Integration
```c
// Create storage metrics context
struct flb_storage_metrics *metrics = flb_storage_metrics_create(config);
if (!metrics) {
    flb_error("Failed to create storage metrics context");
    return -1;
}

// Metrics will be automatically collected and updated
// Access metrics through CMetrics interface
struct cmt *cmt = metrics->cmt;

// Example: Get total chunks gauge
double total_chunks = cmt_gauge_get_value(metrics->cmt_chunks);
printf("Total chunks: %.0f\n", total_chunks);

// Clean up metrics
cmt_destroy(metrics->cmt);
flb_free(metrics);
```

### Chunk Count Monitoring
```c
// Monitor chunk counts programmatically
int mem_chunks, fs_chunks;
flb_storage_chunk_count(config, &mem_chunks, &fs_chunks);

printf("Memory chunks: %d\n", mem_chunks);
printf("Filesystem chunks: %d\n", fs_chunks);

// Use this information for capacity planning or alerting
if (mem_chunks > config->storage_max_chunks_up) {
    flb_warn("Memory chunk limit exceeded: %d > %d", 
             mem_chunks, config->storage_max_chunks_up);
}
```

### Storage Type Detection
```c
// Detect storage type for an input instance
struct flb_input_instance *input = flb_input_new(config, "tail", NULL, FLB_FALSE);

// Determine storage type (will use default if not explicitly set)
if (input->storage_type == FLB_STORAGE_FS) {
    printf("Using filesystem storage\n");
} else if (input->storage_type == FLB_STORAGE_MEM) {
    printf("Using memory storage\n");
} else if (input->storage_type == FLB_STORAGE_MEMRB) {
    printf("Using ring buffer storage\n");
}

// Clean up
flb_input_destroy(input);
```

### Error Handling Pattern
```c
// Robust storage initialization with error handling
int init_storage_subsystem(struct flb_config *config) {
    // Validate storage configuration
    if (config->storage_path) {
        // Check if storage path is accessible
        if (access(config->storage_path, W_OK) != 0) {
            flb_error("Storage path not writable: %s", config->storage_path);
            return -1;
        }
    }
    
    // Initialize storage subsystem
    if (flb_storage_create(config) == -1) {
        flb_error("Failed to initialize storage subsystem");
        return -1;
    }
    
    // Create storage metrics if enabled
    if (config->storage_metrics == FLB_TRUE) {
        config->storage_metrics_ctx = flb_storage_metrics_create(config);
        if (!config->storage_metrics_ctx) {
            flb_error("Failed to initialize storage metrics");
            // Continue without metrics rather than failing completely
        }
    }
    
    return 0;
}

// Usage
struct flb_config *config = flb_config_init();
config->storage_path = flb_strdup("/var/log/fluent-bit/storage");
config->storage_metrics = FLB_TRUE;

if (init_storage_subsystem(config) == 0) {
    printf("Storage subsystem initialized successfully\n");
    
    // Use storage subsystem...
    
    // Cleanup
    flb_storage_destroy(config);
} else {
    printf("Failed to initialize storage subsystem\n");
}

flb_config_destroy(config);
```

### Performance Optimization
```c
// Optimize storage configuration for performance
void optimize_storage_config(struct flb_config *config) {
    // Increase maximum chunks in memory for high-throughput scenarios
    config->storage_max_chunks_up = 256;
    
    // Use full synchronization for maximum durability
    config->storage_sync = flb_strdup("full");
    
    // Enable checksums for data integrity
    config->storage_checksum = FLB_TRUE;
    
    // Set appropriate backlog memory limit
    config->storage_bl_mem_limit = flb_strdup("200M");
}

// Usage
struct flb_config *config = flb_config_init();
optimize_storage_config(config);

if (flb_storage_create(config) == 0) {
    printf("Optimized storage subsystem initialized\n");
    // Use optimized storage...
    flb_storage_destroy(config);
}

flb_config_destroy(config);
```

### Storage Diagnostics
```c
// Diagnostic function to report storage status
void report_storage_status(struct flb_config *config) {
    int mem_chunks, fs_chunks;
    
    flb_storage_chunk_count(config, &mem_chunks, &fs_chunks);
    
    flb_info("Storage Status:");
    flb_info("  Memory chunks: %d", mem_chunks);
    flb_info("  Filesystem chunks: %d", fs_chunks);
    flb_info("  Max chunks up: %d", config->storage_max_chunks_up);
    
    if (mem_chunks > config->storage_max_chunks_up * 0.8) {
        flb_warn("Storage approaching capacity limit");
    }
}

// Usage in monitoring or health check
report_storage_status(config);
```

### Integration Pattern
```c
// Example integration with a custom input plugin
struct custom_input_context {
    struct flb_input_instance *ins;
    struct flb_storage_input *storage;
    // ... other fields
};

int custom_input_init(struct flb_input_instance *ins, struct flb_config *config,
                      void *data) {
    struct custom_input_context *ctx;
    
    ctx = flb_calloc(1, sizeof(struct custom_input_context));
    if (!ctx) {
        flb_errno();
        return -1;
    }
    
    ctx->ins = ins;
    
    // Storage is automatically initialized by Fluent Bit
    // Access storage through input instance
    ctx->storage = ins->storage;
    
    // Use Chunk I/O stream for data storage
    struct cio_chunk *chunk = cio_chunk_create(ctx->storage->stream, 
                                               "custom_data", 
                                               1024);
    if (!chunk) {
        flb_error("Failed to create storage chunk");
        flb_free(ctx);
        return -1;
    }
    
    // Store data in chunk
    cio_chunk_write(chunk, "test data", 9);
    
    // ... rest of initialization
    
    ins->context = ctx;
    return 0;
}

// The storage layer handles all persistence automatically
```