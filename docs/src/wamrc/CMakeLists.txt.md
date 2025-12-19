# CMakeLists.txt (WAMRC)

## Overview

This CMakeLists.txt file configures the build system for the WAMRC (WASM Micro Runtime Compiler) component of Fluent Bit. It sets up compilation flags, dependencies, and build targets for compiling WebAssembly modules to native code.

## Key Components

### Build Configuration
- Sets C++ standard to C++14
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

### WAMR Features
Enables various WebAssembly features:
- WASM_ENABLE_INTERP=1: Enables interpreter mode
- WASM_ENABLE_WAMR_COMPILER=1: Enables WAMR compiler
- WASM_ENABLE_BULK_MEMORY=1: Enables bulk memory operations
- WASM_ENABLE_SHARED_MEMORY=1: Enables shared memory support
- WASM_ENABLE_THREAD_MGR=1: Enables thread management
- WASM_ENABLE_TAIL_CALL=1: Enables tail call optimization
- WASM_ENABLE_SIMD=1: Enables SIMD instruction support
- WASM_ENABLE_REF_TYPES=1: Enables reference types

## Important Variables

### Build Target Configuration
- WAMR_BUILD_TARGET: Specifies the target architecture
- WAMR_BUILD_PLATFORM: Platform identifier (Windows, Darwin, Linux, etc.)
- LLVM_DIR: Path to LLVM installation

### Feature Flags
- WAMR_BUILD_WITH_SYSTEM_LLVM: Whether to use system LLVM installation
- WAMR_BUILD_MINI_LOADER: Enables minimal loader mode
- WAMR_BUILD_INTERP: Enables interpreter mode
- WAMR_BUILD_FAST_INTERP: Enables fast interpreter mode
- WAMR_BUILD_AOT: Enables ahead-of-time compilation
- WAMR_BUILD_JIT: Enables just-in-time compilation

## Dependencies

- LLVM 13.0 or higher for compilation
- CMake 3.13 or higher
- C++14 compatible compiler
- System libraries (pthread, dl, m)

## Implementation Details

### Cross-Platform Support
- Handles Windows (MSVC, MinGW), macOS (Darwin), and Linux builds
- Configures platform-specific compiler flags
- Sets appropriate linker flags for different platforms

### LLVM Integration
- Automatically detects LLVM installation via CMake
- Falls back to bundled LLVM if system LLVM is not found
- Configures LLVM-specific build options
- Handles LLVM version compatibility checks

### Security Hardening
- Enables PIE (Position Independent Executable) for better security
- Uses compiler security flags (-fPIE, -pie)
- Configures garbage collection of unused sections

## Usage

This CMakeLists.txt is automatically included when building Fluent Bit with WAMRC support. To build:

```bash
# Standard build with WAMRC
mkdir build && cd build
cmake .. -DFLB_WASM_MICRO_RUNTIME=On
make
```

The resulting `flb-wamrc` binary can be used to compile WebAssembly modules to native code for improved performance in Fluent Bit's WASM plugin.