# flb_ml_parser_java.c

## Overview

This file implements the Java language multiline parser for Fluent Bit. It handles multiline log messages and exception stack traces from Java applications.

## Key Functions

### Parser Creation

- `flb_ml_parser_java()` - Creates a multiline parser specifically for Java application logs

### Internal Functions

- `rule_error()` - Handles rule creation errors with proper cleanup

## Important Data Structures

### Java Parser Configuration
The Java parser is configured with:
- Type: `FLB_ML_REGEX` (regex pattern matching)
- Match String: `NULL` (uses regex rules instead)
- Negate: `FLB_FALSE` (no negation)
- Flush Timeout: Default multiline flush timeout
- Key Content: Configurable field name (defaults to content field)

### Regex Rules
The Java parser implements a state machine with these rules:

1. **Exception Start States**:
   - `/(.)(?:Exception|Error|Throwable|V8 errors stack trace)[:\r\n]/` → `java_after_exception`

2. **Exception Continuation States**:
   - `java_after_exception` → `/^[\t ]*nested exception is:[\t ]*/` → `java_start_exception`
   - `java_after_exception` → `/^[\r\n]*$/` → `java_after_exception`
   - `java_after_exception, java` → `/^[\t ]+(?:eval )?at /` → `java`
   - `java_after_exception, java` → `/^[\t ]+--- End of inner exception stack trace ---$/` → `java`
   - `java_after_exception, java` → `/^--- End of stack trace from previous (?x:)location where exception was thrown ---$/` → `java`
   - `java_after_exception, java` → `/^[\t ]*(?:Caused by|Suppressed):/` → `java_after_exception`
   - `java_after_exception, java` → `/^[\t ]*... \d+ (?:more|common frames omitted)/` → `java`

## Dependencies

This module depends on:
- Fluent Bit core libraries
- Multiline processing headers
- Parser management functionality (flb_ml_parser.c)
- Rule processing functionality (flb_ml_rule.c)
- Regular expression library

## Implementation Details

The Java parser handles multiline messages from Java applications, particularly:
1. **Exception Messages**: Multi-line exception output with stack traces
2. **Nested Exceptions**: Inner exception information
3. **Stack Frames**: Method call stack with class and line information
4. **Suppressed Exceptions**: Additional exception information
5. **Omitted Frames**: References to omitted stack frames

The parser uses a state machine approach where:
- Exception/error/throwable messages start the multiline sequence
- Stack frames continue the sequence with proper indentation
- Nested exceptions and suppressed exceptions create new sequences
- Omitted frame references indicate truncated stack traces
- Empty lines help separate different parts of the exception

## Usage Examples

```c
// Create a Java multiline parser
struct flb_ml_parser *java_parser = flb_ml_parser_java(config, "message");

// This parser will automatically concatenate Java exception messages
// and stack traces until a complete sequence is formed
```