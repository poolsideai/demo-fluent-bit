# flb_sp_func_time.c

## Overview

This file implements time-related functions for the Fluent Bit Stream Processor. It provides utilities for generating timestamps and formatted time strings that can be used in stream processing queries.

## Key Functions

### `flb_sp_func_time`

The main entry point that handles different time functions based on the command key configuration.

### `func_now`

Generates a formatted timestamp string representing the current system time in the format "YYYY-MM-DD HH:MM:SS".

### `func_unix_timestamp`

Returns the current Unix timestamp as an integer value.

### `pack_key`

Helper function that packs key information into a MessagePack format, either using an alias if provided or the function name.

## Important Variables and Constants

- `FLB_SP_NOW`: Constant representing the NOW() function
- `FLB_SP_UNIX_TIMESTAMP`: Constant representing the UNIX_TIMESTAMP() function

## Dependencies

This file depends on:
- `<fluent-bit/flb_info.h>`: Core Fluent Bit information
- `<fluent-bit/flb_pack.h>`: MessagePack packing utilities
- `<fluent-bit/stream_processor/flb_sp.h>`: Stream processor core definitions
- `<fluent-bit/stream_processor/flb_sp_parser.h>`: Stream processor parser definitions

## Implementation Details

The implementation uses the standard C library functions for time handling:
- `time(NULL)` to get the current system time
- `localtime_r()` to convert to local time representation
- `strftime()` to format the time string

Memory management follows Fluent Bit conventions with proper allocation and deallocation of temporary structures.

## Usage Examples

In SQL-like queries, these functions can be used as:
```sql
SELECT NOW(), UNIX_TIMESTAMP() FROM STREAM:input_stream;
```

The results will be added to the output record with appropriate key names based on whether aliases are specified.