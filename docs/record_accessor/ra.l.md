# ra.l Documentation

## Overview

This file contains the lexical analyzer (lexer) definition for the Record Accessor parser in Fluent Bit. It uses Flex to tokenize record accessor expressions, enabling the parsing of complex data access patterns in structured records.

## Key Components

### Flex Options
- `%option prefix="flb_ra_"` - Sets the prefix for generated functions
- `%option caseless` - Makes the lexer case-insensitive
- `%option 8bit reentrant bison-bridge` - Enables reentrant mode with Bison integration
- `%option warn noyywrap nodefault` - Configures warning behavior and disables default actions
- `%option nounput` - Disables yyunput function generation
- `%option noinput` - Disables yyinput function generation

### Token Definitions

#### INTEGER
Matches integer values (0-9) and converts them to integers.

#### STRING
Matches quoted strings, handling escaped quotes by removing duplicate quotes.

#### IDENTIFIER
Matches identifiers consisting of letters, numbers, underscores, dots, hyphens, and slashes.

#### Special Characters
Tokens for `$`, `[`, `]`, `.`, `,`, and `;` characters used in record accessor syntax.

### Helper Functions

#### remove_dup_quotes()
Removes duplicate quotes from string literals to properly handle escaped quotes in the input.

## Dependencies

- `<stdio.h>` - Standard input/output functions
- `<stdbool.h>` - Boolean type definitions
- `<fluent-bit/flb_str.h>` - Fluent Bit string utilities
- `<fluent-bit/flb_log.h>` - Logging utilities
- `<fluent-bit/record_accessor/flb_ra_parser.h>` - Record accessor parser header
- `ra_parser.h` - Internal parser definitions

## Relationships

This lexer works in conjunction with:
- `ra.y` - The parser grammar definition
- `flb_ra_parser.c` - The main parser implementation

## Implementation Details

The implementation features:
1. Case-insensitive tokenization
2. Proper handling of quoted strings with escaped quotes
3. Reentrant design for thread safety
4. Integration with Bison parser
5. Custom error handling for invalid input characters

## Usage Context

This lexer is used internally by the record accessor system to parse expressions like:
- `$.field.subfield[0]`
- `$[1]`
- `"quoted string"`
- `identifier.name`

The lexer processes these expressions into tokens that the parser can understand and convert into executable record accessor operations.