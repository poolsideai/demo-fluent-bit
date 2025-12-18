# flb_typecast.c

## Overview

The `flb_typecast.c` file implements a type casting system for Fluent Bit that allows conversion between different data types, particularly for MessagePack objects. This module provides functionality to convert values between string, integer, unsigned integer, float, boolean, and hexadecimal formats, which is essential for data transformation in the Fluent Bit pipeline.

The type casting system is designed to handle data type conversions in a flexible and robust manner, supporting both explicit conversions defined by rules and automatic conversions based on data content. It's particularly important for filter plugins that need to transform data types and for ensuring compatibility with different output systems that may require specific data formats.

## Key Functions

### `flb_typecast_str_to_type_t(char *type_str, int type_len)`
Converts a string representation of a type to the corresponding enum value.

Supports case-insensitive matching for:
- "int" → `FLB_TYPECAST_TYPE_INT`
- "uint" → `FLB_TYPECAST_TYPE_UINT`
- "float" → `FLB_TYPECAST_TYPE_FLOAT`
- "hex" → `FLB_TYPECAST_TYPE_HEX`
- "string" → `FLB_TYPECAST_TYPE_STR`
- "bool" → `FLB_TYPECAST_TYPE_BOOL`

Returns `FLB_TYPECAST_TYPE_ERROR` for unrecognized types.

### `flb_typecast_type_t_to_str(flb_typecast_type_t type)`
Converts an enum type value to its string representation.

Provides human-readable type names for debugging and logging purposes.

### `flb_typecast_rule_create(char *from_type, int from_len, char *to_type, int to_len)`
Creates a type casting rule that defines how to convert from one type to another.

The function:
1. Validates input parameters
2. Allocates memory for the rule structure
3. Converts string representations to enum values
4. Performs validation of the conversion rule
5. Returns a properly initialized rule structure

### `flb_typecast_rule_destroy(struct flb_typecast_rule *rule)`
Destroys a type casting rule and frees associated memory.

Handles proper cleanup of rule structures to prevent memory leaks.

### `flb_typecast_value_create(msgpack_object input, struct flb_typecast_rule *rule)`
Creates a converted value based on the input object and casting rule.

The process involves:
1. Allocating memory for the output value structure
2. Performing the actual type conversion based on the rule
3. Populating the output structure with converted data
4. Returning the converted value for use

### `flb_typecast_value_destroy(struct flb_typecast_value* val)`
Destroys a converted value and frees associated memory.

Properly cleans up converted values, including freeing string buffers when necessary.

### `flb_typecast_pack(msgpack_object input, struct flb_typecast_rule *rule, msgpack_packer *pck)`
Converts a MessagePack object according to a rule and packs the result into the provided packer.

This function provides a direct conversion path that avoids intermediate value creation, making it more efficient for scenarios where the converted value is immediately serialized.

## Important Variables and Constants

### Type Constants
- `FLB_TYPECAST_TYPE_INT` - Signed integer
- `FLB_TYPECAST_TYPE_UINT` - Unsigned integer
- `FLB_TYPECAST_TYPE_FLOAT` - Floating point number
- `FLB_TYPECAST_TYPE_HEX` - Hexadecimal value
- `FLB_TYPECAST_TYPE_STR` - String
- `FLB_TYPECAST_TYPE_BOOL` - Boolean
- `FLB_TYPECAST_TYPE_ERROR` - Error state

### Rule Structure Fields
- `from_type` - Source type for conversion
- `to_type` - Target type for conversion

### Value Structure Fields
- `type` - Current type of the value
- `val` - Union containing the actual value in various formats:
  - `boolean` - Boolean value
  - `i_num` - Signed integer
  - `ui_num` - Unsigned integer/hexadecimal
  - `d_num` - Floating point number
  - `str` - String value (SDS)

## Dependencies

This module depends on:
- Fluent Bit memory management (`flb_mem.h`)
- Fluent Bit utilities (`flb_utils.h`)
- Fluent Bit type casting interface (`flb_typecast.h`)
- MessagePack library (`msgpack.h`)
- Standard C string functions (`string.h`)
- Standard integer types (`inttypes.h`)
- Fluent Bit SDS (Simple Dynamic Strings) for string management

## Implementation Details

The type casting system works by:
1. Defining conversion rules that specify source and target types
2. Performing type-specific conversions using dedicated functions:
   - `flb_typecast_conv_str()` - Converts string values
   - `flb_typecast_conv_bool()` - Converts boolean values
   - `flb_typecast_conv_int()` - Converts integer values
   - `flb_typecast_conv_uint()` - Converts unsigned integer values
   - `flb_typecast_conv_float()` - Converts floating point values
3. Automatically handling serialization/deserialization to/from MessagePack format
4. Managing memory allocation for converted values

### Conversion Functions

Each conversion function handles specific type transformations:

#### String Conversion (`flb_typecast_conv_str`)
Handles conversion from strings to other types:
- Integer parsing with overflow detection
- Hexadecimal parsing with base-16 conversion
- Boolean recognition of "true"/"false"
- Float parsing with `atof()`
- Proper error handling for invalid inputs

