# CMakeLists.txt

## Overview

This CMakeLists.txt file defines the build configuration for the multiline processing module in Fluent Bit. It specifies the source files that should be compiled into the multiline component.

## Key Components

- **Built-in Parsers**: Lists the source files for built-in multiline parsers including:
  - `flb_ml_parser_cri.c` - Container Runtime Interface parser
  - `flb_ml_parser_docker.c` - Docker parser
  - `flb_ml_parser_python.c` - Python parser
  - `flb_ml_parser_java.c` - Java parser
  - `flb_ml_parser_go.c` - Go parser
  - `flb_ml_parser_ruby.c` - Ruby parser

- **Core Components**: Lists the core multiline processing source files:
  - `flb_ml_stream.c` - Stream processing functionality
  - `flb_ml_parser.c` - Parser management
  - `flb_ml_group.c` - Group processing functionality
  - `flb_ml_rule.c` - Rule processing functionality
  - `flb_ml.c` - Main multiline processing engine

## Dependencies

This file is part of the Fluent Bit build system and depends on:
- CMake build system
- Fluent Bit core libraries
- Multiline processing headers

## Usage

This file is automatically included during the Fluent Bit build process when the multiline module is enabled. It ensures all necessary source files are compiled into the multiline component.