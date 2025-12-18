# sql.l

## Overview

This file defines the lexical analyzer specification for the Fluent Bit Stream Processor using Flex. It specifies how to tokenize SQL-like query strings into meaningful tokens that can be parsed by the Bison-generated parser.

## Key Components

### Flex Options

The file begins with Flex options that configure the lexer behavior:
- `%option prefix="flb_sp_"`: Sets the prefix for generated functions to avoid naming conflicts
- `%option caseless`: Makes the lexer case-insensitive
- `%option 8bit reentrant bison-bridge`: Enables 8-bit character support, reentrant operation, and Bison integration
- `%option warn noyywrap nodefault`: Enables warnings, disables yywrap, and uses default rules
- `%option nounput noinput`: Disables unused functions

### Helper Functions

#### `remove_dup_qoutes`

Removes duplicate quotes from string literals to handle escaped quotes properly.

#### `to_upper`

Converts strings to uppercase for case-insensitive keyword matching.

#### `func_to_code`

Maps function names to their corresponding numeric codes for efficient processing.

## Token Definitions

### SQL Keywords

- `CREATE`, `STREAM`, `SNAPSHOT`, `FLUSH`, `WITH`, `SELECT`, `AS`, `FROM`, `WHERE`, `AND`, `OR`, `NOT`, `WINDOW`, `GROUP BY`, `LIMIT`
- `IS`, `NULL`

### Aggregation Functions

- `SUM`, `AVG`, `COUNT`, `MIN`, `MAX`, `TIMESERIES_FORECAST`

### Record Functions

- `@RECORD`, `CONTAINS`, `TIME`

### Window Types

- `TUMBLING`, `HOPPING`, `ADVANCE BY`

### Time Units

- `HOUR`, `MINUTE`, `SECOND`

### Time Functions

- `NOW`, `UNIX_TIMESTAMP`

### Record Information Functions

- `RECORD_TAG`, `RECORD_TIME`

### Value Types

- `INTEGER`: Integer literals
- `FLOATING`: Floating-point literals
- `STRING`: String literals
- `BOOLTYPE`: Boolean literals (`true`, `false`)

### Logical Operations

- `NEQ`: Not equal (`!=`, `<>`)
- `LT`: Less than (`<`)
- `LTE`: Less than or equal (`<=`)
- `GT`: Greater than (`>`)
- `GTE`: Greater than or equal (`>=`)

### Special Characters

- `*`, `,`, `=`, `(`, `)`, `[`, `]`, `.`, `;`
- `QUOTE`: Single quote character

## Pattern Matching Rules

### Integer Literals

```flex
-?[1-9][0-9]*|0
```

Matches integer values (positive, negative, and zero).

### Floating-point Literals

```flex
(-?[1-9][0-9]*|0)\.[0-9]+
```

Matches floating-point values with decimal points.

### String Literals

```flex
'([^']|'{2})*'
```

Matches quoted strings, handling escaped quotes properly.

### Identifiers

```flex
[_A-Za-z][A-Za-z0-9_.]*
```

Matches valid identifier names (starting with letter or underscore, followed by letters, digits, underscores, or dots).

### Whitespace

```flex
[ \t]+
```

Ignores whitespace characters.

### Error Handling

```flex
.
flb_error("[sp] bad input character '%s' at line %d", yytext, yylineno);
```

Reports unrecognized characters as errors.

## Dependencies

This lexer specification depends on:
- `<stdio.h>`: Standard input/output functions
- `<stdbool.h>`: Boolean type support
- `<ctype.h>`: Character type functions
- `<fluent-bit/flb_str.h>`: Fluent Bit string utilities
- `<fluent-bit/flb_log.h>`: Logging utilities
- `"sql_parser.h"`: Generated parser header
- `<fluent-bit/stream_processor/flb_sp_parser.h>`: Stream processor parser definitions

## Implementation Details

### Case Insensitive Processing

The `%option caseless` directive makes all keyword matching case-insensitive, allowing queries like:
```sql
select key from stream:input;
SELECT KEY FROM STREAM:INPUT;
```

### Function Code Mapping

The `func_to_code` function efficiently maps function names to numeric codes:
- Aggregation functions: `FLB_SP_AVG`, `FLB_SP_SUM`, etc.
- Time functions: `FLB_SP_NOW`, `FLB_SP_UNIX_TIMESTAMP`
- Record functions: `FLB_SP_RECORD_TAG`, `FLB_SP_RECORD_TIME`

### String Literal Processing

The lexer handles escaped quotes in string literals:
```sql
SELECT 'It\'s a test' FROM STREAM:input;
```

### Memory Management

String literals are properly duplicated using `flb_strdup` and `flb_malloc` for safe memory handling.

### Error Reporting

Invalid characters trigger error messages with position information for debugging.

### Token Value Assignment

Numeric values are parsed using standard library functions (`atoi`, `atof`) and assigned to the appropriate union fields in the parser value structure.

## Usage Examples

The lexer processes SQL-like queries such as:
```sql
CREATE STREAM processed_data WITH(tag='processed') AS 
SELECT key1, COUNT(*) FROM STREAM:input GROUP BY key1 
WINDOW TUMBLING(60 SECOND);
```

Each token is identified and passed to the parser with appropriate semantic values:
- Keywords are identified by their token types
- Literals have their parsed values stored in the parser value union
- Identifiers are duplicated as strings for safe memory handling

The generated lexer (`sql_lex.c`) is compiled and linked with the parser to form the complete query processing pipeline.