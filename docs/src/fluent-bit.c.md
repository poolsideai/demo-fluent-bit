# fluent-bit.c Documentation

## Overview

The `fluent-bit.c` file contains the main entry point and core execution logic for the Fluent Bit application. This implementation handles command-line argument parsing, configuration loading, signal handling, and the main execution loop that drives the Fluent Bit engine.

Fluent Bit is a lightweight log processor and forwarder that collects logs from various sources, processes them, and forwards them to different destinations. This file serves as the foundation for the entire application.

## Key Features

- Main entry point for the Fluent Bit application
- Command-line argument parsing and validation
- Configuration file loading and processing
- Signal handling for graceful shutdown and reload
- Main execution loop with hot reload support
- Plugin help system and documentation generation
- Cross-platform compatibility (Linux, Windows, macOS)

## Data Structures

### Global Variables

Several global variables are used throughout the application:

- `ctx`: Main Fluent Bit context
- `config`: Fluent Bit configuration
- `exit_signal`: Signal received for shutdown
- `flb_bin_restarting`: Hot reload status
- `flb_st`: Stack trace context (when enabled)

### Constants

Various constants define plugin types and help formats:

```c
#define PLUGIN_CUSTOM    0
#define PLUGIN_INPUT     1
#define PLUGIN_PROCESSOR 2
#define PLUGIN_FILTER    3
#define PLUGIN_OUTPUT    4

#define FLB_HELP_TEXT    0
#define FLB_HELP_JSON    1
```

## Key Functions

### flb_main()

```c
int flb_main(int argc, char **argv);
```

Main entry point that initializes and runs Fluent Bit.

**Parameters:**
- `argc`: Number of command-line arguments
- `argv`: Array of command-line arguments

**Returns:**
- Exit status code

### flb_main_run()

```c
static int flb_main_run(int argc, char **argv);
```

Core execution function that handles all Fluent Bit operations.

**Parameters:**
- `argc`: Number of command-line arguments
- `argv`: Array of command-line arguments

**Returns:**
- Exit status code

### flb_help()

```c
static void flb_help(int rc, struct flb_config *config);
```

Displays help information for the Fluent Bit command-line interface.

**Parameters:**
- `rc`: Exit code
- `config`: Fluent Bit configuration

### flb_signal_handler()

```c
static void flb_signal_handler(int signal);
```

Handles various signals sent to the Fluent Bit process.

**Parameters:**
- `signal`: Signal number received

### flb_signal_exit()

```c
static void flb_signal_exit(int signal);
```

Handles exit signals and performs cleanup.

**Parameters:**
- `signal`: Signal number received

## Implementation Details

### Command-Line Argument Parsing

The application uses `getopt_long()` to parse command-line arguments:

1. **Long Options**: Supports both short (`-v`) and long (`--verbose`) options
2. **Plugin Configuration**: Allows configuring input/output/filter plugins directly from command line
3. **Configuration Files**: Can load configuration from files
4. **Help System**: Provides detailed help for the application and individual plugins

### Configuration Loading

Configuration is loaded through multiple mechanisms:

1. **Command Line**: Direct plugin configuration via `-i`, `-o`, `-F` options
2. **Configuration Files**: Loading `.conf` files with `flb_cf_create_from_file()`
3. **Static Configuration**: Embedded configuration for static builds
4. **Environment Variables**: Automatic detection of environment variables

### Signal Handling

The application handles several signals:

- **SIGINT/SIGTERM**: Graceful shutdown
- **SIGHUP**: Configuration reload
- **SIGCONT**: Dump current configuration
- **SIGSEGV/SIGFPE**: Crash handling with stack traces
- **Windows Ctrl+C/Break**: Windows-specific signal handling

### Main Execution Loop

The core execution loop performs these operations:

1. **Initialization**: Sets up the Fluent Bit context and starts the engine
2. **Hot Reload Monitoring**: Checks for reload requests
3. **Signal Processing**: Handles received signals
4. **Cleanup**: Proper shutdown and resource cleanup

