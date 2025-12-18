# flb_ml_parser_go.c

## Overview

This file implements the Go language multiline parser for Fluent Bit. It handles multiline log messages and stack traces from Go applications, particularly panic situations.

## Key Functions

### Parser Creation

- `flb_ml_parser_go()` - Creates a multiline parser specifically for Go application logs

### Internal Functions

- `rule_error()` - Handles rule creation errors with proper cleanup

## Important Data Structures

### Go Parser Configuration
The Go parser is configured with:
- Type: `FLB_ML_REGEX` (regex pattern matching)
- Match String: `NULL` (uses regex rules instead)
- Negate: `FLB_FALSE` (no negation)
- Flush Timeout: Default multiline flush timeout
- Key Content: Configurable field name (defaults to content field)

### Regex Rules
The Go parser implements a state machine with these rules:

1. **Start States**:
   - `/\bpanic: /` → `go_after_panic`
   - `/http: panic serving/` → `go_goroutine`

2. **Continuation States**:
   - `go_after_panic` → `/^$/` → `go_goroutine`
   - `go_after_panic, go_after_signal, go_frame_1` → `/^$/` → `go_goroutine`
   - `go_after_panic` → `/^\[signal /` → `go_after_signal`
   - `go_goroutine` → `/^goroutine \d+ \[[^\]]+\]:$/` → `go_frame_1`
   - `go_frame_1` → `/^(?:[^\s.:]+\.)*[^\s.():]+\(|^created by /` → `go_frame_2`
   - `go_frame_2` → `/^\s/` → `go_frame_1`

## Dependencies

This module depends on:
- Fluent Bit core libraries
- Multiline processing headers
- Parser management functionality (flb_ml_parser.c)
- Rule processing functionality (flb_ml_rule.c)
- Regular expression library

## Implementation Details

The Go parser handles multiline messages from Go applications, particularly:
1. **Panic Messages**: Multi-line panic output with stack traces
2. **Goroutine Information**: Goroutine state information during panics
3. **Stack Frames**: Function call stack with file and line information
4. **Signal Information**: System signal details during crashes

The parser uses a state machine approach where:
- Initial panic or HTTP panic messages start the multiline sequence
- Empty lines indicate transitions between sections
- Goroutine information identifies the goroutine context
- Stack frame information continues until whitespace-only lines
- Signal information indicates system-level issues

## Usage Examples

```c
// Create a Go multiline parser
struct flb_ml_parser *go_parser = flb_ml_parser_go(config, "message");

// This parser will automatically concatenate Go panic messages
// and stack traces until a complete sequence is formed
```