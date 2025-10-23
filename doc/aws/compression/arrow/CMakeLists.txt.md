# src/aws/compression/arrow/CMakeLists.txt Documentation

## Overview

This CMakeLists.txt file is the build configuration for Arrow compression functionality in Fluent Bit. It defines the static library target for Arrow compression and manages dependencies with the Arrow C++ libraries.

## Key Components

### Source Files
The file defines the core Arrow compression source file:
- `compress.c`: Implementation of Arrow compression functionality

### Library Target
Creates a static library target `flb-aws-arrow` that contains Arrow compression functionality.

### Dependencies
The file manages dependencies for Arrow compression:
- Links to Arrow C++ libraries via `${ARROW_GLIB_LDFLAGS}`
- Includes Arrow headers via `${ARROW_GLIB_INCLUDE_DIRS}`
- Optionally links Parquet libraries when available
- Optionally links jemalloc when enabled

## Implementation Details

### Arrow Library Integration
The CMakeLists.txt integrates with the Arrow C++ libraries:
- Uses `ARROW_GLIB_INCLUDE_DIRS` for header inclusion
- Uses `ARROW_GLIB_LDFLAGS` for library linking
- Conditionally includes Parquet support when `ARROW_GLIB_PARQUET_FOUND` is true

### Memory Management
Optionally links jemalloc for improved memory allocation performance when enabled.

## Usage Examples

To build with Arrow compression support:
```bash
cmake -DFLB_AWS=ON -DFLB_ARROW=ON .
make
```

To build with Arrow and Parquet support:
```bash
cmake -DFLB_AWS=ON -DFLB_ARROW=ON -DARROW_GLIB_PARQUET_FOUND=ON .
make
```