# CMakeLists.txt Documentation (simdutf)

## Overview

This CMakeLists.txt file defines the build configuration for the SIMDUTF connector library in Fluent Bit. It specifies how to compile and link the SIMDUTF library integration, which provides optimized Unicode processing capabilities.

## Build Configuration

### Include Directories
- `include_directories (../../${FLB_PATH_LIB_SIMDUTF}/src/simdutf)` - Adds the SIMDUTF source directory to the include path

### Source Files
- `flb_simdutf_connector.cpp` - The main connector implementation file

### Library Definition
- `add_library(flb-simdutf-connector-static STATIC ${src})` - Creates a static library from the specified source files

### Library Linking
- `target_link_libraries(flb-simdutf-connector-static simdutf-static)` - Links against the static SIMDUTF library
- Conditional linking with jemalloc if FLB_JEMALLOC is enabled

## Dependencies

- `${FLB_PATH_LIB_SIMDUTF}` - Path to the SIMDUTF library source
- `simdutf-static` - The static SIMDUTF library target
- `JEMALLOC_LIBRARIES` - Jemalloc libraries (conditional)

## Relationships

This build configuration integrates with:
- The main Fluent Bit CMake build system
- The external SIMDUTF library
- Other Fluent Bit components that require Unicode processing

## Implementation Details

The configuration features:
1. Static library compilation for better performance and reduced dependencies
2. Conditional linking with jemalloc for memory optimization
3. Proper include path setup for SIMDUTF headers
4. Integration with Fluent Bit's library management system

## Usage Context

This CMakeLists.txt is used during the Fluent Bit build process to:
1. Compile the SIMDUTF connector library
2. Link it with the main Fluent Bit binary
3. Enable optimized Unicode processing capabilities
4. Conditionally include jemalloc support if configured

The resulting library provides efficient UTF-8 and UTF-16 processing functions that can be used throughout Fluent Bit for handling internationalized text data.