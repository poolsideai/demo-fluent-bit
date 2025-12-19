# enc_convutils.py

This Python module provides utility functions for generating character encoding conversion tables used by Fluent Bit's Unicode conversion functionality.

## Overview

The `enc_convutils.py` module contains helper functions that are used by the various UCS_to_*.py scripts to:
1. Read and parse Unicode character mapping files
2. Generate optimized radix tree data structures
3. Output C source code for the conversion tables

These utilities enable the efficient conversion between different character encodings and UTF-8.

## Key Constants

- `NONE`, `TO_UNICODE`, `FROM_UNICODE`, `BOTH`: Direction constants for character mappings

## Main Functions

### `read_source(fname)`
Parses a Unicode character mapping file and returns a list of mapping dictionaries.

**Parameters:**
- `fname` (str): Path to the input mapping file

**Returns:**
- List of dictionaries containing character mappings

### `print_conversion_tables(this_script, csname, charset)`
Generates and writes both to- and from-Unicode conversion tables to files.

**Parameters:**
- `this_script` (str): Path to the calling script
- `csname` (str): Name of the character set
- `charset` (list): List of mapping dictionaries

### `ucs2utf(ucs)`
Converts a UCS-4 code point to its UTF-8 representation as an integer.

**Parameters:**
- `ucs` (int): UCS-4 code point

**Returns:**
- Integer representing the UTF-8 encoded character

## Implementation Details

The module implements a sophisticated radix tree generation algorithm that:
1. Builds radix trees in memory from character maps
2. Segments the trees for efficient memory usage
3. Calculates bounds and optimizes the data structures
4. Generates C source code with proper data types (uint16_t or uint32_t)

The radix tree approach allows for very fast character lookup with minimal memory overhead compared to simple lookup tables.

## Data Structures

### Mapping Dictionary
Each character mapping is represented as a dictionary with keys:
- `code`: Character code in the target encoding
- `ucs`: Unicode code point
- `direction`: Mapping direction constant
- `comment`: Comment from the source file
- `f`: Source file name
- `l`: Line number in source file

## Usage

This module is imported and used by the various UCS_to_*.py scripts:
```python
import enc_convutils

mapping = enc_convutils.read_source("../defs/CP932.TXT")
enc_convutils.print_conversion_tables("script_path", "CHARSET_NAME", mapping)
```

## Dependencies

- Standard Python libraries: `sys`, `re`, `collections`
- Used by all UCS_to_*.py scripts in the same directory