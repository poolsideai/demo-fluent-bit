# flb_ml_parser_cri.c Documentation

## Overview

This file contains the implementation for the Container Runtime Interface (CRI) multiline parser in Fluent Bit. It handles multiline log processing specifically for Kubernetes container logs that follow the CRI specification.

## Purpose

The primary purpose of this file is to provide a specialized multiline parser for Container Runtime Interface logs. CRI is the standard interface for container runtimes in Kubernetes, and this parser handles the specific multiline patterns found in CRI-formatted logs.

## Key Components

### CRI Parser Creation
- `flb_ml_parser_cri()` - Creates a multiline parser specifically for CRI logs

### Parser Configuration
- Uses JSON parsing for CRI log format
- Handles multiline continuation patterns specific to CRI
- Groups by container stream identifiers

## Implementation Details

### CRI Log Format
CRI logs follow a specific JSON format where each log entry is a JSON object containing:
- `time` - Timestamp of the log entry
- `stream` - Stream identifier (stdout/stderr)
- `log` - Actual log content

### Multiline Handling
CRI logs can contain multiline messages that span multiple JSON entries. The parser:
- Identifies continuation lines based on content patterns
- Groups related lines by stream identifier
- Reconstructs complete multiline messages

### Stream Grouping
The parser groups log entries by the `stream` field to ensure that stdout and stderr logs are processed separately and correctly.

## Key Functions

### Parser Factory
- `flb_ml_parser_cri()` - Creates and configures a CRI-specific multiline parser

## Dependencies

This module depends on:
- Core Fluent Bit libraries (`flb_info.h`)
- Multiline engine (`flb_ml.h`)
- Parser definitions (`flb_ml_parser.h`)
- JSON parsing capabilities

## Notable Features

### Stream-Aware Processing
The parser correctly handles the separation of stdout and stderr streams, ensuring that multiline messages from different streams are not incorrectly combined.

### JSON Format Compliance
The parser is designed to work with the standard CRI JSON log format, making it compatible with Kubernetes container logs.

### Efficient Pattern Matching
Uses optimized pattern matching for identifying multiline continuations in CRI logs.

## Usage Example

### Creating a CRI Parser
```c
struct flb_ml_parser *cri_parser = flb_ml_parser_cri(config);
```

### Typical CRI Log Entry
```json
{"time":"2021-01-01T00:00:00.000000000Z","stream":"stdout","log":"first line\n"}
{"time":"2021-01-01T00:00:00.000001000Z","stream":"stdout","log":"continuation line\n"}
{"time":"2021-01-01T00:00:00.000002000Z","stream":"stdout","log":"final line\n"}
```

The parser would combine these three entries into a single multiline message:
```
first line
continuation line
final line
```