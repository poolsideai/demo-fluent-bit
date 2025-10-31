# miniz

## Overview

`miniz` is a lossless, high-performance data compression library implemented in a single source file. It implements the zlib (RFC 1950) and Deflate (RFC 1951) compressed data format specification standards. The library serves as a drop-in replacement for zlib's most commonly used APIs while being a completely independent implementation.

Beyond compression, miniz also provides simple-to-use functions for writing PNG format image files and reading/writing/appending ZIP format archives, making it a versatile tool for data compression and archive management.

## Key Methods/Functions

### Compression Functions

- **Deflate Compression**: High-performance compression using the deflate algorithm
- **Zlib Compression**: Compression with zlib headers and Adler-32 checksum
- **Real-time Compression**: Specialized compressor function designed for real-time applications

### Decompression Functions

- **Inflate Decompression**: Fast decompression of deflate-compressed data
- **Zlib Decompression**: Decompression of zlib-formatted data with header parsing
- **Adler-32 Checking**: Built-in checksum verification for data integrity

### Archive Management

- **ZIP Creation**: Functions for creating and writing ZIP format archives
- **ZIP Reading**: Functions for reading and extracting data from ZIP archives
- **ZIP Appending**: Functions for adding data to existing ZIP archives

### Image Support

- **PNG Writing**: Simple functions for writing PNG format image files

### Low-level Codec Access

- **tdefl Compressor**: Low-level compressor with simple state structs
- **tinfl Decompressor**: Low-level decompressor implemented as a coroutine

## Usage Notes

### Basic Integration

Miniz can be easily integrated into projects in several ways:

1. **Direct Source Inclusion**: Simply add `miniz.c` and `miniz.h` to your project
2. **CMake Integration**: Use as a CMake module
3. **Meson Integration**: Use as a Meson module
4. **Package Managers**: Install via package managers like vcpkg

### Performance Tuning

- **Compression Levels**: Supports levels 1-9 with different trade-offs between speed and compression ratio
- **Real-time Mode**: Specialized function for real-time compression scenarios
- **Stream Processing**: Full support for stream-based processing using coroutine-style implementation

### Memory Management

- **Single Threaded**: Optimized for single-threaded performance
- **No Heap Allocation**: Low-level codec APIs don't use the heap
- **State Management**: Simple state structs can be saved/restored with memcpy

### Archive Operations

The ZIP archive functionality is designed to solve common problems in embedded, mobile, or game development:
- Creating archives with multiple files
- Reading and extracting archive contents
- Appending data to existing archives
- Managing file metadata within archives

## Important Considerations

- **Licensing**: MIT licensed, completely independent of zlib's licensing requirements
- **Portability**: Written in plain C, tested with GCC, clang, and Visual Studio
- **Tunability**: Easily trimmed down by defines for embedded applications
- **Performance**: Compression speed tuned to be comparable to zlib
- **Limitations**: No support for encrypted archives
- **Documentation**: Minimal documentation assumes familiarity with basic zlib API
- **Patents**: Uses the same core algorithms as zlib to avoid patent issues

### Building and Installation

- **Releases**: Available as a pair of `miniz.c`/`miniz.h` files via the releases page
- **Amalgamation**: Different source and header files are amalgamated during build
- **Package Managers**: Can be installed via vcpkg or other dependency managers

### Examples and Testing

The library includes 6 examples demonstrating major features and comes with test scripts for verification.