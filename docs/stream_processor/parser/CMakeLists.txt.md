# CMakeLists.txt

## Overview

This CMake configuration file defines the build rules for the Stream Processor parser component in Fluent Bit. It handles the compilation of lexical analyzer and parser generator files using Flex and Bison.

## Key Components

### Flex Target Configuration

Configures the lexical analyzer generation:
```cmake
flex_target(lexer sql.l "${CMAKE_CURRENT_BINARY_DIR}/sql_lex.c"
            DEFINES_FILE "${CMAKE_CURRENT_BINARY_DIR}/sql_lex.h")
```

### Bison Target Configuration

Configures the parser generator:
```cmake
bison_target(parser sql.y "${CMAKE_CURRENT_BINARY_DIR}/sql_parser.c")
```

### Source Files

Specifies the source files to be compiled:
```cmake
set(sources
  flb_sp_parser.c
)
```

### Conditional Compilation

Handles platform-specific compilation flags:
```cmake
if(CMAKE_SYSTEM_NAME MATCHES "Windows")
  FLB_DEFINITION(YY_NO_UNISTD_H)
  message(STATUS "Specifying YY_NO_UNISTD_H")
endif()
```

### Include Directories

Sets up include paths for compilation:
```cmake
include_directories(
  ${CMAKE_CURRENT_SOURCE_DIR}
  ${CMAKE_CURRENT_BINARY_DIR}
)
```

### Library Definition

Defines the static library target:
```cmake
add_library(flb-sp-parser STATIC
    ${sources}
    "${CMAKE_CURRENT_BINARY_DIR}/sql_lex.c"
    "${CMAKE_CURRENT_BINARY_DIR}/sql_parser.c"
)
```

### Dependencies

Establishes build dependencies:
```cmake
add_flex_bison_dependency(lexer parser)
add_dependencies(flb-sp-parser onigmo-static)
```

## Important Variables and Constants

- `YY_NO_UNISTD_H`: Preprocessor definition for Windows compatibility
- `JEMALLOC_LIBRARIES`: Optional jemalloc library linking
- `FLB_JEMALLOC`: Conditional compilation flag for jemalloc support

## Dependencies

This build configuration depends on:
- **Flex**: Lexical analyzer generator
- **Bison**: Parser generator
- **Onigmo**: Regular expression library (onigmo-static)
- **Jemalloc**: Optional memory allocator (conditional)

## Implementation Details

### Build Process Flow

```
SQL Grammar (sql.y)
    ↓
Bison Parser Generator
    ↓
Parser Source (sql_parser.c)
    ↓
Lexical Rules (sql.l)
    ↓
Flex Lexer Generator
    ↓
Lexer Source (sql_lex.c)
    ↓
C Compilation
    ↓
Static Library (flb-sp-parser)
```

### Cross-platform Considerations

The configuration handles platform differences:
- **Windows**: Defines `YY_NO_UNISTD_H` to avoid unistd.h dependencies
- **Unix-like**: Uses standard POSIX headers
- **Memory Allocators**: Optional jemalloc integration for improved performance

### Source Organization

The build system organizes sources as:
- **Generated Sources**: `sql_lex.c`, `sql_parser.c` (created during build)
- **Static Sources**: `flb_sp_parser.c` (included in repository)
- **Header Files**: `sql_lex.h` (generated during build)

### Dependency Management

The configuration establishes proper build order:
1. Flex generates lexer source
2. Bison generates parser source
3. Lexer depends on parser (Flex/Bison dependency)
4. Library depends on Onigmo for regex support
5. Optional jemalloc dependency for memory allocation

## Usage Examples

The parser library is used internally by the Stream Processor:
```c
// In stream processor initialization
struct flb_sp_cmd *cmd = flb_sp_cmd_create("SELECT key FROM STREAM:input");
```

The CMake configuration ensures that the parser is built correctly with all necessary dependencies for the Stream Processor to function properly.