# CMakeLists.txt (WASM)

## Overview

This CMakeLists.txt file configures the build system for the WASM (WebAssembly) runtime component of Fluent Bit. It sets up compilation flags, dependencies, and build targets for integrating WebAssembly support into Fluent Bit.

## Key Components

### Build Configuration
- Sets C standard to C99
- Configures platform-specific build settings
- Defines target architecture based on the host system
- Sets various WAMR (WebAssembly Micro Runtime) feature flags

### Target Architecture Detection
Automatically detects and configures the build target:
- X86_64, AMD_64, X86_32 for Intel/AMD processors
- AARCH64 for ARM64 processors
- ARM for ARM processors (including Raspberry Pi variants)
- RISCV64/RISCV32 for RISC-V processors
- MIPS, XTENSA for embedded architectures
- ARC for Synopsys ARC processors

### WAMR Features
Enables various WebAssembly features:
- WAMR_BUILD_INTERP=1: Enables interpreter mode
- WAMR_BUILD_FAST_INTERP=1: Enables fast interpreter mode
- WAMR_BUILD_AOT=1: Enables ahead-of-time compilation
- WAMR_BUILD_LIBC_BUILTIN=1: Enables built-in libc functions
- WAMR_BUILD_LIBC_WASI=1: Enables WASI libc support
- WAMR_BUILD_LIB_PTHREAD=1: Enables pthread support
- WAMR_BUILD_REF_TYPES=1: Enables reference types
- WASM_BUILD_SHARED_MEMORY=1: Enables shared memory support
- WASM_BUILD_THREAD_MGR=1: Enables thread management
- WASM_BUILD_TAIL_CALL=1: Enables tail call optimization
- WASM_BUILD_REF_TYPES=1: Enables reference types
- WASM_BUILD_GC=1: Enables garbage collection support

## Important Variables

### Build Target Configuration
- WAMR_BUILD_TARGET: Specifies the target architecture
- WAMR_BUILD_PLATFORM: Platform identifier (Windows, Darwin, Linux, etc.)

### Feature Flags
- WAMR_BUILD_MINI_LOADER: Enables minimal loader mode
- WAMR_BUILD_JIT: Enables just-in-time compilation
- WAMR_DISABLE_HW_BOUND_CHECK: Disables hardware boundary checking
- WAMR_BUILD_SIMD: Enables SIMD instruction support

### Library Configuration
- WAMR_ROOT_DIR: Root directory of WASM Micro Runtime
- WAMR_BUILD_LIBC_UVWASI: Enables uvwasi libc support for Windows

## Dependencies

- CMake 3.13 or higher
- C99 compatible compiler
- System libraries (pthread, dl, m)
- Optional: Jemalloc for memory allocation
- Optional: Libuv for uvwasi support

## Implementation Details

### Cross-Platform Support
- Handles Windows (MSVC, MinGW), macOS (Darwin), and Linux builds
- Configures platform-specific compiler flags
- Sets appropriate linker flags for different platforms

### Memory Management
- Integrates with Fluent Bit's memory allocation system
- Supports both system malloc and Jemalloc
- Configures heap and stack sizes for WASM instances

### Security Hardening
- Enables PIE (Position Independent Executable) for better security
- Uses compiler security flags (-fPIE, -pie)
- Configures garbage collection of unused sections

### Library Linking
- Links with WASM Micro Runtime static library (vmlib-static)
- Links with Fluent Bit's WASM support library (flb-wasm-static)
- Conditional linking based on platform and features

## Usage

This CMakeLists.txt is automatically included when building Fluent Bit with WASM support. To build:

```bash
# Standard build with WASM support
mkdir build && cd build
cmake .. -DFLB_WASM=On
make
```

The resulting Fluent Bit binary will include WASM runtime support, allowing plugins to be written in WebAssembly for improved portability and security.