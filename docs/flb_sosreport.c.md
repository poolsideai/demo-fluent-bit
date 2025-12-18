# flb_sosreport.c

## Overview

The `flb_sosreport.c` file implements the System Operational Status (SOS) report functionality for Fluent Bit. This module generates comprehensive diagnostic reports that capture the current state of Fluent Bit's configuration, plugins, and runtime environment.

The SOS report is designed to help users troubleshoot issues, share configuration details with support teams, and understand the current operational state of their Fluent Bit instances. It provides a standardized format for reporting system information that can be easily shared for diagnostic purposes.

Key features:
- Generation of comprehensive system status reports
- Cross-platform support (Unix and Windows)
- Detailed plugin configuration information
- Runtime environment diagnostics
- Standardized output format for easy sharing

## Key Functions/Components

### Main Function

#### `flb_sosreport(struct flb_config *config)`
Generates and prints a comprehensive SOS report:
1. Captures Fluent Bit version and build information
2. Collects operating system details
3. Reports hardware specifications
4. Lists built-in plugins (inputs, filters, outputs)
5. Displays runtime configuration settings
6. Shows detailed instance configurations
7. Includes network and TLS settings where applicable
8. Provides standardized formatting for easy reading

### Helper Functions

#### `print_key(char *key)`
Prints a formatted key label for report entries:
1. Left-aligns the key with padding
2. Ensures consistent column width for readability

#### `print_kv(char *key, char *val)`
Prints a key-value pair in the report format:
1. Calls `print_key()` for consistent formatting
2. Prints the value on the same line

#### `get_str(char *p)`
Safely retrieves string values with fallback:
1. Returns the input string if not NULL
2. Returns "(not set)" for NULL values

#### `log_level(int x)`
Converts numeric log levels to human-readable strings:
1. Maps integers 0-5 to "Off", "Error", "Warn", "Info", "Debug", "Trace"
2. Returns "Unknown" for invalid values

#### `input_flags(int flags)`
Prints input plugin flags in human-readable format:
1. Checks for `FLB_INPUT_NET` flag (network input)
2. Checks for `FLB_INPUT_CORO` flag (coroutine-based input)
3. Formats output for easy reading

#### `print_host(struct flb_net_host *host)`
Prints network host information:
1. Displays address, port, name, and listen settings
2. Handles NULL values gracefully
3. Formats network information consistently

#### `print_properties(struct mk_list *props)`
Prints key-value properties from a list:
1. Iterates through property list entries
2. Calls `print_kv()` for each property
3. Handles empty property lists gracefully

### Platform-Specific Functions

#### Windows Functions
- `win32_arch(int archid)`: Maps Windows architecture IDs to human-readable strings
- `win32_operating_system_info()`: Retrieves and prints Windows OS information
- `win32_hardware_info()`: Retrieves and prints Windows hardware information

#### Unix Functions
- Uses `uname()` system call for OS information
- Uses `sysconf()` for processor count

## Important Data Structures

### Plugin Instance Structures
- `struct flb_input_instance`: Input plugin configuration and state
- `struct flb_filter_instance`: Filter plugin configuration and state
- `struct flb_output_instance`: Output plugin configuration and state
- `struct flb_router_path`: Routing path information

### Configuration Structures
- `struct flb_config`: Main Fluent Bit configuration structure
- `struct flb_net_host`: Network host configuration
- `struct flb_kv`: Key-value property pairs

## Dependencies and Relationships

This module depends on:
- `flb_config`: Main Fluent Bit configuration
- `flb_input`: Input plugin framework
- `flb_output`: Output plugin framework
- `flb_filter`: Filter plugin framework
- `flb_router`: Routing framework
- `flb_version`: Version information
- `flb_utils`: Utility functions for formatting
- `flb_kv`: Key-value pair management
- `mk_list`: Linked list implementation
- System libraries (`sys/utsname.h`, `sysconf`, etc.)

It integrates with:
- Fluent Bit command-line interface
- Support and diagnostic tools
- Configuration management systems
- Monitoring and observability frameworks

## Implementation Details

### Report Structure
The SOS report follows a standardized hierarchical structure:
1. **Fluent Bit Information**: Version, build flags
2. **Operating System**: Name, release, version
3. **Hardware**: Architecture, processor count
4. **Built Plugins**: Available input, filter, and output plugins
5. **Runtime Configuration**: Global settings like flush interval, daemon mode
6. **Plugin Instances**: Detailed configurations for each plugin instance

### Cross-Platform Compatibility
The implementation handles platform differences:
1. **Unix Systems**: Uses `uname()` and `sysconf()`
2. **Windows Systems**: Uses Windows API calls and structure mappings
3. **Consistent Output**: Same report format across platforms

