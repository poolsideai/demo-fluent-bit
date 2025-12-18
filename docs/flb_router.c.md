# flb_router.c

## Overview

The `flb_router.c` file implements the routing functionality for Fluent Bit. This component manages the flow of data between input plugins and output plugins based on tag matching rules and route configurations.

The router is responsible for:
- Establishing connections between input and output instances based on tag matching
- Supporting wildcard and regex-based matching patterns
- Managing direct routing paths for optimized data flow
- Handling new router configuration formats
- Cleaning up routing resources during shutdown

The routing system enables flexible data routing where multiple inputs can feed into multiple outputs based on configurable matching rules.

## Key Functions/Components

### Core Data Structures

#### `struct flb_router_path`
Represents a routing path from an input instance to an output instance:
- `ins`: Pointer to the destination output instance
- `_head`: Linked list header for chaining paths

#### `struct flb_route_condition`
Defines conditions for routing decisions:
- `rules`: List of condition rules
- `is_default`: Flag indicating if this is a default route

#### `struct flb_route`
Represents a complete routing rule:
- `name`: Route identifier
- `signals`: Event types this route handles
- `condition`: Condition for route matching
- `outputs`: List of output destinations
- `processors`: List of processors to apply

### Main Functions

#### `flb_router_match(const char *tag, int tag_len, const char *match, void *match_regex)`
Core matching function that determines if a tag matches a given pattern. Supports:
- Exact tag matching
- Wildcard patterns (using `*`)
- Regex patterns (when compiled with regex support)

#### `flb_router_connect(struct flb_input_instance *in, struct flb_output_instance *out)`
Establishes a routing connection between an input instance and an output instance. Adds the connection to the input's route list.

#### `flb_router_connect_direct(struct flb_input_instance *in, struct flb_output_instance *out)`
Establishes a direct routing connection, bypassing normal filtering for optimized performance.

#### `flb_router_io_set(struct flb_config *config)`
Main router initialization function that sets up all input-output connections based on configuration:
- Handles simple 1:1 routing for basic cases
- Processes complex N:M routing scenarios
- Applies new router configuration if present
- Validates tag and match configurations

#### `flb_router_exit(struct flb_config *config)`
Cleans up all routing resources during shutdown:
- Frees all routing path structures
- Removes direct routing connections
- Cleans up memory allocations

### Matching Logic Functions

#### `router_match(const char *tag, int tag_len, const char *match, void *match_r)`
Internal matching function that implements the core matching logic with support for:
- Exact string matching
- Wildcard pattern matching
- Regex pattern matching (conditional)

### Configuration Functions

#### `flb_router_config_parse(...)`
Parses new router configuration format from configuration files.

#### `flb_router_apply_config(...)`
Applies parsed router configuration to establish routing paths.

#### `flb_router_routes_destroy(...)`
Destroys router configuration data structures.

## Important Variables/Constants

### Signal Types
- `FLB_ROUTER_SIGNAL_LOGS`: Route logs events
- `FLB_ROUTER_SIGNAL_METRICS`: Route metrics events
- `FLB_ROUTER_SIGNAL_TRACES`: Route traces events
- `FLB_ROUTER_SIGNAL_ANY`: Route any event type

### Matching Patterns
- Exact tag matching: `tag = "exact.tag.name"`
- Wildcard matching: `tag = "app.*"` or `tag = "*"`
- Regex matching: `tag = "/^app\\.[^.]+\\.(.*)$/"` (when regex support is enabled)

## Dependencies and Relationships

This module depends on:
- `flb_input`: Input plugin management
- `flb_output`: Output plugin management
- `flb_config`: Configuration management
- `flb_regex`: Regular expression support (conditional)
- `flb_str`: String utilities
- `mk_core`: Linked list and event loop utilities
- `cfl`: Common Fluent Library for data structures

It interacts with:
- Input plugins for source data
- Output plugins for destination data
- Configuration system for routing rules
- Event loop for asynchronous operations

## Implementation Details

The router implementation provides several key features:

1. **Flexible Matching**: Supports exact, wildcard, and regex matching for tag-based routing.

2. **Efficient Connection Management**: Uses linked lists to maintain routing paths between input and output instances.

3. **Direct Routing Optimization**: Provides a direct routing path that bypasses normal filtering for performance-critical routes.

4. **Configuration Validation**: Validates routing configurations during startup to prevent runtime errors.

5. **Resource Cleanup**: Properly cleans up all routing resources during shutdown.

6. **Wildcard Pattern Support**: Implements efficient wildcard matching that handles complex patterns like `app.*.logs`.

7. **Regex Integration**: Seamlessly integrates with the regex subsystem when available.

8. **Event Type Filtering**: Supports routing based on event types (logs, metrics, traces).

The matching algorithm works as follows:
1. For exact matches, compares strings directly
2. For wildcards, implements recursive pattern matching
3. For regex patterns, delegates to the Onigmo regex engine
4. Returns match result as boolean value

## Usage Examples

### Basic Tag Matching
```c
// Check if a tag matches a pattern
const char *tag = "app.web.server";
const char *pattern = "app.*.server";

int match = flb_router_match(tag, strlen(tag), pattern, NULL);
if (match) {
    printf("Tag matches pattern\n");
}
```

### Regex Matching
```c
// With regex support enabled
struct flb_regex *regex = flb_regex_create("/^app\\.[^.]+\\.(.*)$/");
const char *tag = "app.web.server";

int match = flb_router_match(tag, strlen(tag), NULL, regex);
if (match) {
    printf("Tag matches regex pattern\n");
}
```

### Establishing Routing Connections
```c
// Connect input instance to output instance
struct flb_input_instance *input_ins;
struct flb_output_instance *output_ins;

// ... initialize instances ...

int ret = flb_router_connect(input_ins, output_ins);
if (ret == 0) {
    printf("Routing connection established\n");
} else {
    printf("Failed to establish routing connection\n");
}
```

### Direct Routing
```c
// Establish direct routing path (bypasses filters)
int ret = flb_router_connect_direct(input_ins, output_ins);
if (ret == 0) {
    printf("Direct routing connection established\n");
}
```

### Configuration-Based Routing
```ini
[INPUT]
    name cpu
    tag cpu.local

[INPUT]
    name mem
    tag mem.local

[OUTPUT]
    name stdout
    match cpu.*

[OUTPUT]
    name file
    match mem.*
    path /var/log/mem.log
```

In this example:
- CPU input tagged `cpu.local` routes to stdout output
- Memory input tagged `mem.local` routes to file output
- Tags are matched using wildcard patterns

### Advanced Routing with Conditions
```yaml
service:
  # ... service config ...

routes:
  - name: cpu_route
    signals:
      - logs
    condition:
      - field: $cpu.usage
        op: >
        value: "80"
    outputs:
      - name: alert_output
    processors:
      - name: modify
        properties:
          add: severity=critical
```

This YAML configuration demonstrates advanced routing features:
- Conditional routing based on record content
- Multiple output destinations
- Processor pipelines
- Event type filtering

### Checking Route Matching
```c
// Check if an event should be routed to a specific output
struct flb_event_chunk *chunk;
struct flb_output_instance *output_ins;

// Check event type compatibility
if (flb_router_match_type(chunk->event_type, output_ins)) {
    printf("Event type compatible with output\n");
}

// Check route conditions
struct flb_route *route = /* ... get route ... */;
if (flb_route_condition_eval(chunk, route)) {
    printf("Route conditions satisfied\n");
}
```