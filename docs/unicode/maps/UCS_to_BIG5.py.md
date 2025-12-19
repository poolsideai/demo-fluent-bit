# UCS_to_BIG5.py Documentation

## Overview

This Python script generates conversion mapping tables for the BIG5 character encoding. It processes Unicode mapping files to create efficient radix trees that can be used for bidirectional conversion between BIG5 and UTF-8 encodings.

The script is part of Fluent Bit's Unicode conversion framework and works in conjunction with the `enc_convutils.py` utility module to generate optimized C code for character set conversions.

## Key Functions

### `main()`
The main entry point that orchestrates the generation of BIG5 conversion tables:

1. Loads the base BIG5 mapping data from `../defs/BIG5.TXT`
2. Loads additional CP950 mapping data from `../defs/CP950.TXT`
3. Filters and processes the mappings to create the final conversion tables
4. Calls `enc_convutils.print_conversion_tables()` to generate the C code output

## Important Variables and Constants

### `this_script`
A string containing the path to this script for use in generated comments.

### `all_mappings`
A list that accumulates the complete set of BIG5 character mappings.

### `cp950_mappings`
Mappings loaded from the CP950.TXT file that extend the base BIG5 character set.

## Dependencies

- `enc_convutils.py`: Provides utility functions for reading mapping files and generating conversion tables
- `../defs/BIG5.TXT`: Base BIG5 character mapping file (must be obtained from Unicode, Inc.)
- `../defs/CP950.TXT`: Extended CP950 character mapping file (must be obtained from Unicode, Inc.)

## Implementation Details

The script follows a specific processing pipeline:

1. **Data Loading**: Reads both BIG5.TXT and CP950.TXT files using `enc_convutils.read_source()`
2. **Extension Processing**: Adds ETEN extended characters from CP950 to the base BIG5 mappings
3. **Error Handling**: Resolves conflicts in mappings where multiple BIG5 codes map to the same Unicode replacement character (U+FFFD)
4. **Table Generation**: Uses `enc_convutils.print_conversion_tables()` to generate both directions of conversion (BIG5→UTF8 and UTF8→BIG5)

The generated output consists of two files:
- `big5_to_utf8.map`: Contains radix tree data for converting BIG5 to UTF-8
- `utf8_to_big5.map`: Contains radix tree data for converting UTF-8 to BIG5

These files are used directly by the C conversion functions in Fluent Bit's Unicode subsystem.

## Usage

To generate the conversion tables:
```bash
python3 src/unicode/maps/UCS_to_BIG5.py
```

This will produce the two map files in the current directory. These files should then be included by the appropriate C source files in the Unicode conversion framework.

## Notes

- This script requires external mapping files from Unicode, Inc. that are not included in the repository
- The script handles special cases in BIG5 mappings where multiple codes map to the same Unicode replacement character
- Generated tables use radix tree structures for efficient character lookup with minimal memory footprint
- The output is designed to be directly included in C source files without modification