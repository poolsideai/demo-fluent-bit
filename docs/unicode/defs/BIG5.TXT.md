# BIG5.TXT

## Overview

This file contains the Unicode mapping table for the BIG5 character encoding. BIG5 is a traditional Chinese character encoding standard used primarily in Taiwan and Hong Kong.

The file provides a complete mapping between BIG5 code points and their corresponding Unicode code points, enabling character encoding conversion between BIG5 and UTF-8.

## File Structure

The file follows the Unicode Consortium's Format A specification with three tab-separated columns:

1. **BIG5 Code Point**: The BIG5 encoding code in hexadecimal format (e.g., 0xA140)
2. **Unicode Code Point**: The corresponding Unicode code point in hexadecimal format (e.g., 0x3000)
3. **Unicode Name**: The official Unicode character name (e.g., IDEOGRAPHIC SPACE)

## Important Notes

### Limitations
- Round-trip compatibility between BIG5 and Unicode is not guaranteed
- Some characters are mapped to U+FFFD (REPLACEMENT CHARACTER) due to conflicts or missing mappings
- Certain ranges have implementation uncertainties (C6A1-C8FE, F9DD-F9FE)

### Known Issues
- Character 0xA15A (SPACING UNDERSCORE) duplicates 0xA1C4
- Character 0xA1C3 (SPACING HEAVY OVERSCORE) is not in Unicode
- Character 0xA1C5 (SPACING HEAVY UNDERSCORE) is not in Unicode
- Character 0xA1FE duplicates 0xA2AC
- Character 0xA240 duplicates 0xA2AD
- Characters 0xA2CC and 0xA2CE conflict with other mappings

## Supported Character Sets

The file covers:
- Basic Latin characters (0x00-0x7F)
- Extended Latin characters with diacritics
- Greek letters
- Cyrillic characters
- Box drawing characters
- Block elements
- Geometric shapes
- Miscellaneous symbols
- CJK (Chinese, Japanese, Korean) unified ideographs
- Fullwidth ASCII variants
- Halfwidth Katakana variants

## Usage

This mapping table is used by the Unicode conversion library in Fluent Bit to:
1. Convert BIG5-encoded text to UTF-8
2. Convert UTF-8 text to BIG5 encoding
3. Handle character encoding detection and validation

## Version Information

- Unicode version: 1.1
- Table version: 2.0
- Last updated: 2015 December 02
- Format: Format A (three-column tab-separated)

## Copyright

© 2015 Unicode®, Inc.
For terms of use, see http://www.unicode.org/terms_of_use.html