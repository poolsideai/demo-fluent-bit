# flb_parser_ltsv.c Documentation

## Overview

This file implements the LTSV (Labeled Tab-Separated Values) parser for Fluent Bit, which handles parsing of LTSV-formatted log data. LTSV is a structured logging format where each log line consists of tab-separated key=value pairs, providing a balance between human readability and machine parseability.

The parser strictly follows the LTSV specification (http://ltsv.org), handling various data types, escaping mechanisms, and formatting conventions. It efficiently converts LTSV data into Fluent Bit's internal MessagePack format for further processing in the logging pipeline.

## Key Functions/Components

### LTSV Parsing Functions
- `flb_parser_ltsv_do()`: Main LTSV parsing function
- `flb_parser_ltsv_tokenize()`: Tokenizes LTSV input into key-value pairs
- `flb_parser_ltsv_validate()`: Validates LTSV format compliance

### Data Type Detection
- `flb_parser_ltsv_type_detect()`: Automatically detects data types from values
- `flb_parser_ltsv_bool_parse()`: Parses boolean values according to LTSV rules

### Field Processing
- `flb_parser_ltsv_field_process()`: Processes individual LTSV fields
- `flb_parser_ltsv_escape_process()`: Handles LTSV escaping mechanisms

## Important Variables/Constants

### LTSV Format Constants
- `FLB_PARSER_LTSV_MAX_KEY_LEN`: Maximum length for LTSV keys
- `FLB_PARSER_LTSV_MAX_VALUE_LEN`: Maximum length for LTSV values
- `FLB_PARSER_LTSV_ESCAPE_CHAR`: Escape character for special values

### Data Type Indicators
- `FLB_PARSER_LTSV_TYPE_STRING`: String type indicator
- `FLB_PARSER_LTSV_TYPE_INTEGER`: Integer type indicator
- `FLB_PARSER_LTSV_TYPE_FLOAT`: Float type indicator
- `FLB_PARSER_LTSV_TYPE_BOOLEAN`: Boolean type indicator

### Special Values
- `FLB_PARSER_LTSV_TRUE_VALUES`: Recognized true boolean values
- `FLB_PARSER_LTSV_FALSE_VALUES`: Recognized false boolean values
- `FLB_PARSER_LTSV_NULL_VALUES`: Recognized null/empty values

## Dependencies and Relationships

### Core Dependencies
- `flb_info.h`: General Fluent Bit information and logging
- `flb_mem.h`: Memory allocation utilities
- `flb_utils.h`: Utility functions for data handling
- `flb_parser.h`: Main parser system integration
- `flb_time.h`: Time handling utilities
- `msgpack.h`: MessagePack library for data conversion

### Related Components
- Integrates with the parser system for LTSV log processing
- Works with input plugins for LTSV data ingestion
- Connects to output plugins for parsed data delivery
- Interfaces with the buffer system for data queuing

## Notable Implementation Details

### Character Set Validation
The parser validates that LTSV keys only contain allowed characters ([0-9A-Za-z_.-]) and that values follow the LTSV specification for field-value bytes.

### Tab Separation Handling
Proper handling of tab characters as field separators, with careful attention to edge cases like empty fields or trailing tabs.

### Line Ending Processing
Correct handling of both Unix (\n) and Windows (\r\n) line endings as specified in the LTSV standard.

### Field Escaping
Implementation of proper field escaping mechanisms to handle special characters within LTSV values.

## Usage Examples

```c
// Parse LTSV log data
struct flb_parser *parser = flb_parser_create("ltsv_parser", config);
parser->type = FLB_PARSER_TYPE_LTSV;
parser->time_key = "time";
parser->time_fmt = "%Y-%m-%dT%H:%M:%S";

char *ltsv_log = "time:2023-01-01T12:00:00\tlevel:info\tmsg:This is a log message\tcount:42\tsuccess:true";
void *out_buf;
size_t out_size;
struct flb_time out_time;

int ret = flb_parser_ltsv_do(parser, ltsv_log, strlen(ltsv_log), &out_buf, &out_size, &out_time);
if (ret >= 0) {
    // Successfully parsed LTSV
    // Process out_buf with out_size bytes
    // Use out_time for timestamp information
    flb_free(out_buf);
}

// Handle special characters in values
char *special_log = "key:value\twith\ttabs\tcount:100\tsuccess:false";

// The parser will properly handle the tab-separated fields
```

## LTSV Parser Configuration

### Basic Configuration
```
[PARSER]
    Name   ltsv_parser
    Format ltsv
    Time_Key time
    Time_Format %Y-%m-%dT%H:%M:%S
```

### Advanced Configuration with Type Casting
```
[PARSER]
    Name   advanced_ltsv
    Format ltsv
    Time_Key timestamp
    Time_Format %Y-%m-%dT%H:%M:%S.%L
    Types  status:integer,response_time:float,success:boolean
    Decode_Field_As ltsv log
```

## Data Processing Pipeline

### Input Processing
1. **Format Validation**: Input data is validated as LTSV format
2. **Tokenization**: LTSV line is split into tab-separated key=value pairs
3. **Field Extraction**: Individual fields are extracted and processed
4. **Type Detection**: Data types are automatically detected from values

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

## LTSV Specification Compliance

### Key-Value Format
- Keys consist of valid LTSV characters ([0-9A-Za-z_.-])
- Values consist of valid field bytes (excluding tab and newline)
- Tab separation between key=value pairs
- Optional newline termination

### Data Types
- Strings: Unquoted values containing any valid field bytes
- Integers: Numeric values without decimal points
- Floats: Numeric values with decimal points
- Booleans: true, false, 1, 0, etc.
- Null/Empty: empty values or null indicators

### Escaping Rules
- Backslash escapes special characters
- Tabs within values are not allowed in standard LTSV
- Newlines terminate LTSV records

## Performance Optimizations

### Memory Management
- Pre-allocated buffers reduce allocation overhead
- Streaming processing minimizes memory footprint
- Efficient string handling reduces copying operations

### Parsing Efficiency
- Zero-copy operations where possible
- Cache-friendly data structures
- Reduced function call overhead
- Optimized tokenization algorithms

### Scalability Features
- Thread-safe operations for concurrent processing
- Configurable limits prevent resource exhaustion
- Efficient error handling minimizes performance impact
- Streaming support for large LTSV documents