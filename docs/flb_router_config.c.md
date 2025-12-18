# flb_router_config.c

## Overview

The `flb_router_config.c` file implements configuration parsing and application for Fluent Bit's advanced routing system. This component handles the parsing of YAML-based router configurations and applies them to establish direct routing paths between input and output instances.

The routing configuration system provides:
- YAML-based configuration format for defining routes
- Support for conditional routing based on event content
- Event type filtering (logs, metrics, traces)
- Processor pipeline integration
- Fallback output handling
- Validation of route configurations

This functionality enables sophisticated data routing where events can be directed to different outputs based on their content, type, or other criteria.

## Key Functions/Components

### Core Functions

#### `flb_router_config_parse(struct flb_cf *cf, struct cfl_list *input_routes, struct flb_config *config)`
Main entry point for parsing router configuration from configuration format:
1. Iterates through input sections in the configuration
2. Parses router configuration blocks for each input
3. Validates and builds internal route representation
4. Returns 0 on success, -1 on error

#### `flb_router_apply_config(struct flb_config *config)`
Applies parsed router configuration to establish actual routing paths:
1. Finds input instances by name
2. Finds output instances by name
3. Validates output signal compatibility
4. Establishes direct routing connections
5. Handles fallback outputs when primary outputs are missing

### Configuration Parsing Functions

#### `parse_input_section(struct flb_cf_section *section, struct cfl_list *input_routes, struct flb_config *config)`
Parses router configuration for a single input section:
- Extracts input name
- Parses processors configuration
- Parses routes configuration by event type
- Validates route definitions

#### `parse_routes_block(struct cfl_variant *variant, struct flb_input_routes *input, struct flb_config *config, uint32_t signals)`
Parses a routes block for a specific event type:
- Handles both array and single route formats
- Parses individual route definitions
- Validates route structure

#### `parse_route(struct cfl_variant *variant, struct flb_input_routes *input, struct flb_config *config, uint32_t signals)`
Parses a single route definition:
- Extracts route name
- Parses condition rules
- Parses processors for the route
- Parses output destinations
- Validates route completeness

#### `parse_condition(struct cfl_variant *variant, uint32_t signals)`
Parses condition configuration for a route:
- Extracts condition rules array
- Parses default route flag
- Validates rule fields against event type

#### `parse_condition_rule(struct cfl_variant *variant)`
Parses a single condition rule:
- Extracts field, operator, and value
- Validates rule structure
- Converts values to appropriate types

#### `parse_outputs(struct cfl_variant *variant, struct flb_route *route)`
Parses output destinations for a route:
- Handles both array and single output formats
- Extracts output names and fallback options
- Validates output specifications

#### `parse_processors(struct cfl_variant *variant, struct cfl_list *out_list, struct flb_config *config)`
Parses processor pipeline configuration:
- Handles array of processor definitions
- Extracts processor names and properties
- Validates processor specifications

### Validation Functions

#### `validate_rule_field(const char *field, uint32_t signals)`
Validates that a field is appropriate for the specified event types:
- Checks field prefixes against event type constraints
- Ensures logs events don't reference metric/trace fields
- Ensures metric events reference appropriate fields
- Ensures trace events reference appropriate fields

#### `parse_signal_key(const char *key)`
Parses signal type specification from configuration:
- Supports "logs", "metrics", "traces", and "any"
- Handles comma-separated and pipe-separated lists
- Returns appropriate signal mask

#### `output_supports_signals(struct flb_output_instance *out, uint32_t signals)`
Checks if an output instance supports the required event types:
- Validates output event type compatibility
- Handles "any" signal type appropriately

#### `field_allowed_for_*` functions
Specialized validation functions for different event types:
- `field_allowed_for_logs()`: Validates log event fields
- `field_allowed_for_metrics()`: Validates metric event fields
- `field_allowed_for_traces()`: Validates trace event fields

### Resource Management Functions

#### `flb_router_routes_destroy(struct cfl_list *input_routes)`
Destroys all router configuration data structures:
- Frees input route configurations
- Frees route definitions
- Frees condition rules
- Frees output specifications
- Frees processor configurations