#### Boolean Conversion (`flb_typecast_conv_bool`)
Converts boolean values to strings:
- `FLB_TRUE` → "true"
- `FLB_FALSE` → "false"
- Proper MessagePack serialization

#### Integer Conversion (`flb_typecast_conv_int`)
Converts integers to other types:
- String representation with `snprintf()`
- Float conversion with casting
- Unsigned integer conversion
- Proper overflow handling

#### Unsigned Integer Conversion (`flb_typecast_conv_uint`)
Converts unsigned integers to other types:
- String representation with `snprintf()`
- Float conversion with casting
- Signed integer conversion
- Proper range checking

#### Float Conversion (`flb_typecast_conv_float`)
Converts floating point values to other types:
- String representation with format-appropriate precision
- Integer conversion with truncation
- Unsigned integer conversion
- Proper handling of special float values

### Type Validation

The system performs thorough validation:
- Input type checking against expected MessagePack object types
- Range validation for numeric conversions
- Format validation for string-to-number conversions
- Error reporting for invalid conversions

### Memory Management

Careful memory management is implemented:
- Proper allocation and deallocation of rule structures
- SDS management for string values
- Automatic cleanup of temporary buffers
- Prevention of memory leaks in error conditions

## Usage Examples

Creating a type casting rule and converting a value:
```c
struct flb_typecast_rule *rule;
struct flb_typecast_value *converted_value;
msgpack_object input_obj;

// Create a rule to convert from string to integer
rule = flb_typecast_rule_create("string", 6, "int", 3);

// Convert a MessagePack string object to integer
converted_value = flb_typecast_value_create(input_obj, rule);

// Use the converted value...

// Clean up
flb_typecast_value_destroy(converted_value);
flb_typecast_rule_destroy(rule);
```

Direct packing conversion:
```c
msgpack_packer *packer;
msgpack_object input_obj;
struct flb_typecast_rule *rule;

// ... initialize packer and rule ...

// Convert and pack directly
int result = flb_typecast_pack(input_obj, rule, packer);
```

Converting specific data types:
```c
// Convert string "123" to integer
msgpack_object str_obj = {.type = MSGPACK_OBJECT_STR, .via.str.ptr = "123", .via.str.size = 3};
struct flb_typecast_rule *rule = flb_typecast_rule_create("string", 6, "int", 3);
struct flb_typecast_value *val = flb_typecast_value_create(str_obj, rule);
if (val && val->type == FLB_TYPECAST_TYPE_INT) {
    // val->val.i_num contains the integer 123
}
```

## Error Handling

The type casting system implements comprehensive error handling:
- Parameter validation for all public functions
- Proper error codes for different failure scenarios
- Detailed error logging for debugging
- Graceful degradation when conversions fail
- Memory leak prevention in error conditions

## Supported Conversions

The system supports bidirectional conversions between all supported types:

| From\To | String | Integer | Unsigned | Float | Boolean | Hex |
|--------|--------|---------|----------|-------|---------|-----|
| String | ✓      | ✓       | ✓       | ✓     | ✓       | ✓   |
| Integer| ✓      | ✓       | ✓       | ✓     | ✗       | ✗   |
| Unsigned| ✓     | ✓       | ✓       | ✓     | ✗       | ✗   |
| Float  | ✓      | ✓       | ✓       | ✓     | ✗       | ✗   |
| Boolean| ✓      | ✗       | ✗       | ✗     | ✓       | ✗   |
| Hex    | ✓      | ✓       | ✓       | ✓     | ✗       | ✓   |

Note: Some conversions are not supported due to semantic incompatibility (e.g., converting a boolean to a number without explicit rules).

## Performance Considerations

The type casting system is optimized for performance:
- Minimal overhead for simple conversions
- Efficient memory allocation patterns
- Direct packing option to avoid intermediate allocations
- Proper use of SDS for string management

## Thread Safety

The type casting functions are designed to be thread-safe:
- No shared mutable state between function calls
- Proper memory isolation for each conversion
- Reentrant design for concurrent usage

## Integration with Fluent Bit Pipeline

The type casting system integrates seamlessly with Fluent Bit's data pipeline:
- Works with MessagePack objects throughout the pipeline
- Compatible with filter plugin architectures
- Supports dynamic type conversion based on configuration
- Integrates with record accessor for field-level conversions

## Memory Management

All type casting operations follow Fluent Bit's memory management patterns:
- Use of `flb_malloc`/`flb_free` for allocations
- SDS for string management
- Proper cleanup of all allocated resources
- Error-safe memory operations

## Extensibility

The type casting system is designed for extensibility:
- Modular conversion function design
- Clear separation of concerns
- Well-defined interfaces for adding new types
- Support for custom conversion rules

## Debugging and Monitoring

The system includes debugging aids:
- Detailed error messages for failed conversions
- Type validation logging
- Conversion path tracing capabilities
- Memory leak detection support