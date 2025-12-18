# flb_ml_parser_cri.c Documentation

## Overview

This file contains the implementation for the Container Runtime Interface (CRI) multiline parser in Fluent Bit. It handles multiline log processing specifically for Kubernetes container logs that follow the CRI specification. This parser is designed to work with the standard CRI log format used by container runtimes in Kubernetes environments.

## Purpose

The primary purpose of this file is to provide a specialized multiline parser for Container Runtime Interface logs. CRI is the standard interface for container runtimes in Kubernetes, and this parser handles the specific multiline patterns found in CRI-formatted logs. The parser recognizes the CRI log format and properly reconstructs multiline messages that span multiple log entries.

## Key Components

### CRI Parser Creation
- `flb_ml_parser_cri()` - Creates a multiline parser specifically for CRI logs

### Parser Configuration
- Uses regex parsing for CRI log format with custom pattern
- Handles multiline continuation patterns specific to CRI
- Groups by container stream identifiers (stdout/stderr)
- Uses equality matching for the 'F' (full) indicator

## Implementation Details

### CRI Log Format

CRI logs follow a specific format where each log entry is a line containing:
- `time` - Timestamp of the log entry
- `stream` - Stream identifier (stdout/stderr)
- `partial` - Indicator (F for full line, P for partial line)
- `log` - Actual log content

Example format:
```
2021-01-01T00:00:00.000000000Z stdout F first line
2021-01-01T00:00:00.000001000Z stdout P continuation line
2021-01-01T00:00:00.000002000Z stdout F final line
```

### Regex Pattern
The parser uses the following regex pattern to parse CRI logs:
```c
#define FLB_ML_CRI_REGEX \
  "^(?<time>.+?) (?<stream>stdout|stderr) (?<_p>F|P) (?<log>.*)$"
```

This pattern captures:
- `time` - The timestamp
- `stream` - The stream identifier (stdout/stderr)
- `_p` - The partial indicator (F/P)
- `log` - The actual log content

### Time Format
The parser uses the following time format specification:
```c
#define FLB_ML_CRI_TIME \
  "%Y-%m-%dT%H:%M:%S.%L%z"
```

### Multiline Handling
CRI logs can contain multiline messages that span multiple log entries. The parser:
- Identifies complete lines by the 'F' indicator in the partial field
- Identifies continuation lines by the 'P' indicator
- Groups related lines by stream identifier
- Reconstructs complete multiline messages by concatenating partial lines

### Stream Grouping
The parser groups log entries by the `stream` field to ensure that stdout and stderr logs are processed separately and correctly. This prevents mixing of different stream types in the same multiline message.

## Key Functions

### Parser Factory
- `flb_ml_parser_cri()` - Creates and configures a CRI-specific multiline parser

### Internal Helper Functions
- `cri_parser_create()` - Creates the underlying regex parser for CRI log format

## Dependencies

This module depends on:
- Core Fluent Bit libraries (`flb_info.h`) for basic functionality
- Multiline engine (`flb_ml.h`) for integration with core multiline functionality
- Parser definitions (`flb_ml_parser.h`) for parser creation and management
- Regex parsing capabilities through Fluent Bit's parser system

## Notable Features

### Stream-Aware Processing
The parser correctly handles the separation of stdout and stderr streams, ensuring that multiline messages from different streams are not incorrectly combined. This is achieved through the `key_group` parameter set to "stream".

### CRI Format Compliance
The parser is designed to work with the standard CRI log format used by Kubernetes container runtimes, making it compatible with logs from Docker, containerd, and other CRI-compliant runtimes.

### Efficient Pattern Matching
Uses optimized regex pattern matching for identifying multiline continuations in CRI logs. The pattern specifically looks for the 'F' (full) indicator to determine when a multiline message is complete.

### Automatic Flush Mechanism
The parser uses the default flush timeout (`FLB_ML_FLUSH_TIMEOUT`) to ensure that incomplete multiline messages are not held indefinitely, preventing memory issues and ensuring timely delivery of log data.

## Algorithm Overview

The CRI parser processing follows these steps:
1. Incoming log entries are parsed using the regex pattern to extract fields
2. The partial indicator ('F' or 'P') is examined to determine if the entry is complete
3. Entries with 'F' indicator are treated as complete messages
4. Entries with 'P' indicator are treated as continuations and buffered
5. When a complete entry is received, all buffered continuations are concatenated
6. The complete message is flushed to output with preserved metadata

## Key Configuration Parameters

### Parser Setup
- `name` - "cri" (identifier for this parser mode)
- `type` - `FLB_ML_EQ` (equality matching for the 'F' indicator)
- `match_str` - "F" (string to match for complete lines)
- `negate` - `FLB_FALSE` (do not negate the match)
- `flush_ms` - `FLB_ML_FLUSH_TIMEOUT` (default flush timeout)
- `key_content` - "log" (key containing the actual log content)
- `key_group` - "stream" (key for grouping by stream)
- `key_pattern` - "_p" (key containing the partial indicator)

## Memory Management

The implementation uses Fluent Bit's memory management utilities for consistent allocation and deallocation. String data is managed using the SDS (String Data Structure) library for efficient operations. All allocated resources are properly tracked and freed during cleanup operations.

## Thread Safety

The parser creation function is designed to be thread-safe in multi-threaded environments, using appropriate locking mechanisms where necessary to protect shared configuration data structures.

## Error Handling

The function returns specific error codes:
- Valid pointer to multiline parser indicates success
- NULL indicates failure due to resource allocation issues or parser creation failures

Invalid configurations are reported through Fluent Bit's logging system with descriptive error messages.

## Usage Example

### Creating a CRI Parser
```c
struct flb_ml_parser *cri_parser = flb_ml_parser_cri(config);
```

### Typical CRI Log Entry Sequence
```
2021-01-01T00:00:00.000000000Z stdout F first line
2021-01-01T00:00:00.000001000Z stdout P continuation line
2021-01-01T00:00:00.000002000Z stdout F final line
```

The parser would combine these three entries into a single multiline message:
```
first line
continuation line
final line
```

### Incomplete Line Handling
```
2021-01-01T00:00:00.000000000Z stdout P incomplete line
2021-01-01T00:00:00.000001000Z stdout F continuation line
```

The parser would combine these into:
```
incomplete line
continuation line
```

## Configuration and Customization

The CRI parser can be customized through:
- Different flush timeouts based on log volume expectations
- Custom key mappings for different log formats
- Integration with parser contexts for additional preprocessing

## Performance Considerations

For optimal performance with CRI logs:
1. Use the default flush timeout unless specific latency requirements exist
2. Ensure proper stream grouping to prevent cross-stream contamination
3. Monitor memory usage for high-volume log processing
4. Leverage the efficient regex pattern matching for log parsing

## Integration Points

This module integrates with:
- The main multiline engine (`flb_ml.c`) for context creation and processing
- The parser system (`flb_parser.h`) for log format parsing
- The Fluent Bit configuration system for parser registration
- Input plugins for multiline processing integration

## Testing and Debugging

Debugging can be enabled through Fluent Bit's logging system. Parser creation failures are reported with descriptive error messages to aid in troubleshooting configuration issues. The regex pattern used for parsing can be verified independently to ensure proper log format recognition.