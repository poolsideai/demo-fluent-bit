# UCS_to_GB18030.py Documentation

## Overview

This Python script generates conversion mapping tables for the GB18030 character encoding. It processes XML mapping files from the ICU project to create efficient radix trees that can be used for bidirectional conversion between GB18030 and UTF-8 encodings.

The script is part of Fluent Bit's Unicode conversion framework and works in conjunction with the `enc_convutils.py` utility module to generate optimized C code for character set conversions.

## Key Functions

### `main()`
The main entry point that orchestrates the generation of GB18030 conversion tables:

1. Parses the GB18030 XML mapping file using regular expressions
2. Extracts Unicode-to-GB18030 mapping pairs
3. Filters mappings to include only non-ASCII characters
4. Calls `enc_convutils.print_conversion_tables()` to generate the C code output

## Important Variables and Constants

### `this_script`
A string containing the path to this script for use in generated comments.

### `in_file`
Path to the input XML file containing GB18030 mappings (`../defs/gb-18030-2000.xml`).

### `line_regex`
Regular expression pattern to extract Unicode and GB18030 code mappings from XML lines.

### `mapping`
A list that accumulates the parsed character mappings.

## Dependencies

- `enc_convutils.py`: Provides utility functions for generating conversion tables
- `../defs/gb-18030-2000.xml`: GB18030 mapping file in XML format (must be obtained from ICU project)
- Python standard library modules: `sys`, `re`

## Implementation Details

The script processes the XML mapping file using the following approach:

1. **File Parsing**: Reads the XML file line by line
2. **Pattern Matching**: Uses a regular expression to extract `<a u="..." b="..."/>` elements
3. **Data Extraction**: Parses Unicode (`u`) and GB18030 (`b`) code values from each match
4. **Filtering**: Includes only mappings where both codes are >= 0x80 (non-ASCII)
5. **Table Generation**: Uses `enc_convutils.print_conversion_tables()` to generate both directions of conversion

The generated output consists of two files:
- `gb18030_to_utf8.map`: Contains radix tree data for converting GB18030 to UTF-8
- `utf8_to_gb18030.map`: Contains radix tree data for converting UTF-8 to GB18030

These files are used directly by the C conversion functions in Fluent Bit's Unicode subsystem.

## Usage

To generate the conversion tables:
```bash
python3 src/unicode/maps/UCS_to_GB18030.py
```

This will produce the two map files in the current directory. These files should then be included by the appropriate C source files in the Unicode conversion framework.

## Notes

- This script requires external mapping files from the ICU project that are not included in the repository
- The script handles the complex GB18030 encoding which supports 1, 2, and 4-byte sequences
- Generated tables use radix tree structures for efficient character lookup with minimal memory footprint
- The output is designed to be directly included in C source files without modification
- The script specifically filters out ASCII mappings as they are handled separately in the conversion framework