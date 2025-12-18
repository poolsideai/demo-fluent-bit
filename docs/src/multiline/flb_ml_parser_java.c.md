# flb_ml_parser_java.c Documentation

## Overview

This file contains the implementation for the Java stack trace multiline parser in Fluent Bit. It handles multiline log processing specifically for Java application stack traces.

## Purpose

The primary purpose of this file is to provide a specialized multiline parser for Java stack traces. Java applications often generate multiline exception messages and stack traces that span multiple lines, and this parser correctly identifies and reconstructs these multiline messages.

## Key Components

### Java Parser Creation
- `flb_ml_parser_java()` - Creates a multiline parser specifically for Java stack traces

### Parser Configuration
- Uses regex pattern matching for Java stack trace identification
- Handles continuation patterns specific to Java stack traces
- Supports configurable key for pattern matching

## Implementation Details

### Java Stack Trace Format
Java stack traces typically follow this pattern:
```
java.lang.NullPointerException: null pointer exception
	at com.example.MyClass.myMethod(MyClass.java:25)
	at com.example.Main.main(Main.java:10)
Caused by: java.lang.IllegalArgumentException: invalid argument
	at com.example.MyClass.validate(MyClass.java:20)
	... 2 more
```

### Multiline Handling
Java stack traces can be identified by:
- Exception class names (e.g., `java.lang.NullPointerException`)
- Lines starting with `at` followed by class names and method signatures
- Lines starting with `Caused by:` for chained exceptions
- Continuation lines that don't start with recognizable patterns

### Pattern Matching
The parser uses regex patterns to identify:
- Start of a new stack trace (exception class names)
- Continuation lines of an existing stack trace (`at` lines)
- Chained exception starts (`Caused by:` lines)
- End of a stack trace

## Key Functions

### Parser Factory
- `flb_ml_parser_java()` - Creates and configures a Java-specific multiline parser

## Dependencies

This module depends on:
- Core Fluent Bit libraries (`flb_info.h`)
- Multiline engine (`flb_ml.h`)
- Parser definitions (`flb_ml_parser.h`)
- Regular expression processing (`flb_regex.h`)

## Notable Features

### Regex-Based Pattern Matching
Uses sophisticated regex patterns to accurately identify Java stack trace boundaries.

### Configurable Key Support
Supports configurable key names for pattern matching, allowing flexibility in different log formats.

### Chained Exception Handling
Properly handles Java's chained exception mechanism where one exception can cause another.

### Automatic Flush Timeout
Implements a reasonable default flush timeout to prevent indefinite buffering of incomplete stack traces.

## Usage Example

### Creating a Java Parser
```c
struct flb_ml_parser *java_parser = flb_ml_parser_java(config, FLB_ML_FLUSH_TIMEOUT, "message");
```

### Typical Java Stack Trace
```
java.lang.NullPointerException: null pointer exception
	at com.example.MyClass.myMethod(MyClass.java:25)
	at com.example.Main.main(Main.java:10)
```

The parser would identify this as a single multiline message and reconstruct it appropriately.

### Complex Stack Trace with Chained Exceptions
```
java.lang.NullPointerException: null pointer exception
	at com.example.MyClass.myMethod(MyClass.java:25)
	at com.example.Main.main(Main.java:10)
Caused by: java.lang.IllegalArgumentException: invalid argument
	at com.example.MyClass.validate(MyClass.java:20)
	... 2 more
```

The parser correctly identifies the primary exception, its stack trace, the chained exception, and its stack trace as a single multiline entity.