# flb_engine_dispatch.c

## Overview

This file implements the task dispatch functionality for the Fluent Bit engine. It is responsible for converting input chunks into tasks and routing them to appropriate output plugins based on routing rules.

The dispatch module serves as the bridge between input plugins (which generate data chunks) and output plugins (which consume and process the data). It handles task creation, routing decisions, and initial task execution.

## Key Functions

### `flb_engine_dispatch()`
The main dispatch function that processes input chunks and creates tasks for routing to output plugins. This is the primary entry point for the dispatch system.

### `flb_engine_dispatch_retry()`
Handles retry operations for failed tasks by reprocessing chunks and resubmitting them to output plugins.

### `tasks_start()`
Processes newly created tasks, applying routing rules and initiating task execution for eligible output plugins.

### `test_run_formatter()`
Executes test mode formatters for output plugins, used during development and testing scenarios.

## Important Variables/Constants

### Task Creation Context
The dispatch process works with several key structures:
- `struct flb_input_chunk`: Input data chunks from plugins
- `struct flb_task`: Task structures representing work units
- `struct flb_task_route`: Routing information for task distribution
- `struct flb_test_out_formatter`: Test mode formatter callbacks

### Dispatch Flags
- `FLB_OUTPUT_SYNCHRONOUS`: Flag indicating synchronous output plugin operation
- `FLB_OUTPUT_NO_MULTIPLEX`: Flag preventing task multiplexing for certain plugins
- `FLB_TRUE`/`FLB_FALSE`: Standard boolean values for task status tracking

## Dependencies

- `fluent-bit/flb_info.h`: Fluent Bit core information
- `fluent-bit/flb_input.h`: Input plugin interface
- `fluent-bit/flb_input_chunk.h`: Input chunk management
- `fluent-bit/flb_output.h`: Output plugin interface
- `fluent-bit/flb_router.h`: Routing functionality
- `fluent-bit/flb_config.h`: Configuration management
- `fluent-bit/flb_coro.h`: Coroutine support
- `fluent-bit/flb_engine.h`: Engine interface
- `fluent-bit/flb_task.h`: Task management
- `fluent-bit/flb_event.h`: Event handling
- `chunkio/chunkio.h`: Chunk I/O operations

## Implementation Details

1. **Chunk Processing**: The dispatcher iterates through input chunks, identifying those ready for processing and converting them into tasks.

2. **Routing Decisions**: Uses the router to determine which output plugins should receive each task based on configuration rules.

3. **Multiplexing Support**: Handles both multiplexed (multiple concurrent tasks) and singleplexed (one task at a time) output plugin modes.

4. **Retry Handling**: Provides specialized retry processing that can bring chunks back into memory for reprocessing.

5. **Test Mode Support**: Includes functionality for running output plugins in test mode with custom formatter callbacks.

6. **Resource Management**: Carefully manages chunk locks and references to prevent data corruption during task creation.

7. **Error Recovery**: Implements graceful error handling for scenarios like memory exhaustion or task creation failures.

## Usage Example

```c
// During input plugin processing, when chunks are ready for dispatch
struct flb_input_instance *in = get_input_instance();
struct flb_config *config = get_config();

// Dispatch all ready chunks for this input instance
int ret = flb_engine_dispatch(0, in, config);
if (ret == -1) {
    flb_error("Failed to dispatch input chunks");
}

// For retry scenarios
struct flb_task_retry *retry = get_retry_context();
ret = flb_engine_dispatch_retry(retry, config);
if (ret == -1) {
    flb_error("Failed to dispatch retry");
}
```