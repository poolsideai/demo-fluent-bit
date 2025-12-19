# winsvc.c Documentation

## Overview

This file implements Windows Service functionality for Fluent Bit on Windows platforms. It allows Fluent Bit to run as a Windows service, providing automatic startup, background operation, and integration with Windows service management tools.

## Key Components

### Service Configuration
- Service name: "fluent-bit"
- Service type: SERVICE_WIN32_OWN_PROCESS
- Service controls accepted: SERVICE_ACCEPT_STOP

### Core Functions

#### Service Lifecycle Functions
- `win32_main()`: Main entry point that determines if Fluent Bit should run as a service or console application based on SCM connection
- `svc_main()`: Service main function called by Windows Service Control Manager to initialize and start the service
- `svc_handler()`: Handles service control requests (e.g., STOP) and triggers graceful shutdown
- `win32_started()`: Notifies Service Control Manager that the service has started and is running

#### Utility Functions
- `update_default_workdir()`: Sets the working directory to where fluent-bit.exe is located, avoiding the default System32 directory
- `svc_notify()`: Updates service status with Service Control Manager with proper state transitions

## Important Variables

### Global State
- `hstatus`: Service status handle for communication with Service Control Manager
- `win32_argc`, `win32_argv`: Command line arguments passed to the service
- `svc_name`: Name of the Windows service ("fluent-bit")

### Service Table
- `svc_table`: Array defining service entry points for Service Control Manager registration

## Dependencies

### Windows API
- Windows.h: Core Windows API functions for service management
- Shlwapi.h: Path manipulation functions (PathRemoveFileSpecA)

### Fluent Bit Core
- `config`: Global Fluent Bit configuration structure
- `flb_engine_exit()`: Function to gracefully shut down Fluent Bit engine
- `flb_main()`: Main Fluent Bit entry point for actual processing

## Notable Implementation Details

1. **Dual Mode Operation**: Automatically detects whether to run as a service or console application based on SCM connection
2. **Working Directory Management**: Updates the working directory to the executable location instead of System32
3. **Proper Status Reporting**: Implements correct service state transitions with appropriate control acceptance
4. **Graceful Shutdown**: Handles service stop requests by calling flb_engine_exit() for clean termination
5. **Error Handling**: Comprehensive error checking with proper cleanup on failure conditions
6. **Security Considerations**: Avoids accepting control during SERVICE_START_PENDING state to prevent crashes

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