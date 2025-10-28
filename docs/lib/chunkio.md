# Chunk I/O

## Overview

Chunk I/O is a library to manage chunks of data in the file system and load in memory upon demand. It's designed to support:

- Fixed path in the file system to organize data (root_path)
- Streams: categorize data into streams
- Multiple data files per stream
- Data file or chunks are composed by:
  - Optional CRC32 content checksum
  - Metadata (optional, up to 65535 bytes)
  - User data

## Key Methods/Functions

### Core Context Management

- `cio_options_init(struct cio_options *options)` - Initialize options structure
- `cio_create(struct cio_options *options)` - Create a new Chunk I/O context
- `cio_destroy(struct cio_ctx *ctx)` - Destroy a Chunk I/O context
- `cio_load(struct cio_ctx *ctx, char *chunk_extension)` - Load existing chunks from disk
- `cio_qsort(struct cio_ctx *ctx, int (*compar)(const void *, const void *))` - Sort chunks

### Configuration

- `cio_set_log_callback(struct cio_ctx *ctx, void (*log_cb))` - Set custom logging callback
- `cio_set_log_level(struct cio_ctx *ctx, int level)` - Set logging level
- `cio_set_max_chunks_up(struct cio_ctx *ctx, int n)` - Set maximum number of chunks to keep in memory
- `cio_set_realloc_size_hint(struct cio_ctx *ctx, size_t realloc_size_hint)` - Set size hint for chunk reallocation
- `cio_enable_file_trimming(struct cio_ctx *ctx)` - Enable automatic file trimming
- `cio_disable_file_trimming(struct cio_ctx *ctx)` - Disable automatic file trimming

### Metadata Operations

- `cio_meta_write(struct cio_chunk *ch, char *buf, size_t size)` - Write metadata to a chunk
- `cio_meta_cmp(struct cio_chunk *ch, char *meta_buf, int meta_len)` - Compare chunk metadata
- `cio_meta_read(struct cio_chunk *ch, char **meta_buf, int *meta_len)` - Read chunk metadata
- `cio_meta_size(struct cio_chunk *ch)` - Get metadata size

## Usage Notes

Chunk I/O uses a root path to store content, where different streams can be defined to store data files called chunks. The file system structure looks like:

```
root_path/
root_path/stream_1/
root_path/stream_1/chunk1
root_path/stream_1/chunk2
root_path/stream_1/chunkN
root_path/stream_N
```

Each chunk file has the following layout:

```
+--------------+----------------+
|     0xC1     |     0x00       +--> Header 2 bytes
+--------------+----------------+
|    4 BYTES CRC32 + 16 BYTES   +--> CRC32(Content) + Padding
+-------------------------------+
|            Content            |
|  +-------------------------+  |
|  |         2 BYTES         +-----> Metadata Length
|  +-------------------------+  |
|  +-------------------------+  |
|  |                         |  |
|  |        Metadata         +-----> Optional Metadata (up to 65535 bytes)
|  |                         |  |
|  +-------------------------+  |
|  +-------------------------+  |
|  |                         |  |
|  |       Content Data      +-----> User Data
|  |                         |  |
|  +-------------------------+  |
+-------------------------------+
```

## Examples

Basic usage:

```c
struct cio_options options;
struct cio_ctx *ctx;

cio_options_init(&options);
options.root_path = "/tmp/chunks";

ctx = cio_create(&options);
// ... use ctx ...
cio_destroy(ctx);
```