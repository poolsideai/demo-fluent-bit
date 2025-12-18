# ra.y Documentation

## Overview

This file contains the parser grammar definition for the Record Accessor system in Fluent Bit. It uses Bison to define the syntax and semantics of record accessor expressions, enabling the interpretation of complex data access patterns in structured records.

## Key Components

### Parser Configuration
- `%define api.pure full` - Enables pure parser mode for reentrancy
- `%name-prefix "flb_ra_"` - Sets the prefix for generated parser functions
- `%parse-param` and `%lex-param` - Define parameters passed to parser and lexer functions

### Token Declarations
- `%token IDENTIFIER STRING INTEGER` - Declares the tokens recognized by the parser

### Union Definition
Defines the data types that can be returned by parser rules:
- Integer values
- Float values
- String values
- Command structures
- Expression structures

### Type Specifications
- `%type <string> IDENTIFIER` - Specifies that IDENTIFIER tokens return strings
- `%type <integer> INTEGER` - Specifies that INTEGER tokens return integers
- `%type <string> STRING` - Specifies that STRING tokens return strings
- `%type <string> record_key` - Specifies that record_key rules return strings

### Destructor Rules
- `%destructor { flb_free ($$); } IDENTIFIER` - Automatically frees memory for IDENTIFIER tokens
- `%destructor { flb_free ($$); } STRING` - Automatically frees memory for STRING tokens

## Grammar Rules

### statements
The top-level rule that parses record accessor expressions.

### record_accessor
Parses record accessor strings like `$key` or `$key['x']`.

### record_key
Handles the main record key parsing:
- `$` followed by an IDENTIFIER (simple key access)
- `$` followed by an IDENTIFIER and record_subkey (complex key access)

### record_subkey
Handles nested key access patterns:
- Can be a chain of subkey indices
- Or a single subkey index

### record_subkey_index
Defines how to access sub-elements:
- String-based access: `[STRING]`
- Integer-based access: `[INTEGER]`

## Dependencies

- `<stdio.h>` - Standard input/output functions
- `<stdlib.h>` - Standard library functions
- `<fluent-bit/flb_info.h>` - Core Fluent Bit information
- `<fluent-bit/flb_mem.h>` - Memory management utilities
- `<fluent-bit/flb_log.h>` - Logging utilities
- `<fluent-bit/flb_slist.h>` - Simple linked list implementation
- `<fluent-bit/record_accessor/flb_ra_parser.h>` - Record accessor parser header
- `ra_parser.h` - Internal parser definitions
- `ra_lex.h` - Lexical analyzer header

## Relationships

This parser works in conjunction with:
- `ra.l` - The lexical analyzer definition
- `flb_ra_parser.c` - The main parser implementation

## Implementation Details

The implementation features:
1. Pure parser mode for thread safety
2. Reentrant design supporting multiple concurrent parsers
3. Automatic memory management through destructors
4. Comprehensive error handling with verbose error messages
5. Support for both string and integer-based array indexing

## Usage Context

This parser is used internally by the record accessor system to interpret expressions like:
- `$.field` - Access a top-level field
- `$.field['subfield']` - Access a nested field by string key
- `$.field[0]` - Access an array element by index
- `$.field['subfield'][1]` - Access nested array elements

The parser converts these expressions into executable record accessor operations that can extract data from structured records in various formats.