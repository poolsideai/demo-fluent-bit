# flb_parser_json.c Documentation

## Overview

This file contains the JSON-specific parser implementation for Fluent Bit, which handles the parsing of JSON-formatted log data. The JSON parser is designed to efficiently extract structured data from JSON logs and convert them into Fluent Bit's internal MessagePack format for further processing.

The implementation supports various JSON features including nested objects, arrays, and different data types. It also includes sophisticated time parsing capabilities that can extract timestamps from JSON fields and convert them to the appropriate format for Fluent Bit's internal use.

## Key Functions/Components

### JSON Parsing Functions
- `flb_parser_json_do()`: Main JSON parsing function
- `flb_parser_json_time_lookup()`: Extracts and converts timestamps from JSON fields
- `flb_parser_json_nested_parse()`: Handles nested JSON object parsing

### Time Resolution
- `flb_parser_json_time_resolution()`: Resolves time precision from JSON timestamps
- `flb_parser_json_time_formats()`: Handles various JSON time format specifications

### Field Processing
- `flb_parser_json_field_extract()`: Extracts individual fields from JSON data
- `flb_parser_json_array_process()`: Processes JSON array elements

## Important Variables/Constants

### JSON Parsing Modes
- `FLB_PARSER_JSON_MODE_OBJECT`: Parse JSON objects
- `FLB_PARSER_JSON_MODE_ARRAY`: Parse JSON arrays
- `FLB_PARSER_JSON_MODE_MIXED`: Handle mixed JSON content

### Time Format Constants
- `FLB_PARSER_JSON_TIME_ISO8601`: ISO 8601 time format in JSON
- `FLB_PARSER_JSON_TIME_UNIX`: Unix timestamp format
- `FLB_PARSER_JSON_TIME_CUSTOM`: Custom time format specification

### Nesting Limits
- `FLB_PARSER_JSON_MAX_DEPTH`: Maximum nesting depth for JSON objects
- `FLB_PARSER_JSON_MAX_ARRAY_SIZE`: Maximum array size for processing

## Dependencies and Relationships

### Core Dependencies
- `flb_info.h`: General Fluent Bit information and logging
- `flb_mem.h`: Memory allocation utilities
- `flb_utils.h`: Utility functions for data handling
- `flb_parser.h`: Main parser system integration
- `flb_time.h`: Time handling utilities
- `msgpack.h`: MessagePack library for data conversion

### JSON Libraries
- `yajl/yajl_parse.h`: YAJL JSON parser (primary backend)
- `jsmn.h`: JSMN JSON parser (fallback option)

### Related Components
- Integrates with the parser system for JSON log processing
- Works with input plugins for JSON data ingestion
- Connects to output plugins for parsed data delivery
- Interfaces with the buffer system for data queuing

## Notable Implementation Details

### Streaming JSON Processing
The implementation supports streaming JSON processing, allowing large JSON documents to be parsed incrementally without loading the entire document into memory.

### Nested Object Handling
Sophisticated handling of nested JSON objects and arrays, with configurable depth limits to prevent excessive memory consumption.

### Time Precision Resolution
Advanced time precision detection that can identify millisecond, microsecond, and nanosecond precision timestamps in JSON data.

### Error Recovery
Robust error recovery mechanisms that can handle malformed JSON without crashing the parser, with detailed error reporting for debugging purposes.

## Usage Examples

```c
// Parse JSON log data
struct flb_parser *parser = flb_parser_create("json_parser", config);
parser->type = FLB_PARSER_TYPE_JSON;
parser->time_key = "timestamp";
parser->time_fmt = "%Y-%m-%dT%H:%M:%S.%L";

char *json_log = "{\"timestamp\": \"2023-01-01T12:00:00.123\", \"level\": \"info\", \"message\": \"This is a log message\"}";
void *out_buf;
size_t out_size;
struct flb_time out_time;

int ret = flb_parser_json_do(parser, json_log, strlen(json_log), &out_buf, &out_size, &out_time);
if (ret >= 0) {
    // Successfully parsed JSON
    // Process out_buf with out_size bytes
    // Use out_time for timestamp information
    flb_free(out_buf);
}

// Handle nested JSON objects
char *nested_json = "{\"event\": {\"type\": \"login\", \"user\": \"john\"}, \"timestamp\": \"2023-01-01T12:00:00\"}";

// The parser will flatten nested structures or preserve them based on configuration
```

## JSON Parser Configuration

### Basic Configuration
```
[PARSER]
    Name   json_parser
    Format json
    Time_Key timestamp
    Time_Format %Y-%m-%dT%H:%M:%S.%L
```

### Advanced Configuration with Type Casting
```
[PARSER]
    Name   advanced_json
    Format json
    Time_Key ts
    Time_Format %Y-%m-%dT%H:%M:%S
    Types  status:integer,response_time:float,success:boolean
    Decode_Field_As json log
```

## Data Processing Pipeline

### Input Processing
1. **Format Detection**: Input data is validated as JSON
2. **Parsing Initiation**: JSON parser is initialized with configuration
3. **Streaming Parse**: JSON data is parsed incrementally
4. **Field Extraction**: Individual fields are extracted from JSON structure

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

## Performance Optimizations

### Memory Management
- Pre-allocated buffers reduce allocation overhead
- Streaming processing minimizes memory footprint
- Efficient string handling reduces copying operations

### Parsing Efficiency
- Zero-copy operations where possible
- Cache-friendly data structures
- Reduced function call overhead
- Optimized JSON library integration

### Scalability Features
- Thread-safe operations for concurrent processing
- Configurable limits prevent resource exhaustion
- Efficient error handling minimizes performance impact
- Streaming support for large JSON documents