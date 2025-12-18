# flb_crypto.c

## Overview

The `flb_crypto.c` file implements cryptographic operations for Fluent Bit using OpenSSL. This module provides a simplified interface for performing common cryptographic tasks including digital signatures, encryption, and decryption operations.

The crypto system abstracts the complexity of OpenSSL's EVP (Envelope) API, providing a consistent interface for cryptographic operations while maintaining compatibility across different OpenSSL versions. It supports RSA-based operations with various padding schemes and digest algorithms.

## Key Functions

### `flb_crypto_init`
Initializes a cryptographic context:
- Imports PEM-encoded keys (public or private)
- Sets up OpenSSL EVP_PKEY_CTX for cryptographic operations
- Configures padding type and digest algorithm
- Validates key type and parameters
- Returns `FLB_CRYPTO_SUCCESS` on success or error codes on failure

### `flb_crypto_cleanup`
Cleans up a cryptographic context:
- Frees OpenSSL key structures
- Releases EVP_PKEY_CTX resources
- Resets context state
- Prevents memory leaks from cryptographic operations

### `flb_crypto_transform`
Performs cryptographic transformations:
- Signs data using private keys
- Encrypts data using public keys
- Decrypts data using private keys
- Supports operation chaining with state tracking
- Handles OpenSSL error reporting

### Operation-Specific Functions
- `flb_crypto_sign`: Creates digital signatures
- `flb_crypto_encrypt`: Encrypts data with public keys
- `flb_crypto_decrypt`: Decrypts data with private keys

### Simple Operation Functions
- `flb_crypto_sign_simple`: One-shot signing without context management
- `flb_crypto_encrypt_simple`: One-shot encryption without context management
- `flb_crypto_decrypt_simple`: One-shot decryption without context management

## Data Structures

### `struct flb_crypto`
Represents a cryptographic context with:
- `digest_algorithm`: OpenSSL digest algorithm instance
- `backend_context`: OpenSSL EVP_PKEY_CTX for operations
- `last_operation`: Tracks the last performed operation
- `padding_type`: RSA padding scheme configuration
- `block_size`: Key size in bytes
- `last_error`: Last OpenSSL error code
- `key`: Imported OpenSSL key structure

## Supported Algorithms

### Key Types
- `FLB_CRYPTO_PUBLIC_KEY`: Public key for encryption/verification
- `FLB_CRYPTO_PRIVATE_KEY`: Private key for decryption/signing

### Padding Schemes
- `FLB_CRYPTO_PADDING_PKCS1`: PKCS#1 v1.5 padding
- `FLB_CRYPTO_PADDING_PKCS1_OEAP`: PKCS#1 OAEP padding
- `FLB_CRYPTO_PADDING_PKCS1_X931`: X9.31 padding
- `FLB_CRYPTO_PADDING_PKCS1_PSS`: PSS padding

### Digest Algorithms
- `FLB_HASH_MD5`: MD5 hash algorithm
- `FLB_HASH_SHA256`: SHA-256 hash algorithm
- `FLB_HASH_SHA512`: SHA-512 hash algorithm

### Operations
- `FLB_CRYPTO_OPERATION_SIGN`: Digital signature creation
- `FLB_CRYPTO_OPERATION_ENCRYPT`: Data encryption
- `FLB_CRYPTO_OPERATION_DECRYPT`: Data decryption

## Dependencies

This module depends on:
- OpenSSL libraries (libcrypto)
- `flb_crypto_constants`: Cryptographic constants and error codes
- Standard C library functions

## Implementation Details

The crypto system provides several key features:

1. **Context Management**: Efficient reuse of cryptographic contexts
2. **Error Handling**: Comprehensive OpenSSL error reporting
3. **Version Compatibility**: Support for OpenSSL 1.1.x and 3.x
4. **Memory Safety**: Proper cleanup of OpenSSL resources
5. **Simple Interface**: High-level functions for common operations

### Operation Chaining
The system supports operation chaining where:
- First operation initializes the EVP context
- Subsequent operations reuse the initialized context
- State tracking prevents invalid operation sequences

### Key Import Process
1. Validate key type and parameters
2. Create OpenSSL BIO from key data
3. Parse PEM-encoded key using OpenSSL functions
4. Initialize EVP_PKEY_CTX for cryptographic operations
5. Configure padding and digest algorithms

## Usage Example

```c
// Digital signature example
unsigned char *private_key = "-----BEGIN PRIVATE KEY-----...-----END PRIVATE KEY-----";
unsigned char *data = "Hello, World!";
unsigned char signature[512];
size_t signature_len = sizeof(signature);

// Method 1: Using context management
struct flb_crypto ctx;
int result = flb_crypto_init(&ctx,
                              FLB_CRYPTO_PADDING_PKCS1,
                              FLB_HASH_SHA256,
                              FLB_CRYPTO_PRIVATE_KEY,
                              private_key,
                              strlen(private_key));

if (result == FLB_CRYPTO_SUCCESS) {
    result = flb_crypto_sign(&ctx, data, strlen(data), signature, &signature_len);
    flb_crypto_cleanup(&ctx);
}

// Method 2: Using simple function
result = flb_crypto_sign_simple(FLB_CRYPTO_PRIVATE_KEY,
                                 FLB_CRYPTO_PADDING_PKCS1,
                                 FLB_HASH_SHA256,
                                 private_key,
                                 strlen(private_key),
                                 data,
                                 strlen(data),
                                 signature,
                                 &signature_len);

// Encryption example
unsigned char *public_key = "-----BEGIN PUBLIC KEY-----...-----END PUBLIC KEY-----";
unsigned char encrypted[512];
size_t encrypted_len = sizeof(encrypted);

result = flb_crypto_encrypt_simple(FLB_CRYPTO_PADDING_PKCS1_OEAP,
                                    public_key,
                                    strlen(public_key),
                                    data,
                                    strlen(data),
                                    encrypted,
                                    &encrypted_len);

// Decryption example
unsigned char decrypted[512];
size_t decrypted_len = sizeof(decrypted);

result = flb_crypto_decrypt_simple(FLB_CRYPTO_PADDING_PKCS1_OEAP,
                                    private_key,
                                    strlen(private_key),
                                    encrypted,
                                    encrypted_len,
                                    decrypted,
                                    &decrypted_len);
```