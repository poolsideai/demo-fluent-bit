# flb_conditionals.c

## Overview

The `flb_conditionals.c` file implements a conditional evaluation system for Fluent Bit. This system allows defining conditions based on record fields and values, which can be used for routing decisions, filtering, and other logic that needs to evaluate whether certain criteria are met.

The implementation supports various operators for comparing field values, including equality checks, numeric comparisons, regular expressions, and membership tests. Conditions can be combined using AND/OR logic.

## Key Functions

### `flb_condition_create`
Creates a new condition with the specified logical operator (AND or OR).

### `flb_condition_add_rule`
Adds a rule to a condition. Each rule consists of:
- A field name (using record accessor syntax)
- An operator for comparison
- A value or values to compare against
- Context specification (body or metadata)

### `flb_condition_destroy`
Frees all memory associated with a condition and its rules.

### `flb_condition_evaluate`
Evaluates a condition against a record. Returns TRUE if the condition is satisfied.

## Data Structures

### `struct flb_condition`
Represents a condition with:
- Logical operator (AND/OR)
- List of rules that make up the condition

### `struct flb_condition_rule`
Represents a single rule within a condition:
- Record accessor for field extraction
- Context type (body or metadata)
- Comparison operator
- Value(s) to compare against
- Regex pattern for regex operations

## Operators

The system supports the following operators:
- `FLB_RULE_OP_EQ`: Equality check
- `FLB_RULE_OP_NEQ`: Inequality check
- `FLB_RULE_OP_GT`: Greater than
- `FLB_RULE_OP_LT`: Less than
- `FLB_RULE_OP_GTE`: Greater than or equal
- `FLB_RULE_OP_LTE`: Less than or equal
- `FLB_RULE_OP_REGEX`: Regular expression match
- `FLB_RULE_OP_NOT_REGEX`: Regular expression non-match
- `FLB_RULE_OP_IN`: Membership test
- `FLB_RULE_OP_NOT_IN`: Non-membership test

## Dependencies

This module depends on:
- `flb_cfl_record_accessor`: For field extraction from records
- `flb_regex`: For regular expression operations
- `flb_mp`: For message pack handling
- `mk_core`: For linked list operations

## Implementation Details

The evaluation process:
1. Iterates through all rules in the condition
2. Uses record accessor to extract field values from the record
3. Applies the appropriate comparison operator
4. Combines results according to the logical operator (short-circuiting for performance)

For AND conditions, evaluation stops at the first FALSE result.
For OR conditions, evaluation stops at the first TRUE result.

## Usage Example

```c
// Create an AND condition
struct flb_condition *cond = flb_condition_create(FLB_COND_OP_AND);

// Add a rule: field 'status' equals 'error'
flb_condition_add_rule(cond, "status", FLB_RULE_OP_EQ, "error", 1, RECORD_CONTEXT_BODY);

// Add another rule: field 'level' greater than 5
double level_val = 5.0;
flb_condition_add_rule(cond, "level", FLB_RULE_OP_GT, &level_val, 1, RECORD_CONTEXT_BODY);

// Evaluate against a record
int result = flb_condition_evaluate(cond, record);

// Clean up
flb_condition_destroy(cond);
```