#### `route_condition_destroy(struct flb_route_condition *condition)`
Destroys a route condition and its rules.

#### `route_outputs_destroy(struct flb_route *route)`
Destroys output specifications for a route.

#### `route_processors_destroy(struct cfl_list *processors)`
Destroys processor pipeline configurations.

#### `input_routes_destroy(struct flb_input_routes *input)`
Destroys input route configuration and associated resources.

### Utility Functions

#### `variant_to_sds(struct cfl_variant *var)`
Converts a CFL variant to an SDS string:
- Handles string, integer, unsigned integer, double, and boolean types
- Formats numeric values appropriately

#### `variant_to_bool(struct cfl_variant *var, int *out)`
Converts a CFL variant to a boolean value:
- Handles boolean variants directly
- Handles string variants with "true"/"false"

#### `copy_from_cfl_sds(cfl_sds_t value)`
Creates an SDS copy of a CFL SDS string.

### Instance Lookup Functions

#### `find_input_instance(struct flb_config *config, flb_sds_t name)`
Finds an input instance by name:
- Searches by instance name
- Searches by alias
- Searches by plugin name

#### `find_output_instance(struct flb_config *config, flb_sds_t name)`
Finds an output instance by name:
- Searches by instance name
- Searches by alias
- Searches by plugin name

#### `input_has_direct_route(struct flb_input_instance *in, struct flb_output_instance *out)`
Checks if a direct route already exists between input and output.

## Important Variables/Constants

### Signal Types
- `FLB_ROUTER_SIGNAL_LOGS`: Signal for log events
- `FLB_ROUTER_SIGNAL_METRICS`: Signal for metric events
- `FLB_ROUTER_SIGNAL_TRACES`: Signal for trace events
- `FLB_ROUTER_SIGNAL_ANY`: Signal for any event type

### Field Validation Rules
- Log events: Cannot reference `$metric.*`, `$span.*`, or `$scope.*` fields
- Metric events: Must reference `$metric.*`, `$resource[.*]`, or `$attributes[.*]` fields
- Trace events: Must reference `$span.*`, `$resource[.*]`, or `$scope[.*]` fields

### Configuration Structure
- Routes are organized by input instance
- Each input can have multiple routes for different event types
- Routes can have conditions, processors, and multiple outputs
- Outputs can specify fallback destinations

## Dependencies and Relationships

This module depends on:
- `flb_router`: Core routing functionality
- `flb_config`: Configuration management
- `flb_input`: Input plugin management
- `flb_output`: Output plugin management
- `flb_sds`: String data structure
- `cfl`: Common Fluent Library for data structures
- `flb_cf`: Configuration format parsing

It integrates with:
- Configuration system for YAML parsing
- Plugin systems for instance lookup
- Routing system for connection establishment
- Event processing pipeline

## Implementation Details

The router configuration implementation provides several key features:

1. **YAML Configuration Support**: Parses modern YAML-based router configurations that provide more flexibility than traditional INI-style configurations.

2. **Event Type Filtering**: Routes can be configured for specific event types (logs, metrics, traces) or any combination.

3. **Conditional Routing**: Routes can include conditions that determine whether events should be routed based on their content.

4. **Processor Integration**: Routes can specify processor pipelines to apply transformations before routing.

5. **Fallback Handling**: Outputs can specify fallback destinations for graceful degradation.

6. **Validation**: Comprehensive validation of route configurations to prevent runtime errors.

7. **Resource Management**: Proper cleanup of configuration data structures to prevent memory leaks.

8. **Flexible Parsing**: Handles various configuration formats including arrays, key-value lists, and nested structures.

The configuration parsing process follows these steps:
1. Parse input sections for router configuration
2. Extract input names and validate
3. Parse processors configuration
4. Parse routes by event type
5. Validate route conditions and fields
6. Parse output destinations
7. Store configuration in internal data structures

The route application process follows these steps:
1. Locate input instances by name
2. Locate output instances by name
3. Validate output signal compatibility
4. Check for existing direct routes
5. Establish new direct routing connections
6. Handle fallback outputs when needed

