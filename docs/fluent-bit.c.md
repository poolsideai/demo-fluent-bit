# fluent-bit.c

## Overview

The `fluent-bit.c` file is the main entry point for the Fluent Bit application. This module handles command-line argument parsing, configuration loading, signal handling, and the main execution loop. It serves as the core of the Fluent Bit daemon, coordinating all components including inputs, filters, processors, and outputs.

## Key Functions

### `flb_help`

```c
static void flb_help(int rc, struct flb_config *config)
```

Prints the command-line help text with available options and plugins.

- **Parameters**: 
  - `rc`: Exit code
  - `config`: Fluent Bit configuration context
- **Notes**: Displays categorized help for options, inputs, processors, filters, and outputs

### `flb_signal_handler`

```c
static void flb_signal_handler(int signal)
```

Handles incoming signals for graceful shutdown and reload operations.

- **Parameters**: 
  - `signal`: Signal number received
- **Handled Signals**: 
  - `SIGINT`: Interrupt signal (Ctrl+C)
  - `SIGQUIT`: Quit signal
  - `SIGHUP`: Hangup signal (reload configuration)
  - `SIGCONT`: Continue signal (dump status)
  - `SIGTERM`: Termination signal
  - `SIGSEGV`: Segmentation fault
  - `SIGFPE`: Floating-point exception

### `flb_signal_handler_break_loop`

```c
static void flb_signal_handler_break_loop(int signal)
```

Simple signal handler that sets the exit signal flag.

- **Parameters**: 
  - `signal`: Signal number received
- **Notes**: Used for immediate termination signals

### `flb_signal_handler_status_line`

```c
static void flb_signal_handler_status_line(struct flb_cf *cf_opts)
```

Prints formatted status line when signals are received.

- **Parameters**: 
  - `cf_opts`: Configuration format context
- **Notes**: Provides consistent timestamped logging for signal events

### `flb_signal_init`

```c
static void flb_signal_init()
```

Initializes signal handlers for the Fluent Bit process.

- **Notes**: Sets up handlers for various termination and control signals

### `flb_main_run`

```c
static int flb_main_run(int argc, char **argv)
```

Main execution function that runs the Fluent Bit daemon.

- **Parameters**: 
  - `argc`: Argument count
  - `argv`: Argument vector
- **Returns**: Exit status code
- **Process Flow**: 
  1. Parse command-line arguments
  2. Initialize configuration
  3. Load configuration files
  4. Start Fluent Bit engine
  5. Enter main event loop
  6. Handle signals and reloads
  7. Cleanup and exit

### `flb_main`

```c
int flb_main(int argc, char **argv)
```

Wrapper function that runs Fluent Bit under supervisor mode.

- **Parameters**: 
  - `argc`: Argument count
  - `argv`: Argument vector
- **Returns**: Exit status code
- **Notes**: Delegates to `flb_supervisor_run` for process management

### `main`

```c
int main(int argc, char **argv)
```

Standard C main function entry point.

- **Parameters**: 
  - `argc`: Argument count
  - `argv`: Argument vector
- **Returns**: Exit status code
- **Notes**: Platform-specific routing (Windows vs Unix)

## Command-Line Options

The application supports numerous command-line options for configuration:

### Configuration Options
- `-b, --storage_path=PATH`: Specify storage buffering path
- `-c, --config=FILE`: Specify configuration file
- `-D, --dry-run`: Test configuration without running
- `-f, --flush=SECONDS`: Set flush timeout (default: 1)
- `-l, --log_file=FILE`: Write logs to file
- `-w, --workdir`: Set working directory
- `-s, --coro_stack_size`: Set coroutine stack size
- `-q, --quiet`: Quiet mode (no logs)
- `-v, --verbose`: Increase logging verbosity
- `-V, --version`: Show version
- `-h, --help`: Print help

### Plugin Options
- `-C, --custom=CUSTOM`: Enable custom plugin
- `-i, --input=INPUT`: Set input plugin
- `-F, --filter=FILTER`: Set filter plugin
- `-o, --output=OUTPUT`: Set output plugin
- `-p, --prop="A=B"`: Set plugin property
- `-m, --match=MATCH`: Set plugin match pattern
- `-t, --tag=TAG`: Set plugin tag

