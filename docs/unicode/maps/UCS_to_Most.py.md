# UCS_to_Most.py

This Python script generates UTF-8 to/from character code conversion tables for various character encodings from Unicode mapping files.

## Overview

The `UCS_to_Most.py` script is a Python utility that generates conversion tables for multiple character encodings including Windows code pages and GBK. It reads Unicode mapping files from the `../defs/` directory and generates optimized radix tree data structures for efficient character conversion.

## Key Functions

- `main()`: The main function that orchestrates the conversion table generation process
- Uses `enc_convutils.read_source()` to parse Unicode mapping files
- Uses `enc_convutils.print_conversion_tables()` to generate C source files

## Supported Character Encodings

The script processes mappings for the following character encodings:
- Windows code pages: CP866, CP874, CP1250, CP1251, CP1252, CP1253, CP1254, CP1255, CP1256, CP1257, CP1258
- GBK character encoding

## Command Line Usage

The script accepts optional command-line arguments to specify which character sets to process:
```bash
# Process all supported character sets (default)
python3 src/unicode/maps/UCS_to_Most.py

# Process specific character sets
python3 src/unicode/maps/UCS_to_Most.py WIN1252 GBK
```

## Dependencies

- Requires `enc_convutils.py` for utility functions
- Requires mapping files in `../defs/` directory (CP866.TXT, CP874.TXT, CP1250.TXT, etc.)

## Output Files

For each processed character set, the script generates two conversion tables:
1. `{charset}_to_utf8.map` - For converting from the character set to UTF-8
2. `utf8_to_{charset}.map` - For converting from UTF-8 to the character set

## Implementation Details

The script:
1. Reads Unicode mapping files using `enc_convutils.read_source()`
2. Filters out pure ASCII mappings (codes below 0x80)
3. Generates optimized radix tree structures using `enc_convutils.print_conversion_tables()`
4. Creates efficient lookup tables for character conversion

The radix tree approach allows for very fast character lookup with minimal memory overhead compared to simple lookup tables, making it ideal for high-performance text processing in Fluent Bit.

## Usage Examples

To generate conversion tables for all supported character encodings:
```bash
cd src/unicode/maps
python3 UCS_to_Most.py
```

To generate tables for specific encodings only:
```bash
python3 UCS_to_Most.py WIN1252 GBK
```