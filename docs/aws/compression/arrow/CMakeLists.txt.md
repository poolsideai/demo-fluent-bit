# src/aws/compression/arrow/CMakeLists.txt Documentation

## Overview

This CMakeLists.txt file is the build configuration for Apache Arrow-based compression components in Fluent Bit's AWS integration. It defines the Arrow compression library and its dependencies.

## Key Components

### Source Files

The file defines the following source file for Arrow compression:

- `compress.c`: Implementation of Arrow compression functionality

### Build Target

The file creates a static library target `flb-aws-arrow` that contains the Arrow compression implementation.

### Dependencies

The Arrow compression library depends on:

- Arrow GLib libraries (`ARROW_GLIB_LDFLAGS`)
- Arrow GLib Parquet libraries (when available)
- Jemalloc memory allocator (when enabled)

### Include Directories

The build configuration includes:

- Arrow GLib include directories (`ARROW_GLIB_INCLUDE_DIRS`)
- Arrow GLib Parquet include directories (when available)

## Conditional Features

The CMakeLists.txt includes conditional compilation for Parquet support:

- When `ARROW_GLIB_PARQUET_FOUND` is true:
  - Adds Parquet include directories
  - Links against Parquet libraries

## Usage

This CMakeLists.txt is included from the AWS compression CMakeLists.txt (`src/aws/compression/CMakeLists.txt`) when the `FLB_ARROW` flag is set. It builds the Arrow compression components that can be used for efficient data compression in AWS integrations.