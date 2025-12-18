# src/http_server/CMakeLists.txt Documentation

## Overview

The `src/http_server/CMakeLists.txt` file is the CMake build configuration for the Fluent Bit HTTP server component. This file defines how to build the HTTP server library and its dependencies, including the core HTTP server modules and API version subdirectories.

The HTTP server component provides a web-based interface for monitoring and managing Fluent Bit, exposing metrics, configuration information, and control endpoints.

## Key Features

- Build configuration for HTTP server library
- Dependency management for required libraries
- Directory structure for API versions
- Integration with Fluent Bit's build system
- Conditional compilation based on feature flags

## Build Configuration

### Prerequisites

The HTTP server requires the following to be enabled:

```cmake
if(NOT FLB_METRICS)
  message(FATAL_ERROR "FLB_HTTP_SERVER requires FLB_METRICS=On.")
endif()
```

### Source Files

The core HTTP server source files included in the build:

```cmake
# Core Source
set(src
  flb_hs.c
  flb_hs_endpoints.c
  flb_hs_utils.c
  flb_http_server.c
  flb_http_server_http1.c
  flb_http_server_http2.c
  )
```

### API Versions

Subdirectories for different API versions:

```cmake
# api/v1
add_subdirectory(api/v1)

# api/v2
add_subdirectory(api/v2)
```

### Library Definition

Creates the static library for the HTTP server:

```cmake
include_directories(${MONKEY_INCLUDE_DIR})
add_library(flb-http-server STATIC ${src})
target_link_libraries(flb-http-server monkey-core-static api-v1 api-v2)
```

## Dependencies

### Required Libraries

- **Monkey Core**: HTTP server framework (`monkey-core-static`)
- **API v1 Library**: Version 1 API endpoints (`api-v1`)
- **API v2 Library**: Version 2 API endpoints (`api-v2`)

### Include Directories

- **Monkey Include Directory**: Headers for the Monkey HTTP server framework

## Conditional Compilation

The build configuration respects Fluent Bit's feature flags:

- **Metrics Support**: Required for HTTP server functionality
- **API Versions**: Separate builds for different API versions
- **Platform Support**: Cross-platform compilation support

## Integration with Fluent Bit

This CMake file integrates with the broader Fluent Bit build system:

1. **Feature Detection**: Checks for required features before building
2. **Library Linking**: Links against Fluent Bit core libraries
3. **API Structure**: Organizes API versions in separate directories
4. **Dependency Management**: Manages complex dependency relationships

## Usage in Build System

The HTTP server CMake configuration is typically included in the main Fluent Bit build:

```cmake
# In main CMakeLists.txt
if(FLB_HTTP_SERVER)
  add_subdirectory(src/http_server)
endif()
```

## Environment Variables

The build process respects these environment variables:

- **MONKEY_INCLUDE_DIR**: Path to Monkey HTTP server headers
- **FLB_METRICS**: Controls whether metrics support is enabled
- **FLB_HTTP_SERVER**: Controls whether HTTP server is built

## Build Artifacts

The CMake configuration produces these artifacts:

- **flb-http-server**: Static library containing HTTP server functionality
- **api-v1**: Static library for version 1 API endpoints
- **api-v2**: Static library for version 2 API endpoints

## Error Handling

The build configuration includes proper error handling:

- **Prerequisite Checks**: Validates required features before building
- **Dependency Validation**: Ensures required libraries are available
- **Clear Error Messages**: Provides helpful error messages for build failures

## Cross-Platform Support

The CMake configuration supports multiple platforms:

- **Linux**: Primary development platform
- **Windows**: MSVC and MinGW support
- **macOS**: Clang-based compilation
- **FreeBSD**: BSD variant support

## Development Workflow

Developers working with the HTTP server component should:

1. **Modify Source**: Update C source files in the http_server directory
2. **Update CMake**: Adjust build configuration as needed
3. **Test Build**: Verify the build works with `cmake` and `make`
4. **Run Tests**: Execute unit tests for the HTTP server functionality
5. **Documentation**: Update documentation when adding new features

## Example Build Commands

```bash
# Configure the build
cmake -DFLB_HTTP_SERVER=On -DFLB_METRICS=On ..

# Build the HTTP server component
make flb-http-server

# Build all components
make
```

## Debugging Build Issues

Common build issues and solutions:

1. **Missing Dependencies**: Ensure Monkey HTTP server is available
2. **Feature Flags**: Check that required features are enabled
3. **Include Paths**: Verify MONKEY_INCLUDE_DIR is correctly set
4. **Library Linking**: Confirm all required libraries are found

## Version Compatibility

The HTTP server build configuration is compatible with:

- **Fluent Bit 1.x**: Full compatibility
- **Fluent Bit 2.x**: Full compatibility
- **Future Versions**: Designed for forward compatibility

## Customization

Developers can customize the build by:

1. **Adding Source Files**: Include new C source files in the `src` list
2. **Adding Dependencies**: Link additional libraries in `target_link_libraries`
3. **Conditional Compilation**: Use CMake conditions for optional features
4. **API Extensions**: Add new API versions in separate subdirectories