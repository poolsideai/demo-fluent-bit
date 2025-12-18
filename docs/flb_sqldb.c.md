# flb_sqldb.c

## Overview

The `flb_sqldb.c` file implements SQLite database wrapper functionality for Fluent Bit. This module provides a thread-safe interface for working with SQLite databases, including connection management, query execution, and resource handling.

This implementation wraps the SQLite C API to provide Fluent Bit-specific features such as database sharing across multiple instances, thread safety through locking mechanisms, and integration with Fluent Bit's configuration system.

Key features:
- Thread-safe SQLite database operations
- Database connection sharing across instances
- Automatic resource management and cleanup
- Integration with Fluent Bit's locking mechanisms
- Support for database queries with callback functions

## Key Functions/Components

### Core Data Structure

#### `struct flb_sqldb`
Represents a SQLite database connection with Fluent Bit extensions:
- `path`: Physical path of the database file
- `desc`: Database description for identification
- `shared`: Flag indicating if this is a shared database handler
- `users`: Number of active users of this database connection
- `parent`: Reference to parent database if this is a shared context
- `handler`: SQLite3 native database handler
- `lock`: Thread safety mechanism for concurrent access
- `_head`: Linked list node for configuration management

### Main Functions

#### `flb_sqldb_open(const char *path, const char *desc, struct flb_config *config)`
Opens or creates a SQLite database connection:
1. Allocates memory for the database structure
2. Initializes thread safety lock mechanism
3. Checks for existing database connections to share
4. Opens new database connection if none exists
5. Registers database in configuration's database list
6. Returns database handle for subsequent operations

#### `flb_sqldb_close(struct flb_sqldb *db)`
Closes a SQLite database connection:
1. Decrements user count for shared databases
2. Commits pending transactions for exclusive databases
3. Closes SQLite connection for exclusive databases
4. Removes database from configuration list
5. Frees allocated memory and resources

#### `flb_sqldb_query(struct flb_sqldb *db, const char *sql, int (*callback)(void *, int, char **, char **), void *data)`
Executes a SQL query with optional callback processing:
1. Executes SQL statement using SQLite API
2. Calls provided callback function for each result row
3. Handles SQLite errors and provides meaningful error messages
4. Returns success/failure status

#### `flb_sqldb_last_id(struct flb_sqldb *db)`
Retrieves the last inserted row ID:
1. Calls SQLite's `last_insert_rowid()` function
2. Returns the 64-bit integer row ID

#### `flb_sqldb_lock(struct flb_sqldb *db)`
Acquires a lock for thread-safe database operations:
1. Uses Fluent Bit's locking mechanism
2. Implements retry logic with configurable limits
3. Returns success/failure status

#### `flb_sqldb_unlock(struct flb_sqldb *db)`
Releases a previously acquired lock:
1. Uses Fluent Bit's unlocking mechanism
2. Implements retry logic with configurable limits
3. Returns success/failure status

## Important Constants and Definitions

### Lock Constants
- `FLB_LOCK_INFINITE_RETRY_LIMIT`: Retry limit for lock acquisition
- `FLB_LOCK_DEFAULT_RETRY_DELAY`: Default delay between lock retries

### Return Values
- `FLB_OK`: Operation successful
- `FLB_ERROR`: Operation failed

## Dependencies and Relationships

This module depends on:
- `sqlite3`: SQLite database library
- `flb_lock`: Thread safety locking mechanisms
- `flb_mem`: Memory allocation and management
- `flb_str`: String manipulation utilities
- `flb_log`: Logging functions for error reporting

It integrates with:
- Storage layer for persistent data management
- Chunk tracking for log data persistence
- Configuration system for database registration
- Thread-safe operations throughout Fluent Bit

## Implementation Details

### Database Sharing Mechanism
The implementation supports database sharing across multiple Fluent Bit instances:
1. Maintains a global list of open databases in the configuration
2. Checks for existing database connections before creating new ones
3. Increments user count for shared databases
4. Only closes actual SQLite connection when last user disconnects
5. Tracks parent-child relationships for shared contexts

