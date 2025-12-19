# WAMRC CMakeLists.txt Documentation

## Overview

This CMakeLists.txt file configures the build process for the WAMR (WebAssembly Micro Runtime) compiler component within Fluent Bit. It handles platform-specific configurations, compiler flags, and dependencies required to build the WAMR compiler (wamrc).

## Key Components

### Platform Detection and Configuration
- Automatically detects the build platform (Windows, macOS, Linux) and sets appropriate compiler definitions
- Configures target architecture based on system processor (X86_64, ARM, AARCH64, RISCV, etc.)
- Sets platform-specific build flags and compiler options

### WAMR Feature Configuration
- Enables various WAMR features through compile-time definitions:
  - `WASM_ENABLE_INTERP`: Enables interpreter mode
  - `WASM_ENABLE_WAMR_COMPILER`: Enables WAMR compiler
  - `WASM_ENABLE_BULK_MEMORY`: Enables bulk memory operations
  - `WASM_DISABLE_HW_BOUND_CHECK`: Disables hardware boundary checks
  - `WASM_ENABLE_SHARED_MEMORY`: Enables shared memory support
  - `WASM_ENABLE_THREAD_MGR`: Enables thread management
  - `WASM_ENABLE_TAIL_CALL`: Enables tail call optimization
  - `WASM_ENABLE_SIMD`: Enables SIMD instruction support
  - `WASM_ENABLE_REF_TYPES`: Enables reference types
  - `WASM_ENABLE_CUSTOM_NAME_SECTION`: Enables custom name sections
  - `WASM_ENABLE_AOT_STACK_FRAME`: Enables AOT stack frame support
  - `WASM_ENABLE_DUMP_CALL_STACK`: Enables call stack dumping
  - `WASM_ENABLE_PERF_PROFILING`: Enables performance profiling
  - `WASM_ENABLE_LOAD_CUSTOM_SECTION`: Enables loading custom sections
  - `WASM_ENABLE_LIB_WASI_THREADS`: Enables WASI threads library
  - `WASM_ENABLE_MODULE_INST_CONTEXT`: Enables module instance context
  - `WASM_ENABLE_MEMORY64`: Enables 64-bit memory addressing
  - `WASM_ENABLE_EXTENDED_CONST_EXPR`: Enables extended constant expressions

### LLVM Integration
- Searches for system LLVM installation or uses bundled LLVM
- Requires LLVM 13.0 or higher
- Configures LLVM-related compiler and linker flags
- Links against LLVM libraries for AOT compilation

### Library and Executable Targets
- Builds static libraries:
  - `vmlib-wamrc-static`: Core WAMR runtime library
  - `aotclib-static`: AOT compiler library
- Creates executable: `flb-wamrc-bin` (renamed to `flb-wamrc`)

## Dependencies

- LLVM 13.0+ (for AOT compilation)
- System libraries (pthread, dl, m)
- WAMR core components (interpreter, AOT compiler, libraries)

## Notable Implementation Details

1. **Platform-Specific Handling**: Different configurations for Windows (MSVC), macOS (Homebrew LLVM detection), and Linux
2. **Architecture Auto-Detection**: Automatically sets build target based on system processor
3. **Security Hardening**: Uses PIE (Position Independent Executable) flags for security
4. **Conditional Compilation**: Features can be enabled/disabled based on build requirements
5. **Cross-Platform Support**: Handles different architectures and operating systems

## Usage

This file is included in the main Fluent Bit CMake build system. When building Fluent Bit with WAMR support, this configuration ensures the WAMR compiler component is properly built and integrated.