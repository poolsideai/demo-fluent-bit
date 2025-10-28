# CMakeLists.txt Documentation

## Overview

This CMakeLists.txt file is the main build configuration file for the Fluent Bit source code. It defines the core source files, dependencies, and build targets for the project.

## Key Components

### Core Source Files

The file defines a comprehensive list of core source files that make up the Fluent Bit engine:

- Core engine components (`flb_engine.c`, `flb_config.c`, etc.)
- Input/output handling (`flb_input.c`, `flb_output.c`)
- Network utilities (`flb_network.c`, `flb_socket.c`)
- Data processing components (`flb_parser.c`, `flb_filter.c`)
- Compression libraries (`flb_gzip.c`, `flb_zstd.c`, `flb_snappy.c`)
- HTTP client implementations
- Event processing and encoding/decoding utilities

### Conditional Compilation

The CMakeLists.txt uses conditional compilation directives to include/exclude components based on build configuration:

- `FLB_PARSER`: Parser subsystem
- `FLB_AVRO_ENCODER`: Avro encoding support
- `FLB_TLS`: TLS/SSL support
- `FLB_PROXY_GO`: Go proxy support
- `FLB_METRICS`: Metrics collection
- `FLB_SIGNV4`: AWS Signature V4 support
- `FLB_HTTP_CLIENT_DEBUG`: HTTP client debugging
- `FLB_AWS_ERROR_REPORTER`: AWS error reporting
- `FLB_LUAJIT`: LuaJIT scripting support
- `FLB_KAFKA`: Kafka client support
- `FLB_REGEX`: Regular expression support
- `FLB_SQLDB`: SQLite database support
- `FLB_STATIC_CONF`: Static configuration support
- `FLB_CHUNK_TRACE`: Chunk tracing support

### Subdirectories

The file includes several subdirectories that contain additional components:

- `multiline`: Multiline log processing
- `record_accessor`: Record accessor functionality
- `stream_processor`: Stream processing engine
- `aws`: AWS-specific components
- `http_server`: HTTP server components
- `proxy`: Proxy interfaces
- `wasm`: WebAssembly runtime support
- `simdutf`: Unicode encoding support
- `wamrc`: WAMRC compiler
- `unicode`: Unicode conversion utilities

### Dependencies

The CMakeLists.txt defines various dependencies required for building Fluent Bit:

- System libraries (pthread, dl, m, rt)
- Third-party libraries (OpenSSL, libyaml, jemalloc)
- Internal libraries (cfl, fluent-otel-proto, cprofiles, cmetrics, ctraces)
- Plugin dependencies

### Build Targets

The file defines three main build targets:

1. **Shared Library** (`fluent-bit-shared`): Creates a shared library version of Fluent Bit
2. **Static Library** (`fluent-bit-static`): Creates a static library version of Fluent Bit
3. **Binary** (`fluent-bit-bin`): Creates the main executable binary

### Installation

The CMakeLists.txt also handles installation of the built artifacts:

- Libraries to `${FLB_INSTALL_LIBDIR}`
- Binary to `${FLB_INSTALL_BINDIR}`
- Configuration files to `${FLB_INSTALL_CONFDIR}`
- Systemd/Upstart service files

## Usage

This CMakeLists.txt is used by the main project CMakeLists.txt to build the Fluent Bit core engine. It's included when the `FLB_CORE` flag is set.