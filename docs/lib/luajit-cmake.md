# luajit-cmake

## Overview

`luajit-cmake` is a flexible CMake builder for LuaJIT. It provides a convenient way to integrate LuaJIT into CMake-based projects, making it easier to build and link against LuaJIT.

LuaJIT is a Just-In-Time Compiler for Lua, which can significantly improve the execution speed of Lua code compared to the standard Lua interpreter.

## Key Methods/Functions

### Build Configuration

- **CMake Integration**: The library can be easily integrated into existing CMake projects using `add_subdirectory()`
- **Target Linking**: Use `target_link_libraries(yourTarget PRIVATE luajit::lib luajit::header)` to link against LuaJIT

### Cross-compilation Support

- **iOS**: Build for iOS platforms using the provided iOS target
- **Android**: Build for Android platforms using the provided Android target
- **Windows**: Build for Windows platforms using the provided Windows target

## Usage Notes

### Basic Integration

To integrate `luajit-cmake` into your CMake project:

```cmake
add_subdirectory(luajit-cmake)
target_link_libraries(yourTarget PRIVATE luajit::lib luajit::header)
```

### Build Commands

- **Standard Build**: `cmake -H. -Bbuild -DLUAJIT_DIR=...` followed by `make --build build --config Release`
- **Make-based Build**: `make -DLUAJIT_DIR=...` or platform-specific variants like `mingw32-make` or `gnumake`

### Cross-compilation

The library supports cross-compilation for various platforms:
- iOS: `make iOS`
- Android: `make Android`
- Windows: `make Windows`

Note: For Windows builds, when using mingw32-make, please change `\\` to `/` in file paths.

## Important Considerations

- The i386 architecture is deprecated for macOS, so 32-bit builds on macOS require special handling
- The library uses mingw-w64 and wine to build and run 32-bit minilua and buildvm on macOS