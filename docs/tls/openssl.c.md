# openssl.c

## Overview

This file implements the OpenSSL backend for Fluent Bit's TLS functionality. It provides the concrete implementation of all TLS operations using the OpenSSL library.

The file contains the OpenSSL-specific context management, session handling, and network I/O operations that interface with the generic TLS API defined in flb_tls.c.

## Key Functions

### `tls_context_create`

Creates an OpenSSL-specific TLS context with the specified configuration parameters.

**Parameters:**
- `verify`: Enable/disable certificate verification
- `debug`: Debug verbosity level
- `mode`: TLS mode (client/server)
- `vhost`: Virtual host for SNI extension
- `ca_path`: Path to CA certificate directory
- `ca_file`: Path to CA certificate file
- `crt_file`: Path to certificate file
- `key_file`: Path to private key file
- `key_passwd`: Password for private key file

**Returns:** Pointer to the created OpenSSL context or NULL on failure

### `tls_context_destroy`

Destroys an OpenSSL TLS context and frees all associated resources.

### `tls_session_create`

Creates a new OpenSSL TLS session for a connection.

### `tls_session_destroy`

Destroys an OpenSSL TLS session and frees all associated resources.

### `tls_net_read`/`tls_net_write`

Read/write data from/to an OpenSSL TLS connection.

### `tls_net_handshake`

Performs the TLS handshake for a connection.

## Important Data Structures

### `struct tls_context`

Represents an OpenSSL TLS context with the following fields:
- `debug_level`: Debug verbosity level
- `ctx`: OpenSSL SSL context
- `mode`: TLS mode (client/server)
- `alpn`: ALPN protocol string
- `certstore_name`: Certificate store name (Windows only)
- `use_enterprise_store`: Use enterprise certificate store (Windows only)
- `mutex`: Thread safety mutex

### `struct tls_session`

Represents an OpenSSL TLS session with the following fields:
- `ssl`: OpenSSL SSL structure
- `fd`: File descriptor for the connection
- `alpn`: Selected ALPN protocol
- `continuation_flag`: Flag for multi-step operations
- `parent`: Reference to parent TLS context

## Dependencies

- OpenSSL library (libssl, libcrypto)
- `flb_tls.h`: Generic TLS API
- Platform-specific APIs for certificate loading (Windows, macOS)

## Implementation Details

### Platform-Specific Features

#### Windows Support
- `windows_load_system_certificates`: Loads certificates from Windows system stores
- Support for enterprise certificate stores
- Custom certificate store naming

#### macOS Support
- `macos_load_system_certificates`: Loads certificates from macOS Keychain

### Security Features

#### Certificate Validation
- `setup_hostname_validation`: Sets up hostname validation for certificates
- Support for hostname verification
- Proper error handling for certificate validation failures

#### Protocol Configuration
- `tls_set_minmax_proto`: Sets minimum/maximum TLS protocol versions
- `tls_set_ciphers`: Configures TLS cipher suites
- Support for TLS 1.3 (when available)

### Debugging and Monitoring

#### Info Callback
- `tls_info_callback`: Provides detailed TLS state information
- Configurable debug levels (0-4)
- Error reporting and state change notifications

#### Key Logging
- Support for SSLKEYLOGFILE environment variable
- Useful for debugging with tools like Wireshark

### ALPN Support

#### Server-Side
- `tls_context_server_alpn_select_callback`: Selects ALPN protocol for server connections

#### Client-Side
- `tls_context_alpn_set`: Configures ALPN protocols for client connections

### Error Handling

Comprehensive error handling with:
- Proper OpenSSL error code translation
- Detailed error messages
- Graceful degradation for non-critical errors
- Resource cleanup on error conditions

### Thread Safety

All OpenSSL operations are protected with mutex locks to ensure thread safety in multi-threaded environments.