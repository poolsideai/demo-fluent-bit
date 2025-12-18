# flb_config_format.c

## Overview

This file implements the configuration format handling functionality for Fluent Bit. It provides a unified interface for parsing and managing configuration files in both the classic Fluent Bit format (.conf) and YAML format (.yaml/.yml).

The module handles:
- Configuration format detection based on file extension
- Key translation between camelCase (YAML) and snake_case (classic)
- Section management for different configuration types (service, input, filter, output, etc.)
- Property management within sections
- Environment variable handling
- Meta command processing
- Group management within sections

## Key Functions

### `flb_cf_create()`
Creates a new configuration context structure. Initializes all internal lists and sets the default format to classic.

### `flb_cf_destroy()`
Destroys a configuration context, releasing all allocated memory including sections, properties, and lists.

### `flb_cf_key_translate()`
Translates configuration keys between formats:
- Converts camelCase to snake_case for YAML compatibility
- Handles classic format by converting to lowercase
- Preserves original format for non-standard keys

### `flb_cf_section_create()`
Creates a new configuration section with the specified name. Automatically determines section type and links it to appropriate internal lists.

### `flb_cf_section_property_add()`
Adds a property to a configuration section. Handles key translation and value sanitization.

### `flb_cf_create_from_file()`
Main entry point for loading configuration from a file. Automatically detects format based on file extension and delegates to appropriate parser.

### `flb_cf_dump()`
Dumps the entire configuration structure for debugging purposes.

## Important Variables/Constants

### Section Types
- `FLB_CF_SERVICE`: Service configuration section
- `FLB_CF_PARSER`: Parser configuration section
- `FLB_CF_MULTILINE_PARSER`: Multiline parser configuration section
- `FLB_CF_STREAM_PROCESSOR`: Stream processor configuration section
- `FLB_CF_PLUGINS`: External plugin configuration section
- `FLB_CF_UPSTREAM_SERVERS`: Upstream server configuration section
- `FLB_CF_CUSTOM`: Custom plugin configuration section
- `FLB_CF_INPUT`: Input plugin configuration section
- `FLB_CF_FILTER`: Filter plugin configuration section
- `FLB_CF_OUTPUT`: Output plugin configuration section
- `FLB_CF_OTHER`: Other configuration sections

### Format Types
- `FLB_CF_CLASSIC`: Classic Fluent Bit configuration format
- `FLB_CF_YAML`: YAML configuration format

## Dependencies

- `cfl/cfl.h`: Core CFL library for data structures
- `cfl/cfl_sds.h`: String data structure library
- `cfl/cfl_variant.h`: Variant data type library
- `cfl/cfl_kvlist.h`: Key-value list library
- `fluent-bit/flb_info.h`: Fluent Bit core information
- `fluent-bit/flb_mem.h`: Memory management utilities
- `fluent-bit/flb_log.h`: Logging utilities
- `fluent-bit/flb_kv.h`: Key-value utilities
- `fluent-bit/flb_config_format.h`: Configuration format headers

## Implementation Details

1. **Key Translation**: The system automatically translates between camelCase (YAML) and snake_case (classic) formats to maintain compatibility.

2. **Section Management**: Each configuration section is managed through linked lists, allowing efficient traversal and lookup.

3. **Format Detection**: Configuration format is detected based on file extension (.conf for classic, .yaml/.yml for YAML).

4. **Property Validation**: Keys and values are sanitized by trimming whitespace to ensure consistent parsing.

5. **Memory Management**: Uses Fluent Bit's memory allocation functions (flb_calloc, flb_malloc, flb_free) for consistency.

## Usage Example

```c
// Create configuration context
struct flb_cf *ctx = flb_cf_create();

// Load configuration from file
ctx = flb_cf_create_from_file(ctx, "fluent-bit.conf");

// Access configuration properties
struct flb_cf_section *service_section = ctx->service;

// Get a specific property
struct cfl_variant *property = flb_cf_section_property_get(ctx, service_section, "flush");

// Clean up
flb_cf_destroy(ctx);
```