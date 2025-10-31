# Jansson Library Documentation

## Overview

Jansson is a C library for encoding, decoding and manipulating JSON data. Its main features and design principles are:

- Simple and intuitive API and data model
- Comprehensive documentation
- No dependencies on other libraries
- Full Unicode support (UTF-8)
- Extensive test suite

Jansson is licensed under the MIT license.

## Key Methods/Functions

### Object Creation and Management

- `json_object()` - Creates a new empty JSON object
- `json_array()` - Creates a new empty JSON array
- `json_string(const char *value)` - Creates a new JSON string
- `json_integer(json_int_t value)` - Creates a new JSON integer
- `json_real(double value)` - Creates a new JSON real number
- `json_true()` - Creates a new JSON true value
- `json_false()` - Creates a new JSON false value
- `json_null()` - Creates a new JSON null value
- `json_delete(json_t *json)` - Decrements the reference count of a JSON value and frees it if the reference count reaches zero
- `json_incref(json_t *json)` - Increments the reference count of a JSON value
- `json_decref(json_t *json)` - Decrements the reference count of a JSON value

### Object Manipulation

- `json_object_size(const json_t *object)` - Returns the number of key-value pairs in an object
- `json_object_get(const json_t *object, const char *key)` - Gets a value from an object by key
- `json_object_set_new(json_t *object, const char *key, json_t *value)` - Sets a new value to an object by key
- `json_object_del(json_t *object, const char *key)` - Deletes a value from an object by key
- `json_object_clear(json_t *object)` - Removes all key-value pairs from an object
- `json_object_update(json_t *object, json_t *other)` - Updates an object with another object's key-value pairs

### Array Manipulation

- `json_array_size(const json_t *array)` - Returns the number of elements in an array
- `json_array_get(const json_t *array, size_t index)` - Gets an element from an array by index
- `json_array_set_new(json_t *array, size_t index, json_t *value)` - Sets a new value to an array at the given index
- `json_array_append_new(json_t *array, json_t *value)` - Appends a new value to the end of an array
- `json_array_remove(json_t *array, size_t index)` - Removes an element from an array at the given index
- `json_array_clear(json_t *array)` - Removes all elements from an array

### Value Accessors

- `json_string_value(const json_t *string)` - Returns the string value of a JSON string
- `json_string_length(const json_t *string)` - Returns the length of a JSON string
- `json_integer_value(const json_t *integer)` - Returns the integer value of a JSON integer
- `json_real_value(const json_t *real)` - Returns the real value of a JSON real
- `json_number_value(const json_t *json)` - Returns the numeric value of a JSON number (integer or real)

### Encoding/Decoding

- `json_loads(const char *input, size_t flags, json_error_t *error)` - Decodes a JSON string into a JSON value
- `json_load_file(const char *path, size_t flags, json_error_t *error)` - Decodes a JSON file into a JSON value
- `json_dumps(const json_t *json, size_t flags)` - Encodes a JSON value into a JSON string
- `json_dump_file(const json_t *json, const char *path, size_t flags)` - Encodes a JSON value into a JSON file

### Utility Functions

- `json_equal(const json_t *value1, const json_t *value2)` - Tests if two JSON values are equal
- `json_copy(json_t *value)` - Creates a shallow copy of a JSON value
- `json_deep_copy(const json_t *value)` - Creates a deep copy of a JSON value

## Usage Notes

1. Jansson uses reference counting for memory management. When you receive a JSON value from a function, you own a reference to it and must call `json_decref()` when you're done with it.

2. For object and array manipulation, use the `_new` variants of functions (e.g., `json_object_set_new`) when you want to transfer ownership of the value to the container.

3. Error handling is done through the `json_error_t` structure, which contains line, column, position, source, and text fields.

4. Jansson supports various encoding and decoding flags for customizing the behavior:
   - `JSON_INDENT(n)` - Pretty-print with indentation
   - `JSON_COMPACT` - Compact encoding without extra whitespace
   - `JSON_ENSURE_ASCII` - Escape all Unicode characters
   - `JSON_SORT_KEYS` - Sort object keys alphabetically

## Example

```c
#include <jansson.h>
#include <stdio.h>

int main() {
    // Create a JSON object
    json_t *root = json_object();
    
    // Add some values
    json_object_set_new(root, "name", json_string("John"));
    json_object_set_new(root, "age", json_integer(30));
    json_object_set_new(root, "active", json_true());
    
    // Encode to string
    char *json_str = json_dumps(root, JSON_INDENT(2));
    printf("%s\n", json_str);
    
    // Clean up
    free(json_str);
    json_decref(root);
    
    return 0;
}
```