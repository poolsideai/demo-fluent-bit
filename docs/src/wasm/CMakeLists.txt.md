# WASM CMakeLists.txt Documentation

## Overview

This CMakeLists.txt file configures the build process for the WASM (WebAssembly) runtime component within Fluent Bit. It handles platform-specific configurations, compiler flags, and dependencies required to integrate WebAssembly support into Fluent Bit.

## Key Components

### Platform Detection and Configuration
- Automatically detects the build platform (Windows, macOS, Linux) and sets appropriate compiler definitions
- Configures target architecture based on system processor (X86_64, ARM, AARCH64, RISCV, MIPS, XTENSA, ARC, etc.)
- Sets platform-specific build flags and compiler options

### WAMR Feature Configuration
- Enables various WAMR features through compile-time definitions:
  - `WAMR_BUILD_MINI_LOADER`: Enables minimal loader mode
  - `WAMR_BUILD_INTERP`: Enables interpreter mode
  - `WAMR_BUILD_FAST_INTERP`: Enables fast interpreter mode
  - `WAMR_BUILD_AOT`: Enables ahead-of-time compilation
  - `WAMR_BUILD_JIT`: Enables just-in-time compilation
  - `WAMR_BUILD_LIBC_BUILTIN`: Enables built-in libc functions
  - `WAMR_BUILD_LIBC_WASI`: Enables WASI libc support
  - `WAMR_BUILD_LIBC_UVWASI`: Enables uvwasi libc support for Windows
  - `WAMR_BUILD_LIB_PTHREAD`: Enables pthread support
  - `WAMR_BUILD_REF_TYPES`: Enables reference types
  - `WASM_BUILD_SHARED_MEMORY`: Enables shared memory support
  - `WASM_BUILD_THREAD_MGR`: Enables thread management
  - `WASM_BUILD_TAIL_CALL`: Enables tail call optimization
  - `WASM_BUILD_REF_TYPES`: Enables reference types
  - `WASM_BUILD_CUSTOM_NAME_SECTION`: Enables custom name sections
  - `WASM_BUILD_AOT_STACK_FRAME`: Enables AOT stack frame support
  - `WASM_BUILD_DUMP_CALL_STACK`: Enables call stack dumping
  - `WASM_BUILD_PERF_PROFILING`: Enables performance profiling
  - `WASM_BUILD_LOAD_CUSTOM_SECTION`: Enables loading custom sections
  - `WASM_BUILD_MODULE_INST_CONTEXT`: Enables module instance context
  - `WASM_BUILD_MEMORY64`: Enables 64-bit memory addressing
  - `WASM_BUILD_EXTENDED_CONST_EXPR`: Enables extended constant expressions
  - `WASM_BUILD_GC`: Enables garbage collection support
  - `WAMR_DISABLE_HW_BOUND_CHECK`: Disables hardware boundary checking

### Library and Executable Targets
- Builds static libraries:
  - `vmlib-static`: Core WASM Micro Runtime library
  - `flb-wasm-static`: Fluent Bit's WASM integration library

## Dependencies

- WASM Micro Runtime (WAMR) core components
- System libraries (pthread, dl, m)
- Optional: Jemalloc for memory allocation
- Optional: Libuv for uvwasi support

## Notable Implementation Details

1. **Platform-Specific Handling**: Different configurations for Windows (MSVC, MinGW), macOS (Darwin), and Linux
2. **Architecture Auto-Detection**: Automatically sets build target based on system processor
3. **Security Hardening**: Uses PIE (Position Independent Executable) flags for security
4. **Conditional Compilation**: Features can be enabled/disabled based on build requirements
5. **Memory Management Integration**: Integrates with Fluent Bit's memory allocation system
6. **Cross-Platform Support**: Handles different architectures and operating systems

## Usage

This file is included in the main Fluent Bit CMake build system. When building Fluent Bit with WASM support, this configuration ensures the WASM runtime component is properly built and integrated.