### Thread Safety
Thread safety is implemented through:
1. Fine-grained locking per database connection
2. Configurable retry mechanisms for lock acquisition
3. Proper lock ordering to prevent deadlocks
4. Atomic operations for user count management

### Resource Management
Efficient resource management includes:
1. Automatic cleanup of database structures
2. Proper handling of SQLite connection lifecycle
3. Memory leak prevention through systematic freeing
4. Error handling with graceful resource deallocation

### Error Handling
Comprehensive error handling features:
1. Detailed error messages for SQLite operations
2. Graceful degradation on resource allocation failures
3. Consistent return value conventions
4. Proper cleanup on operation failures

## Usage Examples

### Basic Database Operations
```c
// Open a SQLite database
struct flb_config *config = flb_config_init();
struct flb_sqldb *db = flb_sqldb_open("/tmp/fluent-bit.db", "main storage", config);

if (db) {
    // Execute a simple query
    const char *sql = "CREATE TABLE IF NOT EXISTS logs (id INTEGER PRIMARY KEY, message TEXT);"
    int result = flb_sqldb_query(db, sql, NULL, NULL);
    
    if (result == FLB_OK) {
        printf("Table created successfully\n");
        
        // Insert some data
        sql = "INSERT INTO logs (message) VALUES ('Hello, World!');";
        result = flb_sqldb_query(db, sql, NULL, NULL);
        
        if (result == FLB_OK) {
            int64_t id = flb_sqldb_last_id(db);
            printf("Inserted record with ID: %ld\n", (long) id);
        }
    }
    
    // Close the database
    flb_sqldb_close(db);
} else {
    printf("Failed to open database\n");
}

flb_config_destroy(config);
```

### Query with Callback Processing
```c
// Callback function to process query results
int process_log_callback(void *data, int argc, char **argv, char **azColName) {
    for (int i = 0; i < argc; i++) {
        printf("%s = %s\n", azColName[i], argv[i] ? argv[i] : "NULL");
    }
    printf("\n");
    return 0;
}

// Execute query with callback
struct flb_sqldb *db = flb_sqldb_open("/tmp/fluent-bit.db", "query example", config);
if (db) {
    const char *sql = "SELECT * FROM logs ORDER BY id DESC LIMIT 5;";
    int result = flb_sqldb_query(db, sql, process_log_callback, NULL);
    
    if (result == FLB_OK) {
        printf("Query executed successfully\n");
    } else {
        printf("Query failed\n");
    }
    
    flb_sqldb_close(db);
}
```

### Thread-Safe Operations
```c
// Thread-safe database operation
int safe_database_insert(struct flb_sqldb *db, const char *message) {
    // Acquire lock for thread safety
    if (flb_sqldb_lock(db) != 0) {
        flb_error("Failed to acquire database lock");
        return -1;
    }
    
    // Perform database operation
    char sql[256];
    snprintf(sql, sizeof(sql), "INSERT INTO logs (message) VALUES ('%s');", message);
    
    int result = flb_sqldb_query(db, sql, NULL, NULL);
    
    // Release lock
    flb_sqldb_unlock(db);
    
    return result;
}

// Usage in multi-threaded environment
struct flb_sqldb *db = flb_sqldb_open("/tmp/fluent-bit.db", "thread-safe example", config);
if (db) {
    // Multiple threads can safely use the database
    safe_database_insert(db, "Thread 1 message");
    safe_database_insert(db, "Thread 2 message");
    
    flb_sqldb_close(db);
}
```

### Configuration Example
```ini
[SERVICE]
    # Storage configuration using SQLite backend
    storage.path /var/log/fluent-bit/storage
    storage.sync normal
    storage.checksum off
    storage.backlog.mem_limit 50M
    # Uses SQLite database for persistent storage
    
[INPUT]
    name tail
    path /var/log/app.log
    # Data stored in SQLite database
    
[OUTPUT]
    name stdout
    match *
    # Data retrieved from SQLite database
```

