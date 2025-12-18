# CMakeLists.txt Documentation

## Overview

This CMakeLists.txt file defines the build configuration for the multiline parsing module in Fluent Bit. It specifies which source files should be compiled as part of the multiline functionality.

## Purpose

The file serves as the build configuration for the multiline parsing subsystem, listing all the source files that implement various multiline parsing modes and core functionality.

## Key Components

### Source Files Included

1. **Built-in Parsers**:
   - `flb_ml_parser_cri.c` - Container Runtime Interface (CRI) parser
   - `flb_ml_parser_docker.c` - Docker container logs parser
   - `flb_ml_parser_python.c` - Python stack trace parser
   - `flb_ml_parser_java.c` - Java stack trace parser
   - `flb_ml_parser_go.c` - Go stack trace parser
   - `flb_ml_parser_ruby.c` - Ruby stack trace parser

2. **Core Implementation**:
   - `flb_ml_stream.c` - Stream management functionality
   - `flb_ml_parser.c` - Parser creation and management
   - `flb_ml_group.c` - Group management for streams
   - `flb_ml_rule.c` - Rule processing for regex-based multiline parsing
   - `flb_ml.c` - Main multiline processing engine

## Build Configuration

The file uses CMake syntax to define a variable `src_multiline` that contains all the source files needed for the multiline module. The `PARENT_SCOPE` directive ensures that this variable is accessible to parent CMakeLists.txt files.

## Dependencies

This module depends on:
- Core Fluent Bit libraries
- MessagePack for serialization
- Regular expression library for pattern matching
- Time handling utilities

## Usage

This file is automatically included in the main Fluent Bit build process. No special configuration is required for users of Fluent Bit.