# flb_ml_parser_go.c Documentation

## Overview

This file contains the implementation for the Go stack trace multiline parser in Fluent Bit. It handles multiline log processing specifically for Go application stack traces. This parser is designed to recognize and reconstruct the complex multiline patterns found in Go runtime error messages and stack traces.

## Purpose

The primary purpose of this file is to provide a specialized multiline parser for Go stack traces. Go applications often generate multiline error messages and stack traces that span multiple lines, and this parser correctly identifies and reconstructs these multiline messages using sophisticated regex pattern matching.

## Key Components

### Go Parser Creation
- `flb_ml_parser_go()` - Creates a multiline parser specifically for Go stack traces

### Parser Configuration
- Uses regex pattern matching for Go stack trace identification
- Handles continuation patterns specific to Go stack traces
- Supports configurable key for pattern matching
- Implements a state machine approach for complex pattern recognition

## Implementation Details

### Go Stack Trace Format

Go stack traces typically follow these patterns:

#### Panic Messages
```
panic: runtime error: index out of range

goroutine 1 [running]:
main.processData(0xc0000b4000, 0x5, 0x5)
	/path/to/main.go:45 +0x123
main.main()
	/path/to/main.go:20 +0x89
```

#### Signal Handling
```
[signal SIGSEGV: segmentation violation code=0x1 addr=0x0 pc=0x456789]

goroutine 1 [running]:
main.crash()
	/path/to/main.go:15 +0x20
```

#### HTTP Panic
```
http: panic serving [::1]:1234: runtime error: index out of range

goroutine 1 [running]:
main.handleRequest()
	/path/to/main.go:45 +0x123
```

### State Machine Approach

The parser implements a sophisticated state machine with multiple states:
- `start_state` - Initial state for detecting the beginning of a Go stack trace
- `go_after_panic` - State after detecting a panic message
- `go_after_signal` - State after detecting a signal message
- `go_goroutine` - State for detecting goroutine information
- `go_frame_1` - State for detecting the first frame of a stack trace
- `go_frame_2` - State for detecting continuation frames

### Regex Pattern Matching

The parser uses the following regex patterns to identify Go stack trace components:

1. **Panic Detection**: `/\bpanic: /` - Identifies panic messages
2. **HTTP Panic Detection**: `/http: panic serving/` - Identifies HTTP panic messages
3. **Empty Line Transition**: `/^$/` - Handles empty lines between sections
4. **Signal Detection**: `/^\[signal /` - Identifies signal messages
5. **Goroutine Detection**: `/^goroutine \d+ \[[^\]]+\]:$/` - Identifies goroutine information
6. **Frame Detection**: `/^(?:[^\s.:]+\.)*[^\s.():]+\(|^created by /` - Identifies stack frames
7. **Continuation Frame Detection**: `/^\s/` - Identifies continuation lines with leading whitespace

### Multiline Handling

Go stack traces are identified by:
- Lines starting with `panic:` followed by error information
- Lines starting with `http: panic serving` for HTTP panics
- Lines starting with `[signal` for signal handling
- Goroutine information lines: `goroutine X [state]:`
- Function name lines followed by file paths and line numbers
- Continuation lines that start with whitespace

### Pattern Matching Logic

The parser uses regex patterns to identify:
- Start of a new stack trace (panic, signal, or HTTP panic)
- Transition to goroutine information
- Detection of stack frames
- Continuation of stack frames
- End of a stack trace (when a new start pattern is detected)

## Key Functions

### Parser Factory
- `flb_ml_parser_go()` - Creates and configures a Go-specific multiline parser with all regex rules

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

Uses sophisticated regex patterns to accurately identify Go stack trace boundaries. The patterns are designed to handle various Go runtime error formats including panics, signals, and HTTP panics.

### State Machine Architecture

Implements a state machine approach with multiple states to handle the complex structure of Go stack traces. This allows for precise identification of different components of a stack trace.

### Configurable Key Support

Supports configurable key names for pattern matching, allowing flexibility in different log formats and integration with various input sources.

### Comprehensive Error Handling

Implements robust error handling for rule creation failures with proper cleanup of partially allocated resources.

### Automatic Flush Timeout

Implements a reasonable default flush timeout (`FLB_ML_FLUSH_TIMEOUT`) to prevent indefinite buffering of incomplete stack traces.

## Algorithm Overview

The Go parser processing follows these steps:
1. Create a multiline parser with REGEX type and appropriate configuration
2. Add multiple regex rules to define the state machine for Go stack traces
3. Initialize the parser rules to map them for processing
4. Process incoming log entries against the regex rules
5. Transition between states based on pattern matches
6. Buffer continuation lines until a complete stack trace is identified
7. Flush complete stack traces to output with preserved metadata

## Key Configuration Parameters

### Parser Setup
- `name` - "go" (identifier for this parser mode)
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

### Creating a Go Parser
```c
struct flb_ml_parser *go_parser = flb_ml_parser_go(config, "message");
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

### Signal Handling Example
```
[signal SIGSEGV: segmentation violation code=0x1 addr=0x0 pc=0x456789]

goroutine 1 [running]:
main.crash()
	/path/to/main.go:15 +0x20
```

The parser correctly identifies the signal message and associated stack trace.

## Configuration and Customization

The Go parser can be customized through:
- Different flush timeouts based on log volume expectations
- Custom key mappings for different log formats
- Integration with parser contexts for additional preprocessing

## Performance Considerations

For optimal performance with Go stack traces:
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