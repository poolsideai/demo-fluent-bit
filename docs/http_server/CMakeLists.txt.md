# http_server/CMakeLists.txt

## Overview

The `http_server/CMakeLists.txt` file is a CMake build configuration file for the HTTP server component of Fluent Bit. This file defines how to build the HTTP server module, including its source files, dependencies, and linking requirements.

## Key Components

### Build Requirements

```cmake
if(NOT FLB_METRICS)
  message(FATAL_ERROR "FLB_HTTP_SERVER requires FLB_METRICS=On.")
endif()
```

Ensures that the HTTP server component can only be built when metrics support is enabled in the Fluent Bit build.

### Source Files

```cmake
set(src
  flb_hs.c
  flb_hs_endpoints.c
  flb_hs_utils.c
  flb_http_server.c
  flb_http_server_http1.c
  flb_http_server_http2.c
  )
```

Defines the core source files for the HTTP server module:

- `flb_hs.c`: Main HTTP server implementation
- `flb_hs_endpoints.c`: HTTP endpoint handlers
- `flb_hs_utils.c`: Utility functions for HTTP server
- `flb_http_server.c`: Core HTTP server functionality
- `flb_http_server_http1.c`: HTTP/1.1 specific implementation
- `flb_http_server_http2.c`: HTTP/2 specific implementation

### Subdirectories

```cmake
add_subdirectory(api/v1)
add_subdirectory(api/v2)
```

Includes the API version directories for building the HTTP REST API endpoints.

### Include Directories

```cmake
include_directories(${MONKEY_INCLUDE_DIR})
```

Adds the Monkey HTTP server library include directory to the build path.

### Library Definition

```cmake
add_library(flb-http-server STATIC ${src})
```

Creates a static library named `flb-http-server` from the specified source files.

### Linking Dependencies

```cmake
target_link_libraries(flb-http-server monkey-core-static api-v1 api-v2)
```

Links the HTTP server library with its dependencies:

- `monkey-core-static`: Static version of the Monkey HTTP server core
- `api-v1`: Version 1 of the HTTP REST API
- `api-v2`: Version 2 of the HTTP REST API

## Dependencies

This CMake file depends on:

1. **Monkey HTTP Server**: Provides the underlying HTTP server functionality
2. **Fluent Bit Metrics**: Required for the HTTP server to function
3. **API Versions**: Both v1 and v2 API directories must be present

## Build Process

The build process follows these steps:

1. **Validation**: Checks that metrics support is enabled
2. **Source Collection**: Gathers all required source files
3. **Subdirectory Inclusion**: Processes API version directories
4. **Include Setup**: Adds necessary header search paths
5. **Library Creation**: Builds the static library
6. **Dependency Linking**: Links with required libraries

## Configuration Variables

### Required Variables

- `FLB_METRICS`: Must be set to `On` for HTTP server to build
- `MONKEY_INCLUDE_DIR`: Path to Monkey HTTP server headers

### Generated Targets

- `flb-http-server`: Static library containing HTTP server functionality
- `api-v1`: Library for version 1 REST API endpoints
- `api-v2`: Library for version 2 REST API endpoints

## Integration with Fluent Bit

The HTTP server component integrates with Fluent Bit as follows:

1. **Conditional Build**: Only built when metrics are enabled
2. **Static Linking**: Compiled as a static library for embedding
3. **API Versioning**: Supports multiple API versions simultaneously
4. **Monkey Integration**: Leverages the Monkey HTTP server for core functionality

## Usage in Fluent Bit Build

This CMake file is typically included in the main Fluent Bit build process through:

```cmake
if(FLB_HTTP_SERVER)
  add_subdirectory(src/http_server)
endif()
```

## Example Build Configuration

To build Fluent Bit with HTTP server support:

```bash
cmake -DFLB_HTTP_SERVER=On -DFLB_METRICS=On .
make
```

## Troubleshooting

### Missing Dependencies

If the build fails, ensure:

1. `FLB_METRICS=On` is specified
2. Monkey HTTP server development files are installed
3. API version directories exist and are properly configured

### Linking Issues

Common linking problems may occur if:

1. Required libraries are not found
2. API version subdirectories are missing
3. Monkey core library is not available

### Version Compatibility

Ensure that the Monkey HTTP server version is compatible with the Fluent Bit version being built.