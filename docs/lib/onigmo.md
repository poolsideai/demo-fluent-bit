# onigmo Documentation

## Overview

onigmo (Oniguruma-mod) is a regular expressions library forked from Oniguruma. It focuses on supporting new expressions like `\K`, `\R`, `(?(cond)yes|no)` and other features supported in Perl 5.10+. Since onigmo is used as the default regexp library of Ruby 2.0 or later, many patches are backported from Ruby 2.x.

The library provides:
- Support for modern regular expression syntax
- Multiple character encodings (UTF-8, UTF-16, EUC-JP, Shift_JIS, etc.)
- POSIX, GNU, and native APIs
- Efficient pattern matching and compilation
- Capture groups and named groups
- Lookahead and lookbehind assertions

## Key Methods/Functions

### Pattern Compilation
- `onig_new()`: Compiles a regular expression pattern
- `onig_new_deluxe()`: Compiles a pattern with extended options
- `onig_compile()`: Compiles a pattern from a string
- `onig_free()`: Frees compiled pattern resources

### Pattern Matching
- `onig_search()`: Searches for a pattern match in a string
- `onig_match()`: Matches a pattern at a specific position
- `onig_region_new()`: Creates a new region for capture results
- `onig_region_free()`: Frees a region
- `onig_region_resize()`: Resizes a region

### Character Encoding
- `onigenc_get_default_encoding()`: Gets the default encoding
- `onigenc_set_default_encoding()`: Sets the default encoding
- `onigenc_init()`: Initializes encoding support

### Pattern Options
- `ONIG_OPTION_IGNORECASE`: Case-insensitive matching
- `ONIG_OPTION_MULTILINE`: Multi-line mode (`^` and `$` match line boundaries)
- `ONIG_OPTION_DOTALL`: Dot matches newline characters
- `ONIG_OPTION_SINGLELINE`: Single-line mode
- `ONIG_OPTION_FIND_LONGEST`: Find the longest match
- `ONIG_OPTION_FIND_NOT_EMPTY`: Don't match empty strings

### Error Handling
- `onig_error_code_to_str()`: Converts error code to string
- `onig_reg_error_code_to_str()`: Gets error string for a pattern
- `onig_get_syntax_by_name()`: Gets syntax by name

### Memory Management
- `onig_init()`: Initializes the library
- `onig_end()`: Ends the library (frees resources)
- `onig_global_context_alloc()`: Allocates global context
- `onig_global_context_free()`: Frees global context

## Important Usage Notes

### Basic Usage Pattern
```c
#include <onigmo.h>

int main() {
    regex_t *reg;
    OnigErrorInfo einfo;
    OnigRegion *region;
    UChar *str = (UChar*)"Hello World";
    UChar *pattern = (UChar*)"Hello (\w+)";
    
    // Initialize
    onig_init();
    
    // Compile pattern
    int r = onig_new(&reg, pattern, pattern + strlen((char*)pattern),
                     ONIG_OPTION_DEFAULT, ONIG_ENCODING_UTF8,
                     ONIG_SYNTAX_DEFAULT, &einfo);
    
    if (r != ONIG_NORMAL) {
        char s[ONIG_MAX_ERROR_MESSAGE_LEN];
        onig_error_code_to_str((UChar*)s, r, &einfo);
        fprintf(stderr, "ERROR: %s\n", s);
        onig_end();
        return -1;
    }
    
    // Create region for captures
    region = onig_region_new();
    
    // Search for match
    r = onig_search(reg, str, str + strlen((char*)str),
                    str, str + strlen((char*)str),
                    region, ONIG_OPTION_NONE);
    
    if (r >= 0) {
        // Match found
        int i;
        for (i = 0; i < region->num_regs; i++) {
            int beg = region->beg[i];
            int end = region->end[i];
            printf("group %d: "%.*s"\n", i, end - beg, str + beg);
        }
    } else if (r == ONIG_MISMATCH) {
        printf("search fail\n");
    } else {
        // Error
        char s[ONIG_MAX_ERROR_MESSAGE_LEN];
        onig_error_code_to_str((UChar*)s, r);
        fprintf(stderr, "ERROR: %s\n", s);
    }
    
    // Cleanup
    onig_region_free(region, 1);
    onig_free(reg);
    onig_end();
    
    return 0;
}
```

### Character Encoding Support
The library supports multiple character encodings:
- `ONIG_ENCODING_UTF8`: UTF-8 encoding
- `ONIG_ENCODING_UTF16BE`: UTF-16 big-endian
- `ONIG_ENCODING_UTF16LE`: UTF-16 little-endian
- `ONIG_ENCODING_EUC_JP`: EUC-JP encoding
- `ONIG_ENCODING_SHIFT_JIS`: Shift_JIS encoding
- `ONIG_ENCODING_ASCII`: ASCII encoding

### Syntax Options
Different syntax options are available:
- `ONIG_SYNTAX_DEFAULT`: Default syntax
- `ONIG_SYNTAX_PERL`: Perl-compatible syntax
- `ONIG_SYNTAX_JAVA`: Java-compatible syntax
- `ONIG_SYNTAX_ASIS`: ASIS syntax

### Performance Considerations
- Precompile patterns when they will be used multiple times
- Use appropriate encoding for your data
- Consider using `onig_new_deluxe()` for complex patterns with specific options

For more detailed information and examples, refer to the official onigmo documentation and examples in the source distribution.