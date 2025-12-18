# flb_ml_parser_python.c Documentation

## Overview

This file contains the implementation for the Python stack trace multiline parser in Fluent Bit. It handles multiline log processing specifically for Python application stack traces and tracebacks. This parser is designed to recognize and reconstruct the complex multiline patterns found in Python runtime exception messages and stack traces.

## Purpose

The primary purpose of this file is to provide a specialized multiline parser for Python stack traces. Python applications often generate multiline exception messages and tracebacks that span multiple lines, and this parser correctly identifies and reconstructs these multiline messages using sophisticated regex pattern matching.

## Key Components

### Python Parser Creation
- `flb_ml_parser_python()` - Creates a multiline parser specifically for Python stack traces

### Parser Configuration
- Uses regex pattern matching for Python traceback identification
- Handles continuation patterns specific to Python tracebacks
- Supports configurable key for pattern matching
- Implements a state machine approach for complex pattern recognition

## Implementation Details

### Python Traceback Format

Python tracebacks typically follow this pattern:
```
Traceback (most recent call last):
  File "example.py", line 10, in <module>
    main()
  File "example.py", line 5, in main
    process_data()
  File "example.py", line 2, in process_data
    raise ValueError("invalid data")
ValueError: invalid data
```

### State Machine Approach

The parser implements a state machine with three states:
- `start_state` - Initial state for detecting the beginning of a Python traceback
- `python` - State for processing traceback frames
- `python_code` - State for handling code lines within traceback frames

### Regex Pattern Matching

The parser uses the following regex patterns to identify Python traceback components:

1. **Traceback Detection**: `/^Traceback \(most recent call last\):$/` - Identifies the start of a Python traceback
2. **Stack Frame Detection**: `/^[\t ]+File /` - Identifies stack trace frames
3. **Code Line Detection**: `/[^\t ]/` - Identifies code lines within stack frames
4. **Exception Detection**: `/^(?:[^\s.():]+\.)*[^\s.():]+:/` - Identifies exception class names at the end of tracebacks

### Multiline Handling

Python tracebacks are identified by:
- The `Traceback (most recent call last):` line that starts a traceback
- Stack trace frames that start with whitespace followed by `File` references
- Code lines within frames that contain non-whitespace characters
- Exception class names at the end of the traceback
- Continuation lines that don't start with recognizable patterns

### Pattern Matching Logic

The parser uses regex patterns to identify:
- Start of a new traceback (`Traceback` line)
- Stack trace frames (`File` lines)
- Code lines within frames
- Exception lines at the end of tracebacks
- End of a traceback (when a new start pattern is detected)

## Key Functions

### Parser Factory
- `flb_ml_parser_python()` - Creates and configures a Python-specific multiline parser with all regex rules

### Internal Helper Functions
- `rule_error()` - Handles rule creation failures with proper cleanup

## Dependencies

This module depends on:
- Core Fluent Bit libraries (`flb_info.h`) for basic functionality
- Multiline engine (`flb_ml.h`) for integration with core multiline functionality
- Parser definitions (`flb_ml_parser.h`) for parser creation and management
- Rule processing (`flb_ml_rule.h`) for regex-based multiline patterns
- Regular expression processing (`flb_regex.h`) for pattern matching

## Notable Features

### Sophisticated Regex-Based Pattern Matching

Uses sophisticated regex patterns to accurately identify Python traceback boundaries. The patterns are designed to handle various Python runtime error formats including standard exceptions, tracebacks with multiple frames, and complex nested exceptions.

### State Machine Architecture

Implements a state machine approach with multiple states to handle the complex structure of Python tracebacks. This allows for precise identification of different components of a traceback including stack frames and code lines.

### Configurable Key Support

Supports configurable key names for pattern matching, allowing flexibility in different log formats and integration with various input sources.

### Complete Traceback Recognition

Properly handles the full structure of Python tracebacks from the initial trace line through the final exception, including all intermediate stack frames and code lines.

### Automatic Flush Timeout

Implements a reasonable default flush timeout (`FLB_ML_FLUSH_TIMEOUT`) to prevent indefinite buffering of incomplete tracebacks.

## Algorithm Overview

