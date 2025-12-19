# flb_tls.c

## Overview

This file implements the TLS (Transport Layer Security) functionality for Fluent Bit. It provides a generic interface for TLS operations that can work with different TLS backends (currently OpenSSL).

The file contains the main TLS context management, session handling, and network I/O operations for secure connections.

## Key Functions

### `flb_tls_create`

Creates a new TLS context with the specified configuration parameters.

**Parameters:**
- `mode`: TLS mode (client/server)
- `verify`: Enable/disable certificate verification
- `debug`: Debug verbosity level
- `vhost`: Virtual host for SNI extension
- `ca_path`: Path to CA certificate directory
- `ca_file`: Path to CA certificate file
- `crt_file`: Path to certificate file
- `key_file`: Path to private key file
- `key_passwd`: Password for private key file

**Returns:** Pointer to the created TLS context or NULL on failure

### `flb_tls_destroy`

Destroys a TLS context and frees all associated resources.

### `flb_tls_load_system_certificates`

Loads system certificates into the TLS context.

### `flb_tls_session_create`

Creates a new TLS session for a connection.

### `flb_tls_session_destroy`

Destroys a TLS session and frees all associated resources.

### `flb_tls_net_read`/`flb_tls_net_read_async`

Read data from a TLS connection (synchronous/asynchronous versions).

### `flb_tls_net_write`/`flb_tls_net_write_async`

Write data to a TLS connection (synchronous/asynchronous versions).

## Important Variables

### `tls_configmap`

Configuration map defining all TLS-related configuration options that can be set in Fluent Bit configuration files.

Options include:
- `tls`: Enable/disable TLS
- `tls.verify`: Force certificate validation
- `tls.debug`: Set TLS debug verbosity level
- `tls.ca_file`: Absolute path to CA certificate file
- `tls.ca_path`: Absolute path to scan for certificate files
- `tls.crt_file`: Absolute path to Certificate file
- `tls.key_file`: Absolute path to private Key file
- `tls.key_passwd`: Optional password for tls.key_file file
- `tls.vhost`: Hostname to be used for TLS SNI extension
- `tls.verify_hostname`: Enable/disable hostname verification
- `tls.min_version`: Specify the minimum version of TLS
- `tls.max_version`: Specify the maximum version of TLS
- `tls.ciphers`: Specify TLS ciphers up to TLSv1.2

## Dependencies

- `openssl.c`: Contains the OpenSSL-specific implementation
- `flb_tls.h`: Header file with TLS data structures and API declarations
- Event loop system for asynchronous operations
- Socket system for network operations

## Implementation Details

### Event Handling

The file implements sophisticated event handling for TLS operations:
- `io_tls_backup_event`: Backs up connection event state
- `io_tls_restore_event`: Restores connection event state
- `io_tls_event_switch`: Switches event masks for different TLS operations

### Session Management

TLS sessions are managed with proper resource cleanup and error handling:
- Automatic retry mechanisms for WANT_READ/WANT_WRITE conditions
- Timeout handling for connection operations
- Proper coroutine integration for asynchronous operations

### Configuration

Supports comprehensive TLS configuration through the config map system, allowing users to configure all aspects of TLS behavior including certificate validation, cipher suites, protocol versions, and debugging options.