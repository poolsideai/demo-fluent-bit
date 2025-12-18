# flb_log.c

## Overview

The `flb_log.c` file implements Fluent Bit's logging system. It provides a centralized logging mechanism that handles different log levels, output destinations, and includes features like log suppression to reduce noise. The logging system uses a dedicated worker thread to collect and process log messages asynchronously, preventing blocking of the main application threads.

Key features include:
- Multiple log levels (ERROR, WARN, INFO, DEBUG, TRACE)
- Support for different output destinations (stderr, file)
- Log message formatting with timestamps and colors
- Asynchronous logging through a dedicated worker thread
- Log suppression to prevent repetitive message flooding
- Metrics collection for log statistics
- Thread-safe operation

## Key Functions

### `flb_log_create`
Creates and initializes a new logging context with specified output type, log level, and output destination.

### `flb_log_destroy`
Destroys a logging context and releases all associated resources.

### `flb_log_set_level`
Sets the log level for a given configuration.

### `flb_log_set_file`
Configures the logging system to write to a specified file instead of stderr.

### `flb_log_print`
Prints a formatted log message with the specified log level.

### `flb_log_is_truncated`
Checks if a log message would be truncated when printed.

### `flb_log_cache_create`
Creates a log cache for suppressing repetitive messages.

### `flb_log_cache_destroy`
Destroys a log cache and releases its resources.

### `flb_log_cache_check_suppress`
Checks if a log message should be suppressed based on the cache.

## Data Structures

### `struct flb_log`
Represents the main logging context with the following fields:
- `event`: Worker event for manager
- `ch_mng`: Worker channel manager (pipe endpoints)
- `type`: Log output type (stderr, file, socket)
- `level`: Current log level
- `out`: Output destination (file path or socket path)
- `tid`: Thread ID of the logging worker
- `worker`: Reference to the worker context
- `evl`: Event loop for the logging worker
- `metrics`: Metrics collection for log statistics
- Thread synchronization primitives for initialization

### `struct flb_log_cache`
Manages log message caching for suppression:
- `timeout`: Cache timeout in seconds
- `entries`: List of cached log entries

### `struct flb_log_cache_entry`
Represents a cached log entry:
- `buf`: Cached message buffer
- `timestamp`: When the message was cached
- `_head`: List linkage structure

### `struct flb_log_metrics`
Collects metrics about logging activity:
- `cmt`: CMetrics context
- `logs_total_counter`: Counter for total logs by message type

## Log Levels

- `FLB_LOG_ERROR` (1): Error messages
- `FLB_LOG_WARN` (2): Warning messages
- `FLB_LOG_INFO` (3): Informational messages (default)
- `FLB_LOG_DEBUG` (4): Debug messages
- `FLB_LOG_TRACE` (5): Trace messages
- `FLB_LOG_HELP` (6): Help messages
- `FLB_LOG_IDEBUG` (10): Internal debug messages

## Dependencies

- `<stdio.h>`: Standard input/output functions
- `<stdlib.h>`: Standard library functions
- `<signal.h>`: Signal handling
- `<stdarg.h>`: Variable argument lists
- `<inttypes.h>`: Fixed-width integer types
- `<sys/types.h>`: System data types
- `<sys/stat.h>`: File status
- `<fcntl.h>`: File control
- `<monkey/mk_core.h>`: Monkey framework core
- `<fluent-bit/flb_log.h>`: Header file with declarations
- `<fluent-bit/flb_pipe.h>`: Pipe communication utilities
- `<fluent-bit/flb_config.h>`: Configuration management
- `<fluent-bit/flb_worker.h>`: Worker thread management
- `<fluent-bit/flb_mem.h>`: Memory management
- `<fluent-bit/flb_time.h>`: Time handling
- `<cmetrics/cmetrics.h>`: Metrics collection
- `<cmetrics/cmt_counter.h>`: Counter metrics
- Platform-specific headers for Windows support

## Implementation Details

### Asynchronous Logging Architecture
The logging system uses a dedicated worker thread (`log_worker_collector`) that:
1. Runs an event loop to monitor log message pipes
2. Collects log messages from multiple sources
3. Processes and formats messages
4. Writes messages to the configured output destination

This architecture prevents blocking of application threads when logging occurs.

### Log Message Formatting
Log messages are formatted with:
- Timestamp in `[year/month/day hour:minute:second.milliseconds]` format
- Colored output based on log level (when writing to a terminal)
- Log level indicator
- Message content

### Log Suppression
To prevent flooding from repetitive messages, the system implements a cache-based suppression mechanism:
1. Maintains a cache of recent log messages
2. Compares incoming messages with cached ones
3. Suppresses messages that match cached entries within a timeout period

### Metrics Collection
The logging system collects metrics about log activity:
- Total count of logs by message type
- Metrics are exposed through the CMetrics subsystem

## Usage Examples

### Basic Logging Configuration
```c
// Create a logging context
struct flb_log *log = flb_log_create(config, FLB_LOG_STDERR, FLB_LOG_INFO, NULL);

// Set log level to debug
flb_log_set_level(config, FLB_LOG_DEBUG);

// Configure logging to a file
flb_log_set_file(config, "/var/log/fluent-bit.log");
```

### Using Logging Macros
```c
// Error logging
flb_error("Failed to connect to server: %s", strerror(errno));

// Warning logging
flb_warn("Configuration parameter '%s' is deprecated", param_name);

// Info logging
flb_info("Successfully loaded plugin: %s", plugin_name);

// Debug logging
flb_debug("Processing record with tag: %s", tag);

// Trace logging (when enabled)
flb_trace("Function entry: process_record()");
```

### Log Suppression
```c
// Check if a message should be suppressed before logging
if (!flb_log_suppress_check(10, "Connection attempt %d failed", attempt_count)) {
    flb_warn("Connection attempt %d failed: %s", attempt_count, strerror(errno));
}
```