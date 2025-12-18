# flb_pack.c Documentation

## Overview

This file contains the core packing functions for Fluent Bit, which are responsible for converting data between various formats including MessagePack, JSON, and other serialization formats. These functions form the backbone of Fluent Bit's data transformation capabilities, enabling efficient parsing and serialization of log data.

The packing system is designed to be highly performant and memory-efficient, leveraging MessagePack as the primary internal format while supporting conversion to and from JSON and other formats as needed.

## Key Functions/Components

### Core Packing Functions
- `flb_pack_json()`: Converts JSON data to MessagePack format
- `flb_pack_json_state()`: Stateful JSON packing for streaming data
- `flb_pack_raw()`: Packs raw data into MessagePack format

### Unpacking Functions
- `flb_pack_msgpack_to_json()`: Converts MessagePack data to JSON format
- `flb_pack_msgpack_to_json_format()`: Formats MessagePack data to JSON with specific options

### Stream Processing
- `flb_pack_sds()`: Processes data streams with automatic detection
- `flb_pack_sds_raw()`: Raw stream processing without format detection

## Important Variables/Constants

### Format Detection
- `FLB_PACK_JSON`: JSON format identifier
- `FLB_PACK_MSGPACK`: MessagePack format identifier
- `FLB_PACK_RAW`: Raw data format identifier

### Buffer Management
- `FLB_PACK_BUFFER_SIZE`: Default buffer size for packing operations
- `FLB_PACK_MAX_DEPTH`: Maximum nesting depth for JSON parsing

## Dependencies and Relationships

### Core Dependencies
- `msgpack.h`: MessagePack library for serialization
- `flb_info.h`: General Fluent Bit information and logging
- `flb_mem.h`: Memory allocation utilities
- `flb_utils.h`: Utility functions for data handling
- `flb_time.h`: Time handling utilities

### Related Components
- Integrates with the parser system for log format conversion
- Works with input plugins to process incoming data
- Connects to output plugins for data serialization
- Interfaces with the buffer system for data storage

## Notable Implementation Details

### Performance Optimization
The implementation uses zero-copy techniques where possible and minimizes memory allocations during packing operations to maintain high throughput.

### Error Recovery
Robust error handling ensures that malformed input data doesn't crash the system, with appropriate error codes and logging for debugging purposes.

### Memory Management
Careful memory management prevents leaks and fragmentation, using Fluent Bit's memory pool system where appropriate.

### Format Detection
Automatic format detection allows the system to handle mixed input formats without explicit configuration in many cases.

## Usage Examples

```c
// Convert JSON to MessagePack
char *json_data = "{\"key\": \"value\"}";
void *out_buf;
size_t out_size;

int ret = flb_pack_json(json_data, strlen(json_data), &out_buf, &out_size);
if (ret == 0) {
    // Successfully converted to MessagePack
    // Process out_buf with out_size bytes
    flb_free(out_buf);
}

// Convert MessagePack to JSON
char *msgpack_data = /* ... */; // MessagePack data
size_t msgpack_size = /* ... */;

char *json_output;
size_t json_size;

int ret = flb_pack_msgpack_to_json(msgpack_data, msgpack_size, &json_output, &json_size);
if (ret == 0) {
    // Successfully converted to JSON
    // Process json_output with json_size bytes
    flb_free(json_output);
}
```

## Data Flow

1. **Input Reception**: Raw data is received from input sources
2. **Format Detection**: Automatic detection of input format (JSON, MessagePack, etc.)
3. **Parsing**: Input data is parsed according to its format
4. **Transformation**: Data is transformed to internal MessagePack representation
5. **Serialization**: Data is serialized to target format for output
6. **Output Delivery**: Serialized data is delivered to output plugins