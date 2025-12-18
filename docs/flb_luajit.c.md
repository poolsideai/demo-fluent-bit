# flb_luajit.c

## Overview

This file provides LuaJIT integration for Fluent Bit. LuaJIT is a Just-In-Time compiler for Lua that offers significantly better performance than the standard Lua interpreter. This module manages LuaJIT virtual machine instances, script loading, and lifecycle management within the Fluent Bit framework.

The LuaJIT integration is essential for Fluent Bit's Lua filter plugin, which allows users to write custom filtering logic in Lua. By using LuaJIT instead of standard Lua, Fluent Bit achieves much better performance for Lua-based data processing while maintaining the flexibility of scripting.

## Key Functions

### Instance Management

- `flb_luajit_create()` - Creates a new LuaJIT virtual machine instance
- `flb_luajit_destroy()` - Destroys a LuaJIT virtual machine instance
- `flb_luajit_destroy_all()` - Destroys all LuaJIT instances associated with a Fluent Bit context

### Script Loading

- `flb_luajit_load_script()` - Loads and compiles a Lua script from a file
- `flb_luajit_load_buffer()` - Loads and compiles Lua code from a memory buffer

## Important Data Structures

### LuaJIT Context

```c
struct flb_luajit {
    lua_State *state;      /* LuaJIT VM environment   */
    void *config;          /* Fluent Bit context      */
    struct mk_list _head;  /* Link to flb_config->lua */
};
```

This structure represents a LuaJIT virtual machine instance and maintains:
- A pointer to the LuaJIT state (`lua_State *state`)
- A reference to the parent Fluent Bit configuration (`void *config`)
- A linked list node for managing multiple instances (`struct mk_list _head`)

## Dependencies and Relationships

### Direct Dependencies

- `<fluent-bit/flb_luajit.h>` - Main LuaJIT integration header
- `<fluent-bit/flb_info.h>` - Fluent Bit core information
- `<fluent-bit/flb_mem.h>` - Memory management utilities
- `<fluent-bit/flb_log.h>` - Logging utilities
- `<fluent-bit/flb_config.h>` - Configuration management
- `<lauxlib.h>` - Lua auxiliary library
- `<lua.h>` - Lua C API
- `<lualib.h>` - Lua standard libraries

### Relationship with Other Components

1. **Lua Integration**: Works closely with `flb_lua.c` for data type conversion and script execution
2. **Lua Filter Plugin**: Provides the execution environment for Lua filter scripts
3. **Fluent Bit Core**: Integrates with the main Fluent Bit configuration and lifecycle management
4. **Plugin System**: Supports dynamic loading of Lua scripts as part of the plugin architecture

## Notable Implementation Details

### Memory Management

The implementation properly manages memory for LuaJIT instances:
- Allocates memory for the `flb_luajit` structure using `flb_malloc()`
- Initializes the LuaJIT state with `luaL_newstate()`
- Opens standard Lua libraries with `luaL_openlibs()`
- Links instances to the Fluent Bit configuration for proper cleanup

### Error Handling

Comprehensive error handling is implemented for:
- Failed memory allocation for `flb_luajit` structures
- Failed LuaJIT state creation
- Script compilation errors
- Proper cleanup of partially initialized instances

### Instance Lifecycle

The module maintains strict control over LuaJIT instance lifecycles:
- Instances are created and linked to the Fluent Bit configuration
- All instances are properly destroyed when the Fluent Bit context is shut down
- Individual instances can be destroyed independently when no longer needed

### Script Loading

Two methods are provided for loading Lua scripts:
1. **File-based loading**: `flb_luajit_load_script()` loads scripts from files
2. **Buffer-based loading**: `flb_luajit_load_buffer()` loads scripts from memory buffers

Both methods provide detailed error reporting when script compilation fails.

## Usage Examples

### Creating a LuaJIT Instance

```c
struct flb_config *config = /* ... */; // Get Fluent Bit configuration

struct flb_luajit *lj = flb_luajit_create(config);
if (!lj) {
    flb_error("Failed to create LuaJIT instance");
    return -1;
}

// Use the LuaJIT instance for script execution
// ...

// Clean up when done
flb_luajit_destroy(lj);
```

### Loading and Executing a Lua Script

```c
struct flb_luajit *lj = /* ... */; // Get LuaJIT instance

// Load script from file
int ret = flb_luajit_load_script(lj, "/path/to/script.lua");
if (ret != 0) {
    flb_error("Failed to load script: %s", lua_tostring(lj->state, -1));
    return -1;
}

// Execute the loaded script
ret = lua_pcall(lj->state, 0, LUA_MULTRET, 0);
if (ret != 0) {
    flb_error("Error executing script: %s", lua_tostring(lj->state, -1));
    return -1;
}

// Continue with script execution...
```

### Loading Lua Code from Memory

```c
struct flb_luajit *lj = /* ... */; // Get LuaJIT instance

const char *lua_code = "
function process_record(record)
    record.processed = true
    record.timestamp = os.time()
    return record
end
";

// Load code from buffer
int ret = flb_luajit_load_buffer(lj, (char *)lua_code, strlen(lua_code), "inline_script");
if (ret != 0) {
    flb_error("Failed to load inline script: %s", lua_tostring(lj->state, -1));
    return -1;
}

// Execute the loaded code
ret = lua_pcall(lj->state, 0, LUA_MULTRET, 0);
if (ret != 0) {
    flb_error("Error executing inline script: %s", lua_tostring(lj->state, -1));
    return -1;
}
```

### Cleaning Up All Instances

```c
struct flb_config *config = /* ... */; // Get Fluent Bit configuration

// Destroy all LuaJIT instances associated with this configuration
int count = flb_luajit_destroy_all(config);
if (count > 0) {
    flb_info("Destroyed %d LuaJIT instances", count);
}
```

## Integration with Fluent Bit Architecture

The LuaJIT integration module integrates seamlessly with Fluent Bit's architecture:

1. **Plugin System**: Provides the execution environment for Lua-based plugins
2. **Configuration Management**: Instances are linked to Fluent Bit configurations for proper lifecycle management
3. **Memory Management**: Follows Fluent Bit's memory management patterns using `flb_malloc`/`flb_free`
4. **Error Handling**: Integrates with Fluent Bit's logging system for consistent error reporting
5. **Performance Optimization**: Leverages LuaJIT's JIT compilation for high-performance script execution

This design ensures that Lua scripts can be efficiently executed within Fluent Bit while maintaining the stability and performance characteristics expected from the core system.