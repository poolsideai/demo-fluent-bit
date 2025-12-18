# flb_input_profiles.c

## Overview

This file contains the implementation for handling profile data in Fluent Bit input plugins. It provides functionality for appending profile contexts to input chunks, processing profile data through the processor pipeline, and managing profile-specific operations.

The module serves as the primary interface for input plugins to submit profile data to the Fluent Bit engine. It handles conversion of profile contexts to MessagePack format, integrates with the processor system for data transformation, and manages the storage of profile data in input chunks.

Profile data flow through this module from input collection to chunk storage, with optional processing stages applied to transform the data before storage. This is particularly useful for performance profiling data and other structured profiling information.

## Key Functions

### Profile Data Appending

#### `flb_input_profiles_append()`
Appends profile data (in CProfiles format) to an input chunk. This is the primary function used by input plugins to submit profile records. It processes the profiles through the processor pipeline if active.

#### `flb_input_profiles_append_skip_processor_stages()`
Appends profile data starting from a specific processor stage, allowing selective processing of profile records.

### Internal Processing

#### `input_profiles_append()`
Internal function that handles the core logic of profile appending, including processor integration, buffer management, and chunk storage.

## Important Variables/Constants

### Data Structures
- No specific data structures defined in this file as it primarily provides utility functions

## Dependencies

- `fluent-bit/flb_info.h`: Core Fluent Bit information
- `fluent-bit/flb_input.h`: Input plugin interface
- `fluent-bit/flb_input_chunk.h`: Input chunk management
- `fluent-bit/flb_input_plugin.h`: Plugin interface definitions
- `fluent-bit/flb_input_profiles.h`: Header file defining the interface
- `cprofiles/cprofiles.h`: CProfiles library interface
- `cprofiles/cprof_encode_msgpack.h`: MessagePack encoding for CProfiles

## Implementation Details

1. **Processor Integration**: Seamless integration with the processor pipeline to transform profile data before storage. The processor can modify, filter, or enrich profile records as they pass through.

2. **Buffer Management**: Efficient handling of profile encoding buffers, including automatic buffer allocation and deallocation.

3. **Tag Management**: Proper handling of profile tags, falling back to instance-level tags when record-specific tags are not provided.

4. **Error Handling**: Comprehensive error detection and propagation throughout the profile appending process.

5. **Memory Management**: Proper allocation and deallocation of encoding buffers and profile contexts.

6. **Chunk Integration**: Direct integration with the input chunk system for persistent storage of profile data.

## Usage Example

```c
// Simple profile appending example
struct flb_input_instance *instance;
struct cprof *profile_context;
// ... initialize instance and profile context ...

// Append profile data
int ret = flb_input_profiles_append(
    instance,           // Input plugin instance
    "my.profiles.tag",  // Tag for the profile records
    17,                 // Tag length
    profile_context     // Profile context
);

if (ret == 0) {
    printf("Profile data appended successfully\n");
} else {
    printf("Failed to append profile data\n");
}

// Example with processor stages skipping
struct flb_input_instance *instance;
struct cprof *profile_context;
// ... initialize instance with processor and profile context ...

// Skip first processor stage
int ret = flb_input_profiles_append_skip_processor_stages(
    instance,           // Input plugin instance
    1,                  // Skip first processor stage
    "my.processed.profiles.tag", // Tag for the profile records
    27,                 // Tag length
    profile_context     // Profile context
);

if (ret == 0) {
    printf("Profile data processed and appended successfully\n");
} else {
    printf("Failed to process and append profile data\n");
}

// Complete example creating and appending profiles
struct flb_input_instance *instance;
struct cprof *profile_context;
// ... initialize instance ...

// Create a new profile context
profile_context = cprof_create();
if (profile_context == NULL) {
    printf("Failed to create profile context\n");
    return -1;
}

// Add profile data (this would depend on the specific CProfiles API)
// For example, adding a CPU profile sample:
// cprof_sample_add(profile_context, "main", 1000, "cpu");

// Append the profile context to the input chunk
int ret = flb_input_profiles_append(
    instance,           // Input plugin instance
    "cpu.profiles",     // Tag for the profile records
    12,                 // Tag length
    profile_context     // Profile context
);

if (ret == 0) {
    printf("CPU profiles appended successfully\n");
} else {
    printf("Failed to append CPU profiles\n");
}

// Clean up profile context
if (profile_context != NULL) {
    cprof_destroy(profile_context);
}
```