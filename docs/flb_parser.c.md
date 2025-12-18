# flb_parser.c Documentation

## Overview

This file contains the main parser creation, management, and time parsing functions for Fluent Bit. The parser system is a fundamental component that enables Fluent Bit to handle various log formats by providing a flexible framework for parsing structured and unstructured log data.

The implementation supports multiple parser types (regex, JSON, LTSV, logfmt) and provides a unified interface for creating, configuring, and using parsers throughout the Fluent Bit pipeline. It also includes sophisticated time parsing capabilities that can extract and convert timestamps from various formats found in log data.

## Key Functions/Components

### Parser Management
- `flb_parser_create()`: Creates a new parser instance
- `flb_parser_destroy()`: Destroys a parser and frees resources
- `flb_parser_get()`: Retrieves a parser by name
- `flb_parser_check()`: Validates parser configuration

### Time Parsing Functions
- `flb_parser_time_lookup()`: Extracts and converts timestamps from log data
- `flb_parser_tm2time()`: Converts parsed time to Unix timestamp
- `flb_parser_time_formats()`: Handles various time format specifications

### Parser Interface
- `flb_parser_do()`: Main parser execution function
- `flb_parser_typecast()`: Performs type casting on parsed fields
- `flb_parser_decoder_check()`: Validates decoder configurations

## Important Variables/Constants

### Parser Types
- `FLB_PARSER_TYPE_REGEX`: Regular expression-based parser
- `FLB_PARSER_TYPE_JSON`: JSON-based parser
- `FLB_PARSER_TYPE_LTSV`: LTSV-based parser
- `FLB_PARSER_TYPE_LOGFMT`: Logfmt-based parser

### Time Format Constants
- `FLB_PARSER_TIME_ISO8601`: ISO 8601 time format
- `FLB_PARSER_TIME_APACHE`: Apache log time format
- `FLB_PARSER_TIME_RFC3164`: RFC 3164 syslog time format

### Configuration Options
- `FLB_PARSER_SKIP_EMPTY`: Skip empty fields in parsing
- `FLB_PARSER_TIME_KEEP`: Keep original time field after parsing
- `FLB_PARSER_DECODER_CHAIN`: Chain multiple decoders

## Dependencies and Relationships

### Core Dependencies
- `flb_info.h`: General Fluent Bit information and logging
- `flb_mem.h`: Memory allocation utilities
- `flb_utils.h`: Utility functions for data handling
- `flb_time.h`: Time handling utilities
- `flb_regex.h`: Regular expression support

### Parser Implementations
- `flb_parser_regex.h`: Regex parser implementation
- `flb_parser_json.h`: JSON parser implementation
- `flb_parser_ltsv.h`: LTSV parser implementation
- `flb_parser_logfmt.h`: Logfmt parser implementation

### Related Components
- Integrates with the input plugin system for log data ingestion
- Works with the output plugin system for parsed data delivery
- Connects to the buffer system for data queuing
- Interfaces with the scheduler for timing control

## Notable Implementation Details

### Time Zone Handling
Sophisticated time zone conversion capabilities that can handle local time zones, UTC conversions, and custom time zone offsets specified in parser configurations.

### Parser Chaining
Support for chaining multiple parsers together, allowing complex parsing operations where one parser's output becomes another parser's input.

### Type Casting System
Flexible type casting mechanism that can convert parsed string values to integers, floats, booleans, and other data types based on parser configuration.

### Decoder Integration
Seamless integration with decoder functionality that can transform parsed fields using various transformation rules and functions.

## Usage Examples

```c
// Create a regex parser
struct flb_parser *parser = flb_parser_create("my_parser", config);
parser->type = FLB_PARSER_TYPE_REGEX;
parser->regex_str = "^(?<time>[^ ]+) (?<host>[^ ]+) (?<msg>.*)$";
parser->time_fmt = "%Y-%m-%dT%H:%M:%S";

int ret = flb_parser_check(parser);
if (ret == 0) {
    // Parser is valid and ready to use
    // Add to parser list for use by input plugins
}

// Parse log data
char *log_line = "2023-01-01T12:00:00 host1 This is a log message";
void *out_buf;
size_t out_size;
struct flb_time out_time;

int ret = flb_parser_do(parser, log_line, strlen(log_line), &out_buf, &out_size, &out_time);
if (ret >= 0) {
    // Successfully parsed
    // Process out_buf with out_size bytes
    // Use out_time for timestamp information
    flb_free(out_buf);
}
```

## Parser Configuration

### Basic Configuration
```
[PARSER]
    Name   my_parser
    Format regex
    Regex  ^(?<time>[^ ]+) (?<host>[^ ]+) (?<msg>.*)$
    Time_Key time
    Time_Format %Y-%m-%dT%H:%M:%S
```

### Advanced Configuration
```
[PARSER]
    Name   json_parser
    Format json
    Time_Key ts
    Time_Format %Y-%m-%dT%H:%M:%S.%L
    Types  status:integer,response_time:float
    Decode_Field_As json log
```

## Data Flow

1. **Parser Creation**: Parser is created and configured from configuration file
2. **Validation**: Parser configuration is validated for correctness
3. **Registration**: Parser is registered with the global parser list
4. **Input Processing**: Log data is received from input plugins
5. **Parsing**: Data is parsed according to parser rules
6. **Transformation**: Fields are transformed using decoders and type casting
7. **Output Delivery**: Parsed data is delivered to output plugins
8. **Resource Cleanup**: Parser resources are freed when no longer needed