# flb_avro.c

## Overview

This file implements Avro serialization functionality for Fluent Bit. It provides utilities to convert MessagePack data to Avro format, which is commonly used for data serialization in distributed systems.

The module handles:
- Avro schema parsing and validation
- MessagePack to Avro data conversion
- Avro serialization with schema ID encoding
- Integration with external libraries (libavro)

## Key Functions

### `flb_avro_init()`
Initializes an Avro object from a JSON schema. Creates an Avro class from the schema and instantiates a new Avro value.

### `flb_msgpack_to_avro()`
Converts MessagePack data to Avro format. This is the main entry point for data conversion.

### `flb_msgpack_raw_to_avro_sds()`
Converts raw MessagePack data to Avro format with schema ID encoding, suitable for streaming to systems like Apache Kafka.

## Important Variables/Constants

### Data Structures
- `struct flb_avro_fields`: Contains Avro schema information including schema ID and schema string
- `avro_value_t`: Avro value structure for holding serialized data
- `avro_schema_t`: Avro schema structure for validation

### Magic Bytes
- Uses a magic byte (`\0`) followed by a 16-byte schema ID for Avro serialization format
- Schema ID is typically the MD5 hash of the Avro schema

## Dependencies

- `fluent-bit/flb_macros.h`: Fluent Bit macros
- `fluent-bit/flb_log.h`: Logging utilities
- `fluent-bit/flb_mem.h`: Memory management utilities
- `fluent-bit/flb_error.h`: Error handling utilities
- `fluent-bit/flb_sds.h`: String data structure utilities
- `fluent-bit/flb_avro.h`: Avro interface headers
- `libavro`: Apache Avro C library for serialization
- `msgpack`: MessagePack library for data handling

## Implementation Details

1. **Schema Handling**: The module parses JSON schemas using `avro_schema_from_json_length()` and creates appropriate Avro classes.

2. **Data Conversion**: Implements comprehensive conversion from MessagePack types to Avro types:
   - Nil values
   - Boolean values
   - Integer values (positive and negative)
   - Float values
   - String values
   - Binary data
   - Extension data
   - Arrays
   - Maps

3. **Schema ID Encoding**: Implements the standard Avro serialization format with a magic byte and schema ID for compatibility with systems like Apache Kafka.

4. **Error Handling**: Uses a helper function `do_avro()` to handle Avro library errors consistently.

5. **Memory Management**: Properly manages Avro object lifecycle with reference counting and cleanup.

## Usage Example

```c
// Convert MessagePack data to Avro
struct flb_avro_fields ctx = {
    .schema_id = "c4b52aaf22429c7f9eb8c30270bc1795",
    .schema_str = "{\"type\": \"record\", \"name\": \"example\", \"fields\": [{\"name\": \"field1\", \"type\": \"string\"}]}"
};

char output_buffer[1024];
size_t output_size = sizeof(output_buffer);

bool success = flb_msgpack_raw_to_avro_sds(input_data, input_size, &ctx, output_buffer, &output_size);

if (success) {
    // output_buffer now contains Avro-serialized data with schema ID
    // ready to be sent to systems like Apache Kafka
}
```