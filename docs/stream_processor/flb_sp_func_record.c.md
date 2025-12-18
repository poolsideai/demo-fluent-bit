# flb_sp_func_record.c Documentation

## Overview

This file implements record-related functions for Fluent Bit's Stream Processor. It provides utilities for handling record metadata such as tags and timestamps, which are essential for stream processing operations that need to access record-level information.

## Key Functions

### pack_key()
Helper function to pack a key name into a MessagePack packer, using either the alias or the default function name.

### func_tag()
Implements the RECORD_TAG() function, which adds the record's tag to the output map.

### func_time()
Implements the RECORD_TIME() function, which adds the record's timestamp to the output map in double format.

### flb_sp_func_record()
Main entry point for record functions, dispatching to the appropriate function based on the command key's record function type.

## Important Constants

### FLB_SP_RECORD_TAG
Constant indicating the RECORD_TAG() function.

### FLB_SP_RECORD_TIME
Constant indicating the RECORD_TIME() function.

## Dependencies

- `<fluent-bit/flb_info.h>` - Core Fluent Bit information
- `<fluent-bit/flb_pack.h>` - Data packing utilities
- `<fluent-bit/stream_processor/flb_sp.h>` - Stream processor header
- `<fluent-bit/stream_processor/flb_sp_parser.h>` - Stream processor parser header

## Relationships

This file works closely with:
- `flb_sp.c` - The main stream processor implementation
- `flb_sp_func_time.c` - Time-related functions
- Other stream processor components for data flow
- Parser components for SQL statement processing

## Implementation Details

The implementation features:
1. RECORD_TAG() function to access the record's tag string
2. RECORD_TIME() function to access the record's timestamp in double format (seconds.nanoseconds)
3. Proper MessagePack packing for integration with Fluent Bit's data format
4. Support for aliasing function outputs with custom names
5. Efficient implementation with minimal overhead

## Usage Context

These record functions are used in SQL statements like:

```sql
SELECT RECORD_TAG(), RECORD_TIME(), field1, field2
FROM STREAM:input;

SELECT field1, field2, RECORD_TAG() AS source
FROM STREAM:input
WHERE RECORD_TIME() > 1552196165.0;
```

The functions provide access to record-level metadata that is often needed for filtering, grouping, or enrichment operations in stream processing.