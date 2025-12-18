# flb_kernel.c

## Overview

This file contains the implementation for retrieving and managing kernel information in Fluent Bit. It provides functionality for determining the operating system kernel version, which is useful for compatibility checks, feature detection, and system-specific optimizations.

The module implements a cross-platform approach to kernel version detection, with different implementations for Unix-like systems and Windows. On Unix systems, it uses the `uname()` system call to retrieve kernel information, while on Windows it provides a dummy implementation since kernel version information is handled differently.

Kernel information is primarily used for compatibility purposes, allowing Fluent Bit to adapt its behavior based on the underlying kernel capabilities and version-specific features.

## Key Functions

### Kernel Information Retrieval

#### `flb_kernel_info()`
Retrieves detailed kernel information including major, minor, and patch version numbers, as well as string representation of the version. On Unix systems, this function uses the `uname()` system call to get the kernel release information and parses it to extract version components.

On Windows systems, this function provides a dummy implementation that returns a default version (0.0.0) since Windows doesn't expose kernel version information in the same way as Unix systems.

### Resource Management

#### `flb_kernel_destroy()`
Destroys a kernel information structure and frees all associated memory resources.

## Important Variables/Constants

### Version Macros
- `FLB_KERNEL_VERSION(a, b, c)`: Macro to create a numeric representation of kernel version (major.minor.patch)

### Data Structures
- `struct flb_kernel`: Structure containing kernel version information with major, minor, patch numbers, numeric version, and string representation

## Dependencies

- `fluent-bit/flb_info.h`: Core Fluent Bit information
- `fluent-bit/flb_mem.h`: Memory management utilities
- `fluent-bit/flb_kernel.h`: Header file defining the interface
- `fluent-bit/flb_utils.h`: Utility functions
- `sys/utsname.h`: Unix system information (Unix only)
- `ctype.h`: Character type classification (Unix only)
- `monkey/mk_core.h`: Monkey Core utilities

## Implementation Details

1. **Cross-Platform Support**: Different implementations for Unix and Windows systems to handle kernel version detection appropriately for each platform.

2. **Version Parsing**: Robust parsing of kernel version strings on Unix systems, handling various formats including Debian's modified notation with hyphens.

3. **Memory Management**: Proper allocation and deallocation of kernel information structures with error checking.

4. **Numeric Version Encoding**: Efficient encoding of kernel versions into a single 32-bit integer for easy comparison operations.

5. **String Representation**: Maintaining both numeric and string representations of kernel versions for different use cases.

6. **Error Handling**: Comprehensive error detection and reporting throughout the kernel information retrieval process.

7. **Resource Cleanup**: Proper cleanup of allocated memory resources to prevent memory leaks.

8. **Default Values**: Safe default values for Windows implementation where kernel version information is not readily available.

## Usage Example

```c
// Retrieve kernel information
struct flb_kernel *kernel_info = flb_kernel_info();
if (kernel_info != NULL) {
    printf("Kernel Version: %s\n", kernel_info->s_version.data);
    printf("Major: %d, Minor: %d, Patch: %d\n",
           kernel_info->major, kernel_info->minor, kernel_info->patch);
    printf("Numeric Version: %u\n", kernel_info->n_version);
    
    // Use kernel information for compatibility checks
    if (kernel_info->n_version >= FLB_KERNEL_VERSION(3, 10, 0)) {
        printf("Kernel version is compatible with required features\n");
        // Enable advanced features
    } else {
        printf("Kernel version may not support all features\n");
        // Use fallback implementations
    }
    
    // Clean up resources
    flb_kernel_destroy(kernel_info);
} else {
    printf("Failed to retrieve kernel information\n");
    // Handle error appropriately
}

// Example of version comparison
struct flb_kernel *kernel = flb_kernel_info();
if (kernel != NULL) {
    // Check if kernel version is at least 4.19.0
    if (kernel->n_version >= FLB_KERNEL_VERSION(4, 19, 0)) {
        printf("Modern kernel detected, enabling advanced features\n");
        // Enable eBPF, modern networking features, etc.
    } else if (kernel->n_version >= FLB_KERNEL_VERSION(3, 10, 0)) {
        printf("Legacy kernel detected, using compatible features\n");
        // Use older APIs and workarounds
    } else {
        printf("Very old kernel detected, limited functionality\n");
        // Disable advanced features
    }
    
    flb_kernel_destroy(kernel);
}

// Example of string-based version checking
struct flb_kernel *kernel = flb_kernel_info();
if (kernel != NULL) {
    const char *version_str = kernel->s_version.data;
    
    // Simple string comparison for major version
    if (strncmp(version_str, "5.", 2) == 0) {
        printf("Linux 5.x kernel detected\n");
        // Linux 5.x specific optimizations
    } else if (strncmp(version_str, "4.", 2) == 0) {
        printf("Linux 4.x kernel detected\n");
        // Linux 4.x specific optimizations
    }
    
    flb_kernel_destroy(kernel);
}

// Complete example showing typical usage pattern
struct flb_kernel *kernel_info = flb_kernel_info();
if (!kernel_info) {
    fprintf(stderr, "Failed to get kernel information\n");
    return -1;
}

printf("Operating System Kernel Information:\n");
printf("  String Version: %.*s\n", 
       (int)kernel_info->s_version.len, kernel_info->s_version.data);
printf("  Numeric Version: %u (0x%08x)\n", 
       kernel_info->n_version, kernel_info->n_version);
printf("  Major: %d, Minor: %d, Patch: %d\n",
       kernel_info->major, kernel_info->minor, kernel_info->patch);

// Feature detection based on kernel version
if (kernel_info->n_version >= FLB_KERNEL_VERSION(4, 19, 0)) {
    printf("  Features: eBPF, modern networking, BTF support\n");
} else if (kernel_info->n_version >= FLB_KERNEL_VERSION(3, 10, 0)) {
    printf("  Features: Basic networking, limited eBPF\n");
} else {
    printf("  Features: Legacy networking only\n");
}

// Clean up
flb_kernel_destroy(kernel_info);

// Example of checking for minimum required version
struct flb_kernel *kernel = flb_kernel_info();
if (!kernel) {
    fprintf(stderr, "Cannot determine kernel version\n");
    return -1;
}

// Require at least Linux 3.10.0
#define MIN_REQUIRED_VERSION FLB_KERNEL_VERSION(3, 10, 0)
if (kernel->n_version < MIN_REQUIRED_VERSION) {
    fprintf(stderr, "Kernel version %.*s is too old, minimum required is 3.10.0\n",
            (int)kernel->s_version.len, kernel->s_version.data);
    flb_kernel_destroy(kernel);
    return -1;
}

printf("Kernel version %.*s meets minimum requirements\n",
       (int)kernel->s_version.len, kernel->s_version.data);

flb_kernel_destroy(kernel);
```