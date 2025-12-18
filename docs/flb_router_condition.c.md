# flb_router_condition.c

## Overview

The `flb_router_condition.c` file implements condition evaluation functionality for Fluent Bit's routing system. This component evaluates whether event chunks should be routed to specific outputs based on configured conditions and event types.

The condition evaluation system supports:
- Event type filtering (logs, metrics, traces)
- Signal-based routing decisions
- Default route handling
- Future extensibility for field-based conditions

While the current implementation is largely placeholder functionality awaiting full implementation of the condition evaluation engine, it provides the foundational structure for advanced routing decisions based on event content.

## Key Functions/Components

### Core Functions

#### `flb_router_signal_from_chunk(struct flb_event_chunk *chunk)`
Converts an event chunk type to a router signal type:
- `FLB_EVENT_TYPE_LOGS` → `FLB_ROUTER_SIGNAL_LOGS`
- `FLB_EVENT_TYPE_METRICS` → `FLB_ROUTER_SIGNAL_METRICS`
- `FLB_EVENT_TYPE_TRACES` → `FLB_ROUTER_SIGNAL_TRACES`

Returns 0 for unknown or invalid chunk types.

#### `flb_route_condition_eval(struct flb_event_chunk *chunk, struct flb_route *route)`
Main condition evaluation function that determines if an event chunk should be routed to a specific output:
1. Checks if route has conditions defined
2. Validates event type compatibility
3. Checks route signal matching
4. Handles default routes
5. Delegates to specific evaluators based on event type

#### `flb_condition_eval_logs(struct flb_event_chunk *chunk, struct flb_route *route)`
Placeholder evaluator for log event conditions. Currently returns `FLB_FALSE` as the full condition evaluation engine is not yet implemented.

#### `flb_condition_eval_metrics(struct flb_event_chunk *chunk, struct flb_route *route)`
Placeholder evaluator for metric event conditions. Currently returns `FLB_FALSE` as the full condition evaluation engine is not yet implemented.

#### `flb_condition_eval_traces(struct flb_event_chunk *chunk, struct flb_route *route)`
Placeholder evaluator for trace event conditions. Currently returns `FLB_FALSE` as the full condition evaluation engine is not yet implemented.

## Important Variables/Constants

### Signal Types
- `FLB_ROUTER_SIGNAL_LOGS`: Signal for log events
- `FLB_ROUTER_SIGNAL_METRICS`: Signal for metric events
- `FLB_ROUTER_SIGNAL_TRACES`: Signal for trace events
- `FLB_ROUTER_SIGNAL_ANY`: Signal for any event type

### Return Values
- `FLB_TRUE`: Condition is satisfied, route the event
- `FLB_FALSE`: Condition is not satisfied, do not route the event

## Dependencies and Relationships

This module depends on:
- `flb_router`: Main routing functionality
- `flb_event`: Event chunk management
- `flb_mem`: Memory management
- `flb_log`: Logging functionality
- `cfl`: Common Fluent Library for data structures

It integrates with:
- Routing system for condition-based decisions
- Event processing pipeline
- Configuration system for route definitions

## Implementation Details

The current implementation serves as a foundation for future advanced routing capabilities:

1. **Signal Conversion**: Maps event chunk types to router signals for consistent handling.

2. **Route Validation**: Ensures routes are properly configured before evaluation.

3. **Event Type Filtering**: Validates that event types are compatible with route configurations.

4. **Signal Matching**: Checks if route signals match the event signal.

5. **Default Route Handling**: Automatically routes events to default routes when appropriate.

6. **Extensibility Framework**: Provides structure for future implementation of field-based condition evaluation.

The condition evaluation process follows these steps:
1. Convert event chunk to signal type
2. Validate route configuration
3. Check event type compatibility
4. Verify signal matching
5. Handle default routes
6. Delegate to specific evaluators

Note: The specific evaluators (`flb_condition_eval_*`) are currently placeholders and return `FLB_FALSE` until the full condition evaluation engine is implemented.

## Usage Examples

### Checking Event Routing Eligibility
```c
// Check if an event should be routed to a specific output
struct flb_event_chunk *chunk;
struct flb_route *route;

// Convert chunk to signal
uint32_t signal = flb_router_signal_from_chunk(chunk);
if (signal == 0) {
    printf("Invalid or unknown event type\n");
    return FLB_FALSE;
}

// Evaluate route conditions
int should_route = flb_route_condition_eval(chunk, route);
if (should_route) {
    printf("Event should be routed to this output\n");
} else {
    printf("Event should not be routed to this output\n");
}
```

### Event Type Filtering
```c
// Check if route accepts specific event type
uint32_t event_signal = FLB_ROUTER_SIGNAL_LOGS;
uint32_t route_signals = route->signals;

if (route_signals == FLB_ROUTER_SIGNAL_ANY ||
    (route_signals & event_signal)) {
    printf("Route accepts this event type\n");
} else {
    printf("Route does not accept this event type\n");
}
```

### Default Route Handling
```c
// Check if this is a default route
if (route->condition && route->condition->is_default) {
    printf("This is a default route\n");
    // Default routes typically accept all events
    return FLB_TRUE;
}
```

### Configuration Example
```yaml
# Example router configuration with conditions
routes:
  - name: high_cpu_route
    signals:
      - logs
    condition:
      - field: $cpu.usage
        op: >
        value: "80"
    outputs:
      - name: alert_output
      - name: monitoring_output
    
  - name: default_route
    signals:
      - any
    condition:
      is_default: true
    outputs:
      - name: storage_output
```

In this example:
- High CPU usage logs are routed to alert and monitoring outputs
- All other events are routed to storage output via default route
- Event type filtering ensures only log events are considered for the high CPU route

### Future Implementation Notes

The current implementation is designed to support future enhancements:

1. **Field-Based Conditions**: Will evaluate record fields using record accessors
2. **Complex Logic**: Support for AND/OR combinations of conditions
3. **Performance Optimization**: Caching of evaluation results for repeated conditions
4. **Extensibility**: Plugin architecture for custom condition evaluators

Developers working on extending this functionality should focus on:
- Implementing the actual condition evaluation logic in `flb_condition_eval_*` functions
- Adding support for complex condition expressions
- Integrating with record accessor system for field evaluation
- Optimizing performance for high-throughput scenarios