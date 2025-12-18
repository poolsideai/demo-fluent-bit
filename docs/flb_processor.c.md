# flb_processor.c - Processor System for Telemetry Data Processing

## Overview

This file implements Fluent Bit's processor system, which provides a flexible framework for processing telemetry data (logs, metrics, traces, and profiles) through configurable chains of processing units. The processor system allows for complex data transformation pipelines that can be applied to different types of telemetry data independently.

The processor system supports two types of processing units:
1. **Native processors**: Custom plugins specifically designed for the processor system
2. **Pipeline filters**: Existing filter plugins that can be reused in processor chains

Each processor maintains separate chains for different telemetry types, allowing for specialized processing logic for logs, metrics, traces, and profiles.

## Key Components

### Processor Context (`struct flb_processor`)
Represents a complete processor chain with metadata:
- `is_active`: Flag indicating if the processor is active
- `name`: User-defined processor name
- `logs`, `metrics`, `traces`, `profiles`: Lists of processing units for each telemetry type
- `stage_count`: Counter for tracking processing stages
- `data`: Reference to the source plugin instance
- `source_plugin_type`: Type of the source plugin
- `notification_channel`: Pipe for notifications
- `config`: Reference to the Fluent Bit configuration

### Processor Unit (`struct flb_processor_unit`)
Represents an individual processing step in a chain:
- `event_type`: Type of telemetry data this unit processes
- `unit_type`: Whether it's a native processor or pipeline filter
- `name`: Name of the processing unit
- `stage`: Processing stage identifier
- `ctx`: Context data (filter instance for pipeline filters, processor instance for native processors)
- `condition`: Optional condition for conditional processing
- `lock`: Mutex for thread safety
- `unused_list`: List for managing pipeline filters
- `_head`: Linked list node for organization
- `parent`: Reference to the parent processor

### Processor Plugin (`struct flb_processor_plugin`)
Definition of a processor plugin:
- `flags`: Plugin flags
- `name`: Short name of the plugin
- `description`: Human-readable description
- `config_map`: Configuration mapping
- Callback functions for initialization, processing, and cleanup

### Processor Instance (`struct flb_processor_instance`)
Runtime instance of a processor plugin:
- Instance metadata (ID, log level, event type, name, alias)
- Context and data references
- Properties and configuration map
- Log event encoder/decoder for processing logs
- Metrics context
- Notification channel
- Configuration reference

## Key Functions

### `flb_processor_create(struct flb_config *config, char *name, void *source_plugin_instance, int source_plugin_type)`
Creates a new processor context:
- Allocates memory for the processor structure
- Initializes linked lists for all telemetry types
- Sets up basic metadata
- Returns the created processor or NULL on failure

### `flb_processor_unit_create(struct flb_processor *proc, int event_type, char *unit_name)`
Creates a new processing unit:
1. Looks up existing plugins that match the unit name and event type
2. Allocates and initializes the processor unit structure
3. Creates appropriate context (filter instance or processor instance)
4. Links the unit to the appropriate telemetry type list
5. Returns the created unit or NULL on failure

### `flb_processor_unit_set_property(struct flb_processor_unit *pu, const char *k, struct cfl_variant *v)`
Sets a property on a processing unit:
- Handles special "condition" property for conditional processing
- Routes property setting to appropriate handler based on unit type
- Supports various data types through CFL variants

### `flb_processor_unit_init(struct flb_processor_unit *pu)`
Initializes a processing unit:
- Calls appropriate initialization callback based on unit type
- Sets up notification channels
- Returns 0 on success, -1 on failure

### `flb_processor_init(struct flb_processor *proc)`
Initializes all units in a processor:
- Iterates through all units in all telemetry type lists
- Calls `flb_processor_unit_init()` for each unit
- Sets the processor as active if any units were initialized successfully
- Returns 0 on success, -1 on failure

### `flb_processor_run(struct flb_processor *proc, size_t starting_stage, int type, const char *tag, size_t tag_len, void *data, size_t data_size, void **out_buf, size_t *out_size)`
Executes the processor chain on telemetry data:
1. Routes to the appropriate telemetry type list
2. Iterates through processing units in order
3. Acquires locks for thread safety
4. Calls appropriate processing callbacks based on unit type
5. Handles data transformation and buffering
6. Returns processed data through output parameters
7. Returns 0 on success, -1 on failure

### `flb_processor_destroy(struct flb_processor *proc)`
Cleans up a processor and all its units:
- Destroys all units in all telemetry type lists
- Frees the processor structure itself

