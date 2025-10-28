# src/aws/compression/CMakeLists.txt Documentation

## Overview

This CMakeLists.txt file is the build configuration for AWS compression components in Fluent Bit. It defines the compression library interface and conditionally includes Arrow-based compression support.

## Key Components

### Build Target

The file creates an interface library target `flb-aws-compress` that serves as a placeholder for AWS compression functionality.

### Conditional Arrow Support

The CMakeLists.txt includes conditional compilation for Apache Arrow-based compression:

- When `FLB_ARROW` is enabled:
  - Adds the `arrow` subdirectory as a build component
  - Links the `flb-aws-arrow` target to the `flb-aws-compress` interface
  - Uses `EXCLUDE_FROM_ALL` to prevent building Arrow components by default

### Dependencies

The compression library depends on:

- Arrow compression components (when `FLB_ARROW` is enabled)

## Usage

This CMakeLists.txt is included from the main AWS CMakeLists.txt (`src/aws/CMakeLists.txt`). It provides a flexible compression interface that can be extended with different compression algorithms, currently supporting Apache Arrow compression when enabled.