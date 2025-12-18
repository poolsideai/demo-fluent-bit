# CMakeLists.txt

## Overview

This CMakeLists.txt file configures the build system for Fluent Bit's proxy components. It conditionally includes the Go proxy implementation based on the `FLB_PROXY_GO` build option. This file serves as the entry point for building proxy-related functionality in Fluent Bit.

## Build Configuration

### Conditional Compilation

The file uses conditional compilation to include proxy components only when the `FLB_PROXY_GO` option is enabled:

```cmake
if(FLB_PROXY_GO)
  add_subdirectory(go)
endif()
```

### Subdirectory Inclusion

When the Go proxy is enabled, it adds the `go` subdirectory which contains:
- Go proxy implementation files
- Go-specific build configurations
- Go module dependencies

## Dependencies

- **CMake**: Build system configuration
- **FLB_PROXY_GO**: Build option to enable Go proxy functionality
- **Go subdirectory**: Contains Go proxy implementation

## Implementation Details

### Build Option Control

The proxy functionality is controlled by the `FLB_PROXY_GO` CMake option:

- **Enabled**: Includes Go proxy implementation and builds proxy components
- **Disabled**: Excludes proxy components from the build

### Modular Structure

Follows Fluent Bit's modular architecture:

- **Separate Subdirectories**: Each proxy implementation resides in its own subdirectory
- **Conditional Building**: Only builds components that are enabled
- **Clean Separation**: Proxy code is isolated from core Fluent Bit functionality

### Integration Points

The proxy system integrates with Fluent Bit through:

- **Plugin Interface**: Proxies implement Fluent Bit's plugin API
- **Build System**: Uses CMake to manage dependencies and compilation
- **Runtime Loading**: Proxies can be loaded dynamically at runtime

## Usage

To enable Go proxy functionality:

```bash
# Enable Go proxy during CMake configuration
cmake -DFLB_PROXY_GO=ON .

# Or in a CMakeLists.txt file
set(FLB_PROXY_GO ON)
```

The file is part of Fluent Bit's modular build system, allowing users to selectively include proxy functionality based on their requirements. When enabled, it builds the Go proxy components which provide additional language support for custom plugins.