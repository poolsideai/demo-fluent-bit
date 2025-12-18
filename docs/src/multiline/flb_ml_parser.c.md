# flb_ml_parser.c Documentation

## Overview

This file contains the implementation for creating and managing multiline parser definitions in Fluent Bit. It provides the core functionality for defining how multiline log entries should be processed, including pattern matching, rule definitions, and parser initialization.

## Purpose

The primary purpose of this file is to provide functions for creating, configuring, and managing multiline parser definitions. These parsers define the rules and patterns used to identify when a multiline log entry is complete or when additional lines should be accumulated.

## Key Functions

### Parser Creation and Management
- `flb_ml_parser_create()` - Creates a new multiline parser definition
- `flb_ml_parser_destroy()` - Cleans up a multiline parser definition
- `flb_ml_parser_add_rule()` - Adds a rule to a multiline parser

### Rule Management
- `flb_ml_rule_create()` - Creates a new multiline rule
- `flb_ml_rule_destroy()` - Cleans up a multiline rule

### Rule Processing
- `flb_ml_rule_process()` - Processes a log entry against multiline rules

## Key Data Structures

### Multiline Parser (`struct flb_ml_parser`)
- Defines the configuration for a multiline parsing mode
- Contains matching rules and pattern definitions
- Links to parser context for preprocessing
- Manages key mappings for content, grouping, and pattern matching

### Multiline Rule (`struct flb_ml_rule`)
- Defines a single rule for multiline processing
- Contains regex patterns for start and end conditions
- Manages state transitions between rule states

## Important Parameters

### Parser Definition Parameters
- `type` - Matching type (REGEX, ENDSWITH, EQ)
- `match_str` - String to match against (for ENDSWITH/EQ)
- `negate` - Whether to negate the match condition
- `flush_ms` - Automatic flush timeout in milliseconds
- `key_content` - Key containing the multiline content
- `key_group` - Key for grouping streams
- `key_pattern` - Key containing the pattern for matching
- `parser_ctx` - Parser context for preprocessing
- `parser_name` - Name of parser for delayed initialization

### Rule Definition Parameters
- `from_states` - List of states that can transition to this rule
- `to_state` - Target state after rule matches
- `regex` - Regular expression for start pattern matching
- `regex_end` - Regular expression for end pattern matching

## Dependencies

This module depends on:
- Core Fluent Bit libraries (`flb_info.h`, `flb_mem.h`)
- String data structures (`flb_sds.h`)
- Regular expression processing (`flb_regex.h`)
- Linked list utilities (`mk_list.h`)
- Main multiline engine (`flb_ml.h`)
- Parser definitions (`flb_parser.h`)

## Notable Implementation Details

### Rule-Based Processing
For REGEX-type parsers, the system uses a state machine approach where rules define transitions between states. This allows for complex multiline patterns where different parts of a message may have different characteristics.

### Flexible Matching Strategies
The parser supports three matching types:
- REGEX: Full regular expression pattern matching
- ENDSWITH: Simple string suffix matching
- EQ: Exact string matching

### Delayed Parser Initialization
Parsers can be defined with a parser name rather than an immediate parser context, allowing for deferred initialization when the parser is actually needed.

### Key Mapping Flexibility
The system supports mapping different keys for content, grouping, and pattern matching, providing flexibility for various log formats and structures.

## Usage Examples

### Creating a Simple ENDSWITH Parser
```c
struct flb_ml_parser *parser = flb_ml_parser_create(config,
    "simple_mode",
    FLB_ML_ENDSWITH,
    "\n",
    FLB_FALSE,
    1000,
    "message",
    NULL,
    NULL,
    NULL,
    NULL);
```

### Creating a REGEX-Based Parser with Rules
```c
struct flb_ml_parser *parser = flb_ml_parser_create(config,
    "regex_mode",
    FLB_ML_REGEX,
    NULL,
    FLB_FALSE,
    2000,
    "log",
    "stream",
    NULL,
    NULL,
    NULL);

// Add rules for the parser
struct flb_ml_rule *start_rule = flb_ml_rule_create(parser, "start");
struct flb_ml_rule *continue_rule = flb_ml_rule_create(parser, "continue");
struct flb_ml_rule *end_rule = flb_ml_rule_create(parser, "end");

flb_ml_parser_add_rule(parser, start_rule);
```

### Adding Rules to a Parser
```c
struct flb_ml_rule *rule = flb_ml_rule_create(parser, "my_rule");
// Configure rule patterns and transitions
flb_ml_parser_add_rule(parser, rule);
```