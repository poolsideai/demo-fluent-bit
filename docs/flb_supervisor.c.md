# flb_supervisor.c

## Overview

This file implements the supervisor functionality for Fluent Bit, providing process management and monitoring capabilities. The supervisor runs as a parent process that monitors and manages a child Fluent Bit process.

The supervisor is responsible for:
- Process lifecycle management (starting, stopping, restarting child processes)
- Graceful shutdown handling with configurable timeouts
- Signal handling for various termination scenarios
- Inter-process communication through pipes for status updates
- Automatic restart of child processes when they terminate unexpectedly

The supervisor operates in two modes:
1. Parent mode: Monitors the child process and handles signals
2. Child mode: Runs the actual Fluent Bit engine with supervisor awareness

## Key Functions

### `flb_supervisor_requested()`
Checks if the supervisor mode was requested through command line arguments.

### `flb_supervisor_run()`
Main entry point for the supervisor functionality. Determines whether to run in parent or child mode and executes accordingly.

### `flb_supervisor_child_update_grace()`
Allows the child process to communicate its graceful shutdown timeout requirements to the parent supervisor.

### `flb_supervisor_child_signal_shutdown()`
Signals to the parent supervisor that the child process is beginning its shutdown sequence.

### `supervisor_supervise_loop()`
The main supervision loop that monitors the child process and handles restart scenarios.

### `supervisor_spawn()`
Creates a new child process with proper environment setup and inter-process communication pipes.

## Important Variables/Constants

### Supervisor Configuration
- `FLB_SUPERVISOR_DEFAULT_FORCE_TIMEOUT`: Default timeout for forced child process termination (10 seconds)
- `FLB_SUPERVISOR_CHILD_TITLE`: Process name for child Fluent Bit processes
- `FLB_SUPERVISOR_NOTICE_VERSION`: Version identifier for inter-process communication messages

### Process Management
- `sv_restart_requested`: Flag indicating a restart has been requested
- `sv_stop_signal`: Signal that triggered process termination
- `sv_notify_fd`: File descriptor for inter-process communication pipe
- `sv_grace_timeout`: Configured timeout for graceful shutdown
- `sv_shutdown_deadline`: Absolute time when forced termination will occur

### Notice Communication
- `struct flb_supervisor_notice`: Structure for inter-process communication messages
- `FLB_SUPERVISOR_NOTICE_COMMAND_UPDATE_GRACE`: Command for updating grace period settings
- `FLB_SUPERVISOR_NOTICE_COMMAND_SHUTTING_DOWN`: Command for signaling shutdown initiation

## Dependencies

- Standard C library headers for process management, signals, and file operations
- Platform-specific headers for Linux process naming (`prctl`)
- Fluent Bit core components:
  - `flb_info.h`: Core information and logging
  - `flb_macros.h`: Macro definitions
  - `flb_supervisor.h`: Supervisor interface
  - `flb_log.h`: Logging functionality
  - `flb_mem.h`: Memory management utilities
  - `flb_compat.h`: Compatibility layer

## Implementation Details

1. **Inter-Process Communication**: Uses pipes for communication between parent supervisor and child process. Child sends structured notices about its state and shutdown requirements.

2. **Graceful Shutdown Handling**: Implements configurable grace periods for clean shutdown. If a child doesn't terminate within the grace period, it's forcibly killed with SIGKILL.

3. **Automatic Restart**: Monitors child process termination and automatically restarts it unless a stop signal was received.

4. **Signal Management**: Handles SIGHUP (restart), SIGTERM, SIGINT, and SIGQUIT for proper process lifecycle control.

5. **Platform Support**: Full functionality on Unix-like systems. Limited functionality on Windows platforms.

6. **Process Isolation**: Child processes run with isolated environments and proper resource cleanup.

## Usage Example

```c
// Check if supervisor mode was requested
if (flb_supervisor_requested(argc, argv)) {
    // Run with supervisor mode
    return flb_supervisor_run(argc, argv, main_entry_point);
}

// Normal execution without supervisor
return main_entry_point(argc, argv);
```

Configuration example:
```bash
# Enable supervisor mode with custom grace period
fluent-bit --supervisor --config fluent-bit.conf
```