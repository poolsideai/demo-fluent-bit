# flb_ml_parser_ruby.c

## Overview

This file implements the Ruby multiline parser for Fluent Bit. It defines rules for parsing Ruby exception stack traces that span multiple lines. The parser is designed to identify the start of Ruby exceptions and continue parsing subsequent lines that contain exception details.

## Key Functions

### `flb_ml_parser_ruby`

Creates and initializes a multiline parser specifically for Ruby exception stack traces.

**Parameters:**
- `config`: Fluent Bit configuration context
- `key`: Key name for the parsed content

**Returns:**
- Pointer to the created multiline parser on success
- NULL on failure

## Important Variables/Constants

- `FLB_ML_REGEX`: Specifies that this parser uses regular expression rules
- `FLB_ML_FLUSH_TIMEOUT`: Default timeout value for flushing multiline records
- `FLB_FALSE`: Boolean constant for negation flag

## Dependencies

- `flb_ml.h`: Main multiline header
- `flb_ml_rule.h`: Multiline rule definitions
- `flb_ml_parser.h`: Multiline parser interface

## Implementation Details

The Ruby multiline parser defines two key rules:

1. **Start Rule**: Identifies the beginning of a Ruby exception using the pattern `/^.+:\d+:in\s+.*/`
   - Matches lines that contain a file path, line number, and method name
   - Example: `app.rb:15:in 'method_name'`

2. **Continuation Rule**: Matches subsequent lines that continue the exception trace using `/^\s+from\s+.*:\d+:in\s+.*/`
   - Matches lines starting with whitespace followed by "from" and exception details
   - Example: `    from app.rb:10:in 'main'`

The parser uses a state machine approach with states:
- `ruby_start_exception`: Initial state for detecting Ruby exceptions
- `ruby_after_exception`: State for continuing exception parsing
- `ruby`: Final state for completed exception parsing

## Usage

This parser is automatically used when the `ruby` mode is specified in the multiline parser configuration:

```ini
[PARSER]
    Name   ruby
    Format regex
    Regex  ^.+:\d+:in\s+.\*
    State  ruby_start_exception
```

The parser is particularly useful for applications that generate Ruby exception stack traces, allowing them to be properly formatted as single log entries rather than fragmented across multiple lines.