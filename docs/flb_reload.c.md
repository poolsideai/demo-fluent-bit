# flb_reload.c

## Overview

The `flb_reload.c` file implements hot reloading functionality for Fluent Bit. This component allows Fluent Bit to dynamically reload its configuration without restarting the entire process, enabling seamless updates to inputs, filters, and outputs.

Hot reloading works by creating a new Fluent Bit context with the updated configuration, validating it, and then gracefully transitioning from the old context to the new one. This process ensures minimal disruption to ongoing data processing.

The implementation handles complex scenarios such as:
- Configuration validation before applying changes
- Graceful shutdown of the old context
- Proper resource cleanup
- Timeout protection to prevent indefinite hangs
- Support for various configuration formats (YAML, INI)

## Key Functions/Components

### Core Functions

#### `flb_reload(flb_ctx_t *ctx, struct flb_cf *cf_opts)`
Main entry point for hot reloading. This function orchestrates the entire reload process:
1. Validates the new configuration
2. Creates a new Fluent Bit context with the updated configuration
3. Gracefully shuts down the old context
4. Starts the new context
5. Handles error cases and rollbacks

#### `flb_reload_property_check_all(struct flb_config *config)`
Validates all plugin configurations in the new context before applying changes. This includes checking properties for input, filter, output, and custom plugins.

#### `flb_reload_reconstruct_cf(struct flb_cf *src_cf, struct flb_cf *dest_cf)`
Reconstructs a configuration format context by copying sections, properties, and groups from the source to the destination.

### Plugin Validation Functions

#### `flb_input_propery_check_all(struct flb_config *config)`
Validates properties for all input plugins in the configuration.

#### `flb_filter_propery_check_all(struct flb_config *config)`
Validates properties for all filter plugins in the configuration.

#### `flb_output_propery_check_all(struct flb_config *config)`
Validates properties for all output plugins in the configuration.

#### `flb_custom_propery_check_all(struct flb_config *config)`
Validates properties for all custom plugins in the configuration.

### Helper Functions

#### `recreate_cf_section(struct flb_cf_section *s, struct flb_cf *cf)`
Recreates a configuration section by copying its properties and groups to a new configuration context.

#### `flb_reload_reconstruct_sp(struct flb_config *src, struct flb_config *dest)`
Reconstructs stream processor definitions from the source configuration to the destination.

#### `flb_reload_reinstantiate_external_plugins(struct flb_config *src, struct flb_config *dest)`
Reinstantiates external plugins from the source configuration to the destination.

### Watchdog Functions

#### `hot_reload_watchdog_thread(void *arg)`
Background thread that monitors the reload process and aborts if it exceeds the configured timeout.

#### `flb_reload_watchdog_start(struct flb_config *config)`
Starts the watchdog thread to monitor the reload process.

#### `flb_reload_watchdog_cleanup(struct flb_reload_watchdog_ctx *watchdog_ctx)`
Cleans up the watchdog thread resources.

## Important Variables/Constants

### Reload Status Codes
- `FLB_RELOAD_IDLE`: No reload in progress
- `FLB_RELOAD_IN_PROGRESS`: Reload is currently happening
- `FLB_RELOAD_ABORTED`: Reload was aborted due to errors
- `FLB_RELOAD_HALTED`: Reload was halted due to critical errors
- `FLB_RELOAD_NOT_ENABLED`: Hot reload is not enabled
- `FLB_RELOAD_INVALID_CONTEXT`: Invalid Fluent Bit context provided

### Data Structures

#### `struct flb_reload_watchdog_ctx`
Context for the reload watchdog thread:
- `tid`: Thread ID
- `timeout_seconds`: Timeout duration in seconds
- `should_stop`: Flag to signal thread shutdown

## Dependencies and Relationships

This module depends on several core Fluent Bit components:
- `flb_lib`: Main Fluent Bit library functions
- `flb_config`: Configuration management
- `flb_config_format`: Configuration format parsing
- `flb_input`: Input plugin management
- `flb_filter`: Filter plugin management
- `flb_output`: Output plugin management
- `flb_custom`: Custom plugin management
- `flb_pthread`: Threading utilities
- `cfl`: Common Fluent Library for data structures

It integrates with:
- HTTP server for remote reload triggers
- Signal handlers for manual reload triggers
- Configuration parsers for various formats
- Plugin systems for validation

## Implementation Details

The hot reload implementation follows these key principles:

1. **Atomic Transition**: The reload process creates a completely new Fluent Bit context rather than modifying the existing one in-place. This ensures that if the new configuration is invalid, the old configuration remains intact.

2. **Graceful Shutdown**: The old context is properly shut down with all resources cleaned up before the new context takes over.

3. **Validation First**: Configuration validation happens before any changes are applied, preventing invalid configurations from taking effect.

4. **Timeout Protection**: A watchdog thread monitors the reload process and aborts if it takes too long, preventing indefinite hangs.

5. **Resource Isolation**: Each context maintains its own resources, ensuring clean separation between old and new configurations.

6. **Error Recovery**: If any step fails, the process rolls back to the previous state with appropriate error reporting.

The reload process involves several phases:
1. Configuration parsing and validation
2. New context creation
3. Plugin instantiation and property checking
4. Old context shutdown
5. New context startup
6. Resource cleanup

## Usage Examples

### Triggering a Reload Programmatically
```c
// Assuming you have a Fluent Bit context
flb_ctx_t *ctx;
struct flb_cf *cf_opts = NULL; // Optional additional configuration

// Trigger a hot reload
int ret = flb_reload(ctx, cf_opts);

switch(ret) {
    case 0:
        printf("Reload successful\n");
        break;
    case FLB_RELOAD_ABORTED:
        printf("Reload aborted due to errors\n");
        break;
    case FLB_RELOAD_HALTED:
        printf("Reload halted due to critical errors\n");
        break;
    case FLB_RELOAD_NOT_ENABLED:
        printf("Hot reload not enabled\n");
        break;
    case FLB_RELOAD_INVALID_CONTEXT:
        printf("Invalid Fluent Bit context\n");
        break;
}
```

### Enabling Hot Reload in Configuration
```ini
[SERVICE]
    # Enable hot reload
    hot_reload on
    
    # Optional: Set watchdog timeout (in seconds)
    hot_reload_watchdog_timeout_seconds 30
```

### YAML Configuration with Hot Reload
```yaml
service:
  hot_reload: true
  hot_reload_watchdog_timeout_seconds: 30

inputs:
  - name: cpu
    tag: cpu.local

outputs:
  - name: stdout
    match: '*'
```

### Monitoring Reload Status
```c
// Check if reload is in progress
if (ctx->config->hot_reloading == FLB_TRUE) {
    printf("Reload in progress\n");
} else {
    printf("No reload in progress\n");
}

// Check reload success status
if (ctx->config->hot_reload_succeeded == FLB_TRUE) {
    printf("Last reload was successful\n");
}

// Get reload count
printf("Hot reloaded %d times\n", ctx->config->hot_reloaded_count);
```