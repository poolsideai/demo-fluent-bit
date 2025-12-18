# CMakeLists.txt

## Overview

This CMakeLists.txt file defines the build configuration for the Unicode conversion library in Fluent Bit. It specifies the source files that make up the `flb-conv` static library and sets up the necessary include directories.

The file is part of the CMake build system and is responsible for compiling the Unicode conversion functionality that handles various character encodings and provides conversion utilities between different character sets.

## Key Components

### Include Directories
- `${CMAKE_CURRENT_SOURCE_DIR}`: Current source directory
- `${CMAKE_CURRENT_BINARY_DIR}`: Current binary directory

### Source Files
The `conv_src` variable lists all source files that will be compiled into the `flb-conv` static library:

- `flb_conv.c`: Main conversion functions
- `flb_wchar.c`: Wide character handling
- `flb_utf8_and_sjis.c`: UTF-8 and Shift-JIS (CP932) conversion
- `flb_utf8_and_gbk.c`: UTF-8 and GBK (CP936) conversion
- `flb_utf8_and_gb18030.c`: UTF-8 and GB18030 (CP54936) conversion
- `flb_utf8_and_uhc.c`: UTF-8 and UHC (CP949) conversion
- `flb_utf8_and_big5.c`: UTF-8 and Big5 (CP950) conversion
- `flb_utf8_and_win.c`: UTF-8 and various Windows code pages (CP1250, CP1251, CP1252, CP1253, CP1254, CP866, CP874)

### Library Definition
- `add_library(flb-conv STATIC ${conv_src})`: Creates the static library
- Optional linking with jemalloc if `FLB_JEMALLOC` is enabled

## Dependencies

- CMake build system
- Standard C compiler
- Optional: jemalloc library for memory allocation

## Notable Implementation Details

1. **Modular Design**: Each encoding conversion is implemented in separate source files
2. **Static Library**: The functionality is compiled into a static library for easy linking
3. **Conditional Compilation**: Optional jemalloc linking based on build configuration
4. **Comprehensive Coverage**: Supports multiple character encodings commonly used in different regions

## Usage Examples

Building the library:
```cmake
# In the parent CMakeLists.txt
add_subdirectory(src/unicode)

# Linking with the library
target_link_libraries(your_target flb-conv)
```

Using the conversion functions in code:
```c
#include <fluent-bit/flb_conv.h>

// Convert from UTF-8 to another encoding
char *converted = flb_utf8_to_encoding(utf8_string, encoding_type);

// Convert from another encoding to UTF-8
char *utf8_result = flb_encoding_to_utf8(encoded_string, encoding_type);
```