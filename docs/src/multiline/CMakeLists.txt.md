# CMakeLists.txt Documentation

## Overview

This CMakeLists.txt file defines the build configuration for the multiline parsing module in Fluent Bit. It specifies which source files should be compiled as part of the multiline functionality and makes them available to the parent build system.

## Purpose

The file serves as the build configuration for the multiline parsing subsystem, listing all the source files that implement various multiline parsing modes and core functionality. It ensures that all necessary components are compiled and linked together properly.

## Key Components

### Source Files Included

1. **Built-in Parsers**:
   - `flb_ml_parser_cri.c` - Container Runtime Interface (CRI) parser for Kubernetes container logs
   - `flb_ml_parser_docker.c` - Docker container logs parser
   - `flb_ml_parser_python.c` - Python stack trace parser
   - `flb_ml_parser_java.c` - Java stack trace parser
   - `flb_ml_parser_go.c` - Go stack trace parser
   - `flb_ml_parser_ruby.c` - Ruby stack trace parser

2. **Core Implementation**:
   - `flb_ml_stream.c` - Stream management functionality for handling log streams
   - `flb_ml_parser.c` - Parser creation and management utilities
   - `flb_ml_group.c` - Group management for streams to handle different log categories
   - `flb_ml_rule.c` - Rule processing for regex-based multiline parsing
   - `flb_ml.c` - Main multiline processing engine

## Build Configuration Details

The file uses CMake syntax to define a variable `src_multiline` that contains all the source files needed for the multiline module. The `PARENT_SCOPE` directive ensures that this variable is accessible to parent CMakeLists.txt files, allowing the main build system to include all multiline source files in the compilation process.

### Variable Definition
```cmake
set(src_multiline
  # built-in parsers
  multiline/flb_ml_parser_cri.c
  multiline/flb_ml_parser_docker.c
  multiline/flb_ml_parser_python.c
  multiline/flb_ml_parser_java.c
  multiline/flb_ml_parser_go.c
  multiline/flb_ml_parser_ruby.c
  # core
  multiline/flb_ml_stream.c
  multiline/flb_ml_parser.c
  multiline/flb_ml_group.c
  multiline/flb_ml_rule.c
  multiline/flb_ml.c PARENT_SCOPE
  )
```

## Dependencies

This module depends on:
- Core Fluent Bit libraries for basic functionality
- MessagePack for serialization of log data
- Regular expression library for pattern matching in multiline rules
- Time handling utilities for timestamp management
- Memory management utilities for buffer handling

## Integration with Build System

The `PARENT_SCOPE` directive is crucial as it allows the multiline source files to be incorporated into the main Fluent Bit compilation process. Without this directive, the multiline functionality would not be compiled into the final binary.

## Maintenance Considerations

When adding new multiline parsers or core functionality:
1. Add the new source file to the `src_multiline` variable
2. Ensure proper ordering (parsers first, then core components)
3. Verify that the file path is correct relative to the CMakeLists.txt location
4. Test the build to ensure all files compile correctly

## Usage

This file is automatically included in the main Fluent Bit build process. No special configuration is required for users of Fluent Bit. The build system will automatically compile all multiline components when building Fluent Bit with multiline support enabled.