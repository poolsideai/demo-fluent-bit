# README.md Documentation (stream_processor)

## Overview

This README file documents the SQL statement syntax supported by Fluent Bit's Stream Processor component. It provides a comprehensive reference for the EBNF grammar of supported SQL operations, including CREATE STREAM statements, SELECT queries, windowing functions, aggregation functions, and various utility functions.

## Key Components

### SQL Statement Syntax

The Stream Processor supports the following SQL statement syntax in EBNF form:

#### Basic Structure
- `<sql_stmt>` - Either a CREATE STREAM or SELECT statement
- `<create>` - CREATE STREAM statements with optional properties
- `<select>` - SELECT statements with FROM, WHERE, WINDOW, and GROUP BY clauses

#### Properties
- `<properties>` - A list of property assignments
- `<property>` - Individual property assignments in the form `id = 'value'`

#### Select Components
- `<keys>` - Either '*' (all fields) or specific record keys
- `<record_keys>` - A list of record keys
- `<record_key>` - Either an expression or an expression with an alias
- `<exp>` - Either a key or a function
- `<fun>` - Aggregation functions like AVG, SUM, COUNT, MIN, MAX, and TIMESERIES_FORECAST

#### Source and Conditions
- `<source>` - Either a STREAM or TAG source
- `<condition>` - Complex boolean expressions with AND, OR, NOT operators
- `<key>` - Record keys with optional subkey indexing
- `<relation>` - Comparison operators (=, !=, <, <=, >, >=)

### Supported Functions

#### Timeseries Functions
- `TIMESERIES_FORECAST(x, t)` - Forecasts the value of x at current time + t seconds using simple linear regression

#### Time Functions
- `NOW()` - Returns system time in format: %Y-%m-%d %H:%M:%S
- `UNIX_TIMESTAMP()` - Returns current Unix timestamp

#### Record Functions
- `RECORD_TAG()` - Appends the Tag string associated with the record
- `RECORD_TIME()` - Appends record Timestamp in double format: seconds.nanoseconds

### Window Types

#### Hopping Window
- Slides forward by a specified interval while maintaining a fixed window size
- Syntax: `WINDOW HOPPING (<integer> SECOND, ADVANCE BY <integer> SECOND)`
- Allows overlapping windows for continuous analysis

#### Tumbling Window
- Non-overlapping windows where each new window starts after the previous one completes
- Syntax: `WINDOW TUMBLING (<integer> SECOND)`
- Equivalent to hopping window where advance interval equals window size

## Important Syntax Elements

### Identifiers
- `<id>` - Identifiers starting with a letter followed by letters, digits, or underscores
- `<subkey-idx>` - Subkey indexing using bracket notation `[id]`

### Values
- Boolean values: `true`, `false`
- Numeric values: integers and floats
- String values: quoted strings with escaped single quotes

## Dependencies

This documentation assumes familiarity with:
- SQL syntax concepts
- Time series analysis principles
- Fluent Bit's stream processing architecture

## Relationships

This syntax specification relates to:
- The stream processor parser implementation
- The stream processor execution engine
- Fluent Bit's overall data processing pipeline
- Other Fluent Bit components that consume processed streams

## Implementation Details

The Stream Processor implements:
1. Full SQL-like syntax for stream processing operations
2. Efficient windowing mechanisms for time-based aggregations
3. Mathematical forecasting capabilities using linear regression
4. Flexible source selection (STREAM or TAG based)
5. Complex conditional filtering with boolean logic
6. Proper handling of nested record structures through subkey indexing

## Usage Examples

```sql
-- Create a stream with tumbling window aggregation
CREATE STREAM aggregated AS 
SELECT AVG(cpu) as avg_cpu, COUNT(*) as count 
FROM STREAM:input 
WINDOW TUMBLING (10 SECOND);

-- Create a stream with hopping window and filtering
CREATE STREAM filtered_hopping AS 
SELECT STREAM_KEY, VALUE 
FROM STREAM:data 
WHERE VALUE > 100 
WINDOW HOPPING (30 SECOND, ADVANCE BY 5 SECOND);

-- Use timeseries forecasting
CREATE STREAM forecast AS 
SELECT TIMESERIES_FORECAST(metric, 60) as predicted_value 
FROM STREAM:metrics;
```

The Stream Processor enables powerful real-time analytics on log data streams using familiar SQL syntax, making it accessible to developers and analysts alike.