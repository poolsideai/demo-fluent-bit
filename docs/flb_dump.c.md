# flb_dump.c

## Overview

This file implements the debugging dump functionality for Fluent Bit. It provides detailed diagnostic information about the current state of the Fluent Bit engine, including input plugins, tasks, chunks, and storage layer statistics.

The module is primarily used for troubleshooting and monitoring purposes, allowing administrators and developers to inspect the internal state of Fluent Bit at runtime.

## Key Functions

### `flb_dump()`
The main entry point for generating a dump of Fluent Bit's current state. This function orchestrates the collection and display of diagnostic information from various subsystems.

### `dump_input_chunks()`
Collects and displays detailed information about input plugin instances, including their status, memory usage, tasks, and chunk statistics.

### `dump_storage()`
Gathers and presents Chunk I/O layer statistics, showing the distribution of chunks across memory and filesystem storage.

### `dump_tasks()`
Provides detailed information about tasks in the system, including their status, size, and routing information.

## Important Variables/Constants

### Dump Context Structure
While not explicitly defined as a structure, the dump functionality operates on the global `flb_config` context which contains:
- `inputs`: List of input plugin instances
- `cio`: Chunk I/O context for storage statistics
- Various counters and status information for different components

### Status Counters
The dump tracks various status indicators:
- `overlimit`: Whether input plugins have exceeded their memory buffer limits
- `task_new`, `task_running`: Counts of tasks in different states
- `up`, `down`: Counts of chunks in different storage states
- `busy`: Count of chunks currently being flushed

## Dependencies

- `fluent-bit/flb_info.h`: Fluent Bit core information
- `fluent-bit/flb_input.h`: Input plugin interface
- `fluent-bit/flb_input_chunk.h`: Input chunk management
- `fluent-bit/flb_task.h`: Task management
- `fluent-bit/flb_config.h`: Configuration management
- `fluent-bit/flb_storage.h`: Storage layer interface
- `fluent-bit/flb_utils.h`: Utility functions
- `fluent-bit/flb_event.h`: Event handling
- `fluent-bit/flb_stacktrace.h`: Stack trace functionality (conditional)

## Implementation Details

1. **Hierarchical Information Display**: The dump organizes information hierarchically, starting with input plugins and drilling down to individual chunks and tasks.

2. **Human-Readable Sizes**: Memory sizes are converted to human-readable formats (KB, MB, GB) for easier interpretation.

3. **Status Tracking**: The implementation tracks various operational statuses including memory limits, task states, and chunk states.

4. **Conditional Compilation**: Stack trace functionality is conditionally compiled based on the `FLB_DUMP_STACKTRACE` flag.

5. **Real-time Statistics**: The dump provides real-time snapshots of the system's current state, making it valuable for debugging performance issues.

## Usage Example

```c
// Generate a dump of Fluent Bit's current state
struct flb_config *config = flb_config_init();
// ... initialize and run Fluent Bit ...

// At any point, generate a diagnostic dump
flb_dump(config);

// The dump will be printed to stderr with a timestamp:
// [2024/01/15 14:30:45] Fluent Bit Dump
// ===== Input =====
// stdin (stdin)
// │
// ├─ status
// │  └─ overlimit     : no
// │     ├─ mem size   : 128 KB (131072 bytes)
// │     └─ mem limit  : 5 MB (5242880 bytes)
// │
// ├─ tasks
// │  ├─ total tasks   : 3
// │  ├─ new           : 1
// │  ├─ running       : 2
// │  └─ size          : 48 KB (49152 bytes)
// │
// └─ chunks
//    └─ total chunks  : 5
//      ├─ up chunks  : 3
//      ├─ down chunks: 2
//      └─ busy chunks: 1
//         ├─ size    : 16 KB (16384 bytes)
//         └─ size err: 0
```