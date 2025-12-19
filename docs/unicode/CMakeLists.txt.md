# CMakeLists.txt

## Overview

This CMakeLists.txt file defines the build configuration for the Unicode conversion library in Fluent Bit. It specifies the source files that need to be compiled and linked to create the `flb-conv` static library.

The file is responsible for building the Unicode conversion functionality that handles character encoding conversions between various code pages and UTF-8.

## Key Components

### Source Files

The following source files are included in the build:

1. `flb_conv.c` - Main conversion functions
2. `flb_wchar.c` - Wide character handling
3. `flb_utf8_and_sjis.c` - Conversion between UTF-8 and Shift-JIS (cp932)
4. `flb_utf8_and_gbk.c` - Conversion between UTF-8 and GBK (cp936)
5. `flb_utf8_and_gb18030.c` - Conversion between UTF-8 and GB18030 (cp54936)
6. `flb_utf8_and_uhc.c` - Conversion between UTF-8 and UHC (cp949)
7. `flb_utf8_and_big5.c` - Conversion between UTF-8 and BIG5 (cp950)
8. `flb_utf8_and_win.c` - Conversion between UTF-8 and Windows code pages (cp1250, cp1251, cp1252, cp1253, cp1254, cp1256, cp866, cp874)

### Library Definition

```cmake
add_library(flb-conv STATIC ${conv_src})
```

Creates a static library named `flb-conv` from the specified source files.

### Dependencies

```cmake
if(FLB_JEMALLOC)
  target_link_libraries(flb-conv ${JEMALLOC_LIBRARIES})
endif()
```

Links with jemalloc if it's enabled in the Fluent Bit build configuration.

## Build Configuration

### Include Directories

```cmake
include_directories(
  ${CMAKE_CURRENT_SOURCE_DIR}
  ${CMAKE_CURRENT_BINARY_DIR}
)
```

Sets up include directories for the build:
- `${CMAKE_CURRENT_SOURCE_DIR}`: Source directory for header files
- `${CMAKE_CURRENT_BINARY_DIR}`: Build directory for generated files

## Dependencies

- CMake build system
- Standard C library
- Optional: jemalloc memory allocator

## Implementation Details

### Code Page Support

The library supports conversion between UTF-8 and the following code pages:
- **Japanese**: Shift-JIS (cp932)
- **Chinese (Simplified)**: GBK (cp936), GB18030 (cp54936)
- **Chinese (Traditional)**: BIG5 (cp950)
- **Korean**: UHC (cp949)
- **Western European**: Windows-1252 (cp1252)
- **Central European**: Windows-1250 (cp1250)
- **Cyrillic**: Windows-1251 (cp1251)
- **Greek**: Windows-1253 (cp1253)
- **Turkish**: Windows-1254 (cp1254)
- **Arabic**: Windows-1256 (cp1256)
- **Cyrillic (DOS)**: CP866 (cp866)
- **Thai**: Windows-874 (cp874)

### Build Integration

The library is built as a static library and linked into the main Fluent Bit executable. This approach ensures that the Unicode conversion functionality is available wherever needed in the codebase without external dependencies.

### Memory Management

When jemalloc is enabled, the library links with jemalloc libraries to provide optimized memory allocation for the conversion operations.