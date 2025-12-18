# sql.y

## Overview

This file defines the grammar specification for the Fluent Bit Stream Processor using Bison. It specifies the syntax rules for SQL-like queries and defines how parsed tokens should be processed to create command structures for the Stream Processor engine.

## Key Components

### Bison Options

The file begins with Bison configuration directives:
- `%name-prefix="flb_sp_"` (deprecated): Sets prefix for generated functions
- `%define api.pure full`: Enables pure (reentrant) parser
- `%define parse.error verbose`: Provides detailed error messages
- `%parse-param` and `%lex-param`: Define parser and lexer parameters

### Token Definitions

Defines all tokens produced by the lexer (`sql.l`):
- Keywords: `CREATE`, `STREAM`, `SNAPSHOT`, `FLUSH`, `WITH`, `SELECT`, etc.
- Functions: `AVG`, `SUM`, `COUNT`, `NOW`, `RECORD_TAG`, etc.
- Value types: `INTEGER`, `FLOATING`, `STRING`, `BOOLTYPE`
- Logical operations: `AND`, `OR`, `NOT`, `NEQ`, `LT`, `LTE`, `GT`, `GTE`
- Time units: `HOUR`, `MINUTE`, `SECOND`
- Window types: `TUMBLING`, `HOPPING`, `ADVANCE_BY`

### Union Types

Defines the semantic value types used throughout the grammar:
- `bool boolean`: Boolean values
- `int integer`: Integer values
- `float fval`: Floating-point values
- `char *string`: String values
- `struct flb_sp_cmd *cmd`: Command structures
- `struct flb_exp *expression`: Expression structures

## Grammar Rules

### Statements

```bison
statements: create | select
```

Top-level rule for processing either CREATE or SELECT statements.

### CREATE Statements

Supports multiple CREATE variants:
- `CREATE STREAM` for creating new streams
- `CREATE SNAPSHOT` for creating snapshot storage
- `FLUSH SNAPSHOT` for flushing snapshot data

Each variant calls appropriate command creation functions and handles WITH clauses for properties.

### SELECT Statements

```bison
select: SELECT keys FROM source window where groupby limit ';'
```

Complete SELECT statement structure with optional clauses.

### Key Specifications

Handles various key formats:
- Wildcard (`*`) for selecting all keys
- Simple identifiers
- Nested keys with bracket notation
- Aggregation functions with parameters
- Time series forecasting functions
- Time and record functions

### Source Specifications

Supports two source types:
- `FROM_STREAM` for stream-based sources
- `FROM_TAG` for tag-based sources

### Window Specifications

Supports window definitions:
- `TUMBLING` windows with time specifications
- `HOPPING` windows with advance intervals

### WHERE Clause

Handles conditional expressions:
- Simple comparisons
- Logical combinations (AND, OR, NOT)
- Parenthetical grouping
- Record function calls

### GROUP BY Clause

Specifies grouping keys for aggregation operations.

### LIMIT Clause

Sets maximum record limits for queries.

## Dependencies

This grammar specification depends on:
- `<stdio.h>`: Standard input/output functions
- `<stdlib.h>`: Standard library functions
- `<ctype.h>`: Character type functions
- `<fluent-bit/flb_mem.h>`: Memory management utilities
- `<fluent-bit/flb_slist.h>`: Linked list utilities
- `<fluent-bit/stream_processor/flb_sp_parser.h>`: Parser definitions
- `"sql_parser.h"`: Generated parser header
- `"sql_lex.h"`: Generated lexer header

## Implementation Details

### Error Handling

The `yyerror` function provides detailed error reporting:
```c
void yyerror(struct flb_sp_cmd *cmd, const char *query, void *scanner, const char *str)
{
    flb_error("[sp] %s at '%s'", str, query);
}
```

### Memory Management

The grammar carefully manages memory:
- Duplicates strings for safe storage
- Frees temporary allocations
- Uses Fluent Bit's memory allocation functions
- Handles cleanup on parsing errors

### Command Building

Grammar actions build command structures incrementally:
- Creates command contexts
- Adds keys and properties
- Configures sources and windows
- Sets up conditions and limits

### Expression Handling

Supports complex expressions:
- Logical operations with proper precedence
- Comparison operations
- Record function calls
- Nested expressions with parentheses

### Destructor Rules

Proper cleanup of semantic values:
```bison
%destructor { flb_free ($$); } IDENTIFIER
```

## Grammar Structure

The grammar follows a hierarchical structure:
```
Statements
├── CREATE Statements
│   ├── STREAM Creation
│   ├── SNAPSHOT Creation
│   └── FLUSH Operations
└── SELECT Statement
    ├── Keys
    │   ├── Simple Keys
    │   ├── Nested Keys
    │   ├── Aggregation Functions
    │   └── Special Functions
    ├── Source
    ├── Window
    ├── WHERE Clause
    ├── GROUP BY Clause
    └── LIMIT Clause
```

## Usage Examples

The grammar successfully parses complex queries like:
```sql
CREATE STREAM processed_data WITH(tag='processed', routable='true') AS 
SELECT record.key1.subkey AS alias, COUNT(*) FROM STREAM:input 
WHERE record.key2 > 100 
GROUP BY record.key1 
WINDOW TUMBLING(60 SECOND) 
LIMIT 1000;
```

Each grammar rule processes tokens and builds appropriate command structures that can be executed by the Stream Processor engine.

The generated parser (`sql_parser.c`) is compiled and linked with the lexer to form the complete query processing pipeline for the Stream Processor.