# Jsmn Library Documentation

## Overview

Jsmn (pronounced like 'jasmine') is a minimalistic JSON parser in C. It can be easily integrated into resource-limited or embedded projects.

Unlike most JSON parsers that offer a bunch of functions to load JSON data and extract values by name, jsmn proves that checking the correctness of every JSON packet or allocating temporary objects to store parsed JSON fields often is an overkill.

JSON format itself is extremely simple, so why should we complicate it?

Jsmn is designed to be:
- **Robust** (it should work fine even with erroneous data)
- **Fast** (it should parse data on the fly)
- **Portable** (no superfluous dependencies or non-standard C extensions)
- **Simple** (simple code style, simple algorithm, simple integration into other projects)

## Key Methods/Functions

### Core API

- `void jsmn_init(jsmn_parser *parser)` - Creates a new parser over an array of tokens
- `int jsmn_parse(jsmn_parser *parser, const char *js, const size_t len, jsmntok_t *tokens, const unsigned int num_tokens)` - Runs the JSON parser. Parses a JSON data string into an array of tokens, each describing a single JSON object.

### Token Types

Jsmn supports the following token types:

- `JSMN_OBJECT` - A container of key-value pairs, e.g.: `{ "foo":"bar", "x":0.3 }`
- `JSMN_ARRAY` - A sequence of values, e.g.: `[ 1, 2, 3 ]`
- `JSMN_STRING` - A quoted sequence of chars, e.g.: `"foo"`
- `JSMN_PRIMITIVE` - A number, a boolean (`true`, `false`) or `null`

### Token Structure

Each token is an object of `jsmntok_t` type:

```c
typedef struct {
    jsmntype_t type; // Token type
    int start;       // Token start position
    int end;         // Token end position
    int size;        // Number of child (nested) tokens
} jsmntok_t;
```

### Error Codes

Jsmn returns the following error codes:

- `JSMN_ERROR_NOMEM` - Not enough tokens were provided
- `JSMN_ERROR_INVAL` - Invalid character inside JSON string
- `JSMN_ERROR_PART` - The string is not a full JSON packet, more bytes expected

## Usage Notes

1. Jsmn is a single-header, header-only library. To use it, simply download `jsmn.h` and include it in your project.

2. Jsmn uses a token-based approach where tokens do not hold any data, but point to token boundaries in the JSON string instead.

3. For complex use cases, you might need to define additional macros:
   - `#define JSMN_STATIC` hides all jsmn API symbols by making them static
   - `#define JSMN_HEADER` macro can be used to avoid duplication of symbols when including `jsmn.h` from multiple C files

4. Jsmn supports two compilation modes:
   - Strict mode: Only allows valid JSON primitives (numbers, booleans, null)
   - Non-strict mode: Treats every unquoted value as a primitive

5. Jsmn provides parent links feature (when compiled with `JSMN_PARENT_LINKS`):
   - Each token has a `parent` field indicating its parent token
   - Useful for navigating the JSON hierarchy

## Example

```c
#include "jsmn.h"
#include <stdio.h>
#include <string.h>

int main() {
    // JSON string to parse
    const char *js = "{\"name\":\"John\",\"age\":30,\"active\":true}";
    
    // Initialize parser
    jsmn_parser p;
    jsmntok_t tokens[128]; // We expect no more than 128 JSON tokens
    
    jsmn_init(&p);
    
    // Parse JSON string
    int r = jsmn_parse(&p, js, strlen(js), tokens, 128);
    
    if (r < 0) {
        printf("Failed to parse JSON: %d\n", r);
        return 1;
    }
    
    if (r < 1 || tokens[0].type != JSMN_OBJECT) {
        printf("Object expected\n");
        return 1;
    }
    
    // Process tokens
    for (int i = 1; i < r; i++) {
        if (js[tokens[i].start] == '\"') {
            printf("String: %.*s\n", tokens[i].end - tokens[i].start, js + tokens[i].start);
        } else {
            printf("Primitive: %.*s\n", tokens[i].end - tokens[i].start, js + tokens[i].start);
        }
    }
    
    return 0;
}
```