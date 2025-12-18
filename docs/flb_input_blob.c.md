# flb_input_blob.c

## Overview

This file contains the implementation for handling blob data in Fluent Bit input plugins. It provides functionality for registering blob files and managing blob delivery notifications. Blob data refers to binary large objects that can be ingested by Fluent Bit, typically used for file-based inputs where the entire file content is treated as a single record.

The module handles the registration of blob files, validation of file accessibility and size constraints, and encoding of blob metadata into log events that can be processed by the Fluent Bit engine.

## Key Functions

### Blob File Registration

#### `flb_input_blob_file_register()`
Registers a blob file with the input plugin instance. This function validates file accessibility, checks size constraints, and encodes the blob metadata into a log event that gets appended to the input chunk.

#### `flb_input_blob_file_get_info()`
Extracts blob file information from a MessagePack map object. This includes the file path, size, and source plugin name.

### Delivery Notification Management

#### `flb_input_blob_delivery_notification_destroy()`
Destroys a blob delivery notification instance and frees associated resources.

## Important Variables/Constants

### Data Structures
- `struct flb_blob_delivery_notification`: Represents a delivery notification for blob data with a base notification structure, file path, and success indicator
- `struct flb_blob_file`: Simple structure containing a file path for blob files

## Dependencies

- `fluent-bit/flb_info.h`: Core Fluent Bit information
- `fluent-bit/flb_input.h`: Input plugin interface
- `fluent-bit/flb_input_chunk.h`: Input chunk management
- `fluent-bit/flb_input_plugin.h`: Plugin interface definitions
- `fluent-bit/flb_log_event_encoder.h`: Log event encoding utilities
- `fluent-bit/flb_pack.h`: MessagePack packing utilities
- `fluent-bit/flb_notification.h`: Notification system
- `sys/stat.h`: File status utilities

## Implementation Details

1. **File Validation**: Comprehensive validation of file accessibility using `access()` and `stat()` system calls to ensure files are readable and meet size requirements.

2. **Metadata Encoding**: Uses the log event encoder wrapper to encode blob metadata (file path, size, source plugin) into MessagePack format.

3. **Chunk Integration**: Integrates with the input chunk system by appending blob records to input chunks using `flb_input_chunk_append_raw()`.

4. **Error Handling**: Provides detailed error reporting for various failure scenarios including file access issues, size validation failures, and encoding errors.

5. **Memory Management**: Proper allocation and deallocation of string data using CFL SDS (Simple Dynamic Strings) library.

## Usage Example

```c
// Register a blob file with the input plugin
struct flb_log_event_encoder *encoder = flb_log_event_encoder_init(NULL, 0);

if (encoder != NULL) {
    // Register the blob file
    int ret = flb_input_blob_file_register(
        instance,           // Input plugin instance
        encoder,            // Log event encoder
        "my.blob.tag",      // Tag for the blob record
        12,                 // Tag length
        "/path/to/data.bin", // File path
        1024               // File size
    );
    
    if (ret == 0) {
        printf("Blob file registered successfully\n");
    } else {
        printf("Failed to register blob file\n");
    }
    
    // Clean up encoder
    flb_log_event_encoder_destroy(encoder);
}

// Example of extracting blob info from a MessagePack object
cfl_sds_t source = NULL;
cfl_sds_t file_path = NULL;
size_t size = 0;

// Assuming 'map' is a valid MessagePack map object
int ret = flb_input_blob_file_get_info(map, &source, &file_path, &size);
if (ret == 0) {
    printf("Blob file: %s (source: %s, size: %zu)\n", 
           file_path, source, size);
    
    // Clean up allocated strings
    cfl_sds_destroy(source);
    cfl_sds_destroy(file_path);
}
```