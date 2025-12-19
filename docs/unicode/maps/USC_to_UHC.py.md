# USC_to_UHC.py

This Python script generates UTF-8 to/from Unified Hangul Code (UHC) character code conversion tables from XML mapping files.

## Overview

The script reads the `windows-949-2000.xml` file (which contains the official XML mapping for UHC/CP949) and generates two conversion tables:
1. UHC to UTF-8 conversion table (`uhc_to_utf8.map`)
2. UTF-8 to UHC conversion table (`utf8_to_uhc.map`)

These tables are used by Fluent Bit's Unicode conversion functionality to efficiently convert text between UHC and UTF-8 encodings.

## Key Functions

- `main()`: The main function that orchestrates the conversion table generation process
- Uses regular expressions to parse the XML mapping file
- Uses `enc_convutils.print_conversion_tables()` to generate the C source files

## Important Variables

- `line_regex`: Regular expression pattern to extract Unicode and code point mappings from XML
- `mapping`: List of character mappings between UHC codes and Unicode code points

## Dependencies

- Requires `enc_convutils.py` for utility functions
- Requires `../defs/windows-949-2000.xml` (must be downloaded separately from Unicode Consortium)

## Implementation Details

The script:
1. Parses XML mapping files using regular expressions to extract Unicode to code point mappings
2. Filters out special codes (0x0080 and 0x00FF)
3. Only includes mappings where both code and Unicode values are above 0x80
4. Adds one extra character mapping not present in the source file

The generated tables use a radix tree data structure for efficient lookup of character mappings.

## Usage

To generate the conversion tables, run:
```bash
python3 src/unicode/maps/USC_to_UHC.py
```

Note: The windows-949-2000.xml file must be present in the `../defs/` directory.