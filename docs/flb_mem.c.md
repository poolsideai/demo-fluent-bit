# flb_mem.c

## Overview

This file contains memory management utilities for Fluent Bit. It provides custom memory allocation functions that can be used for testing purposes, particularly with OSS-Fuzz.

## Key Functions

### flb_malloc_p and flb_malloc_mod

These global variables are used for memory allocation testing:
- `flb_malloc_p`: A counter that can be used to simulate memory allocation failures
- `flb_malloc_mod`: A modulus value that determines when to simulate memory allocation failures

These variables are only defined when the `FLB_HAVE_TESTS_OSSFUZZ` macro is enabled, which is typically used for fuzz testing.

## Dependencies

- `<fluent-bit/flb_info.h>`: Core Fluent Bit header file

## Implementation Details

The memory management in Fluent Bit is designed to be compatible with standard C memory allocation functions. The OSS-Fuzz testing variables allow for controlled memory allocation failures during testing to ensure robustness.

## Usage Examples

```c
// In normal operation, these variables are not used
// They are only active during fuzz testing

#ifdef FLB_HAVE_TESTS_OSSFUZZ
int flb_malloc_p;
int flb_malloc_mod;
#endif
```