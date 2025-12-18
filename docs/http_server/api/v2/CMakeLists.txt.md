# http_server/api/v2/CMakeLists.txt

## Overview

The `http_server/api/v2/CMakeLists.txt` file is a CMake build configuration file for the version 2 REST API endpoints of Fluent Bit's HTTP server. This file defines how to build the v2 API library, including its source files, and linking requirements.

## Key Components

### Source Files

```cmake
set(src
  metrics.c
  reload.c
  register.c
  )
```

Defines the core source files for the v2 REST API endpoints:

- `metrics.c`: Enhanced metrics collection and reporting endpoint
- `reload.c`: Configuration reload endpoint implementation
- `register.c`: Registration and authentication endpoint

### Include Directories

```cmake
include_directories(${MONKEY_INCLUDE_DIR})
```

Adds the Monkey HTTP server library include directory to the build path.

### Library Definition

```cmake
add_library(api-v2 STATIC ${src})
```

Creates a static library named `api-v2` from the specified source files.

### Linking Dependencies

```cmake
target_link_libraries(api-v2 monkey-core-static fluent-bit-static)
```

Links the v2 API library with its dependencies:

- `monkey-core-static`: Static version of the Monkey HTTP server core
- `fluent-bit-static`: Static version of the Fluent Bit core library

## Dependencies

This CMake file depends on:

1. **Monkey HTTP Server**: Provides the underlying HTTP server functionality
2. **Fluent Bit Core**: Required for accessing Fluent Bit internals

## Build Process

The build process follows these steps:

1. **Source Collection**: Gathers all required source files for v2 API endpoints
2. **Include Setup**: Adds necessary header search paths
3. **Library Creation**: Builds the static API library
4. **Dependency Linking**: Links with required libraries

## Configuration Variables

### Required Variables

- `MONKEY_INCLUDE_DIR`: Path to Monkey HTTP server headers

### Generated Targets

- `api-v2`: Static library containing version 2 REST API endpoints

## API Endpoints Provided

The v2 API library implements the following REST endpoints:

### Metrics Endpoint

- **Path**: `/api/v2/metrics`
- **Method**: GET
- **Purpose**: Enhanced metrics collection and reporting with improved formatting

### Reload Endpoint

- **Path**: `/api/v2/reload`
- **Method**: POST
- **Purpose**: Trigger configuration reload without restarting Fluent Bit

### Register Endpoint

- **Path**: `/api/v2/register`
- **Method**: POST
- **Purpose**: Registration and authentication for API access

## Integration with Fluent Bit HTTP Server

The v2 API library integrates with the Fluent Bit HTTP server as follows:

1. **Static Linking**: Compiled as a static library for embedding
2. **Monkey Integration**: Leverages the Monkey HTTP server for core functionality
3. **Fluent Bit Core Access**: Links with Fluent Bit core for internal data access
4. **Version Coexistence**: Can coexist with v1 API alongside the main HTTP server

## Usage in Fluent Bit Build

This CMake file is typically included in the main Fluent Bit build process through:

```cmake
add_subdirectory(api/v2)
```

Which is called from the parent `http_server/CMakeLists.txt` file.

## Example Build Configuration

To build Fluent Bit with v2 API support:

```bash
cmake -DFLB_HTTP_SERVER=On -DFLB_METRICS=On .
make
```

## Troubleshooting

### Missing Dependencies

If the build fails, ensure:

1. Monkey HTTP server development files are installed
2. Fluent Bit core library is available
3. Required header paths are correctly configured

### Linking Issues

Common linking problems may occur if:

1. Required libraries are not found
2. Fluent Bit core library is not built first
3. Monkey core library is not available

### API Endpoint Availability

Endpoints are only available when:

1. HTTP server is enabled (`FLB_HTTP_SERVER=On`)
2. Metrics support is enabled (`FLB_METRICS=On`)
3. The HTTP server is running and accessible

### Version Differences

Note that v2 API endpoints may have different:

1. Response formats compared to v1
2. Authentication mechanisms
3. Feature sets and capabilities
4. Deprecation status of certain endpoints