# flb_input.c

## Overview

This file contains the core implementation of the input plugin system for Fluent Bit. It provides functionality for managing input plugin instances, handling configuration, managing collectors for event-driven data collection, and supporting both threaded and non-threaded plugin execution models.

The module serves as the foundation for all input plugins in Fluent Bit, implementing the plugin lifecycle management, configuration handling, and data collection mechanisms that enable plugins to gather data from various sources.

## Key Functions

### Instance Management

#### `flb_input_new()`
Creates a new input plugin instance with proper initialization of data structures and resources.

#### `flb_input_instance_init()`
Initializes an input plugin instance with configuration validation and TLS setup if required.

#### `flb_input_instance_destroy()`
Destroys an input plugin instance and frees all associated resources including hash tables, properties, and network connections.

#### `flb_input_instance_pre_run()`
Invokes the pre-run callback for an input plugin instance.

### Plugin Lifecycle

#### `flb_input_init_all()`
Initializes all configured input plugin instances.

#### `flb_input_pre_run_all()`
Invokes the pre-run callback for all input plugin instances.

#### `flb_input_exit_all()`
Invokes the exit callback for all input plugin instances and destroys them.

### Configuration

#### `flb_input_set_property()`
Sets or overrides a configuration property for an input plugin instance.

#### `flb_input_get_property()`
Retrieves a configuration property value for an input plugin instance.

#### `flb_input_get_global_config_map()`
Returns the global configuration map for input plugins.

### Collectors

#### `flb_input_set_collector_time()`
Sets up a time-based collector that triggers a callback at specified intervals.

#### `flb_input_set_collector_event()`
Sets up an event-based collector that triggers a callback when data is available on a file descriptor.

#### `flb_input_set_collector_socket()`
Sets up a socket-based collector for handling network connections.

#### `flb_input_collector_start()`
Starts a collector to begin monitoring for events.

#### `flb_input_collector_pause()`
Pauses a collector to temporarily stop monitoring for events.

#### `flb_input_collector_resume()`
Resumes a paused collector to resume monitoring for events.

#### `flb_input_collector_delete()`
Deletes a collector and frees its resources.

### Threading Support

#### `flb_input_is_threaded()`
Checks if an input plugin instance runs in a separate thread.

#### `flb_input_thread_instance_init()`
Initializes a threaded input plugin instance.

#### `flb_input_thread_instance_exit()`
Signals a threaded input plugin instance to exit.

### Data Ingestion Control

#### `flb_input_pause()`
Pauses data ingestion for an input plugin instance.

#### `flb_input_resume()`
Resumes data ingestion for an input plugin instance.

#### `flb_input_pause_all()`
Pauses data ingestion for all input plugin instances.

### Network Support

#### `flb_input_upstream_set()`
Associates an upstream connection with an input plugin instance.

#### `flb_input_downstream_set()`
Associates a downstream connection with an input plugin instance.

### Utility Functions

#### `flb_input_set_context()`
Sets the plugin-specific context data for an input plugin instance.

#### `flb_input_channel_init()`
Initializes communication channels for an input plugin instance.

#### `flb_input_name()`
Returns the name or alias of an input plugin instance.

#### `flb_input_name_exists()`
Checks if an input plugin instance with a given name already exists.

#### `flb_input_event_loop_get()`
Returns the appropriate event loop for an input plugin instance based on threading mode.

## Important Variables/Constants

### Input Plugin Flags
- `FLB_INPUT_NET`: Plugin uses network connectivity
- `FLB_INPUT_NET_SERVER`: Plugin acts as a network server
- `FLB_INPUT_CORO`: Plugin runs in coroutine mode
- `FLB_INPUT_THREADED`: Plugin runs in a separate thread
- `FLB_INPUT_PRIVATE`: Plugin is private and not exposed to users

### Collector Types
- `FLB_COLLECT_TIME`: Time-based collector
- `FLB_COLLECT_FD_EVENT`: File descriptor event collector
- `FLB_COLLECT_FD_SERVER`: Socket server collector

### Storage Types
- `FLB_STORAGE_FS`: Filesystem storage
- `FLB_STORAGE_MEM`: Memory storage
- `FLB_STORAGE_MEMRB`: Memory ring buffer storage

