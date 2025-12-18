# flb_parser_logfmt.c Documentation

## Overview

This file implements the Logfmt parser for Fluent Bit, which handles parsing of logfmt-formatted log data. Logfmt is a simple key-value format commonly used in logging systems, where each log line consists of space-separated key=value pairs.

The parser follows the logfmt specification precisely, handling various data types, escaping mechanisms, and formatting conventions. It efficiently converts logfmt data into Fluent Bit's internal MessagePack format for further processing in the logging pipeline.

## Key Functions/Components

### Logfmt Parsing Functions
- `flb_parser_logfmt_do()`: Main Logfmt parsing function
- `flb_parser_logfmt_tokenize()`: Tokenizes Logfmt input into key-value pairs
- `flb_parser_logfmt_unescape()`: Handles Logfmt escaping mechanisms

### Data Type Detection
- `flb_parser_logfmt_type_detect()`: Automatically detects data types from values
- `flb_parser_logfmt_bool_parse()`: Parses boolean values according to Logfmt rules

### Field Processing
- `flb_parser_logfmt_field_process()`: Processes individual Logfmt fields
- `flb_parser_logfmt_array_parse()`: Handles array-like value representations

## Important Variables/Constants

### Logfmt Format Constants
- `FLB_PARSER_LOGFMT_MAX_KEY_LEN`: Maximum length for Logfmt keys
- `FLB_PARSER_LOGFMT_MAX_VALUE_LEN`: Maximum length for Logfmt values
- `FLB_PARSER_LOGFMT_ESCAPE_CHAR`: Escape character for special values

### Data Type Indicators
- `FLB_PARSER_LOGFMT_TYPE_STRING`: String type indicator
- `FLB_PARSER_LOGFMT_TYPE_INTEGER`: Integer type indicator
- `FLB_PARSER_LOGFMT_TYPE_FLOAT`: Float type indicator
- `FLB_PARSER_LOGFMT_TYPE_BOOLEAN`: Boolean type indicator

### Special Values
- `FLB_PARSER_LOGFMT_TRUE_VALUES`: Recognized true boolean values
- `FLB_PARSER_LOGFMT_FALSE_VALUES`: Recognized false boolean values
- `FLB_PARSER_LOGFMT_NULL_VALUES`: Recognized null/empty values

## Dependencies and Relationships

### Core Dependencies
- `flb_info.h`: General Fluent Bit information and logging
- `flb_mem.h`: Memory allocation utilities
- `flb_utils.h`: Utility functions for data handling
- `flb_parser.h`: Main parser system integration
- `flb_time.h`: Time handling utilities
- `msgpack.h`: MessagePack library for data conversion

### Related Components
- Integrates with the parser system for Logfmt log processing
- Works with input plugins for Logfmt data ingestion
- Connects to output plugins for parsed data delivery
- Interfaces with the buffer system for data queuing

## Notable Implementation Details

### Automatic Type Detection
The parser automatically detects data types from Logfmt values, recognizing integers, floats, booleans, and strings without explicit type declarations.

### Escaping Mechanism
Proper handling of Logfmt escaping rules, including backslash escaping and quote handling for special characters in values.

### Boolean Recognition
Comprehensive boolean value recognition that supports various common representations of true/false values.

### Array Representation
Support for array-like value representations in Logfmt format, converting them to appropriate structured data.

## Usage Examples

```c
// Parse Logfmt log data
struct flb_parser *parser = flb_parser_create("logfmt_parser", config);
parser->type = FLB_PARSER_TYPE_LOGFMT;
parser->time_key = "ts";
parser->time_fmt = "%Y-%m-%dT%H:%M:%S";

char *logfmt_log = "ts=2023-01-01T12:00:00 level=info msg=\"This is a log message\" count=42 success=true";
void *out_buf;
size_t out_size;
struct flb_time out_time;

int ret = flb_parser_logfmt_do(parser, logfmt_log, strlen(logfmt_log), &out_buf, &out_size, &out_time);
if (ret >= 0) {
    // Successfully parsed Logfmt
    // Process out_buf with out_size bytes
    // Use out_time for timestamp information
    flb_free(out_buf);
}

// Handle escaped values
char *escaped_log = "key=value\"with\"quotes count=100 success=false";

// The parser will properly unescape the value and detect data types
```

## Logfmt Parser Configuration

### Basic Configuration
```
[PARSER]
    Name   logfmt_parser
    Format logfmt
    Time_Key ts
    Time_Format %Y-%m-%dT%H:%M:%S
```

### Advanced Configuration with Type Casting
```
[PARSER]
    Name   advanced_logfmt
    Format logfmt
    Time_Key timestamp
    Time_Format %Y-%m-%dT%H:%M:%S.%L
    Types  status:integer,response_time:float,success:boolean
    Decode_Field_As logfmt log
```

## Data Processing Pipeline

### Input Processing
1. **Format Validation**: Input data is validated as Logfmt format
2. **Tokenization**: Logfmt line is split into key-value pairs
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

## Logfmt Specification Compliance

### Key-Value Format
- Keys consist of alphanumeric characters and underscores
- Values can be unquoted, single-quoted, or double-quoted
- Space separation between key-value pairs

### Data Types
- Strings: Unquoted or quoted values
- Integers: Numeric values without decimal points
- Floats: Numeric values with decimal points
- Booleans: true, false, t, f, yes, no, 1, 0, etc.
- Null/Empty: empty values or null indicators

### Escaping Rules
- Backslash escapes special characters
- Quotes can be escaped within quoted values
- Newlines are not allowed within Logfmt values

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
- Streaming support for large Logfmt documents