# flb_wasm.c Documentation

## Overview

This file implements the WebAssembly runtime integration for Fluent Bit. It provides functionality to load, instantiate, and execute WebAssembly modules within the Fluent Bit framework. The implementation uses the WASM Micro Runtime (WAMR) to provide efficient WebAssembly execution capabilities.

## Key Components

### Data Structures

#### `struct flb_wasm`
Represents a loaded and instantiated WebAssembly module:
- `buffer`: Raw WASM bytecode buffer
- `module`: Loaded WASM module
- `module_inst`: Instantiated module instance
- `exec_env`: Execution environment for the module
- `config`: Pointer to Fluent Bit configuration
- `tag_buffer`, `record_buffer`: Buffers for passing data to WASM functions
- `_head`: List head for linking to config->wasm_list

#### `struct flb_wasm_config`
Configuration parameters for WASM execution:
- `heap_size`: Heap size for WASM instance (default: FLB_WASM_DEFAULT_HEAP_SIZE)
- `stack_size`: Stack size for WASM instance (default: FLB_WASM_DEFAULT_STACK_SIZE)
- File descriptor mappings for stdin/stdout/stderr

### Core Functions

#### Initialization Functions
- `flb_wasm_init()`: Initializes the WASM subsystem by initializing the wasm_list in the config
- `flb_wasm_config_init()`: Creates and initializes WASM configuration with default heap/stack sizes
- `flb_wasm_config_destroy()`: Cleans up WASM configuration by freeing memory

#### Module Management Functions
- `flb_wasm_instantiate()`: Loads and instantiates a WASM module with proper error handling and resource cleanup
- `flb_wasm_destroy()`: Destroys a WASM module instance and frees all associated resources
- `flb_wasm_destroy_all()`: Destroys all WASM modules in the configuration

#### Execution Functions
- `flb_wasm_call_function_format_json()`: Calls a WASM function with JSON-formatted data
- `flb_wasm_call_function_format_msgpack()`: Calls a WASM function with MessagePack-formatted data
- `flb_wasm_call_wasi_main()`: Executes the main function of a WASI module

#### Utility Functions
- `flb_wasm_buffer_free()`: Frees WASM-allocated buffers
- `flb_wasm_load_wasm_binary()`: Loads WASM bytecode from file with format validation

## Important Variables

### Constants
- `FLB_WASM_DEFAULT_HEAP_SIZE`: Default heap size for WASM instances (16MB)
- `FLB_WASM_DEFAULT_STACK_SIZE`: Default stack size for WASM instances (64KB)

### Global State
- `config`: Global Fluent Bit configuration pointer
- `hstatus`: Windows service status handle (Windows only)

## Dependencies

### External Libraries
- WASM Micro Runtime (WAMR): Core WASM execution engine
- MessagePack: For data serialization
- Fluent Bit core libraries: Memory management, logging, etc.

### System Libraries
- Standard C library functions
- File I/O operations
- Windows API (Windows only)

## Notable Implementation Details

1. **Memory Management Integration**: Uses Fluent Bit's memory allocation functions (flb_malloc, flb_free) integrated with WASM runtime's allocator
2. **Error Handling**: Comprehensive error checking with proper resource cleanup on failure
3. **Data Exchange**: Efficient passing of tag and record data to WASM functions with both JSON and MessagePack support
4. **Pointer Validation**: Validates WASM pointers before accessing data to prevent security issues
5. **Cross-Platform Support**: Conditional compilation for Windows, macOS, and Linux with WASI support
6. **File System Access Control**: Restricts WASM module access to specified accessible directories
7. **Resource Cleanup**: Ensures all WASM resources are properly freed to prevent memory leaks

## Usage Examples

### Loading and Instantiating a WASM Module
```c
struct flb_wasm_config *wasm_config = flb_wasm_config_init(config);
struct mk_list accessible_dirs; // List of accessible directories
struct flb_wasm *fw = flb_wasm_instantiate(config, "/path/to/module.wasm", 
                                          &accessible_dirs, wasm_config);
```

### Calling a WASM Function with JSON Data
```c
char *result = flb_wasm_call_function_format_json(fw, "process_record",
                                                  tag, tag_len,
                                                  timestamp,
                                                  record_json, record_len);
// Process result...
if (result) {
    flb_free(result);
}
```

### Cleaning Up Resources
```c
flb_wasm_destroy(fw);
flb_wasm_config_destroy(wasm_config);
```