# flb_time.c

## Overview

The `flb_time.c` file provides time management utilities for Fluent Bit. This module handles various time-related operations including getting current time, time conversions, time arithmetic, and serialization/deserialization of time values in different formats.

The time system is fundamental to Fluent Bit's operation as it manages timestamps for log events, implements time-based scheduling, and handles time serialization for network protocols. The module provides cross-platform compatibility for time operations and supports multiple serialization formats for interoperability with different systems.

## Key Functions

### `flb_time_get(struct flb_time *tm)`
Gets the current time and stores it in the provided `flb_time` structure. Uses platform-specific implementations for optimal performance.

The function supports multiple platform implementations:
- C11 `timespec_get()` when available (most accurate)
- Mach clock services on macOS
- POSIX `clock_gettime()` on Linux
- Fallback to `time()` for basic functionality

Also supports compile-time configuration for forcing integer-only time format.

### `flb_time_msleep(uint32_t ms)`
Sleeps for the specified number of milliseconds. Provides cross-platform compatibility for sleep operations.

Platform-specific implementations:
- Windows: Uses `Sleep()` function
- Unix-like: Uses `nanosleep()` with proper conversion from milliseconds to nanoseconds

### `flb_time_to_double(struct flb_time *tm)`
Converts a `flb_time` structure to a double representation where the integer part represents seconds and the fractional part represents nanoseconds.

Useful for mathematical operations on time values and interfacing with systems that expect floating-point time representations.

### `flb_time_to_nanosec(struct flb_time *tm)`
Converts a `flb_time` structure to nanoseconds since epoch.

Provides high-resolution time representation suitable for precise timing calculations.

### `flb_time_to_millisec(struct flb_time *tm)`
Converts a `flb_time` structure to milliseconds since epoch.

Useful for systems that work with millisecond precision or for compatibility with JavaScript Date objects.

### `flb_time_add(struct flb_time *base, struct flb_time *duration, struct flb_time *result)`
Adds two time values together, properly handling overflow/underflow of nanoseconds.

The function correctly handles edge cases:
- Nanosecond overflow (> 1 second) is converted to additional seconds
- Nanosecond underflow (< 0) borrows from seconds
- Proper validation of input parameters

### `flb_time_diff(struct flb_time *time1, struct flb_time *time0, struct flb_time *result)`
Calculates the difference between two time values.

Handles various edge cases:
- Returns -2 for nanosecond underflow when seconds are equal
- Returns -3 for general time underflow (time1 < time0)
- Properly handles borrowing when nanosecond subtraction results in negative values

### `flb_time_append_to_mpack(mpack_writer_t *writer, struct flb_time *tm, int fmt)`
Serializes time data to MessagePack format using the specified format.

Supports multiple serialization formats:
- Integer format (seconds only): `FLB_TIME_ETFMT_INT`
- EventTime v0 format: `FLB_TIME_ETFMT_V0`
- EventTime v1 extended format: `FLB_TIME_ETFMT_V1_EXT`
- EventTime v1 fixed extended format: `FLB_TIME_ETFMT_V1_FIXEXT`

Uses network byte order for compatibility across different architectures.

### `flb_time_append_to_msgpack(struct flb_time *tm, msgpack_packer *pk, int fmt)`
Serializes time data to MessagePack format using the specified format.

Similar to `flb_time_append_to_mpack()` but uses the older msgpack-c library interface.

### `flb_time_msgpack_to_time(struct flb_time *time, msgpack_object *obj)`
Deserializes time data from a MessagePack object.

Supports multiple input formats:
- Positive integers (seconds only)
- Floating-point numbers (seconds with fractional part)
- Extended types (EventTime format with seconds and nanoseconds)

### `flb_time_pop_from_mpack(struct flb_time *time, mpack_reader_t *reader)`
Reads time data from an mpack reader.

Handles complex deserialization scenarios including:
- Arrays with timestamp elements
- Header arrays with metadata
- Various numeric formats (int, uint, float, double)
- Extended binary formats

### `flb_time_pop_from_msgpack(struct flb_time *time, msgpack_unpacked *upk, msgpack_object **map)`
Reads time data from a MessagePack unpacked object.

Extracts time information from complex MessagePack structures and returns pointers to associated metadata maps.

### `flb_time_tz_offset_to_second()`
Calculates the timezone offset in seconds between local time and UTC.

Computes the difference by comparing local time and UTC time for the current moment, accounting for day boundaries and timezone transitions.

## Important Variables and Constants

### Format Constants
- `FLB_TIME_ETFMT_INT` - Integer format (seconds only)
- `FLB_TIME_ETFMT_V0` - Version 0 format
- `FLB_TIME_ETFMT_V1_EXT` - Version 1 extended format
- `FLB_TIME_ETFMT_V1_FIXEXT` - Version 1 fixed extended format
- `FLB_TIME_ETFMT_OTHER` - Other formats

