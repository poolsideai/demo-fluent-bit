# http_server/api/v1/CMakeLists.txt

## Overview

The `http_server/api/v1/CMakeLists.txt` file is a CMake build configuration file for the version 1 REST API endpoints of Fluent Bit's HTTP server. This file defines how to build the v1 API library, including its source files, conditional compilation based on features, and linking requirements.

## Key Components

### Source Files

```cmake
set(src
  uptime.c
  metrics.c
  storage.c
  plugins.c
  register.c
  health.c
  )
```

Defines the core source files for the v1 REST API endpoints:

- `uptime.c`: Uptime monitoring endpoint implementation
- `metrics.c`: Metrics collection and reporting endpoint
- `storage.c`: Storage status and information endpoint
- `plugins.c`: Plugin information and management endpoint
- `register.c`: Registration and authentication endpoint
- `health.c`: Health check endpoint implementation

### Conditional Compilation

```cmake
if(FLB_CHUNK_TRACE)
  set(src
    ${src}
    trace.c
  )
endif()
```

Conditionally includes the trace endpoint source file when chunk tracing is enabled in the build.

### Include Directories

```cmake
include_directories(${MONKEY_INCLUDE_DIR})
```

Adds the Monkey HTTP server library include directory to the build path.

### Library Definition

```cmake
add_library(api-v1 STATIC ${src})
```

Creates a static library named `api-v1` from the specified source files.

### Linking Dependencies

```cmake
target_link_libraries(api-v1 monkey-core-static fluent-bit-static)
```

Links the v1 API library with its dependencies:

- `monkey-core-static`: Static version of the Monkey HTTP server core
- `fluent-bit-static`: Static version of the Fluent Bit core library

## Dependencies

This CMake file depends on:

1. **Monkey HTTP Server**: Provides the underlying HTTP server functionality
2. **Fluent Bit Core**: Required for accessing Fluent Bit internals
3. **Chunk Tracing**: Optional dependency for trace endpoint

## Build Process

The build process follows these steps:

1. **Source Collection**: Gathers all required source files for v1 API endpoints
2. **Conditional Inclusion**: Adds trace endpoint if chunk tracing is enabled
3. **Include Setup**: Adds necessary header search paths
4. **Library Creation**: Builds the static API library
5. **Dependency Linking**: Links with required libraries

## Configuration Variables

### Optional Variables

- `FLB_CHUNK_TRACE`: When set to `On`, includes the trace endpoint source file
- `MONKEY_INCLUDE_DIR`: Path to Monkey HTTP server headers

### Generated Targets

- `api-v1`: Static library containing version 1 REST API endpoints

## API Endpoints Provided

The v1 API library implements the following REST endpoints:

### Health Endpoint

- **Path**: `/api/v1/health`
- **Method**: GET
- **Purpose**: Health check for the Fluent Bit instance

### Metrics Endpoint

- **Path**: `/api/v1/metrics`
- **Method**: GET
- **Purpose**: Retrieve metrics data from Fluent Bit

### Storage Endpoint

- **Path**: `/api/v1/storage`
- **Method**: GET
- **Purpose**: Information about storage subsystem

### Plugins Endpoint

- **Path**: `/api/v1/plugins`
- **Method**: GET
- **Purpose**: List and information about loaded plugins

### Register Endpoint

- **Path**: `/api/v1/register`
- **Method**: POST
- **Purpose**: Registration and authentication for API access

### Uptime Endpoint

- **Path**: `/api/v1/uptime`
- **Method**: GET
- **Purpose**: System uptime information

### Trace Endpoint (Conditional)

- **Path**: `/api/v1/trace`
- **Method**: Various
- **Purpose**: Chunk tracing for debugging data flow
- **Condition**: Only included when `FLB_CHUNK_TRACE=On`

## Integration with Fluent Bit HTTP Server

The v1 API library integrates with the Fluent Bit HTTP server as follows:

1. **Static Linking**: Compiled as a static library for embedding
2. **Monkey Integration**: Leverages the Monkey HTTP server for core functionality
3. **Fluent Bit Core Access**: Links with Fluent Bit core for internal data access
4. **Conditional Features**: Supports optional features through conditional compilation

## Usage in Fluent Bit Build

This CMake file is typically included in the main Fluent Bit build process through:

```cmake
add_subdirectory(api/v1)
```

Which is called from the parent `http_server/CMakeLists.txt` file.

## Example Build Configuration

To build Fluent Bit with v1 API support:

```bash
cmake -DFLB_HTTP_SERVER=On -DFLB_METRICS=On .
make
```

To include chunk tracing:

```bash
cmake -DFLB_HTTP_SERVER=On -DFLB_METRICS=On -DFLB_CHUNK_TRACE=On .
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

### Conditional Compilation

If the trace endpoint is missing:

1. Verify `FLB_CHUNK_TRACE=On` is set
2. Check that `trace.c` source file exists
3. Confirm conditional compilation logic is working

### API Endpoint Availability

Endpoints are only available when:

1. HTTP server is enabled (`FLB_HTTP_SERVER=On`)
2. Metrics support is enabled (`FLB_METRICS=On`)
3. The HTTP server is running and accessible