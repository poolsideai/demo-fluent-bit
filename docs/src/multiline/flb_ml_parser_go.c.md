# flb_ml_parser_go.c Documentation

## Overview

This file contains the implementation for the Go stack trace multiline parser in Fluent Bit. It handles multiline log processing specifically for Go application stack traces.

## Purpose

The primary purpose of this file is to provide a specialized multiline parser for Go stack traces. Go applications often generate multiline error messages and stack traces that span multiple lines, and this parser correctly identifies and reconstructs these multiline messages.

## Key Components

### Go Parser Creation
- `flb_ml_parser_go()` - Creates a multiline parser specifically for Go stack traces

### Parser Configuration
- Uses regex pattern matching for Go stack trace identification
- Handles continuation patterns specific to Go stack traces
- Supports configurable key for pattern matching

## Implementation Details

### Go Stack Trace Format
Go stack traces typically follow this pattern:
```
goroutine 1 [running]:
main.main()
	/path/to/file.go:15 +0x20
main.function()
	/path/to/file.go:10 +0x20
```

### Multiline Handling
Go stack traces can be identified by:
- Lines starting with `goroutine` followed by state information
- Function names followed by file paths and line numbers
- Continuation lines that don't start with recognizable patterns

### Pattern Matching
The parser uses regex patterns to identify:
- Start of a new stack trace
- Continuation lines of an existing stack trace
- End of a stack trace

## Key Functions

### Parser Factory
- `flb_ml_parser_go()` - Creates and configures a Go-specific multiline parser

## Dependencies

This module depends on:
- Core Fluent Bit libraries (`flb_info.h`)
- Multiline engine (`flb_ml.h`)
- Parser definitions (`flb_ml_parser.h`)
- Regular expression processing (`flb_regex.h`)

## Notable Features

### Regex-Based Pattern Matching
Uses sophisticated regex patterns to accurately identify Go stack trace boundaries.

### Configurable Key Support
Supports configurable key names for pattern matching, allowing flexibility in different log formats.

### Automatic Flush Timeout
Implements a reasonable default flush timeout to prevent indefinite buffering of incomplete stack traces.

## Usage Example

### Creating a Go Parser
```c
struct flb_ml_parser *go_parser = flb_ml_parser_go(config, FLB_ML_FLUSH_TIMEOUT, "message");
```

### Typical Go Stack Trace
```
goroutine 1 [running]:
main.main()
	/path/to/main.go:15 +0x20
main.function()
	/path/to/main.go:10 +0x20
```

The parser would identify this as a single multiline message and reconstruct it appropriately.

### Complex Stack Trace Example
```
panic: runtime error: index out of range

goroutine 1 [running]:
main.processData(0xc0000b4000, 0x5, 0x5)
	/path/to/main.go:45 +0x123
main.main()
	/path/to/main.go:20 +0x89
```

The parser correctly identifies the panic message and the associated stack trace as a single multiline entity.