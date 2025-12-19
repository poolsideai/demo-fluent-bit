# UCS_to_SJIS.py

This Python script generates UTF-8 to/from Shift-JIS (SJIS) character code conversion tables from Unicode mapping files.

## Overview

The script reads the CP932.TXT file (which contains the official Unicode mapping for Shift-JIS) and generates two conversion tables:
1. SJIS to UTF-8 conversion table (`sjis_to_utf8.map`)
2. UTF-8 to SJIS conversion table (`utf8_to_sjis.map`)

These tables are used by Fluent Bit's Unicode conversion functionality to efficiently convert text between Shift-JIS and UTF-8 encodings.

## Key Functions

- `main()`: The main function that orchestrates the conversion table generation process
- Uses `enc_convutils.read_source()` to parse the Unicode mapping file
- Uses `enc_convutils.print_conversion_tables()` to generate the C source files

## Important Variables

- `reject_sjis`: A set of SJIS codes that should only be used for SJIS=>UTF8 conversion, not UTF8=>SJIS
- `additional_mappings`: Extra mappings added specifically for UTF8=>SJIS conversion

## Dependencies

- Requires `enc_convutils.py` for utility functions
- Requires `../defs/CP932.TXT` (must be downloaded separately from Unicode Consortium)

## Implementation Details

The script performs special handling for certain SJIS codes:
1. Some SJIS codes are rejected for UTF8=>SJIS conversion to avoid conflicts
2. Additional mappings are added for characters that need special handling

The generated tables use a radix tree data structure for efficient lookup of character mappings.

## Usage

To generate the conversion tables, run:
```bash
python3 src/unicode/maps/UCS_to_SJIS.py
```

Note: The CP932.TXT file must be present in the `../defs/` directory.