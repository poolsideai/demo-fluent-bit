# libbacktrace Documentation

## Overview

libbacktrace is a C library that may be linked into a C/C++ program to produce symbolic backtraces. It was initially written by Ian Lance Taylor and is provided under a BSD license.

The library is designed to be used for producing detailed backtraces when errors occur or for gathering detailed profiling information. The functions provided by this library are async-signal-safe, meaning that they may be safely called from a signal handler.

As of October 2020, libbacktrace supports ELF, PE/COFF, Mach-O, and XCOFF executables with DWARF debugging information, supporting GNU/Linux, *BSD, macOS, Windows, and AIX.

## Key Functions

### `backtrace_create_state`
Creates state information for the backtrace routines. This must be called before any of the other routines, and its return value must be passed to all of the other routines.

Parameters:
- `filename`: Path name of the executable file; if NULL the library will try system-specific path names
- `threaded`: Non-zero if the state may be accessed by multiple threads simultaneously
- `error_callback`: Callback function for error cases
- `data`: Data passed to the error callback

Returns: A state pointer on success, NULL on error.

### `backtrace_full`
Gets a full stack backtrace with detailed information including filenames, line numbers, and function names.

Parameters:
- `state`: State pointer returned by `backtrace_create_state`
- `skip`: Number of frames to skip
- `callback`: Callback function to receive backtrace information
- `error_callback`: Callback function for error cases
- `data`: Data passed to the callbacks

Returns: 0 on success, non-zero on error.

### `backtrace_simple`
Gets a simple backtrace with just program counters.

Parameters:
- `state`: State pointer returned by `backtrace_create_state`
- `skip`: Number of frames to skip
- `callback`: Callback function to receive program counters
- `error_callback`: Callback function for error cases
- `data`: Data passed to the callbacks

Returns: 0 on success, non-zero on error.

### `backtrace_print`
Prints the current backtrace in a user-readable format to a FILE.

Parameters:
- `state`: State pointer returned by `backtrace_create_state`
- `skip`: Number of frames to skip
- `file`: FILE pointer to write the backtrace to

### `backtrace_pcinfo`
Given a program counter, calls the callback function with filename, line number, and function name information.

Parameters:
- `state`: State pointer returned by `backtrace_create_state`
- `pc`: Program counter
- `callback`: Callback function to receive information
- `error_callback`: Callback function for error cases
- `data`: Data passed to the callbacks

Returns: 0 on success, non-zero on error.

### `backtrace_syminfo`
Given an address, calls the callback function with symbol name and value information.

Parameters:
- `state`: State pointer returned by `backtrace_create_state`
- `addr`: Address in the current program
- `callback`: Callback function to receive symbol information
- `error_callback`: Callback function for error cases
- `data`: Data passed to the callbacks

Returns: 1 on success, 0 on error.

## Usage Notes

1. Always call `backtrace_create_state` first to initialize the library
2. The library requires DWARF debugging information for full functionality
3. For simple backtraces that don't require debug info, use `backtrace_simple`
4. For detailed backtraces with filenames and line numbers, use `backtrace_full`
5. The library is async-signal-safe and can be used in signal handlers

## Example Usage

```c
#include <backtrace.h>
#include <stdio.h>

void error_callback(void *data, const char *msg, int errnum) {
    fprintf(stderr, "Error: %s\n", msg);
}

int main() {
    struct backtrace_state *state;
    
    // Initialize the library
    state = backtrace_create_state(NULL, 0, error_callback, NULL);
    if (!state) {
        fprintf(stderr, "Failed to create backtrace state\n");
        return 1;
    }
    
    // Print backtrace to stdout
    backtrace_print(state, 0, stdout);
    
    return 0;
}
```