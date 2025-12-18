# flb_ml_parser_docker.c

## Overview

This file implements the Docker multiline parser for Fluent Bit. It handles log messages from Docker containers, which follow a specific JSON format for log entries.

## Key Functions

### Parser Creation

- `flb_ml_parser_docker()` - Creates a multiline parser specifically for Docker log format

### Internal Parser Creation

- `docker_parser_create()` - Creates the underlying JSON parser for Docker log format

## Important Data Structures

### Docker Parser Configuration
The Docker parser is configured with:
- Type: `FLB_ML_ENDSWITH` (end-with matching)
- Match String: `"\n"` (newline character indicating complete line)
- Negate: `FLB_FALSE` (no negation)
- Flush Timeout: Default multiline flush timeout
- Key Content: `"log"` (field containing log message)
- Key Group: `"stream"` (field indicating stdout/stderr stream)

### Docker Log Format
Docker logs follow this JSON structure:
```json
{"log": "message content\\n", "stream": "stdout", "time": "2021-02-01T01:40:03.53412Z"}
```

## Dependencies

This module depends on:
- Fluent Bit core libraries
- Multiline processing headers
- Parser management functionality (flb_ml_parser.c)
- JSON parser for Docker log format

## Implementation Details

The Docker parser handles log messages that follow the Docker JSON log format:
1. **Partial Line Detection**: Identifies partial log lines by checking if the `log` field ends with a newline
2. **Stream Grouping**: Groups messages by `stream` field (stdout/stderr)
3. **Content Extraction**: Extracts log content from the `log` field
4. **Time Handling**: Preserves original timestamp from log entry
5. **Size Limiting**: Docker limits log records to 16KB, so partial lines may occur

When a log entry's `log` field does NOT end with `\n`, it's considered a partial line and will be concatenated with subsequent entries until a complete line is formed.

## Usage Examples

```c
// Create a Docker multiline parser
struct flb_ml_parser *docker_parser = flb_ml_parser_docker(config);

// This parser will automatically concatenate partial log lines
// from Docker containers until a complete line is found
```