### `flb_processor_unit_destroy(struct flb_processor_unit *pu)`
Cleans up a processing unit:
- Calls appropriate exit callback based on unit type
- Destroys the condition if it exists
- Frees the unit name and structure

## Conditional Processing

The processor system supports conditional execution of processing units through a flexible condition system:

Conditions are specified as key-value maps with:
- `op`: Operator ("and" or "or") for combining rules
- `rules`: Array of rule specifications

Each rule includes:
- `field`: Field name to evaluate
- `op`: Comparison operator ("eq", "neq", "gt", "lt", "gte", "lte", "regex", "not_regex", "in", "not_in")
- `value`: Value to compare against
- `context`: Optional context ("metadata" or "body")

Example condition specification:
```yaml
condition:
  op: and
  rules:
    - field: status
      op: eq
      value: "error"
    - field: severity
      op: gte
      value: 3
```

## Telemetry Type Support

The processor system handles four types of telemetry data:

1. **Logs** (`FLB_PROCESSOR_LOGS`): Processed as MessagePack data with log event encoding/decoding
2. **Metrics** (`FLB_PROCESSOR_METRICS`): Processed as CMetrics contexts
3. **Traces** (`FLB_PROCESSOR_TRACES`): Processed as CTraces contexts
4. **Profiles** (`FLB_PROCESSOR_PROFILES`): Processed as CProfiles contexts

Each type has dedicated processing paths and data handling.

## Dependencies

- `<fluent-bit/flb_info.h>` - Core information headers
- `<fluent-bit/flb_log.h>` - Logging utilities
- `<fluent-bit/flb_env.h>` - Environment variable utilities
- `<fluent-bit/flb_mem.h>` - Memory management utilities
- `<fluent-bit/flb_event.h>` - Event handling utilities
- `<fluent-bit/flb_processor.h>` - Public interface header
- `<fluent-bit/flb_processor_plugin.h>` - Processor plugin interface
- `<fluent-bit/flb_filter.h>` - Filter plugin interface
- `<fluent-bit/flb_kv.h>` - Key-value utilities
- `<fluent-bit/flb_mp_chunk.h>` - MessagePack chunk utilities
- `<fluent-bit/flb_log_event_decoder.h>` - Log event decoding utilities
- `<fluent-bit/flb_log_event_encoder.h>` - Log event encoding utilities
- `<fluent-bit/flb_conditionals.h>` - Conditional processing utilities
- `<cfl/cfl.h>` - CFL utilities for data structures
- `<pthread.h>` - Threading utilities
- `<unistd.h>` - POSIX utilities
- `<ctraces/ctraces.h>` - Trace handling utilities
- `<cmetrics/cmetrics.h>` - Metrics handling utilities
- `<cprofiles/cprofiles.h>` - Profile handling utilities

## Notable Implementation Details

1. **Thread Safety**: Uses mutexes to protect processing units from concurrent access

2. **Flexible Data Handling**: Supports different data representations for different telemetry types

3. **Conditional Execution**: Allows selective application of processing units based on data content

4. **Resource Management**: Proper allocation and cleanup of all resources including locks and buffers

5. **Error Handling**: Comprehensive error checking with detailed logging

6. **Extensibility**: Architecture supports adding new telemetry types and processing capabilities

7. **Integration**: Seamlessly integrates with Fluent Bit's existing plugin system

## Usage Examples

### Creating and Configuring a Processor
```c
struct flb_config *config; // Assume this is initialized
struct flb_input_instance *input_instance; // Source plugin instance

// Create a processor
struct flb_processor *proc = flb_processor_create(config, "my_processor", input_instance, FLB_INPUT_PLUGIN);

if (proc == NULL) {
    // Handle error
}

// Add a processing unit
struct flb_processor_unit *unit = flb_processor_unit_create(proc, FLB_PROCESSOR_LOGS, "modify");

if (unit == NULL) {
    // Handle error
}

// Set properties on the unit
if (flb_processor_unit_set_property_str(unit, "key", "new_value") == -1) {
    // Handle error
}

// Initialize the processor
if (flb_processor_init(proc) == -1) {
    // Handle error
}
```

### Running a Processor on Data
```c
void *processed_data = NULL;
size_t processed_size = 0;

// Run the processor on log data
if (flb_processor_run(proc,
                      0, // starting stage
                      FLB_PROCESSOR_LOGS,
                      "my.tag",
                      strlen("my.tag"),
                      raw_log_data,
                      raw_log_size,
                      &processed_data,
                      &processed_size) == -1) {
    // Handle error
}

// Use processed_data as needed
// Remember to free processed_data when done
```