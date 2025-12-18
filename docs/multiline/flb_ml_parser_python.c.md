# flb_ml_parser_python.c

## Overview

This file implements the Python language multiline parser for Fluent Bit. It handles multiline log messages and traceback information from Python applications.

## Key Functions

### Parser Creation

- `flb_ml_parser_python()` - Creates a multiline parser specifically for Python application logs

### Internal Functions

- `rule_error()` - Handles rule creation errors with proper cleanup

## Important Data Structures

### Python Parser Configuration
The Python parser is configured with:
- Type: `FLB_ML_REGEX` (regex pattern matching)
- Match String: `NULL` (uses regex rules instead)
- Negate: `FLB_FALSE` (no negation)
- Flush Timeout: Default multiline flush timeout
- Key Content: Configurable field name (defaults to content field)

### Regex Rules
The Python parser implements a state machine with these rules:

1. **Traceback Start States**:
   - `/^Traceback \(most recent call last\):$/` → `python_after_traceback`

2. **Traceback Continuation States**:
   - `python_after_traceback` → `/^[ \t]*File ".*", line \d+.*$/` → `python_frame`
   - `python_frame` → `/^[ \t]*\w+\(.*\)$/` → `python_frame`
   - `python_frame` → `/^[ \t]*\w+\(.*\)$/` → `python_frame`
   - `python_frame` → `/^.*Exception: .*$/` → `python_exception`

## Dependencies

This module depends on:
- Fluent Bit core libraries
- Multiline processing headers
- Parser management functionality (flb_ml_parser.c)
- Rule processing functionality (flb_ml_rule.c)
- Regular expression library

## Implementation Details

The Python parser handles multiline messages from Python applications, particularly:
1. **Traceback Messages**: Multi-line traceback output with stack frames
2. **File Information**: Source file names and line numbers
3. **Function Calls**: Method and function call information
4. **Exception Details**: Exception type and message information

The parser uses a state machine approach where:
- Traceback messages start the multiline sequence
- File and line information continues the sequence
- Function call information provides context
- Exception details conclude the traceback sequence

## Usage Examples

```c
// Create a Python multiline parser
struct flb_ml_parser *python_parser = flb_ml_parser_python(config, "message");

// This parser will automatically concatenate Python traceback messages
// and exception information until a complete sequence is formed
```