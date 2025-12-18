# src/http_server/api/v1/CMakeLists.txt Documentation

## Overview

The `src/http_server/api/v1/CMakeLists.txt` file is the CMake build configuration for the Fluent Bit HTTP server API version 1. This file defines how to build the version 1 API library, including all the endpoint implementations for the v1 API.

The v1 API provides monitoring and management endpoints for Fluent Bit, allowing external systems to query status, metrics, configuration, and perform administrative operations.

## Key Features

- Build configuration for API v1 library
- Source file organization for v1 endpoints
- Conditional compilation for optional features
- Integration with Fluent Bit's build system
- Cross-platform compatibility

## Build Configuration

### Source Files

The core source files for the v1 API endpoints:

```cmake
# api/v1
set(src
  uptime.c
  metrics.c
  storage.c
  plugins.c
  register.c
  health.c
  )
```

### Conditional Compilation

Optional source files based on feature flags:

```cmake
if(FLB_CHUNK_TRACE)
  set(src
    ${src}
    trace.c
  )
endif()
```

### Library Definition

Creates the static library for the v1 API:

```cmake
include_directories(${MONKEY_INCLUDE_DIR})
add_library(api-v1 STATIC ${src})
target_link_libraries(api-v1 monkey-core-static fluent-bit-static)
```

## Dependencies

### Required Libraries

- **Monkey Core**: HTTP server framework (`monkey-core-static`)
- **Fluent Bit Core**: Main Fluent Bit library (`fluent-bit-static`)

### Include Directories

- **Monkey Include Directory**: Headers for the Monkey HTTP server framework

## API Endpoints

The v1 API provides these endpoint implementations:

### Core Endpoints

- **uptime.c**: System uptime information
- **metrics.c**: Performance metrics collection
- **storage.c**: Storage backend information
- **plugins.c**: Plugin status and configuration
- **register.c**: Endpoint registration utilities
- **health.c**: Health check functionality

### Optional Endpoints

- **trace.c**: Chunk tracing (when `FLB_CHUNK_TRACE` is enabled)

## Conditional Compilation Features

The build configuration supports optional features:

- **Chunk Tracing**: Adds tracing endpoints when enabled
- **Platform-Specific**: Adapts to different operating systems
- **Feature Flags**: Respects Fluent Bit's feature configuration

## Integration with Fluent Bit

This CMake file integrates with the broader Fluent Bit build system:

1. **Feature Detection**: Checks for optional features before building
2. **Library Linking**: Links against Fluent Bit core libraries
3. **API Structure**: Organizes endpoints in a logical grouping
4. **Dependency Management**: Manages complex dependency relationships

## Usage in Build System

The v1 API CMake configuration is included by the parent HTTP server build:

```cmake
# In src/http_server/CMakeLists.txt
add_subdirectory(api/v1)
```

## Environment Variables

The build process respects these environment variables:

- **MONKEY_INCLUDE_DIR**: Path to Monkey HTTP server headers
- **FLB_CHUNK_TRACE**: Controls whether chunk tracing endpoints are built

## Build Artifacts

The CMake configuration produces these artifacts:

- **api-v1**: Static library containing v1 API endpoint implementations

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

Developers working with the v1 API component should:

1. **Modify Source**: Update C source files in the api/v1 directory
2. **Update CMake**: Adjust build configuration as needed
3. **Test Build**: Verify the build works with `cmake` and `make`
4. **Run Tests**: Execute unit tests for the v1 API endpoints
5. **Documentation**: Update documentation when adding new endpoints

## Example Build Commands

```bash
# Configure the build with v1 API
cmake -DFLB_HTTP_SERVER=On ..

# Build the v1 API library
make api-v1

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

The v1 API build configuration is compatible with:

- **Fluent Bit 1.x**: Full compatibility
- **Fluent Bit 2.x**: Full compatibility
- **Future Versions**: Designed for forward compatibility

## Customization

Developers can customize the build by:

1. **Adding Source Files**: Include new C source files in the `src` list
2. **Adding Dependencies**: Link additional libraries in `target_link_libraries`
3. **Conditional Compilation**: Use CMake conditions for optional features
4. **API Extensions**: Add new endpoints in separate source files

## API Endpoint Organization

The v1 API endpoints are organized by functionality:

### System Information

- **uptime.c**: System uptime and Fluent Bit start time
- **health.c**: Health check status

### Metrics and Monitoring

- **metrics.c**: Performance metrics and statistics
- **storage.c**: Storage backend status and information

### Plugin Management

- **plugins.c**: Input/output/filter plugin status
- **register.c**: Endpoint registration utilities

### Advanced Features

- **trace.c**: Chunk tracing (optional)

## Security Considerations

The build configuration includes security best practices:

- **Minimal Dependencies**: Only includes necessary libraries
- **Feature Flags**: Allows disabling potentially sensitive endpoints
- **Permission Controls**: Respects system permission models
- **Input Validation**: Ensures proper input handling in endpoints

## Performance Optimization

The build is optimized for performance:

- **Static Linking**: Reduces runtime dependencies
- **Efficient Compilation**: Uses appropriate compiler flags
- **Memory Management**: Follows Fluent Bit's memory patterns
- **Thread Safety**: Ensures thread-safe endpoint implementations