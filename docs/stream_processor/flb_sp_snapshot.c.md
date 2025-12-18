# flb_sp_snapshot.c

## Overview

This file implements snapshot functionality for the Fluent Bit Stream Processor. Snapshots provide a mechanism to capture and store records over time windows, enabling features like time-based data retention and periodic data flushing.

## Key Functions

### `flb_sp_snapshot_update`

The main function for adding new records to a snapshot, managing memory pages and enforcing time/record limits.

### `flb_sp_snapshot_flush`

Handles the process of flushing snapshot data to output streams, clearing the snapshot after successful flush.

### `flb_sp_snapshot_destroy`

Cleans up all resources associated with a snapshot, including memory pages and internal data structures.

### `snapshot_cleanup`

Removes expired records from snapshots based on time limits and record count limits.

### `snapshot_page_create`

Creates new memory pages for storing snapshot data when existing pages are full.

### `flb_sp_snapshot_name_from_flush`

Extracts the snapshot name from a flush operation identifier.

## Important Variables and Constants

- `SNAPSHOT_PAGE_SIZE`: Size of memory pages used for snapshot storage (typically 64KB)
- `struct flb_sp_snapshot`: Main snapshot data structure
- `struct flb_sp_snapshot_page`: Memory page structure for snapshot data

## Dependencies

This file depends on:
- `<fluent-bit/flb_mem.h>`: Memory management utilities
- `<fluent-bit/stream_processor/flb_sp.h>`: Stream processor core definitions
- `<fluent-bit/stream_processor/flb_sp_parser.h>`: Stream processor parser definitions
- `<fluent-bit/stream_processor/flb_sp_snapshot.h>`: Snapshot-specific definitions

## Implementation Details

### Memory Management

The implementation uses a paged memory approach:
- Records are stored in fixed-size memory pages (`SNAPSHOT_PAGE_SIZE`)
- New pages are created when existing pages are full
- Pages are managed through a linked list structure
- Memory is properly freed when snapshots are destroyed

### Time-based Cleanup

Snapshots support automatic cleanup based on two criteria:
1. **Time Limits**: Records older than a specified time threshold are removed
2. **Record Limits**: When the snapshot exceeds a maximum record count, oldest records are removed

The `snapshot_cleanup` function implements this logic by:
- Iterating through snapshot pages
- Checking timestamps of records
- Removing expired records and adjusting page boundaries
- Freeing completely empty pages

### Flush Operations

The flush mechanism:
- Combines data from all snapshot pages
- Clears the snapshot after successful flush
- Handles memory reallocation for combined output buffers
- Maintains proper record ordering during flush

### Data Structure Organization

```
Snapshot
├── Pages (linked list)
│   ├── Page 1
│   │   ├── Start position
│   │   ├── End position
│   │   └── Raw data buffer
│   ├── Page 2
│   └── ...
├── Record count
├── Total size
├── Time limit
└── Record limit
```

## Usage Examples

Snapshots are created and managed through SQL-like commands:
```sql
CREATE SNAPSHOT my_snapshot WITH(tag='snapshot_tag') AS SELECT * FROM STREAM:input_stream;
FLUSH SNAPSHOT my_snapshot AS SELECT * FROM STREAM:input_stream;
```

The snapshot functionality automatically handles time-based retention and periodic flushing based on the configured limits.