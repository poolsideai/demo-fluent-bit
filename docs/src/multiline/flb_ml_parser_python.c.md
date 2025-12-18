# flb_ml_parser_python.c Documentation

## Overview

This file contains the implementation for the Python stack trace multiline parser in Fluent Bit. It handles multiline log processing specifically for Python application stack traces and tracebacks.

## Purpose

The primary purpose of this file is to provide a specialized multiline parser for Python stack traces. Python applications often generate multiline exception messages and tracebacks that span multiple lines, and this parser correctly identifies and reconstructs these multiline messages.

## Key Components

### Python Parser Creation
- `flb_ml_parser_python()` - Creates a multiline parser specifically for Python stack traces

### Parser Configuration
- Uses regex pattern matching for Python traceback identification
- Handles continuation patterns specific to Python tracebacks
- Supports configurable key for pattern matching

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

### Multiline Handling
Python tracebacks can be identified by:
- Lines starting with `Traceback (most recent call last):`
- Lines starting with spaces followed by `File` references
- Exception class names at the end of the traceback
- Continuation lines that don't start with recognizable patterns

### Pattern Matching
The parser uses regex patterns to identify:
- Start of a new traceback (`Traceback` line)
- Continuation lines of an existing traceback (`File` lines)
- Exception lines at the end of tracebacks
- End of a traceback

## Key Functions

### Parser Factory
- `flb_ml_parser_python()` - Creates and configures a Python-specific multiline parser

## Dependencies

This module depends on:
- Core Fluent Bit libraries (`flb_info.h`)
- Multiline engine (`flb_ml.h`)
- Parser definitions (`flb_ml_parser.h`)
- Regular expression processing (`flb_regex.h`)

## Notable Features

### Regex-Based Pattern Matching
Uses sophisticated regex patterns to accurately identify Python traceback boundaries.

### Configurable Key Support
Supports configurable key names for pattern matching, allowing flexibility in different log formats.

### Complete Traceback Recognition
Properly handles the full structure of Python tracebacks from the initial trace line through the final exception.

### Automatic Flush Timeout
Implements a reasonable default flush timeout to prevent indefinite buffering of incomplete tracebacks.

## Usage Example

### Creating a Python Parser
```c
struct flb_ml_parser *python_parser = flb_ml_parser_python(config, FLB_ML_FLUSH_TIMEOUT, "message");
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