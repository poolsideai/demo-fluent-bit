# flb_parser_regex.c Documentation

## Overview

This file implements the regex-based parser for Fluent Bit, which handles parsing of unstructured log data using regular expressions. The regex parser is one of the most flexible parsing mechanisms in Fluent Bit, allowing users to define complex patterns to extract structured data from virtually any log format.

The implementation leverages Fluent Bit's regex engine to efficiently match patterns against log lines and extract named capture groups as structured fields. It also includes sophisticated time parsing capabilities that can extract timestamps from matched groups and convert them to appropriate formats.

## Key Functions/Components

### Regex Parsing Functions
- `flb_parser_regex_do()`: Main regex parsing function
- `flb_parser_regex_compile()`: Compiles regex patterns for matching
- `flb_parser_regex_match()`: Matches regex patterns against log data

### Time Resolution
- `flb_parser_regex_time_lookup()`: Extracts and converts timestamps from matched groups
- `flb_parser_regex_time_formats()`: Handles various time format specifications

### Field Processing
- `flb_parser_regex_field_extract()`: Extracts individual fields from matched groups
- `flb_parser_regex_callback()`: Processes matched groups through callback mechanism

## Important Variables/Constants

### Regex Engine Constants
- `FLB_PARSER_REGEX_MAX_GROUPS`: Maximum number of capture groups supported
- `FLB_PARSER_REGEX_MAX_PATTERN_LEN`: Maximum length for regex patterns
- `FLB_PARSER_REGEX_COMPILE_FLAGS`: Regex compilation flags for optimization

### Time Format Constants
- `FLB_PARSER_REGEX_TIME_ISO8601`: ISO 8601 time format in regex matches
- `FLB_PARSER_REGEX_TIME_UNIX`: Unix timestamp format
- `FLB_PARSER_REGEX_TIME_CUSTOM`: Custom time format specification

### Processing Options
- `FLB_PARSER_REGEX_SKIP_EMPTY`: Skip empty matched groups
- `FLB_PARSER_REGEX_TIME_KEEP`: Keep original time field after parsing
- `FLB_PARSER_REGEX_DECODER_CHAIN`: Chain multiple decoders

## Dependencies and Relationships

### Core Dependencies
- `flb_info.h`: General Fluent Bit information and logging
- `flb_mem.h`: Memory allocation utilities
- `flb_utils.h`: Utility functions for data handling
- `flb_parser.h`: Main parser system integration
- `flb_time.h`: Time handling utilities
- `flb_regex.h`: Fluent Bit regex engine
- `msgpack.h`: MessagePack library for data conversion

### Related Components
- Integrates with the parser system for regex log processing
- Works with input plugins for log data ingestion
- Connects to output plugins for parsed data delivery
- Interfaces with the buffer system for data queuing

## Notable Implementation Details

### Efficient Pattern Matching
The implementation uses optimized regex compilation and matching algorithms to ensure fast processing of large volumes of log data.

### Named Capture Groups
Proper handling of named capture groups in regex patterns, allowing users to easily specify field names in their patterns.

### Time Precision Resolution
Advanced time precision detection that can identify millisecond, microsecond, and nanosecond precision timestamps from matched groups.

### Error Recovery
Robust error recovery mechanisms that can handle regex matching failures without crashing the parser, with detailed error reporting for debugging purposes.

## Usage Examples

```c
// Parse regex log data
struct flb_parser *parser = flb_parser_create("regex_parser", config);
parser->type = FLB_PARSER_TYPE_REGEX;
parser->regex_str = "^(?<time>[^ ]+) (?<host>[^ ]+) (?<msg>.*)$";
parser->time_fmt = "%Y-%m-%dT%H:%M:%S";

char *log_line = "2023-01-01T12:00:00 host1 This is a log message";
void *out_buf;
size_t out_size;
struct flb_time out_time;

int ret = flb_parser_regex_do(parser, log_line, strlen(log_line), &out_buf, &out_size, &out_time);
if (ret >= 0) {
    // Successfully parsed with regex
    // Process out_buf with out_size bytes
    // Use out_time for timestamp information
    flb_free(out_buf);
}

// Handle complex regex patterns
char *complex_pattern = "^(?<ip>\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}) - - \\[(?<time>[^\\]]+)\\] \"(?<method>[A-Z]+) (?<path>[^ ]+) (?<protocol>[^\\"]+)\" (?<status>\\d{3}) (?<size>\\d+|-)$";
```

