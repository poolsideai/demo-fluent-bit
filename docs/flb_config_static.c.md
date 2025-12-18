# flb_config_static.c

## Overview

The `flb_config_static.c` file implements support for static configuration files in Fluent Bit. This feature allows embedding configuration files directly into the Fluent Bit binary at compile time, eliminating the need for external configuration files in certain deployment scenarios.

Static configuration support is particularly useful for:
- Containerized deployments where configuration should be baked into the image
- Embedded systems with limited filesystem access
- Security-sensitive environments where external configuration files are undesirable
- Simplified deployment models where configuration is part of the application binary

This functionality works by generating a header file during the build process that contains the configuration file contents as static arrays. The `flb_config_static_open` function provides an interface to access these embedded configurations as if they were regular files.

## Key Functions

### `flb_config_static_open`
Opens a statically embedded configuration file:
- Searches through the static configuration array for the requested file name
- Creates a configuration format context from the embedded content
- Returns a `struct flb_cf` that can be used with the standard configuration API
- Returns NULL if the requested file is not found in the static array

## Data Structures

### `flb_config_files`
Static array containing embedded configuration files:
- First column: File name (string)
- Second column: File content (string)
- Generated during build process from CMake configuration
- Size determined by `flb_config_files_size`

### `flb_config_files_size`
Integer constant representing the number of embedded configuration files.

## Dependencies

This module depends on:
- `flb_config_format`: Configuration format parsing
- `flb_static_conf`: Build-time generated static configuration header
- CMake build system for generating static configuration arrays

## Implementation Details

The static configuration system works as follows:

1. **Build-time Generation**: During compilation, CMake scans specified directories for configuration files and generates a static header file (`flb_static_conf.h`) containing the file contents as character arrays.

2. **Runtime Access**: The `flb_config_static_open` function provides an interface to access these embedded configurations by name.

3. **Configuration Format Integration**: Embedded configurations are parsed using the same configuration format API as regular files.

4. **Memory Management**: Configuration content is stored in static memory, eliminating dynamic allocation for embedded configurations.

## Usage Example

```c
// In a plugin or configuration loader
struct flb_cf *cf;

// Open a statically embedded configuration file
cf = flb_config_static_open("embedded_config.conf");
if (!cf) {
    // Configuration file not found in static array
    return -1;
}

// Use the configuration context as normal
// ...

// Cleanup (same as regular configuration files)
flb_cf_destroy(cf);
```

## Build System Integration

To enable static configuration embedding:

1. Specify configuration directories in CMake:
   ```cmake
   set(FLB_STATIC_CONF_DIR "${CMAKE_SOURCE_DIR}/conf/embedded")
   ```

2. During build, CMake generates `flb_static_conf.h` containing:
   ```c
   static unsigned char *flb_config_files[N][2] = {
       {"config1.conf", "[SERVICE]\nFlush 1\n"},
       {"config2.conf", "[INPUT]\nName cpu\n"},
       // ...
   };
   static unsigned int flb_config_files_size = N;
   ```

3. At runtime, `flb_config_static_open` searches this array for requested files.

## Limitations

- Static configurations cannot be modified at runtime
- File size is limited by available static memory
- All embedded configurations increase binary size
- Updates require recompilation

## Benefits

- Eliminates external file dependencies
- Improves security by preventing configuration tampering
- Simplifies deployment in containerized environments
- Reduces filesystem I/O operations
- Ensures configuration consistency across deployments