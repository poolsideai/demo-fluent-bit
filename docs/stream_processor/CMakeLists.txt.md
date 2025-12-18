# CMakeLists.txt Documentation (stream_processor)

## Overview

This CMakeLists.txt file defines the build configuration for the Stream Processor component in Fluent Bit. It specifies how to compile and link the stream processor library, which provides SQL-like stream processing capabilities for log data.

## Build Configuration

### Project Definition
- `project(stream-processor C)` - Defines the stream processor project with C language

### Include Directories
- `include_directories(${CMAKE_CURRENT_SOURCE_DIR})` - Adds the current source directory to the include path

### Subdirectories
- `add_subdirectory(parser)` - Includes the parser subdirectory build configuration

### Source Files
The following source files are compiled into the stream processor library:
- `flb_sp.c` - Main stream processor implementation
- `flb_sp_key.c` - Key handling functionality
- `flb_sp_func_time.c` - Time-related functions
- `flb_sp_func_record.c` - Record manipulation functions
- `flb_sp_stream.c` - Stream management functionality
- `flb_sp_snapshot.c` - Snapshot functionality
- `flb_sp_window.c` - Windowing functionality
- `flb_sp_groupby.c` - Group by functionality
- `flb_sp_aggregate_func.c` - Aggregate functions

### Library Definition
- `add_library(flb-sp STATIC ${src})` - Creates a static library from the specified source files

### Library Linking
- `target_link_libraries(flb-sp rbtree)` - Links against the Red-Black tree library
- `target_link_libraries(flb-sp flb-sp-parser)` - Links against the stream processor parser library

## Dependencies

- `rbtree` - Red-Black tree data structure library
- `flb-sp-parser` - Stream processor parser library
- Various Fluent Bit core libraries (implicitly linked)

## Relationships

This build configuration integrates with:
- The main Fluent Bit CMake build system
- The stream processor parser component
- Red-Black tree library for efficient data structures
- Other Fluent Bit components that require stream processing capabilities

## Implementation Details

The configuration features:
1. Static library compilation for better performance and reduced dependencies
2. Proper include path setup for stream processor headers
3. Subdirectory inclusion for modular parser component
4. Integration with Fluent Bit's library management system
5. Dependency linking with required external libraries

## Usage Context

This CMakeLists.txt is used during the Fluent Bit build process to:
1. Compile the stream processor library
2. Link it with the main Fluent Bit binary
3. Enable SQL-like stream processing capabilities
4. Integrate with the parser component for query processing

The resulting library provides powerful stream processing capabilities that allow users to perform complex transformations and aggregations on log data using SQL-like syntax.