# flb_ml_parser_cri.c

## Overview

This file implements the Container Runtime Interface (CRI) multiline parser for Fluent Bit. It handles log messages from container runtimes that follow the CRI specification, such as containerd and CRI-O.

## Key Functions

### Parser Creation

- `flb_ml_parser_cri()` - Creates a multiline parser specifically for CRI log format

## Important Data Structures

### CRI Parser Configuration
The CRI parser is configured with:
- Type: `FLB_ML_EQ` (equality matching)
- Match String: `"F"` (indicates final/complete log line)
- Negate: `FLB_FALSE` (no negation)
- Flush Timeout: Default multiline flush timeout
- Key Content: `"log"` (field containing log message)
- Key Group: `"stream"` (field indicating stdout/stderr stream)
- Key Pattern: `"_p"` (field indicating if line is partial or final)

## Dependencies

This module depends on:
- Fluent Bit core libraries
- Multiline processing headers
- Parser management functionality (flb_ml_parser.c)
- JSON parser for CRI log format

## Implementation Details

The CRI parser handles log messages that follow the CRI specification format:
```
{"log": "message content\n", "stream": "stdout", "time": "2021-02-01T01:40:03.53412Z"}
```

Key features:
1. **Partial Line Detection**: Uses the `_p` field to identify partial vs. complete lines
2. **Stream Grouping**: Groups messages by `stream` field (stdout/stderr)
3. **Content Extraction**: Extracts log content from the `log` field
4. **Time Handling**: Preserves original timestamp from log entry

## Usage Examples

```c
// Create a CRI multiline parser
struct flb_ml_parser *cri_parser = flb_ml_parser_cri(config);

// This parser will automatically concatenate partial log lines
// from CRI-compliant container runtimes until a complete line is found
```