### Memory Management
- No dynamic memory allocation in this module
- Relies on existing configuration structures
- Safe handling of NULL pointers and edge cases
- Efficient iteration through linked lists

### Error Handling
- Comprehensive validation of input parameters
- Graceful handling of system call failures
- Safe navigation of linked list structures
- Consistent formatting regardless of data availability

### Security Considerations
- TLS passwords are masked in output (shown as "*****")
- Sensitive configuration values are handled appropriately
- No exposure of private keys or credentials in reports

## Usage Examples

### Generating an SOS Report
```bash
# Generate SOS report from command line
fluent-bit -i dummy -o stdout -f 1 -t test --sos

# Or using the SOS command
fluent-bit --sos-report
```

### Programmatic Usage
```c
// Generate SOS report programmatically
struct flb_config *config = flb_config_init();
if (config) {
    // Configure Fluent Bit as needed
    flb_config_add_input(config, "dummy", NULL);
    flb_config_add_output(config, "stdout", NULL);
    
    // Generate and print SOS report
    flb_sosreport(config);
    
    // Cleanup
    flb_config_destroy(config);
}
```

### Sample Output
```
Fluent Bit Enterprise - SOS Report
==================================
The following report aims to be used by Fluent Bit and Fluentd 
community users.

[Fluent Bit]
    Version            1.9.0
    Built Flags        http,json,regex,systemd,systemd-journal

[Operating System]
    Name               Linux
    Release            5.4.0-42-generic
    Version            #46-Ubuntu SMP Fri Jul 10 00:24:02 UTC 2020

[Hardware]
    Architecture       x86_64
    Processors         4

[Built Plugins]
    Inputs             dummy tail systemd
    Filters            record_modifier grep parser
    Outputs            stdout http s3

[SERVER] Runtime configuration
    Flush              1.000000
    Daemon             Off
    Log_Level          Info

[INPUT] Instance
    Name               dummy (dummy, id=0)
    Flags              
    Coroutines         Yes
    Tag                test

[OUTPUT] Instance
    Name               stdout (stdout, id=1)
    Match              *
    Host.Address       
    Host.TCP_Port      0
```

### Configuration Example
```ini
[SERVICE]
    # SOS report can be generated with --sos flag
    flush 1
    log_level info

[INPUT]
    name dummy
    tag test
    # SOS report will show this input configuration
    
[OUTPUT]
    name stdout
    match *
    # SOS report will show this output configuration
```

### Integration Pattern
```c
// Integration in support tools or diagnostic utilities
int generate_support_report(struct flb_config *config, const char *output_file) {
    // Redirect stdout to file if needed
    FILE *original_stdout = stdout;
    if (output_file) {
        stdout = fopen(output_file, "w");
        if (!stdout) {
            flb_error("Failed to open output file: %s", strerror(errno));
            return -1;
        }
    }
    
    // Generate the SOS report
    int result = flb_sosreport(config);
    
    // Restore stdout if redirected
    if (output_file && stdout != original_stdout) {
        fclose(stdout);
        stdout = original_stdout;
    }
    
    return result;
}

// Usage
struct flb_config *config = flb_config_init();
// ... configure Fluent Bit ...

// Generate report to console
flb_sosreport(config);

// Generate report to file
generate_support_report(config, "/tmp/fluent-bit-sos.txt");
```

### Error Handling Pattern
```c
// Robust SOS report generation with error handling
int safe_generate_sos_report(struct flb_config *config) {
    if (!config) {
        flb_error("Invalid configuration for SOS report");
        return -1;
    }
    
    // Validate essential configuration components
    if (mk_list_is_empty(&config->inputs) && 
        mk_list_is_empty(&config->outputs)) {
        flb_warn("No input or output plugins configured");
    }
    
    // Generate the report
    int result = flb_sosreport(config);
    
    if (result != 0) {
        flb_error("Failed to generate SOS report: %d", result);
    }
    
    return result;
}

// Usage
struct flb_config *config = flb_config_init();
// ... setup configuration ...

if (safe_generate_sos_report(config) == 0) {
    printf("SOS report generated successfully\n");
} else {
    printf("Failed to generate SOS report\n");
}
```

### Advanced Usage
```c
// Custom SOS report with additional information
int enhanced_sos_report(struct flb_config *config, const char *custom_info) {
    // Generate standard SOS report
    flb_sosreport(config);
    
    // Add custom information
    if (custom_info) {
        printf("\n[CUSTOM INFORMATION]\n");
        printf("    %s\n", custom_info);
    }
    
    // Add timestamp
    time_t now = time(NULL);
    printf("\n[TIMESTAMP]\n");
    printf("    Generated at %s", ctime(&now));
    
    return 0;
}

// Usage
enhanced_sos_report(config, "Deployment: Production Environment");
```