## Usage Examples

### Basic Router Configuration
```yaml
service:
  # ... service configuration ...

routes:
  - name: cpu_route
    signals:
      - logs
    to:
      - name: stdout

  - name: metric_route
    signals:
      - metrics
    to:
      - name: prometheus
```

This configuration:
- Routes log events from CPU input to stdout
- Routes metric events from CPU input to prometheus
- Uses default routing for other event types

### Conditional Routing
```yaml
routes:
  - name: high_cpu_alert
    signals:
      - logs
    condition:
      - field: $cpu.usage
        op: >
        value: "80"
    to:
      - name: alert_output

  - name: normal_cpu
    signals:
      - logs
    condition:
      - field: $cpu.usage
        op: <=
        value: "80"
    to:
      - name: monitoring_output
```

This configuration:
- Routes high CPU usage logs (>80%) to alert output
- Routes normal CPU usage logs (≤80%) to monitoring output
- Uses field-based conditions for intelligent routing

### Multi-Output Routing
```yaml
routes:
  - name: critical_logs
    signals:
      - logs
    condition:
      - field: $severity
        op: ==
        value: "critical"
    to:
      - name: alert_system
      - name: backup_storage
```

This configuration:
- Routes critical severity logs to both alert system and backup storage
- Provides redundancy for critical events
- Uses equality condition for precise matching

### Fallback Output Configuration
```yaml
routes:
  - name: primary_route
    signals:
      - any
    to:
      - name: primary_output
        fallback: secondary_output
```

This configuration:
- Attempts to route to primary output
- Falls back to secondary output if primary is unavailable
- Provides graceful degradation

### Processor Pipeline Integration
```yaml
routes:
  - name: processed_route
    signals:
      - logs
    processors:
      - name: modify
        properties:
          add: processed=true
      - name: record_modifier
        properties:
          remove: sensitive_field
    to:
      - name: secure_output
```

This configuration:
- Applies modify processor to add processed flag
- Applies record modifier to remove sensitive fields
- Routes processed events to secure output
- Demonstrates processor pipeline integration

### Configuration with All Features
```yaml
service:
  # ... service configuration ...

routes:
  - name: application_logs
    signals:
      - logs
    condition:
      - field: $app.name
        op: ==
        value: "web"
      - field: $severity
        op: in
        value: '["error", "critical"]'
    processors:
      - name: modify
        properties:
          add: routing=web_errors
    to:
      - name: error_monitoring
        fallback: general_logs
      - name: alert_system

  - name: default_route
    signals:
      - any
    condition:
      is_default: true
    to:
      - name: storage_output
```

This comprehensive configuration demonstrates:
- Multiple condition rules with AND logic
- Processor pipeline for data transformation
- Multiple output destinations with fallback
- Default route for unmatched events
- Event type filtering

### Programmatic Configuration Usage
```c
// Parse router configuration
struct cfl_list input_routes;
int ret = flb_router_config_parse(config_format, &input_routes, config);

if (ret == 0) {
    printf("Router configuration parsed successfully\n");
    
    // Apply the configuration
    ret = flb_router_apply_config(config);
    if (ret == 0) {
        printf("Router configuration applied successfully\n");
    } else {
        printf("Failed to apply router configuration\n");
    }
} else {
    printf("Failed to parse router configuration\n");
}

// Clean up when done
flb_router_routes_destroy(&input_routes);
```

### Validating Route Conditions
```c
// Check if a field is valid for specific event types
const char *field = "$cpu.usage";
uint32_t signals = FLB_ROUTER_SIGNAL_LOGS | FLB_ROUTER_SIGNAL_METRICS;

if (validate_rule_field(field, signals)) {
    printf("Field is valid for the specified event types\n");
} else {
    printf("Field is not valid for the specified event types\n");
}

// Parse signal specification
const char *signal_spec = "logs,metrics";
uint32_t mask = parse_signal_key(signal_spec);
if (mask != 0) {
    printf("Signal mask: 0x%x\n", mask);
}
```