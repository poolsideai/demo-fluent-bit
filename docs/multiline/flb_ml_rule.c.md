# flb_ml_rule.c

## Overview

This file implements the rule processing functionality for the multiline processing system in Fluent Bit. It handles the creation, management, and evaluation of regex-based rules that define multiline message patterns.

## Key Functions

### Rule Creation and Management

- `flb_ml_rule_create()` - Creates a new regex rule for multiline pattern matching
- `flb_ml_rule_destroy()` - Destroys a rule and its associated resources
- `flb_ml_rule_destroy_all()` - Destroys all rules associated with a parser
- `flb_ml_rule_init()` - Initializes all rules for a parser (maps state transitions)

### Rule Processing

- `flb_ml_rule_process()` - Processes incoming content against configured rules
- `try_start_state()` - Searches for matching start state rules
- `try_flushing_buffer()` - Determines when to flush buffered content

### State Management

- `set_to_state_map()` - Maps rule state transitions
- `to_states_exists()` - Checks if a state exists in any rule
- `to_states_matches_rule()` - Checks if a state matches a specific rule

## Important Data Structures

### flb_ml_rule
Represents a multiline processing rule with:
- Start state flag indicating if this is an initial rule
- List of from states (comma-separated)
- To state name for state transitions
- Regular expression for content pattern matching
- Optional end pattern regex
- List of mapped to-states for state transitions

### to_state
Helper structure for mapping state transitions with:
- Reference to the target rule
- List linkage for to_state_map

## Dependencies

This module depends on:
- Fluent Bit core libraries (flb_regex, flb_slist)
- Multiline processing headers
- Parser management functionality (flb_ml_parser.c)
- Group processing functionality (flb_ml_group.c)
- Regular expression library

## Implementation Details

The rule processing system provides:
1. **State Machine Implementation**: Rules form a state machine where each rule defines transitions between states
2. **Regex Pattern Matching**: Content is matched against regex patterns to determine rule applicability
3. **State Transition Mapping**: Automatic mapping of state transitions between rules
4. **Buffer Management**: Intelligent buffering and flushing based on rule matches
5. **Error Handling**: Comprehensive error checking and reporting

The processing flow:
1. Incoming content is checked against start state rules
2. If no start state matches, check continuation rules based on current state
3. On rule match, content is buffered and state is updated
4. State transitions are evaluated to determine when to flush content
5. Non-matching content triggers flushing of buffered data

## Usage Examples

```c
// Create a multiline parser with regex rules
struct flb_ml_parser *parser = flb_ml_parser_create_params(config, &params);

// Add regex rules to the parser
flb_ml_rule_create(parser, "start_state", "/^ERROR: /", "error_detail", NULL);
flb_ml_rule_create(parser, "error_detail", "/^[ \t]+.*$/", "error_detail", NULL);

// Initialize the rules (maps state transitions)
flb_ml_rule_init(parser);

// Process content against the rules
flb_ml_rule_process(parser, stream, group, full_map, buffer, size, &timestamp, NULL, NULL);
```