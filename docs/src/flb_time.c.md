# flb_time.c

## Overview

The `flb_time.c` file provides time management utilities for Fluent Bit. This module handles various time-related operations including getting current time, time conversions, time arithmetic, and serialization/deserialization of time values in different formats.

## Key Functions

### `flb_time_get(struct flb_time *tm)`
Gets the current time and stores it in the provided `flb_time` structure. Uses platform-specific implementations for optimal performance.

### `flb_time_msleep(uint32_t ms)`
Sleeps for the specified number of milliseconds. Provides cross-platform compatibility for sleep operations.

### `flb_time_to_double(struct flb_time *tm)`
Converts a `flb_time` structure to a double representation where the integer part represents seconds and the fractional part represents nanoseconds.

### `flb_time_to_nanosec(struct flb_time *tm)`
Converts a `flb_time` structure to nanoseconds since epoch.

### `flb_time_to_millisec(struct flb_time *tm)`
Converts a `flb_time` structure to milliseconds since epoch.

### `flb_time_add(struct flb_time *base, struct flb_time *duration, struct flb_time *result)`
Adds two time values together, properly handling overflow/underflow of nanoseconds.

### `flb_time_diff(struct flb_time *time1, struct flb_time *time0, struct flb_time *result)`
Calculates the difference between two time values.

### `flb_time_append_to_mpack(mpack_writer_t *writer, struct flb_time *tm, int fmt)`
Serializes time data to MessagePack format using the specified format.

### `flb_time_append_to_msgpack(struct flb_time *tm, msgpack_packer *pk, int fmt)`
Serializes time data to MessagePack format using the specified format.

### `flb_time_msgpack_to_time(struct flb_time *time, msgpack_object *obj)`
Deserializes time data from a MessagePack object.

### `flb_time_pop_from_mpack(struct flb_time *time, mpack_reader_t *reader)`
Reads time data from an mpack reader.

### `flb_time_pop_from_msgpack(struct flb_time *time, msgpack_unpacked *upk, msgpack_object **map)`
Reads time data from a MessagePack unpacked object.

### `flb_time_tz_offset_to_second()`
Calculates the timezone offset in seconds between local time and UTC.

## Important Variables and Constants

### Format Constants
- `FLB_TIME_ETFMT_INT` - Integer format (seconds only)
- `FLB_TIME_ETFMT_V0` - Version 0 format
- `FLB_TIME_ETFMT_V1_EXT` - Version 1 extended format
- `FLB_TIME_ETFMT_V1_FIXEXT` - Version 1 fixed extended format
- `FLB_TIME_ETFMT_OTHER` - Other formats

### Time Structure Fields
- `tm` - Standard POSIX `timespec` structure containing seconds and nanoseconds

## Dependencies

This module depends on:
- MessagePack libraries (`msgpack.h`, `mpack/mpack.h`)
- Standard C time functions (`time.h`)
- Network byte order functions (`htonl`, `ntohl`)
- Fluent Bit compatibility layer (`flb_compat.h`)
- Fluent Bit macros (`flb_macros.h`)
- Fluent Bit logging (`flb_log.h`)
- Fluent Bit time interface (`flb_time.h`)

## Implementation Details

The time module provides several key features:

1. **Cross-platform time retrieval**: Uses different implementations based on platform capabilities:
   - C11 `timespec_get()` when available
   - Mach clock services on macOS
   - POSIX `clock_gettime()` on Linux
   - Fallbacks to `time()` for basic functionality

2. **Multiple serialization formats**: Supports various time formats for compatibility with different protocols:
   - Integer format (seconds only)
   - EventTime v0 format
   - EventTime v1 format (both extended and fixed extended)

3. **Time arithmetic**: Provides functions for adding and subtracting time values with proper handling of overflow conditions.

4. **Timezone handling**: Includes utilities for calculating timezone offsets.

5. **Serialization/Deserialization**: Comprehensive support for converting time values to and from MessagePack formats used in Fluent Bit's data pipeline.

The module uses network byte order for serialization to ensure compatibility across different architectures and systems.

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