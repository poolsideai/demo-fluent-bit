# flb_tls.c

## Overview

This file implements the TLS (Transport Layer Security) functionality for Fluent Bit. It provides a generic interface for TLS operations that can work with different TLS backends (currently OpenSSL).

The code defines the core TLS structures and functions that are used throughout Fluent Bit to establish secure connections. It handles TLS configuration, session creation, and data transmission with proper error handling and timeout management.

## Key Functions and Components

### Core TLS Structure
- `struct flb_tls`: Main TLS context structure that holds configuration and state information
- `struct flb_tls_session`: Represents a TLS session for a specific connection

### Configuration Functions
- `flb_tls_create()`: Creates a new TLS context with specified parameters
- `flb_tls_set_minmax_proto()`: Sets minimum and maximum TLS protocol versions
- `flb_tls_set_ciphers()`: Configures TLS cipher suites
- `flb_tls_set_verify_hostname()`: Enables/disables hostname verification

### Session Management
- `flb_tls_session_create()`: Creates a new TLS session for a connection
- `flb_tls_session_destroy()`: Cleans up a TLS session
- `flb_tls_session_invalidate()`: Invalidates a TLS session

### Data Transmission
- `flb_tls_net_read()`: Reads data from a TLS connection
- `flb_tls_net_write()`: Writes data to a TLS connection
- `flb_tls_net_read_async()` / `flb_tls_net_write_async()`: Async versions for coroutine-based operations

### ALPN Support
- `flb_tls_set_alpn()`: Sets Application-Layer Protocol Negotiation
- `flb_tls_session_get_alpn()`: Gets negotiated protocol

## Important Variables and Constants

- `FLB_TLS_CLIENT_MODE` / `FLB_TLS_SERVER_MODE`: Connection mode constants
- `FLB_TLS_WANT_READ` / `FLB_TLS_WANT_WRITE`: Return codes indicating non-blocking operation needs
- `FLB_TLS_ALPN_MAX_LENGTH`: Maximum length for ALPN protocol strings

## Dependencies

- `openssl.c`: Contains the OpenSSL-specific implementation
- `flb_socket.h`: Socket operations
- `flb_coro.h`: Coroutine support for async operations
- `flb_config.h`: Configuration management

## Notable Implementation Details

1. **Backend Abstraction**: The code uses a backend API (`struct flb_tls_backend`) to support multiple TLS implementations
2. **Async Support**: Provides both synchronous and asynchronous versions of read/write operations
3. **Timeout Handling**: Implements proper timeout management for TLS handshakes
4. **Event Loop Integration**: Integrates with Fluent Bit's event loop for non-blocking operations
5. **Error Recovery**: Handles TLS errors and retries appropriately

## Usage Examples

Creating a TLS context:
```c
struct flb_tls *tls = flb_tls_create(FLB_TLS_CLIENT_MODE,
                                     FLB_TRUE,  // verify
                                     1,         // debug level
                                     "example.com", // vhost
                                     NULL,      // ca_path
                                     NULL,      // ca_file
                                     NULL,      // crt_file
                                     NULL,      // key_file
                                     NULL);    // key_passwd
```

Creating a TLS session:
```c
struct flb_tls_session *session = flb_tls_client_session_create(tls,
                                                                connection,
                                                                coroutine);
```