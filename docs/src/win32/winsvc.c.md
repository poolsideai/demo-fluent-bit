# winsvc.c

## Overview

This file implements Windows Service functionality for Fluent Bit on Windows platforms. It allows Fluent Bit to run as a Windows service, providing automatic startup, background operation, and integration with Windows service management tools.

## Key Components

### Service Configuration
- Service name: "fluent-bit"
- Service type: SERVICE_WIN32_OWN_PROCESS
- Service controls accepted: SERVICE_ACCEPT_STOP

### Core Functions

#### Service Lifecycle Functions
- `win32_main()`: Main entry point that determines if Fluent Bit should run as a service or console application
- `svc_main()`: Service main function called by Windows Service Control Manager
- `svc_handler()`: Handles service control requests (e.g., STOP)
- `win32_started()`: Notifies Service Control Manager that the service has started

#### Utility Functions
- `update_default_workdir()`: Sets the working directory to where fluent-bit.exe is located
- `svc_notify()`: Updates service status with Service Control Manager

## Important Variables

### Global State
- `hstatus`: Service status handle for communication with Service Control Manager
- `win32_argc`, `win32_argv`: Command line arguments passed to the service
- `svc_name`: Name of the Windows service ("fluent-bit")

### Service Table
- `svc_table`: Array defining service entry points for Service Control Manager

## Dependencies

### Windows API
- Windows.h: Core Windows API functions
- Shlwapi.h: Path manipulation functions

### Fluent Bit Core
- `config`: Global Fluent Bit configuration structure
- `flb_engine_exit()`: Function to gracefully shut down Fluent Bit engine
- `flb_main()`: Main Fluent Bit entry point

## Implementation Details

### Service Installation and Management
- Automatic detection of service vs. console mode
- Graceful shutdown handling through service control handler
- Proper status reporting to Service Control Manager
- Working directory management for service context

### Error Handling
- Comprehensive error checking for Windows API calls
- Proper cleanup on failure conditions
- Logging through Windows event system (implicit)

### Path Management
- Automatic working directory update to executable location
- Proper handling of relative paths in service context
- Unicode path support through Windows API

## Usage

### Installing as a Windows Service
```cmd
# Install Fluent Bit as a service
sc create fluent-bit binPath= "C:\Program Files\fluent-bit\bin\fluent-bit.exe --service"
sc start fluent-bit
```

### Running as Console Application
```cmd
# Run Fluent Bit directly from command line
fluent-bit.exe -i dummy -o stdout
```

### Service Control Operations
```cmd
sc query fluent-bit
sc stop fluent-bit
sc delete fluent-bit
```

## Integration with Fluent Bit

This module seamlessly integrates with Fluent Bit's core functionality:
- Uses the same `flb_main()` entry point as console applications
- Maintains compatibility with all Fluent Bit configuration options
- Provides identical functionality whether running as service or console
- Handles proper resource cleanup during service shutdown

The service implementation ensures that Fluent Bit can be managed through standard Windows service management tools while maintaining all the logging and monitoring capabilities of the core application.