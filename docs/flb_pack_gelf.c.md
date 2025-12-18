# flb_pack_gelf.c Documentation

## Overview

This file implements the GELF (Graylog Extended Log Format) packing functions for Fluent Bit. GELF is a logging format used by Graylog and other logging systems that provides structured logging with compression capabilities. This module handles the conversion of Fluent Bit's internal data structures to GELF format for compatibility with Graylog and other GELF-supporting systems.

The implementation supports both GELF 1.0 and 2.0 specifications, with proper handling of compression, chunking, and metadata fields required by the GELF standard.

## Key Functions/Components

### GELF Packing Functions
- `flb_pack_gelf()`: Main function to convert data to GELF format
- `flb_pack_gelf_chunked()`: Handles GELF chunking for large messages

### Compression Support
- `flb_pack_gelf_compress()`: Compresses GELF data using zlib
- `flb_pack_gelf_decompress()`: Decompresses GELF data

### Metadata Handling
- `flb_pack_gelf_add_metadata()`: Adds standard GELF metadata fields
- `flb_pack_gelf_escape_field()`: Escapes field names according to GELF requirements

## Important Variables/Constants

### GELF Specifications
- `GELF_VERSION_1_0`: GELF version 1.0 identifier
- `GELF_VERSION_2_0`: GELF version 2.0 identifier
- `GELF_MAX_MESSAGE_SIZE`: Maximum size for uncompressed GELF messages (1024 bytes)
- `GELF_CHUNK_SIZE`: Size of GELF chunks for large messages

### Compression Settings
- `GELF_COMPRESSION_GZIP`: Gzip compression method
- `GELF_COMPRESSION_ZLIB`: Zlib compression method
- `GELF_COMPRESSION_LEVEL`: Default compression level

## Dependencies and Relationships

### Core Dependencies
- `zlib.h`: Compression library for GELF compression
- `flb_info.h`: General Fluent Bit information and logging
- `flb_mem.h`: Memory allocation utilities
- `flb_utils.h`: Utility functions for data handling
- `flb_pack.h`: Core packing functions
- `flb_time.h`: Time handling utilities

### Related Components
- Integrates with the output plugin system for GELF delivery
- Works with the parser system for log data preparation
- Connects to the buffer system for message queuing
- Interfaces with the scheduler for timing control

## Notable Implementation Details

### Chunking Algorithm
For messages exceeding the maximum size, the implementation uses GELF's chunking mechanism to split large messages into smaller chunks that can be reassembled by the receiver.

### Field Escaping
Proper escaping of field names and values according to GELF specifications to ensure compatibility with Graylog and other GELF receivers.

### Compression Optimization
Intelligent compression selection based on message size and content to optimize bandwidth usage while maintaining compatibility.

### Timestamp Handling
Precise timestamp conversion from Fluent Bit's internal time format to GELF's millisecond precision requirements.

## Usage Examples

```c
// Convert data to GELF format
struct flb_config *config = /* ... */;
void *in_buf = /* ... */; // Input data
size_t in_size = /* ... */;

void *out_buf;
size_t out_size;

int ret = flb_pack_gelf(in_buf, in_size, &out_buf, &out_size, config);
if (ret == 0) {
    // Successfully converted to GELF
    // Process out_buf with out_size bytes
    flb_free(out_buf);
}

// Handle chunked GELF messages
if (message_size > GELF_MAX_MESSAGE_SIZE) {
    // Message will be automatically chunked
    // Each chunk will be processed separately
}
```

## GELF Message Structure

### Required Fields
- `version`: GELF specification version ("1.0" or "1.1")
- `host`: Hostname of the sending system
- `short_message`: Short descriptive message
- `timestamp`: Unix timestamp with millisecond precision

### Optional Fields
- `full_message`: Detailed message content
- `level`: Syslog severity level
- `facility`: Facility that generated the message
- `_additional_fields`: Custom fields prefixed with underscore

## Data Flow

1. **Data Preparation**: Input data is prepared for GELF conversion
2. **Metadata Addition**: Standard GELF metadata fields are added
3. **Field Processing**: Custom fields are escaped and processed
4. **Compression**: Data is compressed if beneficial
5. **Chunking**: Large messages are split into chunks if necessary
6. **Serialization**: Final GELF message is serialized for transmission
7. **Output Delivery**: Serialized GELF data is sent to output plugins