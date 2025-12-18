# flb_dlfcn_win32.c

## Overview

The `flb_dlfcn_win32.c` file provides Windows-compatible implementations of the POSIX dynamic linking functions (`dlopen`, `dlsym`, `dlclose`, and `dlerror`). This implementation bridges the gap between Unix-style dynamic library loading and Windows DLL loading mechanisms, allowing Fluent Bit to use a consistent API across different platforms.

This compatibility layer is essential for Fluent Bit's plugin architecture, which relies on dynamic library loading to load input, filter, and output plugins at runtime. On Windows systems, this implementation translates POSIX calls to their Windows equivalents using the Win32 API.

## Key Functions

### `dlopen`
Loads a dynamic library (DLL) on Windows systems:
- Takes a filename and loading flag (ignored on Windows)
- Uses `LoadLibrary()` to load the DLL
- Stores error information if loading fails
- Returns handle to loaded library or NULL on failure

### `dlsym`
Retrieves the address of a symbol (function or variable) from a loaded library:
- Takes library handle and symbol name
- Uses `GetProcAddress()` to find the symbol
- Stores error information if symbol lookup fails
- Returns pointer to symbol or NULL on failure

### `dlclose`
Unloads a previously loaded dynamic library:
- Takes library handle
- Uses `FreeLibrary()` to unload the DLL
- Stores error information if unloading fails
- Returns 0 on success, non-zero on failure

### `dlerror`
Returns error message from last failed dynamic linking operation:
- Returns formatted error message string
- Returns NULL on subsequent calls (POSIX behavior)
- Uses `GetLastError()` and `FormatMessageA()` to create human-readable errors

## Implementation Details

### Error Handling
The implementation follows POSIX conventions for error reporting:
- Errors are stored internally after failed operations
- `dlerror()` returns the error message on first call after error
- Subsequent calls to `dlerror()` return NULL (no error)
- Uses Windows `GetLastError()` to retrieve system error codes
- Uses `FormatMessageA()` to convert error codes to readable strings

### Platform Differences
Key differences between POSIX and Windows implementations:
- **Loading**: `LoadLibrary()` vs `dlopen()`
- **Symbol Lookup**: `GetProcAddress()` vs `dlsym()`
- **Unloading**: `FreeLibrary()` vs `dlclose()`
- **Error Reporting**: Windows error codes vs POSIX errno
- **Return Values**: Boolean success/failure vs integer codes

### Function Signatures
The Windows implementation maintains POSIX-compatible function signatures:
```c
void *dlopen(const char *filename, int _flag);
char *dlerror(void);
void *dlsym(void *handle, const char *name);
int dlclose(void *handle);
```

Note that the `_flag` parameter in `dlopen()` is ignored on Windows since Windows loading behavior doesn't require the lazy/now distinction that POSIX systems use.

## Dependencies

This module depends on:
- Windows Win32 API (`windows.h`)
- `GetLastError()`, `FormatMessageA()`, `LoadLibrary()`, `GetProcAddress()`, `FreeLibrary()`
- Standard C library string functions

## Usage Example

```c
// Load a plugin library
void *handle = dlopen("my_plugin.so", RTLD_LAZY);
if (!handle) {
    flb_error("Failed to load plugin: %s", dlerror());
    return -1;
}

// Get symbol address
int (*plugin_init)(void) = (int (*)(void)) dlsym(handle, "plugin_init");
if (!plugin_init) {
    flb_error("Failed to find plugin_init: %s", dlerror());
    dlclose(handle);
    return -1;
}

// Call plugin function
if (plugin_init() != 0) {
    flb_error("Plugin initialization failed");
    dlclose(handle);
    return -1;
}

// Later, unload the library
dlclose(handle);
```

## Error Codes and Messages

The implementation translates Windows error codes to human-readable messages:
- `ERROR_MOD_NOT_FOUND`: Module not found
- `ERROR_PROC_NOT_FOUND`: Procedure not found
- `ERROR_INVALID_HANDLE`: Invalid handle
- Other system errors: Formatted using `FormatMessageA()`

## Thread Safety

The implementation maintains thread-local error state:
- Each thread has its own error message buffer
- Error messages are cleared after retrieval
- Multiple threads can safely use dynamic linking functions concurrently

## Build System Integration

This file is conditionally compiled only on Windows platforms:
```makefile
# In Makefile or CMakeLists.txt
ifeq ($(PLATFORM), windows)
    SOURCES += src/flb_dlfcn_win32.c
endif
```

## Limitations

1. **Flag Parameter Ignored**: The `RTLD_LAZY`/`RTLD_NOW` flags are not implemented
2. **Global Error State**: Error messages are stored globally per thread
3. **Limited Error Information**: Only the last error is preserved
4. **Windows-Specific**: Not portable to non-Windows systems

## Benefits

1. **Cross-Platform Consistency**: Same API for dynamic loading on all platforms
2. **Plugin Architecture Support**: Enables runtime plugin loading on Windows
3. **POSIX Compatibility**: Maintains familiar function signatures
4. **Error Reporting**: Provides meaningful error messages for debugging

## Related Files

- `flb_dlfcn_win32.h`: Header file with function declarations
- `flb_compat.h`: Compatibility definitions
- Plugin loading code throughout Fluent Bit that uses these functions