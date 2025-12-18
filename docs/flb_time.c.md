# flb_time.c

## Overview

This file implements time-related utilities for Fluent Bit, providing high-resolution time measurement, time conversion functions, and serialization/deserialization capabilities for different time formats. The time system supports multiple time representations and integrates with both MessagePack and MPack serialization libraries.

Key features include:
- High-resolution time acquisition using platform-specific APIs
- Time conversion between different formats (seconds, milliseconds, nanoseconds)
- Time arithmetic operations (addition, subtraction)
- Serialization to/from MessagePack and MPack formats
- EventTime format support for Fluent Bit's event system
- Timezone offset calculation

The implementation provides cross-platform compatibility by using different time APIs based on the compilation environment and available system capabilities.

## Key Functions

### `flb_time_get()`
Retrieves the current high-resolution time and stores it in a `flb_time` structure. Uses the most appropriate platform-specific time API available.

### `flb_time_msleep()`
Sleeps for a specified number of milliseconds. Provides a portable sleep function across different platforms.

### `flb_time_to_double()`
Converts a `flb_time` structure to a double-precision floating-point number representing seconds since epoch.

### `flb_time_to_nanosec()`
Converts a `flb_time` structure to nanoseconds since epoch as a 64-bit unsigned integer.

### `flb_time_to_millisec()`
Converts a `flb_time` structure to milliseconds since epoch as a 64-bit unsigned integer.

### `flb_time_add()`
Adds a duration to a base time, handling overflow/underflow correctly and normalizing the result.

### `flb_time_diff()`
Calculates the difference between two time values, returning the result in a `flb_time` structure.

### `flb_time_append_to_mpack()`
Serializes a `flb_time` structure to MPack format using various time formats (integer, EventTime extension).

### `flb_time_append_to_msgpack()`
Serializes a `flb_time` structure to MessagePack format using various time formats.

### `flb_time_msgpack_to_time()`
Deserializes a MessagePack object back to a `flb_time` structure, supporting multiple input formats.

### `flb_time_pop_from_mpack()`
Deserializes time information from an MPack reader, handling different message formats.

### `flb_time_pop_from_msgpack()`
Deserializes time information from a MessagePack unpacked object.

### `flb_time_tz_offset_to_second()`
Calculates the timezone offset in seconds between local time and UTC.

## Important Variables/Constants

### Time Formats
- `FLB_TIME_ETFMT_INT`: Integer format (seconds since epoch)
- `FLB_TIME_ETFMT_V0`: Version 0 EventTime format
- `FLB_TIME_ETFMT_V1_EXT`: Version 1 EventTime extension format
- `FLB_TIME_ETFMT_V1_FIXEXT`: Version 1 EventTime fixed extension format
- `FLB_TIME_ETFMT_OTHER`: Other formats

### Time Conversion Constants
- `ONESEC_IN_NSEC`: Number of nanoseconds in one second (1,000,000,000)

### Time Structures
- `struct flb_time`: Main time structure containing `tv_sec` (seconds) and `tv_nsec` (nanoseconds)

## Dependencies

- External libraries:
  - `cmetrics/lib/mpack/src/mpack/mpack.h`: MPack serialization library
  - `msgpack.h`: MessagePack serialization library
  - `mpack/mpack.h`: Additional MPack headers

- Standard C library headers:
  - `time.h`: Time functions
  - `inttypes.h`: Fixed-width integer types
  - `string.h`: String manipulation functions

- Fluent Bit core components:
  - `flb_compat.h`: Compatibility layer
  - `flb_macros.h`: Macro definitions
  - `flb_log.h`: Logging functionality
  - `flb_time.h`: Time interface definitions

## Implementation Details

1. **Platform-Specific Time APIs**: Uses different time acquisition methods based on platform capabilities:
   - C11 `timespec_get()` when available
   - Mach clock services on macOS
   - `clock_gettime()` on POSIX systems
   - Fallback to `time()` for basic functionality

2. **Cross-Platform Compatibility**: Handles differences between Windows and Unix-like systems, particularly for sleep functions.

3. **EventTime Format Support**: Implements the Fluent Bit EventTime format as specified in the Forward Protocol Specification, using MessagePack extension types.

4. **Time Arithmetic**: Properly handles overflow and underflow conditions when performing time calculations.

5. **Serialization Flexibility**: Supports multiple serialization formats to ensure compatibility with different systems and protocols.

6. **Memory Safety**: Includes validation checks to prevent buffer overflows and invalid memory access.

7. **Error Handling**: Comprehensive error checking with appropriate return codes for different failure scenarios.

## Usage Example

```c
// Get current time
struct flb_time now;
flb_time_get(&now);

// Convert to different formats
double seconds = flb_time_to_double(&now);
uint64_t nanos = flb_time_to_nanosec(&now);
uint64_t millis = flb_time_to_millisec(&now);

// Time arithmetic
struct flb_time duration;
duration.tm.tv_sec = 5;  // 5 seconds
duration.tm.tv_nsec = 500000000;  // 500 million nanoseconds

struct flb_time future;
flb_time_add(&now, &duration, &future);

// Serialize to MessagePack
msgpack_packer *pk = /* ... initialize packer ... */;
flb_time_append_to_msgpack(&now, pk, FLB_TIME_ETFMT_V1_FIXEXT);

// Deserialize from MessagePack
msgpack_object obj = /* ... get object ... */;
struct flb_time parsed_time;
flb_time_msgpack_to_time(&parsed_time, &obj);

// Sleep for 100 milliseconds
flb_time_msleep(100);
```