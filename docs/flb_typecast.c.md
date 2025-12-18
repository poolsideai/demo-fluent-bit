# flb_typecast.c

## Overview

This file implements a type casting system for Fluent Bit that provides flexible conversion between different data types, particularly focusing on MessagePack objects. The type casting system allows for converting data between string, integer, unsigned integer, float, hexadecimal, boolean, and other formats.

Key features include:
- String-based type specification for easy configuration
- Bidirectional type conversion (string ↔ numeric ↔ boolean)
- MessagePack integration for serialization/deserialization
- Rule-based conversion system for consistent type handling
- Memory-safe operations with proper cleanup

The type casting system is essential for Fluent Bit's data processing pipeline, enabling plugins to work with data in their preferred formats regardless of the original data type.

## Key Functions

### `flb_typecast_str_to_type_t()`
Converts a string representation of a type to its corresponding enum value. Supports "int", "uint", "float", "hex", "string", and "bool".

### `flb_typecast_type_t_to_str()`
Converts a type enum value back to its string representation for display and debugging purposes.

### `flb_typecast_rule_create()`
Creates a type conversion rule specifying the source and destination types for conversion operations.

### `flb_typecast_rule_destroy()`
Cleans up and frees memory associated with a type conversion rule.

### `flb_typecast_value_create()`
Converts a MessagePack object to a typed value according to a specified conversion rule.

### `flb_typecast_value_destroy()`
Cleans up and frees memory associated with a converted value, including any allocated strings.

### `flb_typecast_pack()`
Converts a MessagePack object according to a rule and packs the result directly into a MessagePack packer.

### `flb_typecast_value_conv()`
Internal function that performs the actual type conversion based on the specified rule.

## Important Variables/Constants

### Type Enumerations
- `FLB_TYPECAST_TYPE_INT`: Signed integer type
- `FLB_TYPECAST_TYPE_UINT`: Unsigned integer type
- `FLB_TYPECAST_TYPE_FLOAT`: Floating-point type
- `FLB_TYPECAST_TYPE_HEX`: Hexadecimal string type
- `FLB_TYPECAST_TYPE_STR`: String type
- `FLB_TYPECAST_TYPE_BOOL`: Boolean type
- `FLB_TYPECAST_TYPE_ERROR`: Error indicator

### Conversion Rules
- `struct flb_typecast_rule`: Defines a conversion rule with source and destination types
- `struct flb_typecast_value`: Holds converted values with type information

### Supported Conversions
- String ↔ Integer (signed/unsigned)
- String ↔ Float
- String ↔ Boolean
- String ↔ Hexadecimal
- Integer ↔ String
- Integer ↔ Float
- Integer ↔ Unsigned Integer
- Float ↔ String
- Float ↔ Integer
- Float ↔ Unsigned Integer
- Boolean ↔ String

## Dependencies

- Standard C library headers:
  - `string.h`: String manipulation functions
  - `inttypes.h`: Fixed-width integer types and format specifiers

- External libraries:
  - `msgpack.h`: MessagePack serialization library

- Fluent Bit core components:
  - `flb_mem.h`: Memory allocation utilities
  - `flb_utils.h`: Utility functions
  - `flb_typecast.h`: Type casting interface definitions

## Implementation Details

1. **Flexible Type System**: Supports conversion between all common data types used in log processing and data pipelines.

2. **Rule-Based Approach**: Conversion rules allow for consistent and configurable type handling across different parts of the system.

3. **Memory Safety**: Proper allocation and cleanup of converted values, especially important for string conversions that require dynamic memory allocation.

4. **MessagePack Integration**: Seamless integration with MessagePack objects for efficient serialization/deserialization operations.

5. **Error Handling**: Comprehensive error checking with appropriate return codes and logging for debugging.

6. **Hexadecimal Support**: Special handling for hexadecimal string conversion, useful for processing binary data represented as hex strings.

7. **Boolean Conversion**: Handles both string representations ("true"/"false") and numeric representations (0/1) for boolean values.

## Usage Example

```c
// Create a conversion rule from string to integer
struct flb_typecast_rule *rule = flb_typecast_rule_create(
    "string", 6,  // from type
    "int", 3       // to type
);

if (rule) {
    // Convert a MessagePack string object to integer
    msgpack_object input = /* ... string object ... */;
    
    // Direct packing approach
    msgpack_packer *packer = /* ... initialize packer ... */;
    int ret = flb_typecast_pack(input, rule, packer);
    
    if (ret == 0) {
        // Conversion successful, result is packed in the packer
        flb_debug("Successfully converted string to integer");
    }
    
    // Or value creation approach
    struct flb_typecast_value *value = flb_typecast_value_create(input, rule);
    if (value) {
        // Use the converted value
        int64_t converted_int = value->val.i_num;
        
        // Clean up
        flb_typecast_value_destroy(value);
    }
    
    // Clean up rule
    flb_typecast_rule_destroy(rule);
}

// Type conversion examples
// String "123" -> Integer 123
// String "456.78" -> Float 456.78
// String "true" -> Boolean true
// String "FF" -> Hex 255
// Integer 123 -> String "123"
// Float 456.78 -> String "456.78"
// Boolean true -> String "true"
```