### Ring Buffer Configuration
- `FLB_INPUT_RING_BUFFER_CAPACITY`: Default ring buffer capacity (1024 entries)
- `FLB_INPUT_RING_BUFFER_SIZE`: Size of ring buffer in bytes
- `FLB_INPUT_RING_BUFFER_WINDOW`: Default window percentage (5%)

## Dependencies

- `fluent-bit/flb_info.h`: Core Fluent Bit information
- `fluent-bit/flb_mem.h`: Memory management utilities
- `fluent-bit/flb_str.h`: String manipulation utilities
- `fluent-bit/flb_env.h`: Environment variable handling
- `fluent-bit/flb_pipe.h`: Inter-process communication
- `fluent-bit/flb_macros.h`: Utility macros
- `fluent-bit/flb_input.h`: Header file defining the interface
- `fluent-bit/flb_input_thread.h`: Threaded input plugin support
- `fluent-bit/flb_error.h`: Error handling utilities
- `fluent-bit/flb_utils.h`: General utility functions
- `fluent-bit/flb_plugin_proxy.h`: Plugin proxy support
- `fluent-bit/flb_engine.h`: Engine interface
- `fluent-bit/flb_metrics.h`: Metrics collection
- `fluent-bit/flb_storage.h`: Storage management
- `fluent-bit/flb_downstream.h`: Downstream connection management
- `fluent-bit/flb_upstream.h`: Upstream connection management
- `fluent-bit/flb_plugin.h`: Plugin interface
- `fluent-bit/flb_kv.h`: Key-value storage
- `fluent-bit/flb_hash_table.h`: Hash table implementation
- `fluent-bit/flb_scheduler.h`: Task scheduling
- `fluent-bit/flb_ring_buffer.h`: Ring buffer implementation
- `fluent-bit/flb_processor.h`: Data processing pipeline
- `monkey/mk_core.h`: Monkey Core event loop

## Implementation Details

1. **Plugin Instance Management**: Comprehensive lifecycle management for input plugin instances including creation, initialization, configuration, and destruction.

2. **Configuration Handling**: Robust configuration system with property validation, TLS setup, and network configuration support.

3. **Collector System**: Flexible event collection mechanism supporting time-based, file descriptor, and socket-based triggers.

4. **Threading Support**: Full support for both threaded and non-threaded plugin execution models with proper synchronization.

5. **Memory Management**: Efficient memory handling with ring buffers, hash tables, and proper resource cleanup.

6. **Network Integration**: Seamless integration with upstream and downstream connection management systems.

7. **Metrics Collection**: Built-in support for collecting and reporting plugin metrics using both legacy and CMetrics systems.

8. **Storage Management**: Support for multiple storage backends including filesystem, memory, and memory ring buffer.

9. **Error Handling**: Comprehensive error detection and reporting throughout all operations.

10. **Extensibility**: Modular design that allows easy addition of new plugin types and features.

## Usage Example

```c
// Create a new input plugin instance
struct flb_input_instance *instance = flb_input_new(config, "tail", NULL, FLB_FALSE);

if (instance) {
    // Configure the input plugin
    flb_input_set_property(instance, "path", "/var/log/application.log");
    flb_input_set_property(instance, "refresh_interval", "5");
    flb_input_set_property(instance, "rotate_wait", "5");
    
    // Initialize the instance
    if (flb_input_instance_init(instance, config) == 0) {
        // Set up a time-based collector for periodic file monitoring
        int collector_id = flb_input_set_collector_time(
            instance,
            tail_collect_callback,  // Callback function
            5,                     // 5 seconds
            0,                     // 0 nanoseconds
            config
        );
        
        if (collector_id >= 0) {
            // Start the collector
            flb_input_collector_start(collector_id, instance);
            
            printf("Tail input plugin configured successfully\n");
        }
    }
    
    // Later, when shutting down
    flb_input_instance_exit(instance, config);
    flb_input_instance_destroy(instance);
}

// Example collector callback function
int tail_collect_callback(struct flb_input_instance *ins,
                         struct flb_config *config,
                         void *context)
{
    // Collect data from the monitored files
    // This would typically involve reading new log entries
    // and pushing them to the Fluent Bit engine
    
    flb_plg_info(ins, "Collecting log data...");
    
    // Process log files and generate records
    // ...
    
    return 0;
}
```