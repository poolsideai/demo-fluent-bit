# CMakeLists.txt

## Overview

This CMakeLists.txt file configures the build system for Fluent Bit's record accessor functionality. It manages the compilation of lexer and parser components generated from Flex and Bison specifications, along with the core record accessor implementation. The file sets up dependencies and build configurations necessary for the record accessor feature.

## Build Configuration

### Lexer and Parser Generation

Generates lexer and parser components from specification files:

```cmake
flex_target(lexer   ra.l "${CMAKE_CURRENT_BINARY_DIR}/ra_lex.c"
            DEFINES_FILE "${CMAKE_CURRENT_BINARY_DIR}/ra_lex.h"
            )
bison_target(parser ra.y "${CMAKE_CURRENT_BINARY_DIR}/ra_parser.c")
```

### Source Files

Defines source files for the record accessor parser:

```cmake
set(sources
  flb_ra_parser.c
  )
```

### Platform-Specific Configuration

Handles Windows-specific build requirements:

```cmake
if(CMAKE_SYSTEM_NAME MATCHES "Windows")
  FLB_DEFINITION(YY_NO_UNISTD_H)
  message(STATUS "Specifying YY_NO_UNISTD_H")
endif()
```

### Include Directories

Sets up include directories for compilation:

```cmake
include_directories(
  ${CMAKE_CURRENT_SOURCE_DIR}
  ${CMAKE_CURRENT_BINARY_DIR}
  )
```

### Library Target

Creates a static library target for the record accessor parser:

```cmake
add_library(flb-ra-parser STATIC
    ${sources}
    "${CMAKE_CURRENT_BINARY_DIR}/ra_lex.c"
    "${CMAKE_CURRENT_BINARY_DIR}/ra_parser.c"
    )
```

### Dependencies

Manages build dependencies:

```cmake
add_flex_bison_dependency(lexer parser)
add_dependencies(flb-ra-parser onigmo-static)

if(FLB_JEMALLOC)
  target_link_libraries(flb-ra-parser ${JEMALLOC_LIBRARIES})
endif()
```

## Dependencies

- **Flex**: Lexical analyzer generator
- **Bison**: Parser generator
- **onigmo-static**: Static regex library dependency
- **FLB_JEMALLOC**: Build option for jemalloc memory allocator
- **JEMALLOC_LIBRARIES**: Jemalloc library dependencies
- **ra.l**: Lexer specification file
- **ra.y**: Parser specification file
- **flb_ra_parser.c**: Record accessor parser implementation

## Implementation Details

### Code Generation

Uses Flex and Bison to generate parser components:

- **Lexer Generation**: Creates `ra_lex.c` and `ra_lex.h` from `ra.l`
- **Parser Generation**: Creates `ra_parser.c` from `ra.y`
- **Dependency Management**: Ensures proper build order with `add_flex_bison_dependency`

### Cross-Platform Support

Handles platform-specific requirements:

- **Windows**: Defines `YY_NO_UNISTD_H` to avoid unistd.h issues
- **Unix-like**: No special handling required

### Memory Management

Supports optional memory allocators:

- **Standard Allocator**: Default system memory allocation
- **Jemalloc**: High-performance memory allocator when enabled

### Library Structure

Creates a static library (`flb-ra-parser`) rather than a shared library:

- **Integration**: Becomes part of the main Fluent Bit binary
- **Performance**: Avoids dynamic loading overhead
- **Deployment**: Simplifies deployment by not requiring separate library files

### Include Path Management

Properly configures include directories:

- **Source Directory**: For header files in the source tree
- **Binary Directory**: For generated files from Flex/Bison

## Integration with Fluent Bit

### Parser Integration

The record accessor parser integrates with Fluent Bit's core:

- **Lexer**: Tokenizes record accessor expressions
- **Parser**: Parses tokenized expressions into executable forms
- **API**: Provides interfaces for accessing record fields

### Regex Support

Depends on the onigmo regex library:

- **Pattern Matching**: Supports complex pattern matching in record accessors
- **Static Linking**: Links statically to avoid runtime dependencies

### Memory Allocator

Supports configurable memory allocators:

- **Built-in**: Uses system malloc/free by default
- **Jemalloc**: High-performance allocator when enabled

## Usage

The record accessor functionality is automatically built when the record_accessor component is enabled:

```bash
# Enable record accessor during CMake configuration
cmake -DFLB_RECORD_ACCESSOR=ON .

# The record accessor parser will be built as a static library
# and linked into the main Fluent Bit binary
```

Developers can extend the record accessor functionality by modifying the lexer (`ra.l`) and parser (`ra.y`) specification files, which will be automatically regenerated during the build process.