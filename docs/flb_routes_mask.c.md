# flb_routes_mask.c

## Overview

The `flb_routes_mask.c` file implements a bitmask-based routing system for Fluent Bit. This component uses bitfields to efficiently track which output plugins should receive data from input chunks based on tag matching.

The routing mask system provides:
- Efficient storage of routing decisions using bitfields
- Fast tag-based route matching
- Memory-efficient representation of routing relationships
- Support for large numbers of output plugins
- Integration with the main routing system

This implementation optimizes the routing process by pre-computing which outputs should receive data for a given tag, avoiding repeated matching operations during data processing.

## Key Functions/Components

### Core Data Types

#### `flb_route_mask_element`
The fundamental data type for the routing mask:
- Typedef for `uint64_t` (64-bit unsigned integer)
- Each bit represents whether an output plugin should receive data
- Bit position corresponds to output plugin ID

#### `FLB_ROUTES_MASK_ELEMENT_BITS`
Constant defining the number of bits per mask element:
- Calculated as `sizeof(flb_route_mask_element) * CHAR_BIT`
- Currently 64 bits per element
- Allows efficient bit manipulation operations

### Main Functions

#### `flb_routes_mask_set_by_tag(flb_route_mask_element *routes_mask, const char *tag, int tag_len, struct flb_input_instance *in)`
Primary function for computing routing mask based on tag matching:
1. Clears the existing mask
2. Iterates through all output instances
3. Tests tag matching for each output's match pattern
4. Sets bits in the mask for matching outputs
5. Returns non-zero if any routes matched

#### `flb_routes_mask_set_bit(flb_route_mask_element *routes_mask, int value, struct flb_config *config)`
Sets a specific bit in the routing mask:
- Calculates the array index and bit position
- Sets the appropriate bit in the mask
- Handles bounds checking

#### `flb_routes_mask_clear_bit(flb_route_mask_element *routes_mask, int value, struct flb_config *config)`
Clears a specific bit in the routing mask:
- Calculates the array index and bit position
- Clears the appropriate bit in the mask
- Handles bounds checking

#### `flb_routes_mask_get_bit(flb_route_mask_element *routes_mask, int value, struct flb_config *config)`
Checks the state of a specific bit in the routing mask:
- Calculates the array index and bit position
- Returns non-zero if the bit is set
- Handles bounds checking

#### `flb_routes_mask_is_empty(flb_route_mask_element *routes_mask, struct flb_config *config)`
Tests if the routing mask is empty (no bits set):
- Compares against a pre-computed empty mask
- Returns non-zero if mask is empty

### Configuration Functions

#### `flb_routes_empty_mask_create(struct flb_config *config)`
Creates a pre-computed empty routing mask:
- Allocates memory for the empty mask
- Initializes all bits to zero
- Stores in config for reuse

#### `flb_routes_empty_mask_destroy(struct flb_config *config)`
Destroys the pre-computed empty routing mask:
- Frees allocated memory
- Resets pointer in config

#### `flb_routes_mask_set_size(size_t mask_size, struct flb_config *config)`
Configures the routing mask size:
- Calculates required array elements
- Sets config parameters
- Creates empty mask

## Important Variables/Constants

### Bit Manipulation
- `FLB_ROUTES_MASK_ELEMENT_BITS`: Number of bits per mask element (64)
- Each bit position corresponds to an output plugin ID
- Bit value of 1 indicates the output should receive data
- Bit value of 0 indicates the output should not receive data

### Memory Layout
- Routing mask is an array of `flb_route_mask_element`
- Array size determined by maximum output plugin ID
- Each element can represent 64 different output plugins
- Efficient for systems with many output plugins

## Dependencies and Relationships

This module depends on:
- `flb_router`: Core routing functionality for tag matching
- `flb_input`: Input plugin management
- `flb_config`: Configuration management
- `flb_log`: Logging functionality
- `flb_mem`: Memory management

It integrates with:
- Input chunk processing for route determination
- Output plugin selection during data routing
- Configuration system for mask sizing
- Event processing pipeline

## Implementation Details

The routing mask implementation provides several key optimizations:

1. **Bitfield Representation**: Uses compact bitfields instead of arrays of booleans, reducing memory usage by a factor of 64.

2. **Pre-computation**: Computes routing decisions once per tag rather than repeatedly during data processing.

3. **Efficient Bit Operations**: Uses bitwise operations for fast setting, clearing, and testing of route bits.

4. **Bounds Checking**: Validates bit positions to prevent buffer overflows.

5. **Memory Management**: Properly allocates and deallocates mask storage.

6. **Cache Optimization**: Pre-computes empty mask for fast comparison operations.

