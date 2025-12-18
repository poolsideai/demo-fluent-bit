# flb_sqldb.c and flb_sqldb.h Documentation

## Overview

The `flb_sqldb` module provides a SQLite database wrapper for Fluent Bit. This implementation offers thread-safe access to SQLite databases with connection sharing capabilities, allowing multiple Fluent Bit components to efficiently share database connections.

## Data Structures

### struct flb_sqldb

Represents a SQLite database context with thread safety and sharing capabilities.

```c
struct flb_sqldb {
    char *path;               /* physical path of the database */
    char *desc;               /* database description          */
    int shared;               /* is it a shared handler ?      */
    int users;                /* number of active users        */
    void *parent;             /* if shared, ref to parent      */
    sqlite3 *handler;         /* SQLite3 handler               */
    flb_lock_t lock;          /* thread safety mechanism       */
    struct mk_list _head;     /* Link to config->sqldb_list    */
};
```

## Key Functions

### flb_sqldb_open()

```c
struct flb_sqldb *flb_sqldb_open(const char *path, const char *desc,
                                 struct flb_config *config);
```

Opens or creates a SQLite database connection. If a database with the same path is already open, it shares the connection instead of creating a new one.

**Parameters:**
- `path`: Physical path to the database file
- `desc`: Description of the database for logging purposes
- `config`: Fluent Bit configuration context

**Returns:**
- Pointer to the database context on success
- `NULL` on error

### flb_sqldb_close()

```c
int flb_sqldb_close(struct flb_sqldb *db);
```

Closes a database connection. If the connection is shared, it decrements the user count instead of closing the actual connection.

**Parameters:**
- `db`: Database context to close

**Returns:**
- `0` on success
- `-1` on error

### flb_sqldb_query()

```c
int flb_sqldb_query(struct flb_sqldb *db, const char *sql,
                    int (*callback) (void *, int, char **, char **),
                    void *data);
```

Executes a SQL query with an optional callback function for processing results.

**Parameters:**
- `db`: Database context
- `sql`: SQL query string
- `callback`: Optional callback function for processing results
- `data`: User data passed to the callback

**Returns:**
- `FLB_OK` on success
- `FLB_ERROR` on error

### flb_sqldb_last_id()

```c
int64_t flb_sqldb_last_id(struct flb_sqldb *db);
```

Retrieves the last inserted row ID from the database.

**Parameters:**
- `db`: Database context

**Returns:**
- Last inserted row ID

### flb_sqldb_lock()

```c
int flb_sqldb_lock(struct flb_sqldb *db);
```

Acquires a lock on the database for thread-safe operations.

**Parameters:**
- `db`: Database context

**Returns:**
- `0` on success
- `-1` on error

### flb_sqldb_unlock()

```c
int flb_sqldb_unlock(struct flb_sqldb *db);
```

Releases a lock on the database.

**Parameters:**
- `db`: Database context

**Returns:**
- `0` on success
- `-1` on error

## Implementation Details

### Connection Sharing

The implementation optimizes database usage by:
- Checking for existing connections with the same path
- Sharing SQLite handlers when possible
- Tracking the number of active users
- Only closing the actual connection when the last user releases it

### Thread Safety

Each database context includes a mutex lock to ensure thread-safe operations:
- Lock acquisition before database operations
- Lock release after operations complete
- Proper cleanup of locks during close operations

### Error Handling

The implementation handles SQLite errors gracefully:
- Proper error message reporting
- Resource cleanup on failure
- Consistent return codes

## Usage Example

```c
#include <fluent-bit/flb_sqldb.h>
#include <fluent-bit/flb_config.h>
#include <fluent-bit/flb_log.h>

// Callback function for query results
int query_callback(void *data, int argc, char **argv, char **azColName) {
    int i;
    printf("Query Result:\n");
    for (i = 0; i < argc; i++) {
        printf("%s = %s\n", azColName[i], argv[i] ? argv[i] : "NULL");
    }
    printf("\n");
    return 0;
}

// Open a database
struct flb_sqldb *db = flb_sqldb_open("/tmp/fluent-bit.db", "Storage DB", config);
if (db == NULL) {
    flb_error("Failed to open database");
    return -1;
}

// Create a table
const char *create_table_sql = 
    "CREATE TABLE IF NOT EXISTS logs (id INTEGER PRIMARY KEY, message TEXT, timestamp INTEGER);";

if (flb_sqldb_query(db, create_table_sql, NULL, NULL) != FLB_OK) {
    flb_error("Failed to create table");
    flb_sqldb_close(db);
    return -1;
}

// Insert a record
const char *insert_sql = 
    "INSERT INTO logs (message, timestamp) VALUES ('Hello World', 1634567890);";

if (flb_sqldb_query(db, insert_sql, NULL, NULL) != FLB_OK) {
    flb_error("Failed to insert record");
    flb_sqldb_close(db);
    return -1;
}

// Get the last inserted ID
int64_t last_id = flb_sqldb_last_id(db);
flb_info("Last inserted ID: %ld", (long) last_id);

// Query records with callback
const char *select_sql = "SELECT * FROM logs;";

if (flb_sqldb_query(db, select_sql, query_callback, NULL) != FLB_OK) {
    flb_error("Failed to query records");
    flb_sqldb_close(db);
    return -1;
}

// Close the database
if (flb_sqldb_close(db) != 0) {
    flb_error("Failed to close database");
    return -1;
}

return 0;
```