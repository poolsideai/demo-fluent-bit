# flb_simdutf_connector.cpp Documentation

## Overview

This file implements the SIMDUTF connector for Fluent Bit, providing optimized Unicode processing capabilities. It serves as a bridge between Fluent Bit and the external SIMDUTF library, offering high-performance UTF-8 and UTF-16 conversion, validation, and detection functions.

## Key Functions

### flb_simdutf_connector_utf8_length_from_utf16le()
Calculates the length of UTF-8 representation for UTF-16LE encoded data.

### flb_simdutf_connector_utf8_length_from_utf16be()
Calculates the length of UTF-8 representation for UTF-16BE encoded data.

### flb_simdutf_connector_utf8_length_from_utf16()
Calculates the length of UTF-8 representation for generic UTF-16 encoded data.

### flb_simdutf_connector_validate_utf8()
Validates UTF-8 encoded data for correctness.

### flb_simdutf_connector_validate_utf16le()
Validates UTF-16LE encoded data for correctness.

### flb_simdutf_connector_validate_utf16be()
Validates UTF-16BE encoded data for correctness.

### flb_simdutf_connector_validate_utf16()
Validates generic UTF-16 encoded data for correctness.

### flb_simdutf_connector_convert_utf16le_to_utf8()
Converts UTF-16LE encoded data to UTF-8.

### flb_simdutf_connector_convert_utf16be_to_utf8()
Converts UTF-16BE encoded data to UTF-8.

### flb_simdutf_connector_convert_utf16_to_utf8()
Converts generic UTF-16 encoded data to UTF-8.

### flb_simdutf_connector_change_endianness_utf16()
Changes the endianness of UTF-16 data.

### flb_simdutf_connector_detect_encodings()
Detects the encoding type of input data.

### flb_simdutf_connector_convert_from_unicode()
Converts Unicode data to UTF-8 with automatic encoding detection.

### convert_from_unicode()
Helper function for converting Unicode data with proper memory alignment.

## Important Constants

### FLB_SIMDUTF_CONNECTOR_CONVERT_NOP
Constant indicating no conversion is needed.

### FLB_SIMDUTF_CONNECTOR_CONVERT_ERROR
Constant indicating a conversion error occurred.

### FLB_SIMDUTF_CONNECTOR_CONVERT_UNSUPPORTED
Constant indicating an unsupported encoding was encountered.

### FLB_SIMDUTF_CONNECTOR_CONVERT_OK
Constant indicating successful conversion.

### FLB_SIMDUTF_ENCODING_TYPE_UNICODE_AUTO
Constant for automatic encoding detection.

### FLB_SIMDUTF_ENCODING_TYPE_UNSPECIFIED
Constant for unspecified encoding type.

### FLB_SIMDUTF_ENCODING_TYPE_UTF8
Constant for UTF-8 encoding type.

## Dependencies

- `<simdutf.h>` - SIMDUTF library header
- `<fluent-bit/simdutf/flb_simdutf_connector.h>` - Connector header
- `<memory>` - Standard C++ memory utilities
- `<fluent-bit/flb_log.h>` - Fluent Bit logging utilities
- `<fluent-bit/flb_mem.h>` - Fluent Bit memory management

## Relationships

This connector integrates with:
- The external SIMDUTF library for optimized Unicode processing
- Fluent Bit's core components that require Unicode handling
- Other Fluent Bit modules that process internationalized text data

## Implementation Details

The implementation features:
1. Optimized SIMD-based Unicode processing using the SIMDUTF library
2. Proper memory alignment handling for performance
3. Automatic encoding detection and conversion
4. Comprehensive error handling with detailed error codes
5. Support for various UTF encodings (UTF-8, UTF-16LE, UTF-16BE)
6. Efficient memory management with proper allocation/deallocation
7. Endianness conversion capabilities

## Usage Examples

```c
// Validate UTF-8 data
int is_valid = flb_simdutf_connector_validate_utf8(data, length);

// Convert UTF-16LE to UTF-8
char *utf8_output;
size_t out_size;
int result = flb_simdutf_connector_convert_utf16le_to_utf8(
    utf16_data, length, &utf8_output, &out_size);

// Detect encoding and convert automatically
int result = flb_simdutf_connector_convert_from_unicode(
    FLB_SIMDUTF_ENCODING_TYPE_UNICODE_AUTO, input, length,
    &output, &out_size);
```

The connector provides high-performance Unicode processing that is essential for handling internationalized log data in Fluent Bit.