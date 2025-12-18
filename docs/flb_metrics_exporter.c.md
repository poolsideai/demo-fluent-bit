# flb_metrics_exporter.c

## Overview

This file implements the metrics exporter system for Fluent Bit. It periodically collects metrics from all components (inputs, filters, outputs) and exports them through various mechanisms including the built-in HTTP server.

## Key Functions

### collect_inputs

Collects metrics from all input instances and serializes them in MessagePack format.

**Parameters:**
- `mp_sbuf`: MessagePack sbuffer for serialization
- `mp_pck`: MessagePack packer
- `ctx`: Fluent Bit configuration context

**Returns:** 0 on success

### collect_filters

Collects metrics from all filter instances and serializes them in MessagePack format.

**Parameters:**
- `mp_sbuf`: MessagePack sbuffer for serialization
- `mp_pck`: MessagePack packer
- `ctx`: Fluent Bit configuration context

**Returns:** 0 on success

### collect_outputs

Collects metrics from all output instances and serializes them in MessagePack format.

**Parameters:**
- `mp_sbuf`: MessagePack sbuffer for serialization
- `mp_pck`: MessagePack packer
- `ctx`: Fluent Bit configuration context

**Returns:** 0 on success

### collect_metrics

Main function that orchestrates collection of all metrics and pushes them to the HTTP server if enabled.

**Parameters:**
- `me`: Metrics exporter context

**Returns:** 0 on success

### flb_me_create

Creates a new metrics exporter context and registers it with the event loop.

**Parameters:**
- `ctx`: Fluent Bit configuration context

**Returns:** Pointer to the created metrics exporter context, or NULL on failure

### flb_me_fd_event

Handles event loop notifications for metrics collection.

**Parameters:**
- `fd`: File descriptor of the timer event
- `me`: Metrics exporter context

**Returns:** 0 on success, -1 on failure

### flb_me_destroy

Destroys a metrics exporter context and cleans up resources.

**Parameters:**
- `me`: Metrics exporter context

**Returns:** 0 on success

### flb_me_get_cmetrics

Exports all metrics as a CMetrics context for modern Prometheus-style metrics.

**Parameters:**
- `ctx`: Fluent Bit configuration context

**Returns:** Pointer to the CMetrics context, or NULL on failure

## Dependencies

- `<fluent-bit/flb_info.h>`: Core Fluent Bit header
- `<fluent-bit/flb_mem.h>`: Memory management utilities
- `<fluent-bit/flb_utils.h>`: Utility functions
- `<fluent-bit/flb_config.h>`: Configuration management
- `<fluent-bit/flb_input.h>`: Input plugin interface
- `<fluent-bit/flb_output.h>`: Output plugin interface
- `<fluent-bit/flb_pack.h>`: Packing utilities
- `<fluent-bit/flb_http_server.h>`: HTTP server interface
- `<fluent-bit/flb_storage.h>`: Storage interface
- `<fluent-bit/flb_metrics.h>`: Metrics interface
- `<fluent-bit/flb_metrics_exporter.h>`: Metrics exporter interface

## Implementation Details

The metrics exporter runs as a periodic task in the main event loop, collecting metrics every second. It handles three types of metrics:

1. **Legacy metrics** (/v1/metrics): Collected from input, filter, and output instances and serialized in MessagePack format
2. **Health metrics** (/v1/health): Pushed to the HTTP server for health checking
3. **Modern metrics** (/v2/metrics): Collected using the CMetrics library for Prometheus-style metrics

The system collects metrics from:
- Input instances
- Filter instances
- Output instances
- Storage subsystem
- Global log metrics
- Processor units

When the built-in HTTP server is enabled, collected metrics are pushed to appropriate endpoints for consumption by monitoring systems.

## Usage Examples

```c
// Create metrics exporter
struct flb_me *me = flb_me_create(config);

// The exporter will automatically collect metrics every second
// Metrics can be accessed via:
// - /v1/metrics (legacy MessagePack format)
// - /v1/health (health check endpoint)
// - /v2/metrics (modern Prometheus format)

// Destroy when done
flb_me_destroy(me);
```