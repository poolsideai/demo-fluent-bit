# flb_oauth2.c

## Overview

This file implements OAuth 2.0 authentication utilities for Fluent Bit. It provides functions for obtaining, managing, and using OAuth 2.0 access tokens for authenticating with external services. The module handles token retrieval from OAuth 2.0 providers, parsing of JSON responses, and automatic token renewal.

## Key Functions

### flb_oauth2_parse_json_response

Parses a JSON response from an OAuth 2.0 provider to extract access token information.

**Parameters:**
- `json_data`: JSON response data
- `json_size`: Size of the JSON data
- `ctx`: OAuth 2.0 context

**Returns:** 0 on success, -1 on failure

### flb_oauth2_create

Creates a new OAuth 2.0 context for authentication.

**Parameters:**
- `config`: Fluent Bit configuration context
- `auth_url`: URL of the OAuth 2.0 token endpoint
- `expire_sec`: Token expiration time in seconds

**Returns:** Pointer to the created OAuth 2.0 context, or NULL on failure

### flb_oauth2_payload_clear

Clears the current payload and resets token information in the OAuth 2.0 context.

**Parameters:**
- `ctx`: OAuth 2.0 context

### flb_oauth2_payload_append

Appends a key/value pair to the OAuth 2.0 request body.

**Parameters:**
- `ctx`: OAuth 2.0 context
- `key_str`: Key string
- `key_len`: Length of the key string (-1 for automatic calculation)
- `val_str`: Value string
- `val_len`: Length of the value string (-1 for automatic calculation)

**Returns:** 0 on success, -1 on failure

### flb_oauth2_destroy

Destroys an OAuth 2.0 context and frees all associated resources.

**Parameters:**
- `ctx`: OAuth 2.0 context

### flb_oauth2_token_get_ng

Retrieves an OAuth 2.0 access token using the new HTTP client interface.

**Parameters:**
- `ctx`: OAuth 2.0 context

**Returns:** Access token string, or NULL on failure

### flb_oauth2_token_get

Retrieves an OAuth 2.0 access token using the legacy HTTP client interface.

**Parameters:**
- `ctx`: OAuth 2.0 context

**Returns:** Access token string, or NULL on failure

### flb_oauth2_token_len

Gets the length of the current access token.

**Parameters:**
- `ctx`: OAuth 2.0 context

**Returns:** Length of the access token, or -1 if no token is available

### flb_oauth2_token_expired

Checks if the current access token has expired.

**Parameters:**
- `ctx`: OAuth 2.0 context

**Returns:** FLB_TRUE if expired, FLB_FALSE if valid

## Dependencies

- `<fluent-bit/flb_info.h>`: Core Fluent Bit header
- `<fluent-bit/flb_mem.h>`: Memory management utilities
- `<fluent-bit/flb_log.h>`: Logging utilities
- `<fluent-bit/flb_utils.h>`: Utility functions
- `<fluent-bit/flb_oauth2.h>`: OAuth 2.0 interface header
- `<fluent-bit/flb_upstream.h>`: Upstream connection management
- `<fluent-bit/flb_http_client.h>`: HTTP client utilities
- `<fluent-bit/flb_jsmn.h>`: JSON parsing utilities

## Implementation Details

The OAuth 2.0 implementation provides two interfaces for token retrieval:

1. **Legacy Interface** (`flb_oauth2_token_get`): Uses the older HTTP client interface
2. **New Interface** (`flb_oauth2_token_get_ng`): Uses the newer HTTP client interface

Key features:

- **Automatic Token Renewal**: Tokens are automatically renewed when they expire
- **Token Caching**: Valid tokens are cached to avoid unnecessary requests
- **JSON Response Parsing**: Automatically parses OAuth 2.0 JSON responses to extract tokens
- **URL Parsing**: Splits authentication URLs into protocol, host, port, and URI components
- **TLS Support**: Supports secure HTTPS connections with proper certificate validation
- **IPv6 Support**: Automatically falls back to IPv6 if IPv4 connections fail

The token expiration time is adjusted to be 10% shorter than the server-provided expiration time to ensure tokens are refreshed before they actually expire.

The implementation handles various OAuth 2.0 providers by allowing custom payload construction through the `flb_oauth2_payload_append` function.

## Usage Examples

```c
// Create OAuth 2.0 context
struct flb_oauth2 *oauth2 = flb_oauth2_create(config, 
                                               "https://oauth2.example.com/token",
                                               3600);  // 1 hour expiration

if (!oauth2) {
    flb_error("Failed to create OAuth 2.0 context");
    return -1;
}

// Build the OAuth 2.0 request payload
flb_oauth2_payload_append(oauth2, "grant_type", -1, "client_credentials", -1);
flb_oauth2_payload_append(oauth2, "client_id", -1, "my_client_id", -1);
flb_oauth2_payload_append(oauth2, "client_secret", -1, "my_client_secret", -1);

// Get the access token
char *token = flb_oauth2_token_get_ng(oauth2);
if (token) {
    // Use the token for authentication
    printf("Access token: %s\n", token);
    
    // Check if token is expired
    if (flb_oauth2_token_expired(oauth2) == FLB_TRUE) {
        printf("Token has expired\n");
    }
}

// Clean up
flb_oauth2_destroy(oauth2);
```