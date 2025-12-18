# MessagePack-C Library

## Overview

MessagePack-C is a C implementation of an encoder and decoder for the [MessagePack](http://msgpack.org/) serialization format. It provides both packing (serialization) and unpacking (deserialization) capabilities for efficiently converting data structures to and from the compact MessagePack binary format.

The library is designed to be lightweight and efficient, making it suitable for a wide range of applications including embedded systems, network protocols, and data storage.

## Key Methods/Functions

### Packer (Serialization) API

- `void msgpack_packer_init(msgpack_packer* pk, void* data, msgpack_packer_write callback)` - Initializes a packer with a write callback function
- `msgpack_packer* msgpack_packer_new(void* data, msgpack_packer_write callback)` - Creates a new packer with a write callback function
- `void msgpack_packer_free(msgpack_packer* pk)` - Frees a packer
- `int msgpack_pack_nil(msgpack_packer* pk)` - Packs a nil value
- `int msgpack_pack_true(msgpack_packer* pk)` - Packs a true boolean value
- `int msgpack_pack_false(msgpack_packer* pk)` - Packs a false boolean value
- `int msgpack_pack_char(msgpack_packer* pk, char d)` - Packs a char value
- `int msgpack_pack_signed_char(msgpack_packer* pk, signed char d)` - Packs a signed char value
- `int msgpack_pack_short(msgpack_packer* pk, short d)` - Packs a short value
- `int msgpack_pack_int(msgpack_packer* pk, int d)` - Packs an int value
- `int msgpack_pack_long(msgpack_packer* pk, long d)` - Packs a long value
- `int msgpack_pack_long_long(msgpack_packer* pk, long long d)` - Packs a long long value
- `int msgpack_pack_unsigned_char(msgpack_packer* pk, unsigned char d)` - Packs an unsigned char value
- `int msgpack_pack_unsigned_short(msgpack_packer* pk, unsigned short d)` - Packs an unsigned short value
- `int msgpack_pack_unsigned_int(msgpack_packer* pk, unsigned int d)` - Packs an unsigned int value
- `int msgpack_pack_unsigned_long(msgpack_packer* pk, unsigned long d)` - Packs an unsigned long value
- `int msgpack_pack_unsigned_long_long(msgpack_packer* pk, unsigned long long d)` - Packs an unsigned long long value
- `int msgpack_pack_float(msgpack_packer* pk, float d)` - Packs a float value
- `int msgpack_pack_double(msgpack_packer* pk, double d)` - Packs a double value
- `int msgpack_pack_str(msgpack_packer* pk, uint32_t len)` - Starts packing a string
- `int msgpack_pack_str_body(msgpack_packer* pk, const void* b, uint32_t len)` - Packs string body data
- `int msgpack_pack_array(msgpack_packer* pk, uint32_t n)` - Starts packing an array
- `int msgpack_pack_map(msgpack_packer* pk, uint32_t n)` - Starts packing a map
- `int msgpack_pack_ext(msgpack_packer* pk, int8_t type, uint32_t len)` - Starts packing an extension value
- `int msgpack_pack_ext_body(msgpack_packer* pk, const void* b, uint32_t len)` - Packs extension body data

### Unpacker (Deserialization) API

- `typedef struct msgpack_unpacked msgpack_unpacked` - Structure to hold unpacked data
- `typedef struct msgpack_zone msgpack_zone` - Memory zone for unpacked data
- `typedef struct msgpack_object msgpack_object` - Object representation of unpacked data
- `typedef enum { MSGPACK_UNPACK_SUCCESS = 2, MSGPACK_UNPACK_EXTRA_BYTES = 1, MSGPACK_UNPACK_CONTINUE = 0, MSGPACK_UNPACK_PARSE_ERROR = -1, MSGPACK_UNPACK_NOMEM_ERROR = -2 } msgpack_unpack_return` - Return codes for unpacking operations
- `msgpack_unpack_return msgpack_unpack_next(msgpack_unpacked* result, const char* data, size_t len, size_t* off)` - Unpacks the next object from data
- `void msgpack_unpacked_destroy(msgpack_unpacked* result)` - Destroys unpacked data
- `msgpack_object msgpack_unpacked_data(msgpack_unpacked* result)` - Gets the unpacked object data

### Buffer Management

- `typedef struct msgpack_sbuffer msgpack_sbuffer` - Simple buffer structure
- `void msgpack_sbuffer_init(msgpack_sbuffer* sbuf)` - Initializes a simple buffer
- `void msgpack_sbuffer_destroy(msgpack_sbuffer* sbuf)` - Destroys a simple buffer
- `msgpack_sbuffer* msgpack_sbuffer_new(size_t chunk_size)` - Creates a new simple buffer

## Usage Notes

### Basic Serialization Example

```c
#include <msgpack.h>
#include <stdio.h>
#include <string.h>

int main() {
    // Create a simple buffer to hold the serialized data
    msgpack_sbuffer* buffer = msgpack_sbuffer_new(2048);
    
    // Create a packer that writes to our buffer
    msgpack_packer* pk = msgpack_packer_new(buffer, msgpack_sbuffer_write);
    
    // Serialize some data
    msgpack_pack_map(pk, 2);  // Start a map with 2 key-value pairs
    
    // First key-value pair: "name" -> "Alice"
    msgpack_pack_str(pk, 4);  // Key length
    msgpack_pack_str_body(pk, "name", 4);
    msgpack_pack_str(pk, 5);  // Value length
    msgpack_pack_str_body(pk, "Alice", 5);
    
    // Second key-value pair: "age" -> 30
    msgpack_pack_str(pk, 3);  // Key length
    msgpack_pack_str_body(pk, "age", 3);
    msgpack_pack_int(pk, 30);  // Value
    
    // Clean up
    msgpack_packer_free(pk);
    
    // The serialized data is now in buffer->data with length buffer->size
    printf("Serialized %zu bytes\n", buffer->size);
    
    // Don't forget to free the buffer when done
    msgpack_sbuffer_free(buffer);
    
    return 0;
}
```

### Basic Deserialization Example

```c
#include <msgpack.h>
#include <stdio.h>

void print_object(msgpack_object obj) {
    switch (obj.type) {
        case MSGPACK_OBJECT_NIL:
            printf("nil");
            break;
        case MSGPACK_OBJECT_BOOLEAN:
            printf("%s", obj.via.boolean ? "true" : "false");
            break;
        case MSGPACK_OBJECT_POSITIVE_INTEGER:
            printf("%llu", obj.via.u64);
            break;
        case MSGPACK_OBJECT_NEGATIVE_INTEGER:
            printf("%lld", obj.via.i64);
            break;
        case MSGPACK_OBJECT_FLOAT32:
        case MSGPACK_OBJECT_FLOAT64:
            printf("%f", obj.via.f64);
            break;
        case MSGPACK_OBJECT_STR:
            printf("%.*s", obj.via.str.size, obj.via.str.ptr);
            break;
        case MSGPACK_OBJECT_ARRAY:
            printf("[");
            for (size_t i = 0; i < obj.via.array.size; i++) {
                if (i > 0) printf(", ");
                print_object(obj.via.array.ptr[i]);
            }
            printf("]");
            break;
        case MSGPACK_OBJECT_MAP:
            printf("{");
            for (size_t i = 0; i < obj.via.map.size; i++) {
                if (i > 0) printf(", ");
                print_object(obj.via.map.ptr[i].key);
                printf(": ");
                print_object(obj.via.map.ptr[i].val);
            }
            printf("}");
            break;
    }
}

int main() {
    // Example serialized data (would typically come from a file or network)
    const char* serialized_data = "\x82\xa4name\xa5Alice\xa3age\x1e";
    size_t data_size = 12;
    size_t offset = 0;
    
    // Unpack the data
    msgpack_unpacked result;
    msgpack_unpacked_init(&result);
    
    msgpack_unpack_return ret = msgpack_unpack_next(&result, serialized_data, data_size, &offset);
    
    if (ret == MSGPACK_UNPACK_SUCCESS) {
        // Successfully unpacked data
        printf("Unpacked object: ");
        print_object(msgpack_unpacked_data(&result));
        printf("\n");
    } else {
        printf("Failed to unpack data: %d\n", ret);
    }
    
    // Clean up
    msgpack_unpacked_destroy(&result);
    
    return 0;
}
```

### Memory Management

MessagePack-C uses zones for memory management during unpacking. When you unpack data, the library allocates memory in a zone to hold the unpacked objects. You must destroy the unpacked data when you're done with it to free this memory.

### Error Handling

The unpacking functions return specific error codes:
- `MSGPACK_UNPACK_SUCCESS` - Successfully unpacked data
- `MSGPACK_UNPACK_EXTRA_BYTES` - Successfully unpacked data with extra bytes remaining
- `MSGPACK_UNPACK_CONTINUE` - Need more data to continue unpacking
- `MSGPACK_UNPACK_PARSE_ERROR` - Parsing error occurred
- `MSGPACK_UNPACK_NOMEM_ERROR` - Memory allocation error occurred

### Performance Considerations

MessagePack-C is optimized for performance and can handle large amounts of data efficiently. For best performance:
1. Reuse packer and buffer objects when possible
2. Use appropriate buffer sizes for your use case
3. Process data in chunks for large datasets

### Thread Safety

MessagePack-C objects are not thread-safe by default. If you need to use them in a multi-threaded environment, you should provide your own synchronization mechanisms.