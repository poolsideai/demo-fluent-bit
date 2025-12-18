# flb_pack_json.c Documentation

## Overview

This file contains JSON packing wrapper functions for Fluent Bit, providing a simplified interface for converting between JSON data and Fluent Bit's internal MessagePack format. The implementation serves as a bridge between JSON-based input/output operations and Fluent Bit's core MessagePack-based data processing pipeline.

The module supports various JSON processing backends and provides optimized paths for common JSON operations, ensuring efficient conversion while maintaining compatibility with different JSON libraries that might be available in the system.

## Key Functions/Components

### JSON Packing Functions
- `flb_pack_json()`: Main function to convert JSON data to MessagePack
- `flb_pack_json_format()`: Converts MessagePack data to formatted JSON
- `flb_pack_json_simple()`: Simple JSON packing without advanced features

### Backend Selection
- `flb_pack_json_backend()`: Selects appropriate JSON processing backend
- `flb_pack_json_backend_init()`: Initializes selected JSON backend

### Format Options
- `flb_pack_json_format_options()`: Configures JSON formatting options
- `flb_pack_json_escape_unicode()`: Handles Unicode escaping in JSON

## Important Variables/Constants

### Backend Types
- `FLB_PACK_JSON_BACKEND_JSMN`: JSMN JSON parser backend
- `FLB_PACK_JSON_BACKEND_YAJL`: YAJL JSON parser backend
- `FLB_PACK_JSON_BACKEND_DEFAULT`: Default JSON backend selection

### Formatting Options
- `FLB_PACK_JSON_FORMAT_PRETTY`: Pretty-printed JSON output
- `FLB_PACK_JSON_FORMAT_COMPACT`: Compact JSON output
- `FLB_PACK_JSON_ESCAPE_UNICODE`: Enable Unicode escaping

## Dependencies and Relationships

### Core Dependencies
- `flb_info.h`: General Fluent Bit information and logging
- `flb_mem.h`: Memory allocation utilities
- `flb_utils.h`: Utility functions for data handling
- `flb_pack.h`: Core packing functions

### JSON Libraries
- `yajl/yajl_parse.h`: YAJL JSON parser (when available)
- `jsmn.h`: JSMN JSON parser (fallback option)

### Related Components
- Integrates with the parser system for JSON log processing
- Works with input plugins for JSON data ingestion
- Connects to output plugins for JSON data delivery
- Interfaces with the buffer system for data storage

## Notable Implementation Details

### Backend Flexibility
The implementation automatically selects the best available JSON backend based on system capabilities and performance characteristics, falling back to simpler implementations when advanced libraries are not available.

### Memory Efficiency
Optimized memory usage patterns minimize allocations during JSON processing, particularly important for high-throughput logging scenarios.

### Error Resilience
Robust error handling ensures that malformed JSON doesn't crash the system, with detailed error reporting for debugging purposes.

### Unicode Handling
Proper Unicode support with configurable escaping options to handle international character sets correctly.

## Usage Examples

```c
// Convert JSON to MessagePack
char *json_data = "{\"key\": \"value\", \"number\": 42}";
void *out_buf;
size_t out_size;

int ret = flb_pack_json(json_data, strlen(json_data), &out_buf, &out_size);
if (ret == 0) {
    // Successfully converted to MessagePack
    // Process out_buf with out_size bytes
    flb_free(out_buf);
}

// Convert MessagePack to formatted JSON
char *msgpack_data = /* ... */; // MessagePack data
size_t msgpack_size = /* ... */;

char *json_output;
size_t json_size;

int ret = flb_pack_json_format(msgpack_data, msgpack_size, &json_output, &json_size, FLB_PACK_JSON_FORMAT_PRETTY);
if (ret == 0) {
    // Successfully converted to formatted JSON
    // Process json_output with json_size bytes
    flb_free(json_output);
}
```

## JSON Processing Pipeline

### Input Processing
1. **Validation**: Input JSON is validated for basic syntax correctness
2. **Parsing**: JSON is parsed using selected backend
3. **Conversion**: Parsed data is converted to MessagePack format
4. **Validation**: Output MessagePack is validated for integrity

### Output Processing
1. **Deserialization**: MessagePack data is deserialized
2. **Formatting**: Data is formatted according to JSON options
3. **Escaping**: Special characters are properly escaped
4. **Serialization**: Final JSON is serialized for output

## Performance Considerations

### Backend Selection Strategy
- YAJL backend: High performance for complex JSON structures
- JSMN backend: Lightweight alternative with good performance
- Simple parser: Minimal overhead for basic JSON operations

### Memory Management
- Pre-allocated buffers reduce allocation overhead
- Streaming processing minimizes memory footprint
- Efficient string handling reduces copying operations

### Optimization Techniques
- Zero-copy operations where possible
- Cache-friendly data structures
- Reduced function call overhead
- Inline functions for critical paths