# flb_ml_rule.c Documentation

## Overview

This file contains the implementation for multiline rule processing in Fluent Bit. It handles the creation, initialization, and processing of multiline rules that define how log entries should be grouped and processed based on specific patterns.

## Purpose

The primary purpose of this file is to provide the core functionality for defining and processing multiline rules. Multiline rules define state transitions that determine when a multiline message is complete or should continue buffering additional lines. This file manages:
- Rule creation and destruction
- Rule initialization and mapping
- Pattern matching for rule transitions
- State management for multiline processing
- Rule validation and error handling

## Key Data Structures

### Rule Context (`struct flb_ml_rule`)
- Contains the definition of a multiline rule including pattern matching criteria
- Tracks state transitions between different parsing states
- Maintains regex patterns for content and end matching
- Stores rule metadata and configuration

### To State Mapping (`struct to_state`)
- Maps rule transitions between different states
- Links rules that can transition from one state to another
- Enables complex state machine behavior for multiline processing

## Key Functions

### Rule Creation and Management
- `flb_ml_rule_create()` - Creates a new multiline rule with specified patterns and state transitions
- `flb_ml_rule_destroy()` - Cleans up a rule and releases associated resources
- `flb_ml_rule_destroy_all()` - Destroys all rules associated with a multiline parser

### Rule Initialization
- `flb_ml_rule_init()` - Initializes all rules for a multiline parser, mapping state transitions
- `set_to_state_map()` - Maps rule transitions based on state relationships

### Rule Processing
- `flb_ml_rule_process()` - Processes incoming log data against defined rules
- `try_start_state()` - Attempts to match incoming data against start state rules
- `try_flushing_buffer()` - Determines when to flush buffered multiline content

## Important Variables

### Rule Configuration
- `start_state` - Flag indicating if this rule represents a starting point for multiline processing
- `from_states` - List of states that can transition to this rule
- `to_state` - Target state for rule transitions
- `regex` - Regular expression pattern for matching log content
- `regex_end` - Regular expression pattern for end-of-message matching

### State Management
- `to_state_map` - List of possible state transitions from this rule

## Dependencies

This module integrates with several core Fluent Bit components:
- `flb_regex.h` - Regular expression processing for pattern matching
- `flb_slist.h` - String list utilities for managing state names
- `flb_mem.h` - Memory management utilities
- `flb_sds.h` - String data structure utilities
- `flb_utils.h` - General utility functions

## Notable Implementation Details

### State Machine Approach
The multiline rule processing uses a state machine approach where each rule defines transitions between different parsing states. This allows for complex multiline patterns where messages can have multiple continuation lines with different characteristics.

### Rule Validation
Rules are validated during initialization to ensure that all referenced states are properly defined and that the state machine is consistent. This prevents runtime errors from misconfigured rules.

### Pattern Matching Optimization
The implementation uses efficient pattern matching algorithms to quickly identify when log entries match rule criteria, minimizing processing overhead during high-volume log processing.

### Start State Requirement
The first rule in a multiline parser must define a 'start_state' to establish the initial parsing context. This ensures that multiline processing begins correctly.

## Algorithm Overview

The multiline rule processing follows this general flow:
1. Incoming log data is examined against active rules
2. If in a continuation state, check for matching next-state rules
3. If no continuation match, check for start state matches
4. Apply appropriate pattern matching based on rule type
5. Update internal state tracking for the stream group
6. Determine if buffered content should be flushed
7. Return processing status for further handling

## Memory Management

The implementation uses Fluent Bit's memory management utilities (`flb_calloc`, `flb_free`) for consistent memory handling. String data structures use the SDS library for efficient operations. All allocated resources are properly tracked and freed during cleanup operations.

## Thread Safety

The rule processing functions are designed to be thread-safe in multi-threaded environments, using appropriate locking mechanisms where necessary to protect shared rule data structures.

## Usage Examples

### Creating a Multiline Rule
```c
int ret = flb_ml_rule_create(ml_parser,
                             "start_state, java_exception",
                             "/^.*Exception: .*/",
                             "java_after_exception", NULL);
```

### Processing Log Data
```c
int result = flb_ml_rule_process(ml_parser, stream, group,
                                 full_map, buf, size, &timestamp,
                                 val_content, val_pattern);
```

## Error Handling

The functions return specific error codes:
- `0` or positive values indicate success
- `-1` indicates general failure
- `FLB_MULTILINE_TRUNCATED` indicates the message was truncated due to size limits

Rule creation failures are reported through Fluent Bit's logging system with descriptive error messages.

## Configuration Options

Multiline rules can be configured through:
- State transition definitions
- Pattern matching criteria
- Rule grouping and relationships
- Custom state names for complex parsing scenarios

## Performance Considerations

For optimal performance:
1. Minimize the number of rules to reduce pattern matching overhead
2. Use efficient regex patterns that can be quickly evaluated
3. Design state machines with clear, distinct transition paths
4. Monitor memory usage for high-volume rule processing