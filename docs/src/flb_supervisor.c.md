# flb_supervisor.c

## Overview

The `flb_supervisor.c` file implements a process supervisor for Fluent Bit that allows the main process to monitor and manage a child Fluent Bit process. This supervisor provides features like automatic restart of crashed processes, graceful shutdown handling, and signal management.

## Key Functions

### `flb_supervisor_requested(int argc, char **argv)`
Checks if the supervisor mode is requested via command-line arguments.

### `flb_supervisor_run(int argc, char **argv, flb_supervisor_entry_fn entry)`
Main entry point for the supervisor. This function either runs the supervisor mode or directly executes the entry function if supervisor mode is not requested.

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
- `sv_grace_timeout`: Current grace timeout value
- `sv_shutdown_deadline`: Deadline for child process shutdown

## Dependencies

This module depends on:
- Standard C library functions for process management (`fork`, `waitpid`, `kill`, etc.)
- Signal handling functions (`sigaction`, `signal`)
- File descriptor operations (`pipe`, `read`, `write`)
- Environment variable functions (`setenv`, `getenv`)
- Fluent Bit logging system (`flb_log.h`)
- Fluent Bit memory management (`flb_mem.h`)

## Implementation Details

The supervisor works by:
1. Creating a pipe for communication between parent and child processes
2. Forking a child process that runs the actual Fluent Bit engine
3. Monitoring the child process and handling signals appropriately
4. Managing graceful shutdown with configurable timeouts
5. Automatically restarting the child process if it exits unexpectedly

The supervisor uses a notice protocol to communicate with the child process about grace periods and shutdown status. This protocol uses a versioned structure that can be extended in the future.

## Usage Examples

To enable supervisor mode, run Fluent Bit with the `--supervisor` flag:

```bash
fluent-bit --supervisor
```

The supervisor will automatically restart the Fluent Bit process if it crashes, and handle graceful shutdown when receiving termination signals.