### Time Structure Fields
- `tm` - Standard POSIX `timespec` structure containing:
  - `tv_sec` - Seconds since epoch
  - `tv_nsec` - Additional nanoseconds

### Helper Constants
- `ONESEC_IN_NSEC` - Number of nanoseconds in one second (1,000,000,000)

## Dependencies

This module depends on:
- MessagePack libraries (`msgpack.h`, `mpack/mpack.h`)
- Standard C time functions (`time.h`)
- Network byte order functions (`htonl`, `ntohl`)
- Fluent Bit compatibility layer (`flb_compat.h`)
- Fluent Bit macros (`flb_macros.h`)
- Fluent Bit logging (`flb_log.h`)
- Fluent Bit time interface (`flb_time.h`)
- Platform-specific headers for time functions

## Implementation Details

The time module provides several key features:

### Cross-Platform Time Retrieval

Uses different implementations based on platform capabilities:
1. **C11 `timespec_get()`** - Most accurate when available
2. **Mach clock services** - On macOS systems
3. **POSIX `clock_gettime()`** - On Linux and other POSIX systems
4. **Fallback `time()`** - Basic functionality when other methods unavailable

Also supports compile-time configuration to force integer-only time format for compatibility scenarios.

### Multiple Serialization Formats

Supports various time formats for compatibility with different protocols:
- **Integer format** - Simple seconds representation
- **EventTime v0** - Original EventTime format
- **EventTime v1 extended** - Extended EventTime format
- **EventTime v1 fixed extended** - Compact fixed-size EventTime format

All binary formats use network byte order to ensure compatibility across different architectures.

### Time Arithmetic

Provides robust time arithmetic functions:
- Addition with proper overflow handling
- Subtraction with underflow detection
- Conversion between different time units
- Mathematical operations on time values

### Deserialization Complexity

Handles complex deserialization scenarios:
- Arrays with timestamp elements
- Header arrays with metadata
- Multiple numeric representations
- Binary extended types
- Error handling for malformed data

### Timezone Handling

Includes utilities for timezone calculations:
- Offset computation between local and UTC time
- Proper handling of day boundaries
- Accounting for timezone transitions

## Usage Examples

Getting current time:
```c
struct flb_time tm;
flb_time_get(&tm);
printf("Current time: %ld.%09ld\n", tm.tm.tv_sec, tm.tm.tv_nsec);
```

Sleeping for 500 milliseconds:
```c
flb_time_msleep(500);
```

Converting time to double:
```c
struct flb_time tm;
flb_time_get(&tm);
double time_double = flb_time_to_double(&tm);
```

Serializing time to MessagePack:
```c
struct flb_time tm;
msgpack_packer *pk;
// ... initialize packer
flb_time_get(&tm);
flb_time_append_to_msgpack(&tm, pk, FLB_TIME_ETFMT_V1_FIXEXT);
```

Performing time arithmetic:
```c
struct flb_time start, duration, end;
flb_time_get(&start);
// Set duration to 1 second
flb_time_set(&duration, 1, 0);
flb_time_add(&start, &duration, &end);
```

Calculating time differences:
```c
struct flb_time start, end, diff;
flb_time_get(&start);
// ... some operations ...
flb_time_get(&end);
flb_time_diff(&end, &start, &diff);
```

## Error Handling

The time module implements comprehensive error handling:
- Parameter validation for all functions
- Proper error codes for different failure scenarios
- Graceful degradation when preferred time sources are unavailable
- Logging of warnings for unknown or unexpected time formats

## Performance Considerations

The time system is optimized for performance:
- Uses the most accurate and efficient time source available on each platform
- Minimizes system calls through careful implementation
- Efficient serialization/deserialization algorithms
- Proper handling of edge cases to avoid expensive error paths

## Cross-Platform Compatibility

The module ensures compatibility across different platforms:
- Windows: Uses `Sleep()` for millisecond sleep
- Unix-like: Uses `nanosleep()` with proper conversion
- Different time retrieval methods based on platform capabilities
- Consistent behavior regardless of underlying system differences

## Network Protocol Compatibility

Supports multiple serialization formats for network protocols:
- Fluentd Forward Protocol specifications
- MessagePack binary formats
- Network byte order for cross-architecture compatibility
- Backward compatibility with older format versions

## Timezone Awareness

The time module includes timezone utilities:
- Calculation of local timezone offset from UTC
- Proper handling of day boundary crossings
- Accounting for timezone transition effects
- Integration with system timezone databases

## Memory Management

All time operations are designed to be lightweight:
- No dynamic memory allocation in core functions
- Stack-based operations where possible
- Efficient use of existing buffers for serialization
- Proper cleanup of resources in error conditions