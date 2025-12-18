# flb_typecast.c

## Overview

The `flb_typecast.c` file implements a type casting system for Fluent Bit that allows conversion between different data types, particularly for MessagePack objects. This module provides functionality to convert values between string, integer, unsigned integer, float, boolean, and hexadecimal formats, which is essential for data transformation in the Fluent Bit pipeline.

## Key Functions

### `flb_typecast_str_to_type_t(char *type_str, int type_len)`
Converts a string representation of a type to the corresponding enum value.

### `flb_typecast_type_t_to_str(flb_typecast_type_t type)`
Converts an enum type value to its string representation.

### `flb_typecast_rule_create(char *from_type, int from_len, char *to_type, int to_len)`
Creates a type casting rule that defines how to convert from one type to another.

### `flb_typecast_rule_destroy(struct flb_typecast_rule *rule)`
Destroys a type casting rule and frees associated memory.

### `flb_typecast_value_create(msgpack_object input, struct flb_typecast_rule *rule)`
Creates a converted value based on the input object and casting rule.

### `flb_typecast_value_destroy(struct flb_typecast_value* val)`
Destroys a converted value and frees associated memory.

### `flb_typecast_pack(msgpack_object input, struct flb_typecast_rule *rule, msgpack_packer *pck)`
Converts a MessagePack object according to a rule and packs the result into the provided packer.

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
- `val` - Union containing the actual value in various formats

## Dependencies

This module depends on:
- Fluent Bit memory management (`flb_mem.h`)
- Fluent Bit utilities (`flb_utils.h`)
- Fluent Bit type casting interface (`flb_typecast.h`)
- MessagePack library (`msgpack.h`)
- Standard C string functions (`string.h`)
- Standard integer types (`inttypes.h`)

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

The system supports bidirectional conversions between all supported types, with special handling for:
- Hexadecimal string parsing
- Boolean string representation ("true"/"false")
- Proper floating-point formatting
- Overflow/underflow detection for numeric conversions

Memory management is carefully handled with dedicated destroy functions to prevent leaks.

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