### Advanced Options
- `-Y, --enable-hot-reload`: Enable hot reloading
- `-W, --disable-thread-safety-on-hot-reloading`: Disable thread safety for hot reload
- `-S, --sosreport`: Support report for enterprise
- `-H, --http`: Enable HTTP monitoring server
- `-P, --port`: Set HTTP server port
- `-Z, --enable-chunk-trace`: Enable chunk tracing
- `--trace`: Setup trace pipeline
- `--supervisor`: Run under supervising parent process
- `-J, --help-json`: Print help in JSON format

## Dependencies

- `<stdio.h>`: Standard I/O functions
- `<stdint.h>`: Standard integer types
- `<stdlib.h>`: Standard library functions
- `<string.h>`: String manipulation functions
- `<signal.h>`: Signal handling
- `<ctype.h>`: Character type functions
- `<cfl/cfl.h>`: CFL library core
- `<cfl/cfl_array.h>`: CFL array utilities
- `<cfl/cfl_kvlist.h>`: CFL key-value list utilities
- `<fluent-bit/flb_compat.h>`: Compatibility utilities
- `<fluent-bit/flb_info.h>`: Core information
- `<fluent-bit/flb_dump.h>`: Debug dumping utilities
- `<fluent-bit/flb_stacktrace.h>`: Stack trace utilities
- `<fluent-bit/flb_env.h>`: Environment utilities
- `<fluent-bit/flb_macros.h>`: Macro definitions
- `<fluent-bit/flb_utils.h>`: General utilities
- `<fluent-bit/flb_pack.h>`: Packing utilities
- `<fluent-bit/flb_meta.h>`: Metadata utilities
- `<fluent-bit/flb_config.h>`: Configuration management
- `<fluent-bit/flb_version.h>`: Version information
- `<fluent-bit/flb_error.h>`: Error handling
- `<fluent-bit/flb_custom.h>`: Custom plugins
- `<fluent-bit/flb_input.h>`: Input plugins
- `<fluent-bit/flb_output.h>`: Output plugins
- `<fluent-bit/flb_filter.h>`: Filter plugins
- `<fluent-bit/flb_processor.h>`: Processor plugins
- `<fluent-bit/flb_engine.h>`: Engine management
- `<fluent-bit/flb_str.h>`: String utilities
- `<fluent-bit/flb_slist.h>`: String list utilities
- `<fluent-bit/flb_plugin.h>`: Plugin management
- `<fluent-bit/flb_parser.h>`: Parser utilities
- `<fluent-bit/flb_lib.h>`: Library interface
- `<fluent-bit/flb_help.h>`: Help utilities
- `<fluent-bit/flb_record_accessor.h>`: Record accessor
- `<fluent-bit/flb_ra_key.h>`: Record accessor keys
- `<fluent-bit/flb_kv.h>`: Key-value utilities
- `<fluent-bit/flb_reload.h>`: Reload utilities
- `<fluent-bit/flb_config_format.h>`: Configuration format
- `<fluent-bit/flb_supervisor.h>`: Supervisor utilities
- `<fluent-bit/flb_chunk_trace.h>`: Chunk tracing (conditional)

## Implementation Details

1. **Configuration Management**: Supports both file-based and command-line configuration

2. **Signal Handling**: Comprehensive signal handling for graceful shutdown and reload

3. **Plugin Architecture**: Dynamic loading of input, filter, processor, and output plugins

4. **Supervisor Mode**: Optional supervising parent process for enhanced reliability

5. **Hot Reloading**: Runtime configuration reloading without restart

6. **Cross-Platform Support**: Handles both Unix and Windows platforms appropriately

7. **Memory Management**: Uses Fluent Bit's custom memory allocation functions

8. **Error Handling**: Consistent error reporting and handling throughout

9. **Logging**: Configurable logging levels and output destinations

10. **Chunk Tracing**: Optional detailed tracing for debugging data flow

## Usage Examples

### Basic usage with configuration file

```bash
fluent-bit -c /path/to/fluent-bit.conf
```

### Command-line configuration

```bash
fluent-bit -i cpu -o stdout -f 1 -v
```

### Dry run to test configuration

```bash
fluent-bit -c fluent-bit.conf -D
```

### Enable HTTP monitoring server

```bash
fluent-bit -c fluent-bit.conf -H -P 2020
```

### Hot reloading enabled

```bash
fluent-bit -c fluent-bit.conf -Y
```

### Verbose logging

```bash
fluent-bit -c fluent-bit.conf -vv
```

### Complex pipeline with multiple plugins

```bash
fluent-bit \
  -i tail -p path=/var/log/app.log -t app \
  -F grep -p regex=error -p exclude=false \
  -o http -p host=localhost -p port=8080 -p uri=/api/logs
```