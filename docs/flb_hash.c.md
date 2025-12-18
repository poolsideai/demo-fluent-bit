# flb_hash.c

## Overview

This file implements a cryptographic hash interface for Fluent Bit that wraps OpenSSL's EVP digest functions. It provides a clean API for computing various hash digests including MD5, SHA256, and SHA512.

The module serves as an abstraction layer over OpenSSL's hashing functions, allowing Fluent Bit to compute cryptographic hashes in a standardized way. It supports both streaming operations (where data is fed incrementally) and simple one-shot operations.

## Key Functions

### `flb_hash_init()`
Initializes a hash context for a specific digest algorithm. This function creates the underlying OpenSSL context and configures it for the requested hash type.

### `flb_hash_cleanup()`
Cleans up and destroys the hash context, freeing all associated resources.

### `flb_hash_finalize()`
Finalizes the hash computation and writes the resulting digest to the provided buffer.

### `flb_hash_update()`
Feeds data into the hash computation. This function can be called multiple times to process data incrementally.

### `flb_hash_simple_batch()`
Computes a hash for multiple data entries in a single operation, simplifying batch processing scenarios.

### `flb_hash_simple()`
Computes a hash for a single data entry in a one-shot operation.

## Important Variables/Constants

### Hash Types
- `FLB_HASH_MD5`: MD5 hash algorithm
- `FLB_HASH_SHA256`: SHA256 hash algorithm
- `FLB_HASH_SHA512`: SHA512 hash algorithm

### Return Codes
- `FLB_CRYPTO_SUCCESS`: Operation completed successfully
- `FLB_CRYPTO_BACKEND_ERROR`: OpenSSL backend reported an error
- `FLB_CRYPTO_INVALID_ARGUMENT`: Invalid parameter provided

### Hash Context Structure
The `struct flb_hash` contains:
- `backend_context`: Pointer to the OpenSSL EVP digest context
- `digest_size`: Size of the resulting digest in bytes
- `last_error`: Last OpenSSL error code if an operation failed

## Dependencies

- `fluent-bit/flb_hash.h`: Header file defining the interface
- `fluent-bit/flb_crypto_constants.h`: Constants for crypto operations
- `openssl/evp.h`: OpenSSL EVP digest interface
- `openssl/sha.h`: OpenSSL SHA functions
- `openssl/md5.h`: OpenSSL MD5 functions

## Implementation Details

1. **OpenSSL Integration**: The implementation directly uses OpenSSL's EVP digest interface for maximum compatibility and performance.

2. **Error Handling**: All functions return standardized error codes and store the last OpenSSL error in the context for debugging.

3. **Memory Management**: Uses OpenSSL's context creation/destruction functions for proper resource management.

4. **Algorithm Support**: Supports MD5, SHA256, and SHA512 through OpenSSL's EVP interface.

5. **Batch Processing**: Provides optimized functions for processing multiple data entries at once.

## Usage Example

```c
// Simple one-shot hash computation
unsigned char digest[32]; // SHA256 produces 32 bytes
int result = flb_hash_simple(FLB_HASH_SHA256,
                             (unsigned char*)"Hello World", 11,
                             digest, sizeof(digest));

if (result == FLB_CRYPTO_SUCCESS) {
    // Process the hash digest
    printf("SHA256: ");
    for (int i = 0; i < 32; i++) {
        printf("%02x", digest[i]);
    }
    printf("\n");
}

// Streaming hash computation
struct flb_hash hash_ctx;
result = flb_hash_init(&hash_ctx, FLB_HASH_SHA512);

if (result == FLB_CRYPTO_SUCCESS) {
    // Feed data incrementally
    flb_hash_update(&hash_ctx, (unsigned char*)"Part 1", 6);
    flb_hash_update(&hash_ctx, (unsigned char*)"Part 2", 6);
    
    // Finalize and get result
    unsigned char final_digest[64]; // SHA512 produces 64 bytes
    flb_hash_finalize(&hash_ctx, final_digest, sizeof(final_digest));
    
    // Clean up
    flb_hash_cleanup(&hash_ctx);
}
```