# flb_config.c

## Overview

The `flb_config.c` file implements the core configuration management system for Fluent Bit. This module is responsible for:

- Initializing and managing the main configuration context
- Parsing configuration files and command-line options
- Managing plugin instances and their configurations
- Handling service-level settings and global parameters
- Memory management for configuration resources
- Integration with various subsystems (storage, routing, etc.)

The configuration system uses a hierarchical approach where service-level settings are defined in the `[SERVICE]` section, and plugin instances are defined in their respective sections (`[INPUT]`, `[FILTER]`, `[OUTPUT]`, etc.).

## Key Functions

### `flb_config_init`
Initializes a new Fluent Bit configuration context with default values:
- Flush interval: 1 second
- Daemon mode: disabled
- Verbose logging: info level (3)
- Grace period: 5 seconds
- Initializes all linked lists for plugins and instances
- Sets up environment and routing systems
- Registers static plugins

### `flb_config_exit`
Performs comprehensive cleanup of a configuration context:
- Destroys all plugin instances
- Frees memory for configuration strings
- Cleans up event loops and file descriptors
- Releases environment and routing resources
- Handles platform-specific cleanup (Windows, HTTP server, etc.)

### `flb_config_set_property`
Sets a service-level configuration property:
- Maps property names to internal configuration fields
- Handles type conversion (string to int, double, boolean)
- Supports environment variable substitution
- Validates property values before assignment

### `flb_config_load_config_format`
Loads configuration from a parsed configuration format structure:
- Processes environment variables
- Handles meta commands
- Configures plugin instances based on section definitions
- Sets up processors for input/output plugins

## Data Structures

### `struct flb_config`
The main configuration context containing:
- Service-level settings (flush, grace, daemon mode, etc.)
- Plugin management lists (inputs, filters, outputs, parsers)
- Environment and routing contexts
- Event loop and worker management
- Storage and chunk I/O configuration
- HTTP server settings (when enabled)
- Platform-specific configurations (Windows, DNS, etc.)

### `struct flb_service_config`
Defines service-level configuration properties with:
- Property key name
- Data type (int, double, bool, string)
- Memory offset within the configuration structure

## Configuration Properties

Service-level properties include:
- `Flush`: Interval in seconds between flush operations
- `Grace`: Maximum time in seconds to wait for pending operations on shutdown
- `Daemon`: Run in background mode
- `Log_Level`: Verbosity level (error, warn, info, debug, trace)
- `Parsers_File`: Path to parser configuration file
- `Plugins_File`: Path to external plugins configuration file
- `storage.*`: Chunk I/O buffering settings
- `dns.*`: DNS resolution configuration
- `coro_stack_size`: Coroutine stack size in bytes
- `http_server`: Enable HTTP monitoring server

## Dependencies

This module interacts with:
- `flb_cf`: Configuration format parsing
- `flb_env`: Environment variable handling
- `flb_plugins`: Plugin registration and management
- `flb_router`: Routing system
- `flb_storage`: Chunk I/O buffering
- `monkey/mk_core`: Event loop and core utilities
- Platform-specific modules (Windows, HTTP server, etc.)

## Implementation Details

The configuration system follows these principles:
1. **Hierarchical Structure**: Service settings at the top level, plugin instances below
2. **Lazy Initialization**: Resources allocated only when needed
3. **Memory Safety**: Comprehensive cleanup in `flb_config_exit`
4. **Extensibility**: Support for dynamic plugins and custom sections
5. **Environment Integration**: Automatic substitution of environment variables

Configuration loading involves:
1. Parsing configuration files or command-line arguments
2. Creating plugin instances based on section definitions
3. Applying property settings to each instance
4. Setting up routing and processing pipelines
5. Initializing subsystem components (storage, HTTP server, etc.)

## Usage Example

```c
// Initialize configuration
struct flb_config *config = flb_config_init();
if (!config) {
    flb_error("Failed to initialize configuration");
    return -1;
}

// Set service properties
flb_config_set_property(config, "Flush", "5");
flb_config_set_property(config, "Log_Level", "debug");
flb_config_set_property(config, "Parsers_File", "/etc/fluent-bit/parsers.conf");

// Load configuration from file
struct flb_cf *cf = flb_cf_load_file("/etc/fluent-bit/fluent-bit.conf");
flb_config_load_config_format(config, cf);

// Use configuration throughout the application
// ...

// Cleanup when done
flb_config_exit(config);
```