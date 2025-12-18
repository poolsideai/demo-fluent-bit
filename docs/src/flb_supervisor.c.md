# flb_supervisor.c

## Overview

The `flb_supervisor.c` file implements a process supervisor for Fluent Bit that allows the main process to monitor and manage a child Fluent Bit process. This supervisor provides features like automatic restart of crashed processes, graceful shutdown handling, and signal management.

The supervisor works by forking a child process that runs the actual Fluent Bit engine while the parent process monitors the child and handles signals appropriately. It uses a notice protocol to communicate with the child process about grace periods and shutdown status.

This module is particularly useful for production environments where automatic restart of crashed processes is desired, and graceful shutdown handling is important for data integrity.

## Key Functions

### `flb_supervisor_requested(int argc, char **argv)`
Checks if the supervisor mode is requested via command-line arguments by looking for the `--supervisor` flag.

### `flb_supervisor_run(int argc, char **argv, flb_supervisor_entry_fn entry)`
Main entry point for the supervisor. This function either runs the supervisor mode or directly executes the entry function if supervisor mode is not requested.

In supervisor mode:
1. Prepares sanitized command-line arguments by removing the `--supervisor` flag
2. Checks if already running in supervised mode via environment variable
3. Enters the supervision loop that monitors the child process

### `flb_supervisor_child_update_grace(int grace, int grace_input)`
Allows the child process to communicate its grace period settings to the supervisor.

### `flb_supervisor_child_signal_shutdown(int grace, int grace_input)`
Notifies the supervisor that the child process has started shutdown.

## Important Variables and Constants

### Constants
- `FLB_SUPERVISOR_DEFAULT_FORCE_TIMEOUT`: Default timeout (10 seconds) for forcing child process termination
- `FLB_SUPERVISOR_CHILD_TITLE`: Title used for the child process
- `FLB_SUPERVISOR_NOTICE_VERSION`: Version number for supervisor notice protocol

### Variables
- `sv_restart_requested`: Flag indicating if a restart has been requested
- `sv_stop_signal`: Signal that caused the stop request
- `sv_notify_fd`: File descriptor for communication pipe with child
- `sv_notice_bytes`: Number of bytes read from the notice pipe
- `sv_notice_buffer`: Buffer for storing notice messages from child
- `sv_grace_timeout`: Current grace timeout value
- `sv_shutdown_deadline`: Deadline for child process shutdown
- `sv_shutdown_window`: Window for child process shutdown
- `sv_child_grace`: Grace period for child service
- `sv_child_grace_input`: Grace period for child inputs
- `sv_child_notify_fd`: File descriptor for child to send notices

## Dependencies

This module depends on:
- Standard C library functions for process management (`fork`, `waitpid`, `kill`, etc.)
- Signal handling functions (`sigaction`, `signal`)
- File descriptor operations (`pipe`, `read`, `write`)
- Environment variable functions (`setenv`, `getenv`)
- Unix-specific functions (`fcntl`, `prctl` on Linux)
- Fluent Bit logging system (`flb_log.h`)
- Fluent Bit memory management (`flb_mem.h`)
- Fluent Bit info and macros (`flb_info.h`, `flb_macros.h`)
- Fluent Bit compatibility layer (`flb_compat.h`)

## Implementation Details

The supervisor works by:
1. Creating a pipe for communication between parent and child processes
2. Forking a child process that runs the actual Fluent Bit engine
3. Monitoring the child process and handling signals appropriately
4. Managing graceful shutdown with configurable timeouts
5. Automatically restarting the child process if it exits unexpectedly

### Notice Protocol

The supervisor uses a versioned notice protocol to communicate with the child process. This protocol allows the child to inform the supervisor about:
- Grace periods for different components
- Shutdown status and progress

The notice structure includes:
- Version number for protocol compatibility
- Command identifier (update grace period or shutdown notification)
- Grace period values for service and input components

### Signal Handling

The supervisor handles several signals:
- `SIGHUP`: Requests a restart of the child process
- `SIGTERM`, `SIGINT`, `SIGQUIT`: Trigger graceful shutdown of the child process

### Process Management

Key aspects of process management:
- Child processes are spawned with a specific title for identification
- Communication between parent and child occurs through a dedicated pipe
- Child processes can advertise their grace periods for proper shutdown timing
- Automatic restart occurs if the child exits with a non-zero status
- Forced termination is used as a last resort if graceful shutdown fails

## Usage Examples

To enable supervisor mode, run Fluent Bit with the `--supervisor` flag:

```bash
fluent-bit --supervisor
```

The supervisor will automatically restart the Fluent Bit process if it crashes, and handle graceful shutdown when receiving termination signals. The supervisor also respects the grace periods configured in the Fluent Bit configuration to ensure data is properly flushed before termination.

For programmatic usage, the supervisor can be integrated into custom applications by calling `flb_supervisor_run()` with appropriate entry point functions.

## Configuration Options

The supervisor behavior can be influenced by:
- Command-line arguments (`--supervisor`)
- Environment variables (`FLB_SUPERVISOR_NOTIFY_FD`, `FLB_SUPERVISOR_ACTIVE`)
- Fluent Bit configuration settings for grace periods

## Error Handling

The supervisor implements robust error handling:
- Failed pipe creation results in immediate termination
- Failed fork operations are logged and handled gracefully
- Communication errors with child processes trigger appropriate recovery actions
- Signal delivery failures are logged but don't necessarily terminate the supervisor

## Platform Support

The supervisor is implemented for Unix-like systems and includes fallback implementations for Windows platforms where process supervision is not supported.