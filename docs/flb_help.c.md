# flb_help.c

## Overview

This file implements the help system for Fluent Bit that generates structured documentation for all plugins in MessagePack format. The implementation provides detailed information about plugin types, names, descriptions, and configuration options.

The module serves as a centralized help generator that can produce comprehensive documentation for all Fluent Bit plugins including inputs, outputs, filters, processors, and custom plugins. It creates structured data that can be easily consumed by tools or converted to various formats.

## Key Functions

### `flb_help_custom()`
Generates help information for a custom plugin instance.

### `flb_help_input()`
Generates help information for an input plugin instance.

### `flb_help_processor()`
Generates help information for a processor plugin instance.

### `flb_help_filter()`
Generates help information for a filter plugin instance.

### `flb_help_output()`
Generates help information for an output plugin instance.

### `flb_help_build_json_schema()`
Builds a complete JSON schema containing help information for all registered plugins.

## Important Variables/Constants

### Plugin Types
- `FLB_HELP_PLUGIN_CUSTOM`: Custom plugin type
- `FLB_HELP_PLUGIN_INPUT`: Input plugin type
- `FLB_HELP_PLUGIN_PROCESSOR`: Processor plugin type
- `FLB_HELP_PLUGIN_FILTER`: Filter plugin type
- `FLB_HELP_PLUGIN_OUTPUT`: Output plugin type

### Schema Version
- `FLB_HELP_SCHEMA_VERSION`: Current help schema version ("1")

## Dependencies

- `fluent-bit/flb_help.h`: Header file defining the interface
- `fluent-bit/flb_info.h`: Core Fluent Bit information
- `fluent-bit/flb_version.h`: Version information
- `fluent-bit/flb_utils.h`: Utility functions
- `fluent-bit/flb_pack.h`: MessagePack packing utilities
- `fluent-bit/flb_mp.h`: MessagePack utilities
- `fluent-bit/flb_custom.h`: Custom plugin interface
- `fluent-bit/flb_input.h`: Input plugin interface
- `fluent-bit/flb_filter.h`: Filter plugin interface
- `fluent-bit/flb_output.h`: Output plugin interface
- `fluent-bit/flb_processor.h`: Processor plugin interface
- `fluent-bit/flb_sds.h`: String data structure utilities

## Implementation Details

1. **MessagePack Format**: All help information is generated in MessagePack format for efficient serialization and deserialization.

2. **Structured Data**: Each plugin's help information includes type, name, description, and detailed configuration properties.

3. **Configuration Mapping**: Extracts and documents all configuration options defined by plugins using the config map system.

4. **Network Options**: Automatically includes networking-related configuration options for network-enabled plugins.

5. **TLS Options**: Includes TLS configuration options for plugins that support secure connections.

6. **Global Options**: Documents global configuration options that apply to all plugins of a given type.

7. **Schema Generation**: Provides a complete JSON schema of all registered plugins for external tool consumption.

## Usage Example

```c
// Build help schema for all plugins
struct flb_config *config = flb_config_init();
flb_sds_t help_schema = flb_help_build_json_schema(config);

if (help_schema) {
    printf("Help Schema:\n%s\n", help_schema);
    flb_sds_destroy(help_schema);
}

// Generate help for a specific input plugin
struct flb_input_instance *ins = flb_input_new(config, "tail", 0, FLB_TRUE);
if (ins) {
    void *help_buf;
    size_t help_size;
    
    flb_help_input(ins, &help_buf, &help_size);
    
    // Convert MessagePack to JSON for display
    flb_sds_t json_out = flb_msgpack_raw_to_json_sds(help_buf, help_size, FLB_TRUE);
    printf("Input Plugin Help:\n%s\n", json_out);
    
    flb_sds_destroy(json_out);
    flb_free(help_buf);
    flb_input_instance_destroy(ins);
}

flb_config_exit(config);
```