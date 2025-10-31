# lwrb

## Overview

`lwrb` (Lightweight Ring Buffer) is a generic FIFO (First In First Out) ring buffer implementation written in ANSI C99. It provides an efficient way to manage circular buffers for data storage and transfer, particularly useful in embedded systems and real-time applications.

The library is platform independent and doesn't use any architecture-specific code, making it suitable for various environments including embedded systems, operating systems, and applications requiring efficient data buffering.

## Key Methods/Functions

### Core Buffer Operations

- **Buffer Initialization**: Initialize a ring buffer with a static array
- **Data Writing**: Write data to the buffer with optimized memory copy operations
- **Data Reading**: Read data from the buffer with optimized memory copy operations
- **Peek Operations**: View data without removing it from the buffer
- **Skip Operations**: Advance the read pointer without reading data
- **Advance Operations**: Advance the write pointer without writing data

### Thread and Interrupt Safety

- **Thread Safe**: Safe for use in multi-threaded environments when used as a pipe with single write and single read entries
- **Interrupt Safe**: Safe for use in interrupt-driven environments when used as a pipe with single write and single read entries

### Event Notifications

- **Notification Support**: Implements support for event notifications when buffer conditions change

### DMA Compatibility

- **Zero-Copy Overhead**: Suitable for DMA transfers from and to memory with zero-copy overhead between buffer and application memory

## Usage Notes

### Basic Usage Pattern

The typical usage involves:
1. Initializing the ring buffer with a static array
2. Using write operations to add data to the buffer
3. Using read operations to retrieve data from the buffer
4. Optionally using peek/skip/advance operations for more fine-grained control

### Memory Management

- No dynamic memory allocation is performed
- All data is stored in a static array provided by the user
- Memory copy operations are optimized for performance

### Thread Safety Guidelines

For thread-safe operation:
- Use single writer and single reader pattern
- Ensure proper synchronization mechanisms are in place
- The library handles the internal state management safely

### Interrupt Safety Guidelines

For interrupt-safe operation:
- Use single writer and single reader pattern
- Ensure interrupt handlers follow the same access patterns
- The library maintains interrupt safety through atomic operations

## Important Considerations

- The library is written in ANSI C99 and is compatible with `size_t` for size data types
- Platform independent with no architecture-specific code
- Uses optimized memory copy instead of loops for better performance
- Suitable for embedded systems where memory allocation is constrained
- Designed to work efficiently with DMA transfers
- Provides event notification support for integration with event-driven systems