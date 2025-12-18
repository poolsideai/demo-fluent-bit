# flb_hmac.c

## Overview

This file implements HMAC (Hash-based Message Authentication Code) functionality for Fluent Bit that wraps OpenSSL's EVP MAC interface. It provides a clean API for computing cryptographic signatures using various hash algorithms including MD5, SHA256, and SHA512.

The module serves as an abstraction layer over OpenSSL's HMAC functions, allowing Fluent Bit to compute cryptographic signatures in a standardized way. It supports both streaming operations (where data is fed incrementally) and simple one-shot operations.

## Key Functions

### `flb_hmac_init()`
Initializes an HMAC context for a specific digest algorithm with a given key. This function creates the underlying OpenSSL context and configures it for the requested HMAC type.

### `flb_hmac_cleanup()`
Cleans up and destroys the HMAC context, freeing all associated resources.

### `flb_hmac_finalize()`
Finalizes the HMAC computation and writes the resulting signature to the provided buffer.

### `flb_hmac_update()`
Feeds data into the HMAC computation. This function can be called multiple times to process data incrementally.

### `flb_hmac_simple_batch()`
Computes an HMAC for multiple data entries in a single operation, simplifying batch processing scenarios.

### `flb_hmac_simple()`
Computes an HMAC for a single data entry in a one-shot operation.

## Important Variables/Constants

### Hash Types
- `FLB_HASH_MD5`: MD5 hash algorithm
- `FLB_HASH_SHA256`: SHA256 hash algorithm
- `FLB_HASH_SHA512`: SHA512 hash algorithm

### Return Codes
- `FLB_CRYPTO_SUCCESS`: Operation completed successfully
- `FLB_CRYPTO_BACKEND_ERROR`: OpenSSL backend reported an error
- `FLB_CRYPTO_INVALID_ARGUMENT`: Invalid parameter provided
- `FLB_CRYPTO_ALLOCATION_ERROR`: Memory allocation failed

### HMAC Context Structure
The `struct flb_hmac` contains:
- `backend_context`: Pointer to the OpenSSL HMAC context
- `mac_algorithm`: Pointer to the MAC algorithm (OpenSSL 3.0+)
- `digest_size`: Size of the resulting signature in bytes
- `last_error`: Last OpenSSL error code if an operation failed

## Dependencies

- `fluent-bit/flb_hmac.h`: Header file defining the interface
- `fluent-bit/flb_crypto_constants.h`: Constants for crypto operations
- `openssl/evp.h`: OpenSSL EVP digest interface
- `openssl/hmac.h`: OpenSSL HMAC functions
- `openssl/sha.h`: OpenSSL SHA functions
- `openssl/md5.h`: OpenSSL MD5 functions

## Implementation Details

1. **OpenSSL Compatibility**: The implementation supports multiple OpenSSL versions through conditional compilation:
   - OpenSSL 3.0+: Uses EVP MAC interface
   - OpenSSL 1.1.x: Uses HMAC_CTX interface
   - OpenSSL 1.0.x: Uses legacy HMAC_CTX interface

2. **Error Handling**: All functions return standardized error codes and store the last OpenSSL error in the context for debugging.

3. **Memory Management**: Uses proper OpenSSL context creation/destruction functions for all supported versions.

4. **Algorithm Support**: Supports MD5, SHA256, and SHA512 through OpenSSL's HMAC interface.

5. **Batch Processing**: Provides optimized functions for processing multiple data entries at once.

## Usage Example

```c
// Simple one-shot HMAC computation
unsigned char key[] = "my-secret-key";
unsigned char data[] = "Hello World";
unsigned char signature[32]; // SHA256 produces 32 bytes

int result = flb_hmac_simple(FLB_HASH_SHA256,
                              key, strlen((char*)key),
                              data, strlen((char*)data),
                              signature, sizeof(signature));

if (result == FLB_CRYPTO_SUCCESS) {
    // Process the HMAC signature
    printf("HMAC-SHA256: ");
    for (int i = 0; i < 32; i++) {
        printf("%02x", signature[i]);
    }
    printf("\n");
}

// Streaming HMAC computation
struct flb_hmac hmac_ctx;
result = flb_hmac_init(&hmac_ctx, FLB_HASH_SHA512, key, strlen((char*)key));

if (result == FLB_CRYPTO_SUCCESS) {
    // Feed data incrementally
    flb_hmac_update(&hmac_ctx, (unsigned char*)"Part 1", 6);
    flb_hmac_update(&hmac_ctx, (unsigned char*)"Part 2", 6);
    
    // Finalize and get result
    unsigned char final_signature[64]; // SHA512 produces 64 bytes
    flb_hmac_finalize(&hmac_ctx, final_signature, sizeof(final_signature));
    
    // Clean up
    flb_hmac_cleanup(&hmac_ctx);
}
```