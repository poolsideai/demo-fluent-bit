# flb_notification.c

## Overview

This file implements the notification system for Fluent Bit plugins. It provides mechanisms for plugins to send notifications to each other and to the core engine. Notifications are used for inter-plugin communication, event signaling, and coordination between different components of the Fluent Bit pipeline.

## Key Functions

### flb_notification_enqueue

Enqueues a notification for delivery to a specific plugin instance.

**Parameters:**
- `plugin_type`: Type of plugin (input, output, filter, processor) or -1 to search all types
- `instance_name`: Name of the plugin instance to receive the notification
- `notification`: Notification structure to deliver
- `config`: Fluent Bit configuration context

**Returns:** 0 on success, -1 on failure

### flb_notification_receive

Receives a notification from a notification channel.

**Parameters:**
- `channel`: Pipe file descriptor for the notification channel
- `notification`: Pointer to store the received notification

**Returns:** 0 on success, -1 on failure

### flb_notification_deliver

Delivers a notification to the appropriate plugin callback function.

**Parameters:**
- `notification`: Notification to deliver

**Returns:** 0 on success, negative values for specific errors

### flb_notification_cleanup

Cleans up resources associated with a notification.

**Parameters:**
- `notification`: Notification to clean up

### find_input_instance

Finds an input plugin instance by name.

**Parameters:**
- `name`: Name of the input instance
- `config`: Fluent Bit configuration context

**Returns:** Pointer to the input instance, or NULL if not found

### find_output_instance

Finds an output plugin instance by name.

**Parameters:**
- `name`: Name of the output instance
- `config`: Fluent Bit configuration context

**Returns:** Pointer to the output instance, or NULL if not found

### find_filter_instance

Finds a filter plugin instance by name.

**Parameters:**
- `name`: Name of the filter instance
- `config`: Fluent Bit configuration context

**Returns:** Pointer to the filter instance, or NULL if not found

### find_processor_instance

Finds a processor instance by name.

**Parameters:**
- `name`: Name of the processor instance
- `plugin_type`: Pointer to store the plugin type
- `config`: Fluent Bit configuration context

**Returns:** Pointer to the processor instance, or NULL if not found

## Dependencies

- `<monkey/mk_core.h>`: Monkey core library
- `<fluent-bit/flb_info.h>`: Core Fluent Bit header
- `<fluent-bit/flb_plugin.h>`: Plugin interface
- `<fluent-bit/flb_input.h>`: Input plugin interface
- `<fluent-bit/flb_filter.h>`: Filter plugin interface
- `<fluent-bit/flb_output.h>`: Output plugin interface
- `<fluent-bit/flb_engine.h>`: Engine interface
- `<fluent-bit/flb_notification.h>`: Notification interface header

## Implementation Details

The notification system uses Unix pipes for inter-process communication between plugins:

1. **Plugin Discovery**: Functions to find plugin instances by name across all plugin types (input, output, filter, processor)

2. **Notification Enqueuing**: The `flb_notification_enqueue` function finds the target plugin instance and sends the notification through its dedicated notification channel (pipe)

3. **Notification Delivery**: The `flb_notification_deliver` function routes notifications to the appropriate plugin callback based on the plugin type

4. **Error Handling**: Comprehensive error checking for missing plugins, failed deliveries, and invalid notifications

Each plugin instance has its own notification channel (pipe) for receiving notifications. The system supports automatic plugin type detection when the type is not explicitly specified.

Processor instances require special handling as they can be nested within input and output instances. The system searches through processor units to find the correct instance.

## Usage Examples

```c
// Enqueue a notification to an output plugin
struct flb_notification *notification = flb_malloc(sizeof(struct flb_notification));
// ... initialize notification fields ...

int result = flb_notification_enqueue(FLB_PLUGIN_OUTPUT, 
                                      "my_output_instance",
                                      notification,
                                      config);

if (result == 0) {
    // Notification was successfully enqueued
    // The target plugin will receive it via its notification channel
}

// Receive a notification in a plugin
struct flb_notification *received_notification;
result = flb_notification_receive(plugin_instance->notification_channel,
                                  &received_notification);

if (result == 0) {
    // Process the notification
    // ... handle notification ...
    
    // Clean up when done
    flb_notification_cleanup(received_notification);
}

// Deliver a notification to a plugin's callback
result = flb_notification_deliver(notification);
if (result == 0) {
    // Notification was successfully delivered
} else if (result == -3) {
    // Plugin doesn't have a notification callback
}
```