### Integration Pattern
```c
// Typical integration in a storage plugin
struct flb_storage_context {
    struct flb_sqldb *db;
    struct flb_config *config;
};

int storage_plugin_init(struct flb_storage_context *ctx, struct flb_config *config) {
    // Initialize database connection
    ctx->db = flb_sqldb_open(ctx->db_path, "storage backend", config);
    if (!ctx->db) {
        flb_error("Failed to initialize storage database");
        return -1;
    }
    
    // Create necessary tables
    const char *sql = "CREATE TABLE IF NOT EXISTS chunks (" \
                      "id TEXT PRIMARY KEY, " \
                      "data BLOB, " \
                      "created INTEGER);"
                      ";";
    
    int result = flb_sqldb_query(ctx->db, sql, NULL, NULL);
    return result;
}

int storage_plugin_store_chunk(struct flb_storage_context *ctx, 
                               const char *chunk_id, 
                               const char *data, size_t data_len) {
    // Thread-safe chunk storage
    if (flb_sqldb_lock(ctx->db) != 0) {
        return -1;
    }
    
    // Prepare SQL statement
    char sql[512];
    snprintf(sql, sizeof(sql), 
             "INSERT OR REPLACE INTO chunks (id, data, created) VALUES (?, ?, ?);");
    
    // Execute with parameters (simplified)
    sqlite3_stmt *stmt;
    int result = sqlite3_prepare_v2(ctx->db->handler, sql, -1, &stmt, NULL);
    
    if (result == SQLITE_OK) {
        sqlite3_bind_text(stmt, 1, chunk_id, -1, SQLITE_STATIC);
        sqlite3_bind_blob(stmt, 2, data, data_len, SQLITE_STATIC);
        sqlite3_bind_int64(stmt, 3, time(NULL));
        
        result = sqlite3_step(stmt);
        sqlite3_finalize(stmt);
    }
    
    flb_sqldb_unlock(ctx->db);
    return (result == SQLITE_DONE) ? FLB_OK : FLB_ERROR;
}

// Usage
struct flb_storage_context ctx;
storage_plugin_init(&ctx, config);
storage_plugin_store_chunk(&ctx, "chunk123", "log data", 8);
```

### Error Handling Pattern
```c
// Robust database operations with error handling
int safe_database_operation(struct flb_sqldb *db, const char *sql) {
    if (!db || !sql) {
        return -1;
    }
    
    // Acquire lock
    if (flb_sqldb_lock(db) != 0) {
        flb_error("Failed to acquire database lock");
        return -1;
    }
    
    // Execute query
    int result = flb_sqldb_query(db, sql, NULL, NULL);
    
    // Release lock
    flb_sqldb_unlock(db);
    
    if (result != FLB_OK) {
        flb_error("Database query failed: %s", sql);
    }
    
    return result;
}

// Usage
struct flb_sqldb *db = flb_sqldb_open("/tmp/fluent-bit.db", "safe example", config);
if (db) {
    if (safe_database_operation(db, "CREATE TABLE IF NOT EXISTS test (id INTEGER);") == FLB_OK) {
        printf("Table created successfully\n");
    }
    flb_sqldb_close(db);
}
```

### Performance Considerations
```c
// Performance-optimized database operations
void batch_database_operations(struct flb_sqldb *db, const char **sql_statements, int count) {
    // Acquire lock once for batch operations
    if (flb_sqldb_lock(db) != 0) {
        return;
    }
    
    // Begin transaction
    flb_sqldb_query(db, "BEGIN;", NULL, NULL);
    
    // Execute batch operations
    for (int i = 0; i < count; i++) {
        flb_sqldb_query(db, sql_statements[i], NULL, NULL);
    }
    
    // Commit transaction
    flb_sqldb_query(db, "COMMIT;", NULL, NULL);
    
    // Release lock
    flb_sqldb_unlock(db);
}

// Usage
const char *statements[] = {
    "INSERT INTO logs VALUES ('msg1');",
    "INSERT INTO logs VALUES ('msg2');",
    "INSERT INTO logs VALUES ('msg3');"
};

batch_database_operations(db, statements, 3);
```