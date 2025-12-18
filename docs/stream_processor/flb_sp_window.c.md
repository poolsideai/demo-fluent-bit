# flb_sp_window.c

## Overview

This file implements window management functionality for the Fluent Bit Stream Processor. Windows provide time-based or count-based grouping of records for aggregation operations, enabling complex analytical queries over streaming data.

## Key Functions

### `flb_sp_window_prune`

The primary function for managing window lifecycle, removing expired records and cleaning up window state based on window type and configuration.

### `flb_sp_window_populate`

Handles the process of adding new records to windows, preparing them for aggregation operations.

## Important Variables and Constants

- `FLB_SP_WINDOW_DEFAULT`: Default window type
- `FLB_SP_WINDOW_TUMBLING`: Tumbling window type
- `FLB_SP_WINDOW_HOPPING`: Hopping window type
- `struct flb_sp_hopping_slot`: Data structure for hopping window slots

## Dependencies

This file depends on:
- `<fluent-bit/stream_processor/flb_sp.h>`: Stream processor core definitions
- `<fluent-bit/stream_processor/flb_sp_window.h>`: Window-specific definitions
- `<fluent-bit/stream_processor/flb_sp_parser.h>`: Stream processor parser definitions
- `<fluent-bit/stream_processor/flb_sp_groupby.h>`: Group-by functionality
- `<fluent-bit/stream_processor/flb_sp_aggregate_func.h>`: Aggregation functions

## Implementation Details

### Window Types

The implementation supports three window types:

1. **Default Window**: Simple window without explicit time boundaries
2. **Tumbling Window**: Fixed-size, non-overlapping windows that slide forward in time
3. **Hopping Window**: Overlapping windows with configurable advance intervals

### Pruning Logic

The `flb_sp_window_prune` function implements sophisticated pruning logic:

#### Tumbling Windows
- Completely clears the window when the time/record limit is reached
- Destroys all aggregate nodes and rebuilds the aggregate tree
- Resets record counters

#### Hopping Windows
- Maintains multiple time slots
- Compares current aggregation state with previous slot state
- Removes records that are no longer in the current window
- Updates aggregation values by removing contributions from expired records
- Destroys expired hopping slots

### Aggregation Management

The implementation handles complex aggregation scenarios:
- Tracks record counts for each group
- Manages Red-Black trees for efficient group lookup
- Handles partial aggregation updates when records expire
- Maintains proper memory management for aggregation nodes

### Data Structure Organization

```
Window
├── Type (default/tumbling/hopping)
├── Size (time or record count)
├── Advance interval (for hopping windows)
├── Aggregate tree (Red-Black tree)
├── Aggregate list (linked list of nodes)
├── Record count
├── Hopping slots (for hopping windows)
└── Current timestamp
```

### Memory Management

The implementation carefully manages memory:
- Allocates and frees aggregation nodes
- Maintains Red-Black tree structures
- Handles linked list operations for aggregation nodes
- Properly cleans up hopping window slots
- Manages temporary data structures during pruning

## Usage Examples

Windows are specified in SQL-like queries:
```sql
-- Tumbling window: 60 seconds
SELECT key1, COUNT(*) FROM STREAM:input_stream WINDOW TUMBLING(60 SECOND);

-- Hopping window: 60 seconds window, advance by 30 seconds
SELECT key1, COUNT(*) FROM STREAM:input_stream WINDOW HOPPING(60 SECOND, ADVANCE BY 30 SECOND);
```

The window functionality automatically manages record grouping, aggregation, and cleanup based on the configured window parameters.