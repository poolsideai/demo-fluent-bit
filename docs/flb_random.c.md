# flb_random.c - Cross-Platform Random Number Generation

## Overview

This file implements a cross-platform random number generator for Fluent Bit, providing cryptographically secure random bytes suitable for various security-sensitive operations. The implementation adapts to different operating systems and available system interfaces to ensure reliable and secure random number generation.

The module prioritizes security and reliability by using the best available system random number sources:
- Windows: Uses `BCryptGenRandom()` from the CNG API
- Unix/Linux: Uses `getentropy()` syscall when available, falling back to `/dev/urandom`

## Key Functions

### `flb_random_bytes(unsigned char *buf, int len)`
Fills a buffer with cryptographically secure random bytes:
- Takes a buffer pointer and desired length in bytes
- Returns 0 on success, -1 on error
- Platform-specific implementation ensures optimal security

## Platform-Specific Implementations

### Windows Implementation
Uses the Windows CNG (Cryptography Next Generation) API:
- Calls `BCryptGenRandom()` with `BCRYPT_USE_SYSTEM_PREFERRED_RNG` flag
- Available since Windows Vista
- Provides cryptographically secure random numbers
- Returns 0 on success, -1 on failure

### Unix/Linux Implementation
Uses the best available system interface in order of preference:

1. **getentropy() syscall** (when available):
   - Uses `getentropy()` function for direct kernel entropy access
   - Limited to 256 bytes per call, so multiple calls may be needed
   - Falls back to `/dev/urandom` if syscall is not available (Linux)

2. **/dev/urandom fallback**:
   - Opens `/dev/urandom` for reading
   - Reads the requested number of bytes
   - Closes the file descriptor after reading
   - Provides cryptographically secure random numbers

## Security Features

1. **Cryptographically Secure**: All implementations provide cryptographically secure random numbers suitable for security-sensitive applications

2. **Fallback Mechanisms**: Graceful degradation to alternative methods when preferred methods are unavailable

3. **Error Handling**: Proper error reporting with meaningful return codes

4. **Resource Management**: Proper cleanup of file descriptors and system resources

## Dependencies

- `<fluent-bit/flb_compat.h>` - Compatibility layer
- `<fcntl.h>` - File control operations
- `<unistd.h>` - Unix standard functions (when `FLB_HAVE_GETENTROPY` is defined)
- `<sys/random.h>` - System random functions (when `FLB_HAVE_GETENTROPY_SYS_RANDOM` is defined)
- `<errno.h>` - Error number definitions
- Windows headers (when `FLB_SYSTEM_WINDOWS` is defined)

## Notable Implementation Details

1. **Chunked Processing**: For large requests, the implementation processes data in chunks to work within system limitations

2. **Maximum Chunk Size**: Limits individual `getentropy()` calls to 256 bytes to comply with system constraints

3. **Error Recovery**: Handles `ENOSYS` errors gracefully by falling back to `/dev/urandom` on Linux systems

4. **Loop-Based Reading**: Ensures complete buffer filling even if individual system calls return fewer bytes than requested

5. **Resource Cleanup**: Always closes file descriptors and properly handles system resources

## Usage Examples

### Generating Random Bytes
```c
#include <fluent-bit/flb_random.h>

// Allocate buffer for random bytes
unsigned char random_buffer[32];

// Generate 32 cryptographically secure random bytes
if (flb_random_bytes(random_buffer, sizeof(random_buffer)) == 0) {
    // Successfully generated random bytes
    // Use random_buffer for cryptographic operations
    
    // Example: Print hex representation
    for (int i = 0; i < 32; i++) {
        printf("%02x", random_buffer[i]);
    }
    printf("\n");
} else {
    // Handle error - random number generation failed
    fprintf(stderr, "Failed to generate random bytes\n");
    return -1;
}
```

### Generating Random Integers
```c
#include <fluent-bit/flb_random.h>

// Generate a random 32-bit integer
uint32_t generate_random_uint32() {
    unsigned char buffer[4];
    
    if (flb_random_bytes(buffer, sizeof(buffer)) != 0) {
        return 0; // Error case
    }
    
    // Convert bytes to uint32_t (little-endian)
    return (uint32_t)buffer[0] |
           ((uint32_t)buffer[1] << 8) |
           ((uint32_t)buffer[2] << 16) |
           ((uint32_t)buffer[3] << 24);
}

// Use the function
uint32_t random_number = generate_random_uint32();
printf("Random number: %u\n", random_number);
```

### Generating UUIDs
```c
#include <fluent-bit/flb_random.h>

// Generate a random UUID (16 bytes)
void generate_random_uuid(unsigned char uuid[16]) {
    if (flb_random_bytes(uuid, 16) != 0) {
        // Handle error
        memset(uuid, 0, 16);
        return;
    }
    
    // Set UUID version to 4 (random)
    uuid[6] = (uuid[6] & 0x0f) | 0x40;
    
    // Set UUID variant to RFC 4122
    uuid[8] = (uuid[8] & 0x3f) | 0x80;
}

// Generate and print UUID
unsigned char uuid[16];
generate_random_uuid(uuid);

printf("UUID: ");
for (int i = 0; i < 16; i++) {
    if (i == 4 || i == 6 || i == 8 || i == 10) {
        printf("-");
    }
    printf("%02x", uuid[i]);
}
printf("\n");
```