# flb_sp_aggregate_func.c Documentation

## Overview

This file implements the aggregate functions for Fluent Bit's Stream Processor. It provides implementations for common SQL aggregation functions like AVG, SUM, COUNT, MIN, MAX, and the specialized TIMESERIES_FORECAST function. These functions are used to perform calculations on grouped data within stream processing operations.

## Key Functions

### aggregate_func_string
Static array containing the names of supported aggregate functions.

### aggregate_func_clone_nop()
No-operation clone function for aggregate nodes that don't require special cloning.

### aggregate_func_clone_timeseries_forecast()
Clones a timeseries forecast aggregate node, copying all statistical data needed for forecasting.

### aggregate_func_add_sum()
Adds a value to a SUM aggregation, handling both integer and floating-point types.

### aggregate_func_add_count()
Increments the count for a COUNT aggregation.

### aggregate_func_add_min()
Updates the minimum value for a MIN aggregation, handling both integer and floating-point types.

### aggregate_func_add_max()
Updates the maximum value for a MAX aggregation, handling both integer and floating-point types.

### aggregate_func_calc_avg()
Calculates the average value for an AVG aggregation and packs the result.

### aggregate_func_calc_sum()
Calculates and packs the sum value for a SUM aggregation.

### aggregate_func_calc_count()
Calculates and packs the count value for a COUNT aggregation.

### aggregate_func_remove_sum()
Removes a value from a SUM aggregation, used for sliding window operations.

### aggregate_func_remove_nop()
No-operation removal function for aggregate types that don't support removal.

### aggregate_func_add_timeseries_forecast()
Adds a value to a timeseries forecast aggregation, updating statistical accumulators.

### aggregate_func_calc_timeseries_forecast()
Calculates and packs the forecasted value using simple linear regression.

### aggregate_func_remove_timeseries_forecast()
Removes statistical data from a timeseries forecast aggregation, used for sliding window operations.

### aggregate_func_destroy_sum()
Destroys a SUM aggregation node, cleaning up resources.

### aggregate_func_destroy_timeseries_forecast()
Destroys a timeseries forecast aggregation node, freeing allocated memory.

## Function Arrays

### aggregate_func_clone
Array of clone functions for each aggregate type.

### aggregate_func_add
Array of add functions for each aggregate type.

### aggregate_func_calc
Array of calculation functions for each aggregate type.

### aggregate_func_remove
Array of removal functions for each aggregate type.

### aggregate_func_destroy
Array of destruction functions for each aggregate type.

## Important Constants

### AGGREGATE_FUNCTIONS
The number of supported aggregate functions.

### FLB_SP_NUM_I64
Constant indicating a 64-bit integer numeric type.

### FLB_SP_NUM_F64
Constant indicating a 64-bit floating-point numeric type.

## Dependencies

- `<fluent-bit/stream_processor/flb_sp.h>` - Stream processor header
- `<fluent-bit/stream_processor/flb_sp_parser.h>` - Stream processor parser header
- `<fluent-bit/stream_processor/flb_sp_aggregate_func.h>` - Aggregate functions header

## Relationships

This file works closely with:
- `flb_sp.c` - The main stream processor implementation
- Other stream processor components for data flow and windowing
- Parser components for SQL statement processing

## Implementation Details

The implementation features:
1. Support for standard SQL aggregation functions (AVG, SUM, COUNT, MIN, MAX)
2. Specialized TIMESERIES_FORECAST function using simple linear regression
3. Type-aware handling of both integer and floating-point numeric values
4. Efficient statistical accumulation for forecasting calculations
5. Proper memory management with allocation and deallocation functions
6. Support for sliding window operations with add/remove functions
7. Integration with MessagePack for result serialization

## Usage Context

These aggregate functions are used internally by the Stream Processor when executing SQL statements like:

```sql
SELECT AVG(cpu), SUM(memory), COUNT(*), MIN(response_time), MAX(throughput)
FROM STREAM:input
GROUP BY service;

SELECT TIMESERIES_FORECAST(metric, 60)
FROM STREAM:metrics
WINDOW TUMBLING (30 SECOND);
```

The functions provide the computational foundation for complex stream processing operations, enabling real-time analytics on log data streams.