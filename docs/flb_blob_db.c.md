# flb_blob_db.c

## Overview

This file implements a blob database interface for Fluent Bit using SQLite as the backend. It provides persistent storage for blob files and their associated metadata, particularly for handling large binary data that needs to be processed in chunks.

The module handles:
- Database initialization and connection management
- Blob file metadata storage and retrieval
- File part tracking for chunked processing
- Remote ID management for distributed systems
- Delivery attempt counting for retry mechanisms
- File state management (aborted, stale, ready)
- Thread-safe operations with locking mechanisms

## Key Functions

### `flb_blob_db_open()`
Opens a connection to the blob database, creating tables if they don't exist and preparing SQL statements for efficient execution.

### `flb_blob_db_close()`
Closes the database connection and cleans up prepared statements.

### `flb_blob_db_file_insert()`
Inserts a new blob file record into the database with metadata including tag, source, destination, path, and size.

### `flb_blob_db_file_delete()`
Removes a blob file record from the database.

### `flb_blob_db_file_get_next_stale()`
Retrieves the next stale file (files that haven't been processed recently) for cleanup or retry operations.

### `flb_blob_db_file_get_next_aborted()`
Retrieves the next aborted file for recovery operations.

### `flb_blob_db_file_part_insert()`
Inserts a file part record for chunked processing of large files.

### `flb_blob_db_file_part_get_next()`
Retrieves the next file part to process for upload operations.

## Important Variables/Constants

### Data Structures
- `struct flb_blob_db`: Main database context containing SQLite connection and prepared statements
- `struct flb_sqldb`: SQLite database wrapper
- `sqlite3_stmt`: Prepared SQL statements for efficient execution

### SQL Statements
- `SQL_INSERT_FILE`: Insert new blob file record
- `SQL_DELETE_FILE`: Delete blob file record
- `SQL_SET_FILE_ABORTED_STATE`: Update file aborted state
- `SQL_UPDATE_FILE_REMOTE_ID`: Update file remote ID
- `SQL_UPDATE_FILE_DESTINATION`: Update file destination
- `SQL_UPDATE_FILE_DELIVERY_ATTEMPT_COUNT`: Update delivery attempt counter
- `SQL_GET_FILE`: Retrieve file by path
- `SQL_GET_FILE_PART_COUNT`: Get count of file parts
- `SQL_GET_NEXT_ABORTED_FILE`: Get next aborted file
- `SQL_GET_NEXT_STALE_FILE`: Get next stale file
- `SQL_RESET_FILE_UPLOAD_STATES`: Reset file upload states
- `SQL_RESET_FILE_PART_UPLOAD_STATES`: Reset file part upload states
- `SQL_INSERT_FILE_PART`: Insert file part record
- `SQL_UPDATE_FILE_PART_REMOTE_ID`: Update file part remote ID
- `SQL_GET_FILE_PART_REMOTE_ID`: Get file part remote ID
- `SQL_UPDATE_FILE_PART_UPLOADED`: Mark file part as uploaded
- `SQL_GET_NEXT_FILE_PART`: Get next file part to process
- `SQL_UPDATE_FILE_PART_IN_PROGRESS`: Update file part in-progress flag
- `SQL_UPDATE_FILE_PART_DELIVERY_ATTEMPT_COUNT`: Update file part delivery attempt counter
- `SQL_GET_OLDEST_FILE_WITH_PARTS`: Get oldest file with parts ready for commit

### Error Codes
- `FLB_BLOB_DB_SUCCESS`: Operation successful
- `FLB_BLOB_DB_ERROR_*`: Various error conditions for different failure scenarios

## Dependencies

- `fluent-bit/flb_sqldb.h`: SQLite database wrapper
- `fluent-bit/flb_blob_db.h`: Blob database interface headers
- `sqlite3`: SQLite database library
- `cfl/cfl_sds.h`: String data structure utilities
- `fluent-bit/flb_lock.h`: Thread locking utilities
- `time.h`: Time functions
- `errno.h`: Error handling

## Implementation Details

1. **Conditional Compilation**: The implementation is only compiled when `FLB_HAVE_SQLDB` is defined, providing a fallback implementation that returns errors when disabled.

2. **Prepared Statements**: All SQL operations use prepared statements for better performance and security against SQL injection.

3. **Thread Safety**: Uses mutex locks to ensure thread-safe database operations.

4. **Memory Management**: Properly manages string allocations using CFL SDS (String Data Structure) and cleans up resources on errors.

5. **Error Handling**: Comprehensive error handling with specific error codes for different failure scenarios.

6. **Chunked Processing**: Supports processing large files in chunks through file part tracking.

7. **State Management**: Tracks file states including aborted, stale, and ready for processing.

8. **Retry Mechanisms**: Maintains delivery attempt counters for retry logic.

## Usage Example

```c
// Open blob database
struct flb_blob_db context;
int result = flb_blob_db_open(&context, config, "/var/lib/fluent-bit/blobs.db");

if (result == FLB_BLOB_DB_SUCCESS) {
    // Insert a new blob file
    int64_t file_id = flb_blob_db_file_insert(&context, 
                                              "my_tag", 
                                              "source_system", 
                                              "destination_system", 
                                              "/path/to/file.bin", 
                                              1024);
    
    if (file_id > 0) {
        // Insert file parts for chunked processing
        int64_t part_id;
        flb_blob_db_file_part_insert(&context, file_id, 1, 0, 512, &part_id);
        flb_blob_db_file_part_insert(&context, file_id, 2, 512, 1024, &part_id);
    }
    
    // Process files
    uint64_t file_id, part_id;
    off_t offset_start, offset_end;
    cfl_sds_t file_path, destination, remote_id, tag;
    
    while (flb_blob_db_file_part_get_next(&context, &file_id, &file_id, &part_id,
                                          &offset_start, &offset_end, NULL, NULL,
                                          &file_path, &destination, &remote_id, &tag) == SQLITE_ROW) {
        // Process the file part
        // Upload to destination, etc.
        
        // Mark as uploaded
        flb_blob_db_file_part_uploaded(&context, file_id);
        
        // Cleanup strings
        cfl_sds_destroy(file_path);
        cfl_sds_destroy(destination);
        cfl_sds_destroy(remote_id);
        cfl_sds_destroy(tag);
    }
    
    // Close database
    flb_blob_db_close(&context);
}
```