The routing mask algorithm works as follows:
1. For a given tag, clear the routing mask
2. Iterate through all output plugins
3. Test if the tag matches the output's match pattern
4. Set the corresponding bit in the mask for matching outputs
5. Use the mask during data processing to quickly determine routing destinations

### Bit Positioning
Bit positions in the mask correspond directly to output plugin IDs:
- Bit 0: Output plugin with ID 0
- Bit 1: Output plugin with ID 1
- Bit 63: Output plugin with ID 63
- Bit 64: Output plugin with ID 64 (second element, bit 0)

### Array Indexing
The mask is stored as an array where:
- Index 0: Bits 0-63
- Index 1: Bits 64-127
- Index N: Bits (N*64) to ((N+1)*64-1)

### Performance Characteristics
- Tag matching: O(n) where n is the number of outputs
- Bit setting/clearing: O(1)
- Bit testing: O(1)
- Mask comparison: O(m) where m is the number of mask elements

## Usage Examples

### Computing Routing Mask for a Tag
```c
// Compute routing mask for a specific tag
struct flb_input_instance *input_ins;
char *tag = "app.web.server";

// Allocate routing mask (typically done once per chunk)
flb_route_mask_element routes_mask[max_outputs / 64 + 1];

// Compute the mask
int has_routes = flb_routes_mask_set_by_tag(routes_mask, tag, strlen(tag), input_ins);

if (has_routes) {
    printf("Tag matches %d output routes\n", has_routes);
} else {
    printf("Tag does not match any output routes\n");
}
```

### Checking Specific Output Routes
```c
// Check if a specific output should receive data
struct flb_config *config;
int output_id = 5;

if (flb_routes_mask_get_bit(routes_mask, output_id, config)) {
    printf("Output %d should receive this data\n", output_id);
    // Route data to this output
} else {
    printf("Output %d should not receive this data\n", output_id);
}
```

### Setting and Clearing Route Bits
```c
// Manually set a route bit
int output_id = 10;
flb_routes_mask_set_bit(routes_mask, output_id, config);

// Check if bit was set
if (flb_routes_mask_get_bit(routes_mask, output_id, config)) {
    printf("Bit %d is set\n", output_id);
}

// Clear the bit
flb_routes_mask_clear_bit(routes_mask, output_id, config);

// Verify bit was cleared
if (!flb_routes_mask_get_bit(routes_mask, output_id, config)) {
    printf("Bit %d is cleared\n", output_id);
}
```

### Checking Empty Mask
```c
// Check if no routes are selected
if (flb_routes_mask_is_empty(routes_mask, config)) {
    printf("No routes selected for this tag\n");
    // Handle case where no outputs match
} else {
    printf("Routes are selected for this tag\n");
    // Proceed with routing
}
```

### Configuration Example
```ini
[SERVICE]
    # Route mask configuration
    route_mask_size 100

[INPUT]
    name cpu
    tag cpu.*

[OUTPUT]
    name stdout
    match cpu.*

[OUTPUT]
    name file
    match *.logs
    path /var/log/app.log
```

In this example:
- Route mask size configured for 100 outputs
- CPU input tagged `cpu.*` routes to stdout output
- Any input tagged `*.logs` routes to file output
- The routing mask system efficiently tracks these relationships

### Performance Optimization Pattern
```c
// Optimized routing pattern using masks
struct flb_event_chunk *chunk;
struct flb_input_instance *input_ins;

// Compute mask once per chunk (expensive operation)
if (flb_routes_mask_set_by_tag(chunk->routes_mask, chunk->tag, chunk->tag_len, input_ins)) {
    // Fast bit testing for each output (cheap operation)
    struct mk_list *o_head;
    struct flb_output_instance *o_ins;
    
    mk_list_foreach(o_head, &input_ins->config->outputs) {
        o_ins = mk_list_entry(o_head, struct flb_output_instance, _head);
        
        if (flb_routes_mask_get_bit(chunk->routes_mask, o_ins->id, input_ins->config)) {
            // Route chunk to this output
            flb_output_flush(o_ins, chunk);
        }
    }
}
```

### Memory Management
```c
// Proper initialization
struct flb_config *config;
size_t max_outputs = 200;

// Configure mask size
if (flb_routes_mask_set_size(max_outputs, config) != 0) {
    flb_error("Failed to configure route mask size");
    return -1;
}

// Later, during cleanup
flb_routes_empty_mask_destroy(config);
```

### Debugging Route Masks
```c
// Debug function to print route mask
void debug_print_route_mask(flb_route_mask_element *mask, struct flb_config *config) {
    int i;
    
    printf("Route mask: ");
    for (i = 0; i < config->route_mask_slots; i++) {
        if (flb_routes_mask_get_bit(mask, i, config)) {
            printf("%d ", i);
        }
    }
    printf("\n");
}

// Usage
debug_print_route_mask(chunk->routes_mask, config);
```