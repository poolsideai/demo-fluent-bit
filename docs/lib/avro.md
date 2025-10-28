# lib/avro Documentation

## Overview

The lib/avro library is a C implementation of Apache Avro, a data serialization system. Avro provides:

* Rich data structures
* A compact, fast, binary data format
* A container file, to store persistent data
* Remote procedure call (RPC)

This implementation supports:
* Binary encoding/decoding of all primitive and complex data types
* Storage to an Avro Object Container File
* Schema resolution, promotion and projection
* Validating and non-validating mode for writing Avro data

## Key Functions

### Schema Functions

* `avro_schema_string()` - Create a string schema
* `avro_schema_bytes()` - Create a bytes schema
* `avro_schema_int()` - Create an int schema
* `avro_schema_long()` - Create a long schema
* `avro_schema_float()` - Create a float schema
* `avro_schema_double()` - Create a double schema
* `avro_schema_boolean()` - Create a boolean schema
* `avro_schema_null()` - Create a null schema
* `avro_schema_record()` - Create a record schema
* `avro_schema_enum()` - Create an enum schema
* `avro_schema_fixed()` - Create a fixed schema
* `avro_schema_map()` - Create a map schema
* `avro_schema_array()` - Create an array schema
* `avro_schema_union()` - Create a union schema

### Value Functions

* `avro_generic_class_from_schema()` - Return a generic avro_value_iface_t implementation for the given schema
* `avro_generic_value_new()` - Allocate a new instance of the given generic value class
* `avro_value_get_type()` - Return the general Avro type of a value instance
* `avro_value_get_schema()` - Return the Avro schema that a value is an instance of
* `avro_value_equal()` - Compare two values for equality
* `avro_value_copy()` - Copy the contents of src into dest
* `avro_value_hash()` - Return a hash value for a given Avro value
* `avro_value_to_json()` - Return a string containing the JSON encoding of an Avro value

### Primitive Value Getters

* `avro_value_get_boolean()` - Get the boolean value
* `avro_value_get_bytes()` - Get the bytes value
* `avro_value_get_double()` - Get the double value
* `avro_value_get_float()` - Get the float value
* `avro_value_get_int()` - Get the int value
* `avro_value_get_long()` - Get the long value
* `avro_value_get_null()` - Get the null value
* `avro_value_get_string()` - Get the string value
* `avro_value_get_enum()` - Get the enum value
* `avro_value_get_fixed()` - Get the fixed value

### Primitive Value Setters

* `avro_value_set_boolean()` - Set the boolean value
* `avro_value_set_bytes()` - Set the bytes value
* `avro_value_set_double()` - Set the double value
* `avro_value_set_float()` - Set the float value
* `avro_value_set_int()` - Set the int value
* `avro_value_set_long()` - Set the long value
* `avro_value_set_null()` - Set the null value
* `avro_value_set_string()` - Set the string value
* `avro_value_set_enum()` - Set the enum value
* `avro_value_set_fixed()` - Set the fixed value

### Compound Value Functions

* `avro_value_get_size()` - Return the number of elements in array/map, or the number of fields in a record
* `avro_value_get_by_index()` - For arrays and maps, returns the element with the given index
* `avro_value_get_by_name()` - For maps, returns the element with the given key
* `avro_value_get_discriminant()` - Return the discriminant of current union value
* `avro_value_get_current_branch()` - Return the current union value
* `avro_value_append()` - Creates a new array element
* `avro_value_add()` - Creates a new map element, or returns an existing one
* `avro_value_set_branch()` - Select a union branch

## Usage Notes

1. **Memory Management**: The library uses reference counting for all schema and data objects. When the number of references drops to zero, the memory is freed.

2. **Error Handling**: Most functions in the Avro C library return a single `int` status code. Following the POSIX `errno.h` convention, a status code of 0 indicates success. Non-zero codes indicate an error condition.

3. **Creating Values**: To create a value, you need to:
   * Get an implementation struct for the value implementation
   * Use the implementation's constructor function to allocate instances
   * Do whatever you need to the value
   * Free the value instance, if necessary, using the implementation's destructor function

4. **Generic Implementation**: The library provides a "generic" value implementation that will work (efficiently) for any Avro schema. This is typically what you want to use in most applications.

## Example Usage

```c
#include <avro.h>
#include <stdio.h>

// Create a schema
avro_schema_t schema = avro_schema_long();

// Create a generic value implementation for the schema
avro_value_iface_t *iface = avro_generic_class_from_schema(schema);

// Allocate a new instance of the generic value
avro_value_t val;
avro_generic_value_new(iface, &val);

// Set the value
avro_value_set_long(&val, 42);

// Do something with the value
// ...

// Clean up
avro_generic_value_free(&val);
avro_value_iface_decref(iface);
avro_schema_decref(schema);
```