## Regex Parser Configuration

### Basic Configuration
```
[PARSER]
    Name   regex_parser
    Format regex
    Regex  ^(?<time>[^ ]+) (?<host>[^ ]+) (?<msg>.*)$
    Time_Key time
    Time_Format %Y-%m-%dT%H:%M:%S
```

### Advanced Configuration with Type Casting
```
[PARSER]
    Name   advanced_regex
    Format regex
    Regex  ^(?<ip>\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}) - - \\[(?<time>[^\\]]+)\\] \"(?<method>[A-Z]+) (?<path>[^ ]+) (?<protocol>[^\\"]+)\" (?<status>\\d{3}) (?<size>\\d+|-)$
    Time_Key time
    Time_Format %d/%b/%Y:%H:%M:%S %z
    Types  status:integer,size:integer
    Decode_Field_As regex log
```

## Data Processing Pipeline

### Input Processing
1. **Pattern Compilation**: Regex pattern is compiled for efficient matching
2. **Match Execution**: Pattern is matched against input log data
3. **Group Extraction**: Named capture groups are extracted as fields
4. **Validation**: Matched data is validated for integrity

### Transformation
1. **Time Processing**: Timestamp fields are extracted and converted
2. **Type Casting**: Field values are converted to specified types
3. **Decoder Application**: Additional transformations are applied
4. **Validation**: Parsed data is validated for integrity

### Output Generation
1. **MessagePack Conversion**: Parsed data is converted to MessagePack format
2. **Metadata Addition**: Parser metadata is added to output
3. **Buffer Preparation**: Output is prepared for delivery
4. **Delivery**: Parsed data is delivered to next processing stage

## Regex Pattern Guidelines

### Capturing Groups
- Use named capture groups `(?<name>...)` for clear field identification
- Non-capturing groups `(?:...)` can be used for grouping without field creation
- Backreferences `\1`, `\2`, etc. for referencing previous captures

### Common Patterns
- **IP Addresses**: `(?<ip>\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3})`
- **Timestamps**: `(?<time>[^ ]+)` or more specific patterns
- **Status Codes**: `(?<status>\\d{3})`
- **Method Names**: `(?<method>[A-Z]+)`

### Performance Considerations
- Avoid overly complex patterns that may cause exponential backtracking
- Use specific character classes rather than generic wildcards where possible
- Consider using possessive quantifiers or atomic groups for better performance
- Test patterns with representative log data to ensure optimal performance

## Error Handling and Debugging

### Common Issues
- **No Match**: Pattern doesn't match input data - verify pattern syntax and input format
- **Partial Match**: Some fields extracted but others missing - check capture group names
- **Type Conversion Errors**: Fields extracted but type casting fails - verify data types

### Debugging Techniques
- Use `flb_warn` and `flb_error` logging for detailed error information
- Test patterns independently with sample data
- Enable verbose logging to see parsing steps
- Use regex testing tools to validate complex patterns

## Performance Optimizations

### Regex Engine
- Compiled regex patterns for repeated use
- Optimized matching algorithms
- Efficient memory management for match results

### Memory Management
- Pre-allocated buffers reduce allocation overhead
- Streaming processing minimizes memory footprint
- Efficient string handling reduces copying operations

### Processing Efficiency
- Zero-copy operations where possible
- Cache-friendly data structures
- Reduced function call overhead
- Optimized field extraction algorithms

### Scalability Features
- Thread-safe operations for concurrent processing
- Configurable limits prevent resource exhaustion
- Efficient error handling minimizes performance impact
- Streaming support for large log files