# CMakeLists.txt

## Overview

This CMakeLists.txt file configures the build system for Fluent Bit's Go proxy implementation. It defines the static library target for the Go proxy plugin and manages its dependencies. This file is included when the `FLB_PROXY_GO` option is enabled in the main proxy CMakeLists.txt.

## Build Configuration

### Source Files

Defines the source files for the Go proxy plugin:

```cmake
set(src
  go.c)
```

### Library Target

Creates a static library target for the Go proxy:

```cmake
add_library(flb-plugin-proxy-go STATIC ${src})
```

### Dependency Management

Conditionally links required libraries based on build options:

```cmake
if(FLB_JEMALLOC)
  target_link_libraries(flb-plugin-proxy-go ${JEMALLOC_LIBRARIES})
endif()
if(FLB_REGEX)
  target_link_libraries(flb-plugin-proxy-go onigmo-static)
endif()
```

## Dependencies

- **CMake**: Build system configuration
- **FLB_JEMALLOC**: Build option for jemalloc memory allocator
- **FLB_REGEX**: Build option for regex support
- **JEMALLOC_LIBRARIES**: Jemalloc library dependencies
- **onigmo-static**: Static regex library
- **go.c**: Go proxy implementation source file

## Implementation Details

### Conditional Linking

Manages optional dependencies:

- **Jemalloc**: Links jemalloc libraries when `FLB_JEMALLOC` is enabled
- **Regex**: Links onigmo regex library when `FLB_REGEX` is enabled

### Static Library

Creates a static library (`flb-plugin-proxy-go`) rather than a shared library, which:

- Integrates directly into the main Fluent Bit binary
- Provides better performance by avoiding dynamic loading overhead
- Simplifies deployment by not requiring separate plugin files

### Source Management

Uses CMake's `set()` command to define source files, making it easy to:

- Add new source files
- Maintain clean separation of concerns
- Enable/disable components through build options

## Integration with Fluent Bit

### Plugin Architecture

The Go proxy integrates with Fluent Bit's plugin system:

- **Static Linking**: Becomes part of the main binary
- **API Compliance**: Implements Fluent Bit's plugin interface
- **Language Bridge**: Provides Go language support for custom plugins

### Memory Management

Supports optional memory allocators:

- **Standard Allocator**: Default system memory allocation
- **Jemalloc**: High-performance memory allocator when enabled

### Text Processing

Supports regex operations when the regex option is enabled:

- **Pattern Matching**: Advanced text processing capabilities
- **Onigmo Library**: Robust regex engine support

## Usage

The Go proxy is automatically built when the `FLB_PROXY_GO` option is enabled:

```bash
# Enable Go proxy during CMake configuration
cmake -DFLB_PROXY_GO=ON .

# The Go proxy will be built as a static library
# and linked into the main Fluent Bit binary
```

Developers can extend the Go proxy by adding additional source files to the `src` variable and updating the library target accordingly. The conditional linking ensures that only required dependencies are included in the final build.