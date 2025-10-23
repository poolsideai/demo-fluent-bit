# src/CMakeLists.txt Documentation

## Overview

This CMakeLists.txt file is the main build configuration file for the Fluent Bit core library. It defines the source files, dependencies, and build targets for the core Fluent Bit functionality. This file orchestrates the compilation of the core engine, input/output plugins, filters, and various subsystems.

## Key Components

### Core Source Files
The file defines a comprehensive list of core source files that form the foundation of Fluent Bit:
- Engine components (`flb_engine.c`, `flb_task.c`, `flb_scheduler.c`)
- Input/Output subsystems (`flb_input.c`, `flb_output.c`)
- Configuration management (`flb_config.c`, `flb_config_map.c`)
- Network and I/O handling (`flb_network.c`, `flb_io.c`, `flb_socket.c`)
- Data processing components (`flb_pack.c`, `flb_parser.c`, `flb_record_accessor.c`)
- Utility functions (`flb_utils.c`, `flb_mem.c`, `flb_time.c`)
- Compression libraries (`flb_gzip.c`, `flb_snappy.c`, `flb_zstd.c`)

### Conditional Compilation
The file uses numerous conditional blocks to enable/disable features based on build configuration:
- Parser support (`FLB_PARSER`)
- TLS support (`FLB_TLS`)
- AWS integration (`FLB_AWS`)
- LuaJIT scripting (`FLB_LUAJIT`)
- Metrics collection (`FLB_METRICS`)
- SignV4 authentication (`FLB_SIGNV4`)
- HTTP client debugging (`FLB_HTTP_CLIENT_DEBUG`)
- AWS error reporting (`FLB_AWS_ERROR_REPORTER`)
- Kafka support (`FLB_KAFKA`)
- Regex support (`FLB_REGEX`)
- SQLite database support (`FLB_SQLDB`)
- Static configuration (`FLB_STATIC_CONF`)
- Chunk tracing (`FLB_CHUNK_TRACE`)
- Record accessor (`FLB_RECORD_ACCESSOR`)
- Stream processor (`FLB_STREAM_PROCESSOR`)
- HTTP server (`FLB_HTTP_SERVER`)
- WASM runtime (`FLB_WASM`)
- Unicode encoder (`FLB_UNICODE_ENCODER`)
- WAMRC compiler (`FLB_WAMRC`)
- AVRO encoder (`FLB_AVRO_ENCODER`)
- UTF-8 encoder (`FLB_UTF8_ENCODER`)
- Backtrace support (`FLB_BACKTRACE`)
- SASL support (`FLB_SASL_ENABLED`)
- EBPF support (`FLB_IN_EBPF`)

### Dependencies
The file manages a complex set of dependencies:
- System libraries (pthread, m, rt, dl)
- Third-party libraries (OpenSSL, libyaml, jansson, msgpack)
- Internal libraries (co, rbtree, mk_core, cfl, cmetrics, ctraces)
- Compression libraries (snappy, zstd, miniz)
- Protocol buffers (fluent-otel-proto, cprofiles)

### Subdirectories
The file includes several subdirectories that contain specialized functionality:
- `multiline`: Multiline log processing
- `record_accessor`: Record accessor subsystem
- `stream_processor`: Stream processing capabilities
- `aws`: AWS-specific functionality
- `http_server`: HTTP server components
- `proxy`: Plugin proxy interfaces
- `wasm`: WebAssembly runtime
- `unicode`: Unicode conversion utilities
- `simdutf`: SIMD UTF-8 processing

### Build Targets
The file defines two main library targets:
1. `fluent-bit-shared`: Shared library target
2. `fluent-bit-static`: Static library target

It also defines the main executable target `fluent-bit-bin` when `FLB_BINARY` is enabled.

## Implementation Details

### Platform-Specific Handling
The CMakeLists.txt includes platform-specific configurations:
- Windows: Different library linking and resource files
- Linux: Additional timer library linking
- macOS: Framework linking for Foundation, IOKit, and Security

### Installation Routines
The file includes comprehensive installation routines for:
- Libraries and binaries
- Configuration files
- Systemd/upstart service files
- Parser and plugin configuration files

## Usage Examples

To build Fluent Bit with all features enabled:
```bash
cmake -DFLB_ALL=ON .
make
```

To build with specific features:
```bash
cmake -DFLB_AWS=ON -DFLB_TLS=ON .
make
```

To build only the static library:
```bash
cmake -DFLB_SHARED_LIB=OFF .
make
```