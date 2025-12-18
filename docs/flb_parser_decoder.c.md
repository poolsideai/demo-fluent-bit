# flb_parser_decoder.c Documentation

## Overview

This file implements the parser decoder functionality for Fluent Bit, which provides field transformation and enhancement capabilities for parsed log data. Decoders allow users to modify, transform, and enrich parsed fields according to specific rules, enabling sophisticated data processing pipelines.

The decoder system supports various transformation types including field renaming, value modification, data type conversion, and complex field operations. It operates on the MessagePack data structures produced by parsers, allowing for efficient in-place transformations without requiring additional parsing overhead.

## Key Functions/Components

### Decoder Management
- `flb_parser_decoder_create()`: Creates a new decoder instance
- `flb_parser_decoder_destroy()`: Destroys a decoder and frees resources
- `flb_parser_decoder_do()`: Executes decoder transformations on data

### Transformation Functions
- `flb_parser_decoder_rename()`: Renames fields in parsed data
- `flb_parser_decoder_modify()`: Modifies field values according to rules
- `flb_parser_decoder_convert()`: Converts field data types

### Rule Processing
- `flb_parser_decoder_rules_process()`: Processes decoder rule chains
- `flb_parser_decoder_rule_apply()`: Applies individual transformation rules

## Important Variables/Constants

### Decoder Types
- `FLB_PARSER_DECODER_RENAME`: Field renaming decoder
- `FLB_PARSER_DECODER_MODIFY`: Field value modification decoder
- `FLB_PARSER_DECODER_CONVERT`: Data type conversion decoder
- `FLB_PARSER_DECODER_CUSTOM`: Custom transformation decoder

### Transformation Rules
- `FLB_PARSER_DECODER_OP_SET`: Set field to specific value
- `FLB_PARSER_DECODER_OP_ADD`: Add value to existing field
- `FLB_PARSER_DECODER_OP_REMOVE`: Remove field from data
- `FLB_PARSER_DECODER_OP_COPY`: Copy field value to another field

### Data Types
- `FLB_PARSER_DECODER_TYPE_STRING`: String data type
- `FLB_PARSER_DECODER_TYPE_INTEGER`: Integer data type
- `FLB_PARSER_DECODER_TYPE_FLOAT`: Float data type
- `FLB_PARSER_DECODER_TYPE_BOOLEAN`: Boolean data type

## Dependencies and Relationships

### Core Dependencies
- `flb_info.h`: General Fluent Bit information and logging
- `flb_mem.h`: Memory allocation utilities
- `flb_utils.h`: Utility functions for data handling
- `flb_parser.h`: Parser system integration
- `msgpack.h`: MessagePack library for data manipulation

### Parser Integration
- `flb_parser_decoder_check()`: Validates decoder configurations
- `flb_parser_decoder_load()`: Loads decoders from parser configuration

### Related Components
- Integrates with the parser system for field transformation
- Works with input plugins to process incoming log data
- Connects to output plugins for transformed data delivery
- Interfaces with the buffer system for data queuing

## Notable Implementation Details

### In-Place Transformations
The implementation performs transformations directly on MessagePack data structures, minimizing memory allocations and copying operations for optimal performance.

### Rule Chaining
Support for chaining multiple transformation rules together, allowing complex multi-step transformations on parsed data fields.

### Conditional Processing
Conditional transformation rules that can be applied based on field values or other criteria, enabling sophisticated data filtering and routing.

### Error Handling
Robust error handling ensures that failed transformations don't corrupt the entire data structure, with individual field failures gracefully handled.

## Usage Examples

```c
// Create a rename decoder
struct flb_parser_decoder *decoder = flb_parser_decoder_create();
decoder->type = FLB_PARSER_DECODER_RENAME;
decoder->field = "old_name";
decoder->value = "new_name";

// Apply decoder to parsed data
void *data = /* ... */; // MessagePack data
size_t size = /* ... */;

void *out_buf;
size_t out_size;

int ret = flb_parser_decoder_do(decoder, data, size, &out_buf, &out_size);
if (ret == 0) {
    // Successfully transformed data
    // Process out_buf with out_size bytes
    flb_free(out_buf);
}

// Create a value modification decoder
struct flb_parser_decoder *modify_decoder = flb_parser_decoder_create();
modify_decoder->type = FLB_PARSER_DECODER_MODIFY;
modify_decoder->field = "status";
modify_decoder->operation = FLB_PARSER_DECODER_OP_SET;
modify_decoder->value = "processed";
```

## Decoder Configuration

### Basic Rename Configuration
```
[PARSER]
    Name   my_parser
    Format json
    Decode_Field_As rename log
    Rename_Field    old_field new_field
```

### Complex Transformation Configuration
```
[PARSER]
    Name   advanced_parser
    Format regex
    Regex  ^(?<time>[^ ]+) (?<host>[^ ]+) (?<status>\d+) (?<msg>.*)$
    Decode_Field_As modify log
    Modify_Field    status 200 OK
    Modify_Field    status 404 Not Found
    Decode_Field_As convert log
    Convert_Field   status integer
```

## Transformation Pipeline

### Field Renaming
1. **Identification**: Target field is identified by name
2. **Validation**: New field name is validated for correctness
3. **Replacement**: Field name is replaced in data structure
4. **Cleanup**: Old field references are removed

### Value Modification
1. **Field Lookup**: Target field is located in data structure
2. **Rule Application**: Modification rule is applied to field value
3. **Type Checking**: Resulting value type is validated
4. **Update**: Modified value is stored in data structure

### Type Conversion
1. **Field Analysis**: Target field type is analyzed
2. **Conversion Attempt**: Field value is converted to target type
3. **Error Handling**: Conversion errors are handled gracefully
4. **Storage**: Converted value is stored with correct type

## Performance Considerations

### Memory Efficiency
- In-place transformations minimize memory allocations
- Streaming processing reduces peak memory usage
- Efficient string handling reduces copying operations

### Processing Speed
- Optimized MessagePack manipulation routines
- Cached field lookups for repeated operations
- Reduced function call overhead in critical paths

### Scalability
- Thread-safe operations for concurrent processing
- Minimal locking for performance-critical sections
- Efficient resource cleanup to prevent leaks