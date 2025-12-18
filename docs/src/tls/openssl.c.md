# openssl.c

## Overview

This file implements the OpenSSL backend for Fluent Bit's TLS functionality. It provides the concrete implementation of all TLS operations using the OpenSSL library.

The implementation handles OpenSSL context creation, session management, data transmission, and various TLS features like ALPN, certificate validation, and protocol version control. It also includes platform-specific code for Windows and macOS to load system certificates.

## Key Functions and Components

### Backend Structure
- `struct tls_context`: OpenSSL-specific TLS context
- `struct tls_session`: OpenSSL-specific TLS session
- `tls_openssl`: Backend registration structure implementing the `flb_tls_backend` interface

### Context Management
- `tls_context_create()`: Creates OpenSSL context with specified parameters
- `tls_context_destroy()`: Destroys OpenSSL context
- `tls_context_alpn_set()`: Sets ALPN protocols for the context

### Session Management
- `tls_session_create()`: Creates OpenSSL session for a connection
- `tls_session_destroy()`: Destroys OpenSSL session
- `tls_session_invalidate()`: Invalidates OpenSSL session
- `tls_session_alpn_get()`: Gets negotiated ALPN protocol

### Data Transmission
- `tls_net_read()`: Reads data from OpenSSL connection
- `tls_net_write()`: Writes data to OpenSSL connection

### Handshake Operations
- `tls_net_handshake()`: Performs TLS handshake
- `setup_hostname_validation()`: Sets up hostname verification

### Protocol Configuration
- `tls_set_minmax_proto()`: Sets minimum/maximum TLS protocol versions
- `tls_set_ciphers()`: Configures TLS cipher suites

### System Certificate Loading
- `load_system_certificates()`: Loads system certificates (platform-specific)
- `windows_load_system_certificates()`: Windows-specific certificate loading
- `macos_load_system_certificates()`: macOS-specific certificate loading

## Important Variables and Constants

- `OPENSSL_1_1_0`: Version constant for OpenSSL 1.1.0
- `FLB_DEFAULT_SEARCH_CA_BUNDLE`: Default CA bundle path
- `FLB_DEFAULT_CA_DIR`: Default CA directory path
- Various OpenSSL version constants for protocol version control

## Dependencies

- OpenSSL library headers (`ssl.h`, `err.h`, `x509v3.h`)
- Platform-specific headers for Windows (Security API) and macOS (Security Framework)
- `flb_tls.h`: Fluent Bit TLS interface
- Standard C library headers

## Notable Implementation Details

1. **Version Compatibility**: Handles different OpenSSL versions with conditional compilation
2. **Thread Safety**: Uses mutex locks for thread-safe operations
3. **Platform Support**: Includes Windows and macOS specific code for system certificate loading
4. **Debug Support**: Implements TLS debug callback for verbose logging
5. **Error Handling**: Comprehensive error checking and reporting
6. **ALPN Support**: Full implementation of Application-Layer Protocol Negotiation
7. **Certificate Validation**: Supports hostname verification and custom certificate stores

## Usage Examples

Creating an OpenSSL context:
```c
struct tls_context *ctx = tls_context_create(FLB_TRUE,   // verify
                                            1,           // debug level
                                            FLB_TLS_CLIENT_MODE,
                                            "example.com", // vhost
                                            NULL,        // ca_path
                                            NULL,        // ca_file
                                            NULL,        // crt_file
                                            NULL,        // key_file
                                            NULL);      // key_passwd
```

Performing a TLS handshake:
```c
int result = tls_net_handshake(tls, vhost, session_ptr);
if (result == 0) {
    // Handshake successful
} else if (result == FLB_TLS_WANT_READ || result == FLB_TLS_WANT_WRITE) {
    // Non-blocking operation, need to retry
}
```