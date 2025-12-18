# BIG5.TXT

## Overview

This file contains the character mapping table for BIG5 encoding to Unicode. BIG5 is a traditional Chinese character encoding standard used primarily in Taiwan and Hong Kong for representing Traditional Chinese characters.

The file defines the mapping between BIG5 code points and their corresponding Unicode code points. It includes special notes about characters that cannot be mapped due to conflicts or absence in Unicode.

## Key Information

### File Details
- **Name**: BIG5 to Unicode table (complete)
- **Unicode version**: 1.1
- **Table version**: 2.0
- **Table format**: Format A
- **Date**: 2011 October 14 (header updated: 2015 December 02)

### Format
The file uses Format A with three tab-separated columns:
1. **BIG5 code** (in hex as 0xXXXX)
2. **Unicode code** (in hex as 0xXXXX)
3. **Unicode name** (follows a comment sign, '#')

For CJK Unified Ideographs (U+4E00 to U+9FA5), the token "<CJK>" is used instead of the full name to reduce file size.

## Important Notes

### Unmappable Characters
Several characters cannot be mapped due to conflicts or absence in Unicode:
- `0xA15A`: SPACING UNDERSCORE (duplicates A1C4)
- `0xA1C3`: SPACING HEAVY OVERSCORE (not in Unicode)
- `0xA1C5`: SPACING HEAVY UNDERSCORE (not in Unicode)
- `0xA1FE`: LT DIAG UP RIGHT TO LOW LEFT (duplicates A2AC)
- `0xA240`: LT DIAG UP LEFT TO LOW RIGHT (duplicates A2AD)
- `0xA2CC`: HANGZHOU NUMERAL TEN (conflicts with A451 mapping)
- `0xA2CE`: HANGZHOU NUMERAL THIRTY (conflicts with A4CA mapping)

These characters are mapped to U+FFFD (REPLACEMENT CHARACTER).

### Uncertain Mappings
There is some uncertainty about mappings in the range C6A1 - C8FE and F9DD - F9FE due to differences between ETEN version of BIG5 and standard BIG5.

### Special Character Mapping
The BIG5 character `0xA3BC` (tone mark for first Mandarin tone) is mapped to U+02C9 MODIFIER LETTER MACRON. However, since bopomofo uses absence of tone mark for first tone, U+2003 EM SPACE might be preferred in some implementations.

## Dependencies and Relationships

- Used by Fluent Bit's Unicode conversion system (`flb_utf8_and_big5.c`)
- Part of the comprehensive character encoding support in Fluent Bit
- Referenced by the CMake build system for Unicode conversion library

## Notable Implementation Details

1. **Complete Mapping**: Contains one set of mappings from BIG5 into Unicode
2. **Round-trip Compatibility Warning**: It's impossible to provide round-trip compatibility between BIG5 and Unicode
3. **CJK Optimization**: Uses "<CJK>" token for CJK Unified Ideographs to reduce file size
4. **Duplicate Handling**: Explicitly handles duplicate character mappings
5. **Version Tracking**: Maintains revision history with dates and changes

## Usage Examples

Converting BIG5 to Unicode:
```c
// Using the mapping table in code
uint16_t big5_code = 0xA140;  // BIG5 code for IDEOGRAPHIC SPACE
uint16_t unicode_code = lookup_big5_to_unicode(big5_code);  // Returns 0x3000
```

Converting Unicode to BIG5:
```c
// Reverse lookup (requires building reverse mapping)
uint16_t unicode_code = 0x3000;  // IDEOGRAPHIC SPACE
uint16_t big5_code = lookup_unicode_to_big5(unicode_code);  // Returns 0xA140
```