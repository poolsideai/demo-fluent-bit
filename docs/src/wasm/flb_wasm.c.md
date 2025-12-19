# flb_wasm.c

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
- `flb_wasm_init()`: Initializes the WASM subsystem
- `flb_wasm_config_init()`: Creates and initializes WASM configuration
- `flb_wasm_config_destroy()`: Cleans up WASM configuration

#### Module Management Functions
- `flb_wasm_instantiate()`: Loads and instantiates a WASM module
- `flb_wasm_destroy()`: Destroys a WASM module instance
- `flb_wasm_destroy_all()`: Destroys all WASM modules

#### Execution Functions
- `flb_wasm_call_function_format_json()`: Calls a WASM function with JSON-formatted data
- `flb_wasm_call_function_format_msgpack()`: Calls a WASM function with MessagePack-formatted data
- `flb_wasm_call_wasi_main()`: Executes the main function of a WASI module

#### Utility Functions
- `flb_wasm_buffer_free()`: Frees WASM-allocated buffers
- `flb_wasm_load_wasm_binary()`: Loads WASM bytecode from file

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

## Implementation Details

### Memory Management
- Uses Fluent Bit's memory allocation functions (flb_malloc, flb_free)
- Integrates with WASM runtime's memory allocator
- Manages WASM heap and stack allocation
- Handles buffer allocation for data exchange with WASM modules

### Error Handling
- Comprehensive error checking for WASM operations
- Proper cleanup of resources on failure
- Detailed error messages for debugging
- Exception handling for WASM runtime errors

### Data Exchange
- Efficiently passes tag and record data to WASM functions
- Handles both JSON and MessagePack data formats
- Validates WASM pointers before accessing data
- Properly manages memory for returned strings

### Platform Support
- Cross-platform support for Windows, macOS, and Linux
- Conditional compilation for platform-specific features
- WASI support for sandboxed execution
- File system access control through accessible directory lists

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

## Integration with Fluent Bit

This module integrates with Fluent Bit's plugin system, allowing developers to write input, filter, and output plugins in WebAssembly. The WASM runtime provides a secure sandboxed environment for executing custom logic while maintaining high performance through the WAMR interpreter and optional AOT compilation.