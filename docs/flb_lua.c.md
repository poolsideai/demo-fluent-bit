# flb_lua.c

## Overview

This file provides Lua integration capabilities for Fluent Bit. It enables the execution of Lua scripts within the Fluent Bit pipeline, allowing for custom filtering, processing, and transformation of log data. The module handles the conversion between Lua data types and Fluent Bit's internal data structures, particularly MessagePack objects.

The Lua integration is primarily used by the Lua filter plugin, which allows users to write custom filtering logic in Lua. This file contains core functions for pushing and pulling data between Lua and C contexts, handling type conversions, and managing Lua state.

## Key Functions

### Initialization and Setup

- `flb_lua_enable_flb_null()` - Enables the `flb_null` global variable in Lua for representing null values
- `flb_lua_pushtimetable()` - Pushes a time table to Lua with seconds and nanoseconds fields

### Validation Functions

- `flb_lua_is_valid_func()` - Checks if a specified function exists in the Lua context

### Data Conversion Functions

- `flb_lua_pushmpack()` - Pushes MessagePack data to Lua as appropriate Lua types
- `flb_lua_pushmsgpack()` - Pushes MessagePack objects to Lua as appropriate Lua types
- `flb_lua_tomsgpack()` - Converts Lua values to MessagePack format
- `flb_lua_tompack()` - Converts Lua values to MPack format

### Utility Functions

- `flb_lua_arraylength()` - Calculates the length of a Lua array
- `flb_lua_dump_stack()` - Dumps the current Lua stack for debugging purposes

## Important Variables and Constants

### Global Variables

- `FLB_LUA_VAR_FLB_NULL` - Name of the global variable used to represent null values in Lua

### Type Conversion Configuration

- `FLB_LUA_L2C_TYPES_NUM_MAX` (16) - Maximum number of type conversion rules

### Data Type Enumerations

- `FLB_LUA_L2C_TYPE_INT` - Integer type
- `FLB_LUA_L2C_TYPE_ARRAY` - Array type
- `FLB_LUA_L2C_TYPE_MAP` - Map type

## Data Structures

### Type Conversion Configuration

```c
struct flb_lua_l2c_config {
    int    l2c_types_num;      /* number of l2c_types */
    struct mk_list l2c_types;  /* data types (lua -> C) */
};
```

### Metadata Structure

```c
struct flb_lua_metadata {
    int initialized;
    int data_type; /* Map or Array */
};
```

### Type Definition

```c
struct flb_lua_l2c_type {
    flb_sds_t key;
    int type;
    struct mk_list _head;
};
```

## Dependencies and Relationships

### Direct Dependencies

- `<fluent-bit/flb_lua.h>` - Main Lua integration header
- `<fluent-bit/flb_info.h>` - Fluent Bit core information
- `<fluent-bit/flb_sds.h>` - String data structure utilities
- `<fluent-bit/flb_time.h>` - Time handling utilities
- `<fluent-bit/flb_luajit.h>` - LuaJIT integration
- `<monkey/mk_core/mk_list.h>` - Linked list utilities
- `<msgpack/pack.h>` - MessagePack packing utilities
- `<lua.h>` - Lua C API

### Relationship with Other Components

1. **Lua Filter Plugin**: This module is primarily used by the Lua filter plugin for custom data processing
2. **LuaJIT Integration**: Works with `flb_luajit.c` to manage Lua virtual machine instances
3. **MessagePack Integration**: Handles conversion between Lua types and MessagePack objects
4. **Data Pipeline**: Integrates with Fluent Bit's core data processing pipeline

## Notable Implementation Details

### Two-Phase Data Conversion

The implementation uses a two-phase approach for complex data structures:
1. **Push Phase**: Converts C/MessagePack data to Lua types
2. **Pull Phase**: Converts Lua types back to C/MessagePack data

### Metatable Support

The module supports Lua metatables for preserving type information when converting between Lua and C:
- Arrays are identified by metatables with `type=0`
- Maps are identified by metatables with `type=1`

### Type Conversion Rules

Configurable type conversion rules allow specifying how Lua tables should be interpreted:
- Tables can be forced to be treated as arrays
- Tables can be forced to be treated as maps
- Numeric values can be explicitly converted to integers

### Error Handling

The implementation includes robust error handling for:
- Invalid Lua types that cannot be serialized
- Malformed data structures
- Memory allocation failures

## Usage Examples

### Basic Data Conversion

```c
// Convert MessagePack object to Lua
msgpack_object *obj = /* ... */; // Get MessagePack object
lua_State *L = /* ... */; // Get Lua state

flb_lua_pushmsgpack(L, obj); // Push to Lua stack

// Call Lua function with the data
lua_getglobal(L, "process_data");
lua_insert(L, -2); // Move function below data
if (lua_pcall(L, 1, 1, 0) != 0) {
    flb_error("Error calling process_data: %s", lua_tostring(L, -1));
    return -1;
}

// Convert result back to MessagePack
msgpack_packer *packer = /* ... */; // Get MessagePack packer
struct flb_lua_l2c_config *l2cc = /* ... */; // Get conversion config

flb_lua_tomsgpack(L, packer, -1, l2cc); // Convert result to MessagePack
```

### Type Conversion Configuration

```c
struct flb_lua_l2c_config l2cc;
struct flb_lua_l2c_type l2c_type;

// Initialize configuration
l2cc.l2c_types_num = 0;
mk_list_init(&l2cc.l2c_types);

// Add type conversion rule
l2c_type.key = flb_sds_create("force_array");
l2c_type.type = FLB_LUA_L2C_TYPE_ARRAY;
mk_list_add(&l2c_type._head, &l2cc.l2c_types);
l2cc.l2c_types_num++;

// Use in conversion
flb_lua_tomsgpack(L, packer, -1, &l2cc);
```

### Array Length Calculation

```c
lua_State *L = /* ... */; // Get Lua state
int index = /* ... */; // Stack index of array

int len = flb_lua_arraylength(L, index);
if (len > 0) {
    // Process array elements
    for (int i = 1; i <= len; i++) {
        lua_rawgeti(L, index, i);
        // Process element at stack top
        lua_pop(L, 1);
    }
} else {
    // Handle map or invalid array
}
```

### Debugging with Stack Dump

```c
lua_State *L = /* ... */; // Get Lua state

// Debug current Lua stack
flb_lua_dump_stack(stdout, L);

// Example output:
// top index =3 ======
// 003: string: hello world
// 002: number: d=42.0 i=42
// 001: boolean: true
// =====
```

## Integration with Fluent Bit Architecture

The Lua integration module serves as a bridge between Fluent Bit's C-based core and Lua scripting capabilities:

1. **Input Plugins** can use Lua scripts for custom data parsing
2. **Filter Plugins** extensively use this module for custom data transformation
3. **Output Plugins** can leverage Lua for custom formatting or routing decisions
4. **Core Engine** manages the lifecycle of Lua virtual machines through the LuaJIT integration

This design allows users to extend Fluent Bit's functionality without modifying the core C codebase, providing flexibility for complex data processing scenarios while maintaining performance through the efficient LuaJIT implementation.