### Plugin Help System

The application provides comprehensive help for plugins:

1. **Text Format**: Human-readable help output
2. **JSON Format**: Machine-readable help for programmatic access
3. **Plugin-Specific**: Detailed help for individual input/output/filter plugins
4. **Property Documentation**: Shows plugin configuration properties

### Cross-Platform Compatibility

Special handling for different platforms:

1. **Windows**: Uses `SetConsoleCtrlHandler` for signal simulation
2. **Linux/macOS**: Standard POSIX signal handling
3. **Daemon Mode**: Background execution support
4. **Supervisor Mode**: Parent process supervision

## Usage Examples

### Basic Usage

```bash
# Run with default configuration
fluent-bit

# Run with specific configuration file
fluent-bit -c /path/to/fluent-bit.conf

# Run in daemon mode
fluent-bit -d

# Enable verbose logging
fluent-bit -v
```

### Command Line Configuration

```bash
# Configure input and output directly
fluent-bit \ 
  -i cpu \ 
  -o stdout \ 
  -p format=json

# Set flush interval
fluent-bit -f 5

# Enable HTTP monitoring server
fluent-bit -H
```

### Plugin Help

```bash
# Show general help
fluent-bit -h

# Show help for specific plugin
fluent-bit -i cpu -h

# Show JSON help for plugin
fluent-bit -i cpu -J
```

### Hot Reload

```bash
# Send SIGHUP to reload configuration
kill -HUP $(cat /var/run/fluent-bit.pid)

# Or use supervisor mode for automatic reload
fluent-bit --supervisor
```

### C Code Example

```c
#include <fluent-bit/flb_lib.h>
#include <fluent-bit/flb_info.h>

int main(int argc, char **argv) {
    // This is essentially what fluent-bit.c does
    return flb_main(argc, argv);
}
```

## Integration with Fluent Bit Components

The main application integrates with all Fluent Bit components:

1. **Engine**: Starts and manages the Fluent Bit engine
2. **Configuration**: Loads and validates configuration
3. **Plugins**: Initializes and manages all plugin types
4. **Logging**: Handles application-level logging
5. **Storage**: Initializes storage subsystem
6. **HTTP Server**: Starts monitoring HTTP server when enabled
7. **Metrics**: Initializes metrics collection

## Error Handling

The application follows robust error handling practices:

- **Early Validation**: Validates configuration and arguments early
- **Graceful Degradation**: Continues operation when possible after errors
- **Proper Cleanup**: Ensures resources are freed on exit
- **User Feedback**: Provides clear error messages to users
- **Signal Safety**: Handles signals safely during critical operations

## Security Considerations

The main application implements several security measures:

- **Input Validation**: Validates all command-line arguments and configuration
- **Privilege Dropping**: Can run with reduced privileges
- **Secure Defaults**: Uses secure default configurations
- **Resource Limits**: Respects system resource limits
- **Signal Handling**: Secure signal handling to prevent exploitation

## Performance Considerations

The implementation is optimized for:

- **Startup Time**: Fast initialization and configuration loading
- **Memory Usage**: Efficient memory management
- **Event Loop**: Non-blocking event-driven architecture
- **Concurrency**: Proper thread management for multi-core systems
- **Scalability**: Handles large numbers of inputs/outputs/filters

## Debugging and Development

Several features aid in debugging and development:

- **Verbose Logging**: Multiple verbosity levels
- **Dry Run Mode**: Tests configuration without processing data
- **Stack Traces**: Detailed crash information when enabled
- **Dump Functionality**: Dumps current configuration state
- **Trace Mode**: Detailed execution tracing

## Exit Codes

The application returns specific exit codes:

- `0`: Success
- `1`: General error
- `2`: Misuse of shell builtins
- `126`: Command invoked cannot execute
- `127`: Command not found
- `128+n`: Fatal error signal n
- `130`: Script terminated by Control-C
- `255`: Exit status out of range