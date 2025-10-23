# src/aws/compression/CMakeLists.txt Documentation

## Overview

This CMakeLists.txt file is the build configuration for AWS compression functionality in Fluent Bit. It defines the interface library for AWS compression and conditionally includes Arrow compression support when enabled.

## Key Components

### Library Target
Creates an interface library target `flb-aws-compress` that serves as a container for AWS compression functionality.

### Conditional Compilation
The file supports conditional compilation for Arrow compression:
- When `FLB_ARROW` is enabled, it includes the `arrow` subdirectory
- Links the `flb-aws-arrow` library when Arrow compression is enabled

### Subdirectories
The file conditionally includes the `arrow` subdirectory which contains Arrow compression implementation.

## Implementation Details

### Interface Library
Uses an INTERFACE library to provide a clean abstraction layer for AWS compression functionality without creating a separate static/shared library.

### Conditional Subdirectory Inclusion
The `EXCLUDE_FROM_ALL` flag prevents the Arrow subdirectory from being built by default, only including it when explicitly requested.

## Usage Examples

To build with AWS compression support:
```bash
cmake -DFLB_AWS=ON .
make
```

To build with Arrow compression support:
```bash
cmake -DFLB_AWS=ON -DFLB_ARROW=ON .
make
```