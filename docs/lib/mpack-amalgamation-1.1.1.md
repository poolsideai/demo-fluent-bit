# MPack Library (v1.1.1)

## Overview

MPack is a C implementation of an encoder and decoder for the [MessagePack](http://msgpack.org/) serialization format. It is:

* Simple and easy to use
* Secure against untrusted data
* Lightweight, suitable for embedded systems
* Extensively documented
* Extremely fast

The core of MPack contains a buffered reader and writer, and a tree-style parser that decodes into a tree of dynamically typed nodes. Helper functions can be enabled to read values of expected type, to work with files, to grow buffers or allocate strings automatically, to check UTF-8 encoding, and more.

MPack supports all modern compilers, all desktop and smartphone operating systems, WebAssembly, inside the Linux kernel, and even 8-bit microcontrollers such as Arduino. The MPack featureset can be customized at compile-time to set which features, components and debug checks are compiled, and what dependencies are available.

## Key Methods/Functions

### Tree Parsing API

- `void mpack_tree_init_data(mpack_tree_t* tree, const char* data, size_t length)` - Initializes a tree parser with a data buffer
- `void mpack_tree_init_filename(mpack_tree_t* tree, const char* filename, size_t max_bytes)` - Initializes a tree parser with a file
- `void mpack_tree_init_stream(mpack_tree_t* tree, mpack_tree_read_t read_fn, void* context, size_t max_bytes)` - Initializes a tree parser with a stream
- `void mpack_tree_init_pool(mpack_tree_t* tree, const char* data, size_t length, mpack_node_data_t* node_pool, size_t node_pool_count)` - Initializes a tree parser with a node pool
- `void mpack_tree_parse(mpack_tree_t* tree)` - Parses the data into a node tree
- `mpack_node_t mpack_tree_root(mpack_tree_t* tree)` - Gets the root node of the parsed tree
- `mpack_error_t mpack_tree_destroy(mpack_tree_t* tree)` - Destroys the tree parser and checks for errors

### Node Access Functions

- `bool mpack_node_bool(mpack_node_t node)` - Reads a boolean value from a node
- `int mpack_node_i32(mpack_node_t node)` - Reads a 32-bit signed integer from a node
- `uint32_t mpack_node_u32(mpack_node_t node)` - Reads a 32-bit unsigned integer from a node
- `float mpack_node_float(mpack_node_t node)` - Reads a float value from a node
- `double mpack_node_double(mpack_node_t node)` - Reads a double value from a node
- `const char* mpack_node_str(mpack_node_t node)` - Reads a string from a node
- `size_t mpack_node_strlen(mpack_node_t node)` - Gets the length of a string in a node
- `mpack_node_t mpack_node_map_cstr(mpack_node_t node, const char* key)` - Gets a map value by string key
- `mpack_node_t mpack_node_array_at(mpack_node_t node, size_t index)` - Gets an array element by index

### Writer API

- `void mpack_writer_init(mpack_writer_t* writer, char* buffer, size_t size)` - Initializes a writer with a buffer
- `void mpack_writer_init_growable(mpack_writer_t* writer, char** data, size_t* size)` - Initializes a writer with a growable buffer
- `void mpack_writer_init_filename(mpack_writer_t* writer, const char* filename)` - Initializes a writer with a file
- `void mpack_writer_init_stdfile(mpack_writer_t* writer, FILE* stdfile, bool close_when_done)` - Initializes a writer with a stdio file
- `void mpack_build_map(mpack_writer_t* writer)` - Starts writing a map (automatically tracks size)
- `void mpack_build_array(mpack_writer_t* writer)` - Starts writing an array (automatically tracks size)
- `void mpack_complete_map(mpack_writer_t* writer)` - Completes writing a map
- `void mpack_complete_array(mpack_writer_t* writer)` - Completes writing an array
- `void mpack_write_bool(mpack_writer_t* writer, bool value)` - Writes a boolean value
- `void mpack_write_i32(mpack_writer_t* writer, int32_t value)` - Writes a 32-bit signed integer
- `void mpack_write_u32(mpack_writer_t* writer, uint32_t value)` - Writes a 32-bit unsigned integer
- `void mpack_write_float(mpack_writer_t* writer, float value)` - Writes a float value
- `void mpack_write_double(mpack_writer_t* writer, double value)` - Writes a double value
- `void mpack_write_cstr(mpack_writer_t* writer, const char* str)` - Writes a string
- `void mpack_write_bin(mpack_writer_t* writer, const char* data, size_t count)` - Writes binary data
- `mpack_error_t mpack_writer_destroy(mpack_writer_t* writer)` - Destroys the writer and checks for errors

## Usage Notes

### Parsing Data

To parse MessagePack data into a node tree:

```c
// Parse a file into a node tree
mpack_tree_t tree;
mpack_tree_init_filename(&tree, "data.mp", 0);
mpack_tree_parse(&tree);
mpack_node_t root = mpack_tree_root(&tree);

// Extract data
bool compact = mpack_node_bool(mpack_node_map_cstr(root, "compact"));
int schema = mpack_node_i32(mpack_node_map_cstr(root, "schema"));

// Clean up and check for errors
if (mpack_tree_destroy(&tree) != mpack_ok) {
    fprintf(stderr, "An error occurred decoding the data!\n");
    return;
}
```

### Writing Data

To encode structured data to MessagePack:

```c
// Encode to memory buffer
char* data;
size_t size;
mpack_writer_t writer;
mpack_writer_init_growable(&writer, &data, &size);

// Write the example on the msgpack homepage
mpack_build_map(&writer);
mpack_write_cstr(&writer, "compact");
mpack_write_bool(&writer, true);
mpack_write_cstr(&writer, "schema");
mpack_write_uint(&writer, 0);
mpack_complete_map(&writer);

// Finish writing
if (mpack_writer_destroy(&writer) != mpack_ok) {
    fprintf(stderr, "An error occurred encoding the data!\n");
    return;
}

// Use the data
do_something_with_data(data, size);
free(data);
```

### Error Handling

MPack uses stateful error handling. If any error occurs during parsing or writing, the parser/writer is placed in an error state. No additional error handling is needed during the parsing/writing process; any subsequent operations are ignored when in an error state. An error check is only needed before using the data.

### Memory Management

MPack can work with:
- Pre-allocated buffers
- Stack-allocated buffers
- Growable memory buffers
- Fixed node pools (for memory-constrained environments)

For maximum performance and minimal memory usage, the Expect API can be used to parse data of a predefined schema.

### Security

MPack is secure against untrusted data and includes built-in protection against various attack vectors such as buffer overflows and integer overflows.