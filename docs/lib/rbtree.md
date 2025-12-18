# rbtree Documentation

## Overview

rbtree is a simple, intrusive, zero-allocation Red-Black tree implementation. It is designed exclusively for systems where determinism is needed. The library provides efficient O(log n) insertion, deletion, and search operations while maintaining the Red-Black tree properties.

Key features:
- Intrusive data structure (embeds node structure in user data)
- Zero dynamic allocation (no malloc/free calls)
- Deterministic behavior
- Standard Red-Black tree operations
- Support for custom comparison functions
- Thread-safe when used with external synchronization

## Key Methods/Functions

### Tree Management
- `rb_tree_new()`: Creates a new empty red-black tree
- `rb_tree_new_ex()`: Creates a new empty red-black tree with extended state
- `rb_tree_destroy()`: Destroys a red-black tree
- `rb_tree_empty()`: Checks if a tree is empty

### Node Operations
- `rb_tree_insert()`: Inserts a node into the tree
- `rb_tree_remove()`: Removes a node from the tree
- `rb_tree_find()`: Finds a node by key
- `rb_tree_find_or_insert()`: Finds a node or inserts a candidate

### Navigation
- `rb_tree_get_rightmost()`: Gets the rightmost (greatest) node
- `rb_tree_find_successor()`: Finds the successor node
- `rb_tree_find_predecessor()`: Finds the predecessor node

### Utility Macros
- `RB_CONTAINER_OF()`: Gets pointer to containing structure from node pointer
- `RB_ASSERT_ARG()`: Asserts argument validity
- `RB_UNLIKELY()`: Compiler hint for unlikely branch

## Important Usage Notes

### Data Structure Definition
To use rbtree, embed `struct rb_tree_node` in your data structure:

```c
struct my_data {
    int key;
    char *value;
    struct rb_tree_node rnode;
};
```

### Tree Initialization
```c
struct rb_tree tree;

// Simple initialization with basic comparison function
rb_tree_new(&tree, my_compare_function);

// Extended initialization with state
rb_tree_new_ex(&tree, my_compare_function_ex, my_state);
```

### Comparison Functions
Define a comparison function that returns:
- Positive value if lhs > rhs
- Zero if lhs == rhs
- Negative value if lhs < rhs

```c
int my_compare(const void *lhs, const void *rhs) {
    const struct my_data *a = (const struct my_data *)lhs;
    const struct my_data *b = (const struct my_data *)rhs;
    return a->key - b->key;
}

// Extended comparison function with state
int my_compare_ex(void *state, const void *lhs, const void *rhs) {
    // Use state parameter for additional context
    return my_compare(lhs, rhs);
}
```

### Basic Operations
```c
// Insert a node
struct my_data *data = malloc(sizeof(struct my_data));
data->key = 42;
data->value = "Hello";
rb_tree_insert(&tree, &data->key, &data->rnode);

// Find a node
struct rb_tree_node *found_node;
rb_result_t result = rb_tree_find(&tree, &search_key, &found_node);
if (result == RB_OK) {
    struct my_data *found_data = RB_CONTAINER_OF(found_node, struct my_data, rnode);
    // Use found_data
}

// Remove a node
rb_tree_remove(&tree, &node_to_remove);

// Check if tree is empty
int is_empty;
rb_tree_empty(&tree, &is_empty);
```

### Result Codes
Functions return these result codes:
- `RB_OK` (0): Operation successful
- `RB_NOT_FOUND` (1): Element not found
- `RB_BAD_ARG` (2): Invalid argument
- `RB_DUPLICATE` (3): Duplicate element

### Memory Management
The library is zero-allocation, meaning:
- No internal malloc/free calls
- User must manage memory for nodes
- Nodes remain valid after removal until explicitly freed

### Thread Safety
The implementation is not thread-safe by default. External synchronization is required for concurrent access:
- Use mutex locks around tree operations
- Ensure exclusive access during modifications
- Reads can be concurrent with proper synchronization

### Performance Characteristics
- Insertion: O(log n)
- Deletion: O(log n)
- Search: O(log n)
- Space complexity: O(n) for n nodes
- No memory allocation overhead

## Examples

### Complete Example
```c
#include <stdio.h>
#include <stdlib.h>
#include "rbtree.h"

struct my_record {
    int key;
    char *data;
    struct rb_tree_node node;
};

int compare_keys(const void *lhs, const void *rhs) {
    const int *a = (const int *)lhs;
    const int *b = (const int *)rhs;
    return *a - *b;
}

struct my_record *create_record(int key, const char *data) {
    struct my_record *record = malloc(sizeof(struct my_record));
    record->key = key;
    record->data = strdup(data);
    return record;
}

void destroy_record(struct my_record *record) {
    free(record->data);
    free(record);
}

int main() {
    struct rb_tree tree;
    rb_tree_new(&tree, compare_keys);
    
    // Insert some records
    struct my_record *r1 = create_record(10, "Ten");
    struct my_record *r2 = create_record(20, "Twenty");
    struct my_record *r3 = create_record(30, "Thirty");
    
    rb_tree_insert(&tree, &r1->key, &r1->node);
    rb_tree_insert(&tree, &r2->key, &r2->node);
    rb_tree_insert(&tree, &r3->key, &r3->node);
    
    // Find a record
    struct rb_tree_node *found_node;
    int search_key = 20;
    if (rb_tree_find(&tree, &search_key, &found_node) == RB_OK) {
        struct my_record *found_record = RB_CONTAINER_OF(found_node, struct my_record, node);
        printf("Found: %d -> %s\n", found_record->key, found_record->data);
    }
    
    // Clean up
    struct rb_tree_node *rightmost;
    while (rb_tree_get_rightmost(&tree, &rightmost) == RB_OK && rightmost != NULL) {
        struct my_record *record = RB_CONTAINER_OF(rightmost, struct my_record, node);
        rb_tree_remove(&tree, &record->node);
        destroy_record(record);
    }
    
    rb_tree_destroy(&tree);
    return 0;
}
```

For more detailed information and advanced usage patterns, refer to the source code and examples in the rbtree distribution.