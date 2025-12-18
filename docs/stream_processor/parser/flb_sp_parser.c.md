# flb_sp_parser.c

## Overview

This file implements the core parser functionality for the Fluent Bit Stream Processor. It provides the interface between the generated lexer/parser (Flex/Bison) and the Stream Processor engine, handling command creation, key management, and query parsing.

## Key Functions

### `flb_sp_cmd_create`

The primary entry point for parsing SQL-like queries into command structures that can be executed by the Stream Processor.

### `flb_sp_cmd_destroy`

Cleans up all resources associated with a parsed command structure.

### `flb_sp_cmd_key_add`

Adds a key specification to a command, handling various key types and aliases.

### `flb_sp_cmd_source`

Sets the data source for a command (stream or tag-based).

### `flb_sp_cmd_window`

Configures window parameters for time-based aggregation operations.

### `flb_sp_cmd_condition_add`

Adds conditional expressions to filter records in queries.

### `flb_sp_cmd_gb_key_add`

Adds group-by keys for aggregation operations.

## Important Variables and Constants

- `FLB_SP_SELECT`: Select command type
- `FLB_SP_CREATE_STREAM`: Create stream command type
- `FLB_SP_CREATE_SNAPSHOT`: Create snapshot command type
- `FLB_SP_FLUSH_SNAPSHOT`: Flush snapshot command type
- `FLB_SP_OK`: Success status code
- `FLB_SP_ERROR`: Error status code
- `RECORD_FUNCTIONS_SIZE`: Size of record function array

## Dependencies

This file depends on:
- `<stdio.h>`: Standard input/output functions
- `<stdlib.h>`: Standard library functions
- `<string.h>`: String manipulation functions
- `<fluent-bit/flb_info.h>`: Core Fluent Bit information
- `<fluent-bit/flb_log.h>`: Logging utilities
- `<fluent-bit/flb_mem.h>`: Memory management utilities
- `<fluent-bit/flb_str.h>`: String utilities
- `<fluent-bit/flb_sds.h>`: Simple Dynamic String utilities
- `<fluent-bit/flb_slist.h>`: Simple linked list utilities
- `<fluent-bit/stream_processor/flb_sp_parser.h>`: Parser definitions
- `<fluent-bit/stream_processor/flb_sp_aggregate_func.h>`: Aggregation functions
- `<fluent-bit/stream_processor/flb_sp_record_func.h>`: Record functions
- `"sql_parser.h"`: Generated parser header
- `"sql_lex.h"`: Generated lexer header

## Implementation Details

### Command Structure Management

The implementation handles complex command structures:
- Manages linked lists for keys, group-by keys, and conditions
- Handles temporary subkey lists for nested key navigation
- Properly allocates and frees memory for all string data
- Maintains command status and error handling

### Key Creation and Management

The `flb_sp_key_create` function handles sophisticated key management:
- Supports various function types (aggregation, time, record functions)
- Handles key aliases and automatic alias generation
- Manages nested subkeys for complex object navigation
- Composes appropriate alias names for aggregation functions

### Condition Handling

Supports complex conditional expressions:
- Logical operations (AND, OR, NOT)
- Comparison operations (=, !=, <, >, etc.)
- Type-specific value handling (integers, floats, strings, booleans)
- Record function calls (contains, time functions)

### Memory Management

The implementation follows strict memory management practices:
- Uses Fluent Bit's memory allocation functions
- Properly initializes and destroys linked lists
- Handles string duplication and cleanup
- Manages temporary data structures
- Provides cleanup functions for all allocated resources

### Data Structure Organization

```
Command Structure
├── Type (SELECT/CREATE_STREAM/etc.)
├── Status
├── Keys (linked list)
├── Group-by Keys (linked list)
├── Source Information
├── Conditions (linked list)
├── Stream Properties (linked list)
├── Temporary Subkeys
├── Window Configuration
├── Limit
└── Alias
```

### Error Handling

Comprehensive error handling is implemented:
- Memory allocation failures
- Invalid command states
- Parsing errors from lexer/parser
- Type conversion issues
- Resource cleanup on errors

### Integration with Generated Parser

The file serves as the bridge between generated code and Stream Processor logic:
- Calls Flex/Bison parser functions
- Processes parser output into command structures
- Handles parser errors and cleanup
- Integrates with Stream Processor execution engine

## Usage Examples

Commands are created from SQL-like strings:
```c
struct flb_sp_cmd *cmd = flb_sp_cmd_create(
    "SELECT key1, COUNT(*) FROM STREAM:input GROUP BY key1 WINDOW TUMBLING(60 SECOND)");

// Use command in Stream Processor
struct flb_sp_task *task = flb_sp_create_task(sp, cmd);

// Clean up
flb_sp_cmd_destroy(cmd);
```

The parser handles complex nested structures and automatically generates appropriate command representations for execution by the Stream Processor engine.