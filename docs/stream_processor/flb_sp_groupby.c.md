# flb_sp_groupby.c

## Overview

This file implements the GROUP BY functionality for the Fluent Bit Stream Processor. It provides comparison logic for grouping records based on specified keys, enabling aggregation operations on grouped data.

## Key Functions

### `flb_sp_groupby_compare`

The primary comparison function used by the Red-Black tree implementation to compare two aggregate nodes based on their group-by keys. This function handles type conversion and comparison for different data types.

## Important Variables and Constants

- `FLB_SP_NUM_I64`: Constant for 64-bit integer type
- `FLB_SP_NUM_F64`: Constant for 64-bit float type
- `FLB_SP_BOOLEAN`: Constant for boolean type
- `FLB_SP_STRING`: Constant for string type

## Dependencies

This file depends on:
- `<fluent-bit/flb_info.h>`: Core Fluent Bit information
- `<fluent-bit/stream_processor/flb_sp.h>`: Stream processor core definitions

## Implementation Details

The implementation handles several key aspects:

1. **Type Conversion**: Automatically converts integer values to double when comparing with float values to ensure accurate comparisons.

2. **Multi-key Comparison**: Iterates through all group-by keys in the nodes being compared, ensuring that all keys match before considering the nodes equal.

3. **Type-specific Comparisons**: Implements specialized comparison logic for each data type:
   - Boolean: Direct equality comparison
   - Integer: Standard integer comparison
   - Float: Standard float comparison
   - String: Uses `strcmp()` for lexicographic comparison

4. **Error Handling**: Returns appropriate values (-1, 0, 1) for sorting purposes, with -1 indicating an error condition or mismatch.

## Usage Examples

The GROUP BY functionality is used in SQL-like queries as:
```sql
SELECT key1, COUNT(*) FROM STREAM:input_stream GROUP BY key1;
```

The comparison function is automatically invoked by the stream processor when organizing records into groups for aggregation operations.