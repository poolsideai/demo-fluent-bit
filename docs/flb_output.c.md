# flb_output.c

## Overview

This file implements the core output plugin system for Fluent Bit. It provides the infrastructure for managing output plugins, handling data delivery, implementing retry mechanisms, and coordinating between input and output components. The output system is responsible for routing processed data to its final destinations.

## Key Functions

### flb_output_get_global_config_map

Returns the global configuration map for output plugins.

**Parameters:**
- `config`: Fluent Bit configuration context

**Returns:** Pointer to the global configuration map

### flb_output_prepare

Prepares the output system by initializing thread-local storage.

### check_protocol

Validates the protocol of an output address.

**Parameters:**
- `prot`: Expected protocol
- `output`: Output address string

**Returns:** 1 if protocol matches, 0 otherwise

### flb_output_pre_run

Invokes pre-run callbacks for all output plugins.

**Parameters:**
- `config`: Fluent Bit configuration context

### flb_output_free_properties

Frees properties associated with an output instance.

**Parameters:**
- `ins`: Output instance

### flb_output_flush_prepare_destroy

Prepares an output flush context for destruction.

**Parameters:**
- `out_flush`: Output flush context

### flb_output_flush_id_get

Gets a unique flush ID for an output instance.

**Parameters:**
- `ins`: Output instance

**Returns:** Unique flush ID

### flb_output_coro_add

Adds a coroutine to an output instance's flush list.

**Parameters:**
- `ins`: Output instance
- `coro`: Coroutine to add

### flb_output_task_queue_enqueue

Queues a task for flushing at a later time.

**Parameters:**
- `queue`: Task queue
- `retry`: Retry context
- `task`: Task to queue
- `out_ins`: Output instance
- `config`: Fluent Bit configuration context

**Returns:** 0 on success, -1 on failure

### flb_output_task_queue_flush_one

Flushes one task from the pending queue.

**Parameters:**
- `queue`: Task queue

**Returns:** 0 on success, -1 on failure

### flb_output_task_singleplex_enqueue

Enqueues a task for singleplex mode (synchronous flushing).

**Parameters:**
- `queue`: Task queue
- `retry`: Retry context
- `task`: Task to queue
- `out_ins`: Output instance
- `config`: Fluent Bit configuration context

**Returns:** 0 on success, -1 on failure

### flb_output_task_singleplex_flush_next

Clears the in-progress task and flushes the next queued task.

**Parameters:**
- `queue`: Task queue

**Returns:** 0 on success, -1 on failure

### flb_output_task_flush

Flushes a task through the output plugin.

**Parameters:**
- `task`: Task to flush
- `out_ins`: Output instance
- `config`: Fluent Bit configuration context

**Returns:** 0 on success, -1 on failure

### flb_output_instance_destroy

Destroys an output instance and frees all associated resources.

**Parameters:**
- `ins`: Output instance

**Returns:** 0 on success

## Dependencies

- `<stdio.h>`: Standard I/O functions
- `<stdlib.h>`: Standard library functions
- `<string.h>`: String manipulation functions
- `<fluent-bit/flb_info.h>`: Core Fluent Bit header
- `<fluent-bit/flb_mem.h>`: Memory management utilities
- `<fluent-bit/flb_str.h>`: String utilities
- `<fluent-bit/flb_env.h>`: Environment management
- `<fluent-bit/flb_coro.h>`: Coroutine utilities
- `<fluent-bit/flb_output.h>`: Output plugin interface
- `<fluent-bit/flb_kv.h>`: Key-value utilities
- `<fluent-bit/flb_io.h>`: I/O utilities
- `<fluent-bit/flb_uri.h>`: URI utilities
- `<fluent-bit/flb_config.h>`: Configuration management
- `<fluent-bit/flb_macros.h>`: Macro definitions
- `<fluent-bit/flb_utils.h>`: Utility functions
- `<fluent-bit/flb_plugin.h>`: Plugin interface
- `<fluent-bit/flb_plugin_proxy.h>`: Plugin proxy interface
- `<fluent-bit/flb_http_client_debug.h>`: HTTP client debugging
- `<fluent-bit/flb_output_thread.h>`: Output thread utilities
- `<fluent-bit/flb_mp.h>`: MessagePack utilities
- `<fluent-bit/flb_pack.h>`: Packing utilities

## Important Variables

### output_latency_buckets

Defines histogram buckets for output latency metrics in seconds.

### output_global_properties

Configuration map defining global properties for output plugins.

## Implementation Details

The output system implements several key mechanisms:

1. **Task Management**: Tasks represent units of work that need to be delivered to output destinations. The system manages task queues for both regular and retry scenarios.

2. **Threading Support**: Output plugins can run in threaded mode using a thread pool, or in synchronous mode where tasks are processed sequentially.

3. **Retry Mechanism**: Failed deliveries are automatically retried according to configurable limits. The system maintains retry contexts and queues for failed tasks.

4. **Singleplex Mode**: For synchronous output plugins, the system ensures only one task is processed at a time to maintain ordering guarantees.

5. **Resource Management**: Proper cleanup of resources including URIs, TLS contexts, metrics, and configuration maps.

6. **Metrics Collection**: Built-in support for collecting output-related metrics including latency histograms.

7. **Protocol Validation**: Ensures output addresses use valid protocols.

The system uses coroutines for asynchronous task processing and provides mechanisms for both immediate delivery and queued delivery of tasks.

## Usage Examples

```c
// Create an output instance
struct flb_output_instance *ins = flb_output_instance_create(config, "stdout", NULL);

// Configure the output
flb_output_instance_set_property(ins, "format", "json");

// Register the output with the configuration
mk_list_add(&ins->_head, &config->outputs);

// Process tasks through the output
struct flb_task *task;  // Assume task is created elsewhere
int result = flb_output_task_flush(task, ins, config);

if (result == 0) {
    // Task was successfully flushed
} else {
    // Task failed, will be retried according to retry policy
}

// Clean up when done
flb_output_instance_destroy(ins);
```