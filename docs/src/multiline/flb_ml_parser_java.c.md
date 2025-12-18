# flb_ml_parser_java.c Documentation

## Overview

This file contains the implementation for the Java stack trace multiline parser in Fluent Bit. It handles multiline log processing specifically for Java application stack traces. This parser is designed to recognize and reconstruct the complex multiline patterns found in Java runtime exception messages and stack traces.

## Purpose

The primary purpose of this file is to provide a specialized multiline parser for Java stack traces. Java applications often generate multiline exception messages and stack traces that span multiple lines, and this parser correctly identifies and reconstructs these multiline messages using sophisticated regex pattern matching.

## Key Components

### Java Parser Creation
- `flb_ml_parser_java()` - Creates a multiline parser specifically for Java stack traces

### Parser Configuration
- Uses regex pattern matching for Java stack trace identification
- Handles continuation patterns specific to Java stack traces
- Supports configurable key for pattern matching
- Implements a state machine approach for complex pattern recognition

## Implementation Details

### Java Stack Trace Format

Java stack traces typically follow these patterns:

#### Basic Exception
```
java.lang.NullPointerException: null pointer exception
	at com.example.MyClass.myMethod(MyClass.java:25)
	at com.example.Main.main(Main.java:10)
```

#### Exception with Chained Cause
```
java.lang.NullPointerException: null pointer exception
	at com.example.MyClass.myMethod(MyClass.java:25)
	at com.example.Main.main(Main.java:10)
Caused by: java.lang.IllegalArgumentException: invalid argument
	at com.example.MyClass.validate(MyClass.java:20)
	... 2 more
```

#### Exception with Suppressed Exceptions
```
java.lang.Exception: main exception
	at com.example.Main.main(Main.java:10)
Suppressed: java.lang.Exception: suppressed exception 1
	at com.example.Main.main(Main.java:15)
Suppressed: java.lang.Exception: suppressed exception 2
	at com.example.Main.main(Main.java:20)
```

#### C# Exception (Supported for Compatibility)
```
System.Exception: main exception
   at MyClass.MyMethod()
   at Program.Main()
--- End of inner exception stack trace ---
System.Exception: inner exception
   at InnerClass.InnerMethod()
```

### State Machine Approach

The parser implements a sophisticated state machine with multiple states:
- `start_state` - Initial state for detecting the beginning of a Java stack trace
- `java_start_exception` - State after detecting nested exception indicators
- `java_after_exception` - State after detecting an exception class
- `java` - State for processing stack trace frames

### Regex Pattern Matching

The parser uses the following regex patterns to identify Java stack trace components:

1. **Exception Detection**: `/(.)(?:Exception|Error|Throwable|V8 errors stack trace)[:\r\n]/` - Identifies exception/error class names
2. **Nested Exception Detection**: `/^[\t ]*nested exception is:[\t ]*/` - Identifies nested exception indicators
3. **Empty Line Handling**: `/^[\r\n]*$/` - Handles empty lines within stack traces
4. **Stack Frame Detection**: `/^[\t ]+(?:eval )?at /` - Identifies stack trace frames
5. **C# Inner Exception End**: `/^[\t ]+--- End of inner exception stack trace ---$/` - Identifies end of C# inner exception traces
6. **C# Async Exception End**: `/^--- End of stack trace from previous (?x:)location where exception was thrown ---$/` - Identifies end of C# async exception traces
7. **Chained Exception Detection**: `/^[\t ]*(?:Caused by|Suppressed):/` - Identifies chained exceptions
8. **Frame Omission Detection**: `/^[\t ]*... \d+ (?:more|common frames omitted)/` - Identifies frame omission indicators

### Multiline Handling

Java stack traces are identified by:
- Exception class names (e.g., `java.lang.NullPointerException`)
- Lines starting with whitespace followed by `at` for stack frames
- Lines starting with `Caused by:` or `Suppressed:` for chained exceptions
- Lines indicating frame omission (`... N more`)
- Empty lines within stack traces
- C# exception patterns for compatibility

### Pattern Matching Logic

The parser uses regex patterns to identify:
- Start of a new stack trace (exception class names)
- Nested exception indicators
- Empty lines within stack traces
- Stack trace frames
- Chained exception starts
- Frame omission indicators
- End of stack trace indicators

## Key Functions

### Parser Factory
- `flb_ml_parser_java()` - Creates and configures a Java-specific multiline parser with all regex rules

### Internal Helper Functions
- `rule_error()` - Handles rule creation failures with proper cleanup

## Dependencies