The Python parser processing follows these steps:
1. Create a multiline parser with REGEX type and appropriate configuration
2. Add multiple regex rules to define the state machine for Python tracebacks
3. Initialize the parser rules to map them for processing
4. Process incoming log entries against the regex rules
5. Transition between states based on pattern matches
6. Buffer continuation lines until a complete traceback is identified
7. Flush complete tracebacks to output with preserved metadata

## Key Configuration Parameters

### Parser Setup
- `name` - "python" (identifier for this parser mode)
- `type` - `FLB_ML_REGEX` (regex-based matching for complex patterns)
- `match_str` - NULL (no simple string matching)
- `negate` - `FLB_FALSE` (do not negate the match)
- `flush_ms` - `FLB_ML_FLUSH_TIMEOUT` (default flush timeout)
- `key_content` - Configurable key (default: "message") for content extraction
- `key_group` - NULL (no stream grouping)
- `key_pattern` - NULL (no separate pattern key)

## Memory Management

The implementation uses Fluent Bit's memory management utilities for consistent allocation and deallocation. String data is managed using the SDS (String Data Structure) library for efficient operations. All allocated resources are properly tracked and freed during cleanup operations.

## Thread Safety

The parser creation function is designed to be thread-safe in multi-threaded environments, using appropriate locking mechanisms where necessary to protect shared configuration data structures.

## Error Handling

The function returns specific error codes:
- Valid pointer to multiline parser indicates success
- NULL indicates failure due to resource allocation issues, rule creation failures, or parser initialization failures

Rule creation failures are handled with descriptive error messages and proper cleanup of partially allocated resources.

## Usage Example

### Creating a Python Parser
```c
struct flb_ml_parser *python_parser = flb_ml_parser_python(config, "message");
```

### Typical Python Traceback
```
Traceback (most recent call last):
  File "example.py", line 10, in <module>
    main()
  File "example.py", line 5, in main
    process_data()
  File "example.py", line 2, in process_data
    raise ValueError("invalid data")
ValueError: invalid data
```

The parser would identify this as a single multiline message and reconstruct it appropriately.

### Complex Traceback with Multiple Frames
```
Traceback (most recent call last):
  File "main.py", line 20, in <module>
    app.run()
  File "framework.py", line 100, in run
    self.process_request()
  File "framework.py", line 50, in process_request
    handler.handle()
  File "handlers.py", line 15, in handle
    data = self.fetch_data()
  File "handlers.py", line 8, in fetch_data
    return database.query(sql)
  File "database.py", line 30, in query
    raise DatabaseError("Connection failed")
DatabaseError: Connection failed
```

The parser correctly identifies all frames of the traceback and the final exception as a single multiline entity.

### Traceback with Nested Exception
```
Traceback (most recent call last):
  File "main.py", line 10, in <module>
    main()
  File "main.py", line 5, in main
    process_data()
  File "main.py", line 2, in process_data
    raise RuntimeError("processing failed")
RuntimeError: processing failed

During handling of the above exception, another exception occurred:

Traceback (most recent call last):
  File "main.py", line 15, in <module>
    try:
  File "main.py", line 16, in <module>
    main()
  File "main.py", line 7, in main
    cleanup()
  File "main.py", line 3, in cleanup
    raise Exception("cleanup failed")
Exception: cleanup failed
```

The parser correctly handles nested exceptions that occur during exception handling.

## Configuration and Customization

The Python parser can be customized through:
- Different flush timeouts based on log volume expectations
- Custom key mappings for different log formats
- Integration with parser contexts for additional preprocessing

## Performance Considerations

For optimal performance with Python tracebacks:
1. Use the default flush timeout unless specific latency requirements exist
2. Ensure proper key configuration to match the actual log format
3. Monitor memory usage for high-volume log processing
4. Leverage the efficient regex pattern matching for log parsing

## Integration Points

This module integrates with:
- The main multiline engine (`flb_ml.c`) for context creation and processing
- Rule processing (`flb_ml_rule.c`) for regex-based multiline patterns
- The Fluent Bit configuration system for parser registration
- Input plugins for multiline processing integration

## Testing and Debugging

Debugging can be enabled through Fluent Bit's logging system. Rule creation failures are reported with descriptive error messages to aid in troubleshooting configuration issues. The regex patterns used for parsing can be verified independently to ensure proper log format recognition.