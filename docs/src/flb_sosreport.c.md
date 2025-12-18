# flb_sosreport.c and flb_sosreport.h Documentation

## Overview

The `flb_sosreport` module generates a System Operating Status (SOS) report for Fluent Bit. This report provides detailed diagnostic information about the Fluent Bit instance, including system information, configuration details, and plugin information. The SOS report is designed to help troubleshoot issues and provide context for support requests.

## Key Functions

### flb_sosreport()

```c
int flb_sosreport(struct flb_config *config);
```

Generates and prints a comprehensive SOS report to stdout.

**Parameters:**
- `config`: Pointer to the Fluent Bit configuration structure

**Returns:**
- `0` on success
- `-1` on error

## Report Sections

The SOS report includes the following sections:

### [Fluent Bit]

Contains basic Fluent Bit information:
- Version number
- Built flags and compilation options

### [Operating System]

System information:
- OS name and release
- Kernel version
- Platform-specific details (architecture, build info)

### [Hardware]

Hardware information:
- CPU architecture
- Number of processors

### [Built Plugins]

Lists all compiled-in plugins:
- Input plugins
- Filter plugins
- Output plugins

### [SERVER] Runtime configuration

Global configuration settings:
- Flush interval
- Daemon mode status
- Log level

### [INPUT] Instance

Information about each input instance:
- Plugin name and type
- Instance ID
- Flags (network, coroutine support)
- Coroutines status
- Tag configuration
- Host information (for network inputs)
- Memory buffer limits
- Custom properties
- Routing information

### [FILTER] Instance

Information about each filter instance:
- Plugin name and type
- Instance ID
- Match patterns
- Custom properties

### [OUTPUT] Instance

Information about each output instance:
- Plugin name and type
- Instance ID
- Match patterns
- TLS settings (if enabled)
- Retry limits
- Host information
- Custom properties

## Implementation Details

### Cross-Platform Support

The implementation supports both Unix-like systems and Windows:
- Uses `uname()` on Unix systems for OS information
- Uses Windows API functions on Windows systems
- Handles platform-specific data types and structures

### Data Collection

The report collects information from:
- Fluent Bit configuration structure
- Plugin instance lists
- System information APIs
- Custom properties of each instance

### Formatting

The report uses consistent formatting:
- Section headers in brackets
- Key-value pairs with aligned columns
- Human-readable units for sizes
- Masked sensitive information (passwords)

## Usage Example

```c
#include <fluent-bit/flb_sosreport.h>
#include <fluent-bit/flb_config.h>

// Initialize Fluent Bit configuration
struct flb_config *config = flb_config_init();

// Configure Fluent Bit (add plugins, set properties, etc.)
// ...

// Generate SOS report
if (flb_sosreport(config) == 0) {
    flb_info("SOS report generated successfully");
} else {
    flb_error("Failed to generate SOS report");
}

// Clean up
flb_config_exit(config);
```

## Command Line Usage

The SOS report can also be generated from the command line:

```bash
# Generate SOS report
fluent-bit --sos

# Or with configuration file
fluent-bit -c /path/to/config.conf --sos
```

## Sample Output

```
Fluent Bit Enterprise - SOS Report
==================================
The following report aims to be used by Fluent Bit and Fluentd community users.

[Fluent Bit]
    Version		1.9.0
    Built Flags		Linux,x86_64,sse4.2,avx,avx2,debug,tls,openssl,jemalloc

[Operating System]
    Name		Linux
    Release		5.4.0-74-generic
    Version		#84-Ubuntu SMP Thu May 6 11:08:32 UTC 2021

[Hardware]
    Architecture	x86_64
    Processors		8

[Built Plugins]
    Inputs		cpu tail systemd
    Filters		grep parser
    Outputs		stdout kafka

[SERVER] Runtime configuration
    Flush			1.000000
    Daemon		Off
    Log_Level		Info

[INPUT] Instance
    Name		tail (tail, id=1)
    Flags		
    Coroutines		Yes
    Tag			app
    Path			/var/log/app.log

[OUTPUT] Instance
    Name		stdout (stdout, id=2)
    Match		*
    Retry Limit		no limit
```