This module depends on:
- Core Fluent Bit libraries (`flb_info.h`) for basic functionality
- Multiline engine (`flb_ml.h`) for integration with core multiline functionality
- Parser definitions (`flb_ml_parser.h`) for parser creation and management
- Rule processing (`flb_ml_rule.h`) for regex-based multiline patterns
- Regular expression processing (`flb_regex.h`) for pattern matching

## Notable Features

### Sophisticated Regex-Based Pattern Matching

Uses sophisticated regex patterns to accurately identify Java stack trace boundaries. The patterns are designed to handle various Java runtime exception formats including basic exceptions, chained exceptions, suppressed exceptions, and C# exception patterns for compatibility.

### State Machine Architecture

Implements a state machine approach with multiple states to handle the complex structure of Java stack traces. This allows for precise identification of different components of a stack trace including nested exceptions and frame omissions.

### Configurable Key Support

Supports configurable key names for pattern matching, allowing flexibility in different log formats and integration with various input sources.

### Comprehensive Exception Handling

Properly handles all Java exception mechanisms:
- Basic exceptions with stack traces
- Chained exceptions using `Caused by:`
- Suppressed exceptions using `Suppressed:`
- Frame omission indicators (`... N more`)
- Nested exception patterns
- C# exception patterns for compatibility

### Automatic Flush Timeout

Implements a reasonable default flush timeout (`FLB_ML_FLUSH_TIMEOUT`) to prevent indefinite buffering of incomplete stack traces.

## Algorithm Overview

The Java parser processing follows these steps:
1. Create a multiline parser with REGEX type and appropriate configuration
2. Add multiple regex rules to define the state machine for Java stack traces
3. Initialize the parser rules to map them for processing
4. Process incoming log entries against the regex rules
5. Transition between states based on pattern matches
6. Buffer continuation lines until a complete stack trace is identified
7. Flush complete stack traces to output with preserved metadata

## Key Configuration Parameters

### Parser Setup
- `name` - "java" (identifier for this parser mode)
- `type` - `FLB_ML_REGEX` (regex-based matching for complex patterns)
- `match_str` - NULL (no simple string matching)
- `negate` - `FLB_FALSE` (do not negate the match)
- `flush_ms` - `FLB_ML_FLUSH_TIMEOUT` (default flush timeout)
- `key_content` - Configurable key (default: "message") for content extraction
- `key_group` - NULL (no stream grouping)
- `key_pattern` - NULL (no separate pattern key)

## Memory Management

The implementation uses Fluent Bit's memory management utilities for consistent allocation and deallocation. String data is managed using the SDS (String Data Structure) library for efficient operations. All allocated resources are properly tracked and freed during cleanup operations.

## Thread Safety

The parser creation function is designed to be thread-safe in multi-threaded environments, using appropriate locking mechanisms where necessary to protect shared configuration data structures.

## Error Handling

The function returns specific error codes:
- Valid pointer to multiline parser indicates success
- NULL indicates failure due to resource allocation issues, rule creation failures, or parser initialization failures

Rule creation failures are handled with descriptive error messages and proper cleanup of partially allocated resources.

## Usage Example

### Creating a Java Parser
```c
struct flb_ml_parser *java_parser = flb_ml_parser_java(config, "message");
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

### Exception with Suppressed Exceptions
```
java.lang.Exception: main exception
	at com.example.Main.main(Main.java:10)
Suppressed: java.lang.Exception: suppressed exception 1
	at com.example.Main.main(Main.java:15)
Suppressed: java.lang.Exception: suppressed exception 2
	at com.example.Main.main(Main.java:20)
```

The parser correctly handles all suppressed exceptions as part of the main stack trace.

## Configuration and Customization

The Java parser can be customized through:
- Different flush timeouts based on log volume expectations
- Custom key mappings for different log formats
- Integration with parser contexts for additional preprocessing

## Performance Considerations

For optimal performance with Java stack traces:
1. Use the default flush timeout unless specific latency requirements exist
2. Ensure proper key configuration to match the actual log format
3. Monitor memory usage for high-volume log processing
4. Leverage the efficient regex pattern matching for log parsing

## Integration Points

This module integrates with:
- The main multiline engine (`flb_ml.c`) for context creation and processing
- Rule processing (`flb_ml_rule.c`) for regex-based multiline patterns
- The Fluent Bit configuration system for parser registration
- Input plugins for multiline processing integration

## Testing and Debugging

Debugging can be enabled through Fluent Bit's logging system. Rule creation failures are reported with descriptive error messages to aid in troubleshooting configuration issues. The regex patterns used for parsing can be verified independently to ensure proper log format recognition.