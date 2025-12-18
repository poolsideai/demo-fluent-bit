# flb_strptime.c

## Overview

The `flb_strptime.c` file provides a portable implementation of the `strptime` function for parsing date and time strings according to format specifications. This implementation is based on the OpenBSD version but includes enhancements for better timezone handling and cross-platform compatibility.

The `strptime` function converts a character string representing a date and time into values stored in a `struct flb_tm` structure. It supports a wide range of format specifiers and handles various timezone formats including standard abbreviations, ISO 8601 formats, and RFC-822/RFC-2822 formats.

Key features:
- Comprehensive timezone support with extensive abbreviation database
- Cross-platform compatibility (Windows, Unix-like systems)
- ISO 8601 and RFC-822/RFC-2822 format support
- Robust error handling and validation
- Locale-aware string matching
- Support for two-digit year interpretation
- Automatic field computation for missing values

## Key Functions/Components

### Main Function

#### `flb_strptime(const char *s, const char *format, struct flb_tm *tm)`
Parses a date/time string according to a format specification:
1. Initializes the `flb_tm` structure
2. Processes each format specifier in sequence
3. Extracts corresponding values from the input string
4. Validates extracted values against ranges
5. Computes missing fields when possible
6. Returns pointer to end of parsed string or NULL on failure

### Helper Functions

#### `_flb_strptime(const char *buf, const char *fmt, struct flb_tm *tm, int initialize)`
Internal parsing function that handles the actual format processing:
1. Manages format specifier parsing
2. Handles whitespace skipping
3. Processes alternative format modifiers
4. Implements complex format rules through recursion
5. Performs elementary conversions
6. Handles timezone parsing with comprehensive database

#### `_conv_num(const unsigned char **buf, int *dest, int llim, int ulim)`
Converts numeric string to integer with bounds checking:
1. Validates that characters are digits
2. Converts digit sequence to integer
3. Checks result against specified limits
4. Returns success/failure status

#### `_conv_num64(const unsigned char **buf, int64_t *dest, int64_t llim, int64_t ulim)`
Converts numeric string to 64-bit integer with bounds checking:
1. Similar to `_conv_num` but for 64-bit values
2. Includes overflow protection for large numbers
3. Handles seconds since epoch conversion

#### `_find_string(const u_char *bp, int *tgt, const char * const *n1, const char * const *n2, int c)`
Searches for string matches in locale arrays:
1. Checks full names first
2. Falls back to abbreviated names
3. Performs case-insensitive comparison
4. Returns matched index and updated position

#### `leaps_thru_end_of(const int y)`
Calculates number of leap years up to a given year:
1. Handles positive and negative years
2. Accounts for Gregorian calendar rules
3. Used for day-of-week calculations

### Data Structures

#### `struct flb_tm`
Extended time structure that includes timezone information:
- `struct tm tm`: Standard time structure
- `int gmtoff`: Seconds east of UTC
- `char *zone`: Timezone abbreviation

#### `flb_tz_abbr_info_t`
Timezone abbreviation information:
- `const char *abbr`: Abbreviation string
- `int offset_sec`: Offset in seconds from UTC
- `int is_dst`: Daylight saving time indicator

### Timezone Database

#### `flb_known_timezones`
Comprehensive array of timezone abbreviations with their offsets:
- UTC/GMT variants (UTC, GMT, Z, UT)
- North American timezones (EST, EDT, CST, CDT, MST, MDT, PST, PDT, etc.)
- European timezones (WET, WEST, CET, CEST, EET, EEST, MSK)
- South American timezones (ART, BRT, BRST, CLT, CLST)
- Australasian timezones (AEST, AEDT, ACST, ACDT, AWST, NZST, NZDT)
- Asian timezones (JST, KST, SGT, IST, GST, ICT, WIB, WITA, WIT, MYT, BDT, NPT)
- African timezones (WAT, CAT, EAT, SAST)
- Military timezones (A-Z except J)

## Important Constants and Definitions

### Time Constants
- `TM_YEAR_BASE`: Base year for tm_year calculation (1900)
- `DAYSPERNYEAR`: Days in a non-leap year (365)
- `DAYSPERLYEAR`: Days in a leap year (366)
- `DAYSPERWEEK`: Days in a week (7)
- `MONSPERYEAR`: Months in a year (12)
- `EPOCH_YEAR`: Unix epoch year (1970)
- `EPOCH_WDAY`: Day of week for epoch (Thursday = 4)
- `SECSPERHOUR`: Seconds per hour (3600)
- `SECSPERMIN`: Seconds per minute (60)

### Field Tracking
- `FIELD_TM_MON`: Month field set
- `FIELD_TM_MDAY`: Day of month field set
- `FIELD_TM_WDAY`: Day of week field set
- `FIELD_TM_YDAY`: Day of year field set
- `FIELD_TM_YEAR`: Year field set

### Alternative Format Modifiers
- `_ALT_E`: Extended format modifier
- `_ALT_O`: Alternative numeric format modifier
- `_LEGAL_ALT(x)`: Macro to validate allowed alternative modifiers

## Dependencies and Relationships

This module depends on:
- `ctype.h`: Character classification functions
- `locale.h`: Locale-specific information
- `string.h`: String manipulation functions
- `fluent-bit/flb_langinfo.h`: Language-specific information
- `fluent-bit/flb_time.h`: Time-related definitions and structures

It integrates with:
- Input plugins that need to parse timestamps
- Parser plugins for log processing
- Filter plugins that manipulate timestamps
- Storage layer for chunk timestamp handling
- Network plugins for timestamp conversion

## Implementation Details

### Format Specifier Support
The implementation supports all standard `strptime` format specifiers:

#### Date Format Specifiers
- `%a`, `%A`: Day of week (abbreviated/full)
- `%b`, `%B`, `%h`: Month name (abbreviated/full)
- `%c`: Date and time (locale format)
- `%d`, `%e`: Day of month (01-31)
- `%F`: ISO 8601 date format (%Y-%m-%d)
- `%j`: Day of year (001-366)
- `%m`: Month number (01-12)
- `%U`, `%W`: Week number (00-53)
- `%w`: Day of week (0-6, Sunday=0)
- `%u`: Day of week (1-7, Monday=1)
- `%y`, `%Y`: Year (2-digit/4-digit)

#### Time Format Specifiers
- `%H`: Hour (24-hour clock, 00-23)
- `%I`: Hour (12-hour clock, 01-12)
- `%k`: Hour (24-hour clock, 0-23)
- `%l`: Hour (12-hour clock, 1-12)
- `%M`: Minute (00-59)
- `%p`: AM/PM designation
- `%S`: Second (00-60)
- `%s`: Seconds since epoch
- `%T`: Time (%H:%M:%S)
- `%X`: Time (locale format)

#### Timezone Format Specifiers
- `%z`: Numeric timezone offset
- `%Z`: Timezone abbreviation

#### Other Format Specifiers
- `%n`, `%t`: Whitespace characters
- `%%`: Literal percent sign

### Timezone Handling
Comprehensive timezone support includes:

1. **Numeric Offsets**:
   - `[+-]hhmm`: Hours and minutes (e.g., +0530)
   - `[+-]hh:mm`: Hours and minutes with colon (e.g., +05:30)
   - `[+-]hh`: Hours only (e.g., +05)

2. **Standard Abbreviations**:
   - UTC/GMT variants (UTC, GMT, Z, UT)
   - North American (EST, EDT, CST, CDT, MST, MDT, PST, PDT)
   - European (WET, WEST, CET, CEST, EET, EEST)
   - And many more from around the world

3. **Military Timezones**:
   - Single letter codes (A-Z except J)
   - Represents time zones from UTC-12 to UTC+12

4. **System Timezones**:
   - Uses system `tzname` array as fallback
   - Handles platform-specific timezone APIs

### Two-Digit Year Interpretation
Handles ambiguous two-digit years:
- Years 00-68 interpreted as 2000-2068
- Years 69-99 interpreted as 1969-1999
- Can be overridden with century specifier (%C)

### Field Computation
Automatically computes missing fields when possible:
- Day of year from month and day
- Day of week from year and day of year
- Month and day from year and day of year
- Ensures consistency between related fields

### Error Handling
Robust error handling includes:
- Input validation for all format specifiers
- Range checking for numeric values
- Proper bounds checking for all operations
- Graceful handling of malformed input
- Clear return values indicating success/failure

### Platform Compatibility
Cross-platform support through:
- Conditional compilation for Windows vs. POSIX
- Proper timezone API usage per platform
- Consistent behavior across different systems
- Handling of platform-specific quirks

## Usage Examples

### Basic Date Parsing
```c
#include <fluent-bit/flb_strptime.h>
#include <fluent-bit/flb_time.h>
#include <stdio.h>

int main() {
    struct flb_tm tm;
    const char *date_str = "2023-12-25 15:30:45";
    const char *format = "%Y-%m-%d %H:%M:%S";
    
    char *result = flb_strptime(date_str, format, &tm);
    
    if (result != NULL) {
        printf("Parsed date: %d-%02d-%02d %02d:%02d:%02d\n",
               tm.tm.tm_year + 1900,
               tm.tm.tm_mon + 1,
               tm.tm.tm_mday,
               tm.tm.tm_hour,
               tm.tm.tm_min,
               tm.tm.tm_sec);
        printf("Timezone offset: %d seconds\n", tm.gmtoff);
    } else {
        printf("Failed to parse date\n");
    }
    
    return 0;
}
```

### ISO 8601 Timestamp Parsing
```c
// Parse ISO 8601 timestamp with timezone
struct flb_tm tm;
const char *iso_timestamp = "2023-12-25T15:30:45+05:30";
const char *format = "%Y-%m-%dT%H:%M:%S%z";

char *result = flb_strptime(iso_timestamp, format, &tm);
if (result != NULL) {
    printf("Timestamp parsed successfully\n");
    printf("Local time: %d-%02d-%02d %02d:%02d:%02d\n",
           tm.tm.tm_year + 1900,
           tm.tm.tm_mon + 1,
           tm.tm.tm_mday,
           tm.tm.tm_hour,
           tm.tm.tm_min,
           tm.tm.tm_sec);
    printf("UTC offset: %d seconds\n", tm.gmtoff);
} else {
    printf("Failed to parse ISO timestamp\n");
}
```

### RFC 3339 Timestamp Parsing
```c
// Parse RFC 3339 timestamp
struct flb_tm tm;
const char *rfc3339_timestamp = "2023-12-25T15:30:45Z";
const char *format = "%Y-%m-%dT%H:%M:%SZ";

char *result = flb_strptime(rfc3339_timestamp, format, &tm);
if (result != NULL) {
    printf("RFC 3339 timestamp parsed\n");
    printf("UTC time: %d-%02d-%02d %02d:%02d:%02d\n",
           tm.tm.tm_year + 1900,
           tm.tm.tm_mon + 1,
           tm.tm.tm_mday,
           tm.tm.tm_hour,
           tm.tm.tm_min,
           tm.tm.tm_sec);
} else {
    printf("Failed to parse RFC 3339 timestamp\n");
}
```

### Log Timestamp Parsing
```c
// Parse common log timestamp formats
struct flb_tm tm;

// Apache/Nginx log format
const char *apache_timestamp = "[25/Dec/2023:15:30:45 +0530]";
const char *apache_format = "[%d/%b/%Y:%H:%M:%S %z]";

char *result = flb_strptime(apache_timestamp, apache_format, &tm);
if (result != NULL) {
    printf("Apache timestamp parsed\n");
}

// Syslog format
const char *syslog_timestamp = "Dec 25 15:30:45";
const char *syslog_format = "%b %d %H:%M:%S";

result = flb_strptime(syslog_timestamp, syslog_format, &tm);
if (result != NULL) {
    printf("Syslog timestamp parsed\n");
}
```

### Timezone-Aware Parsing
```c
// Parse timestamps with various timezone formats
struct flb_tm tm;

// Timezone abbreviation
const char *tz_abbr = "2023-12-25 15:30:45 EST";
const char *format1 = "%Y-%m-%d %H:%M:%S %Z";

char *result = flb_strptime(tz_abbr, format1, &tm);
if (result != NULL) {
    printf("EST timestamp parsed\n");
    printf("Offset: %d seconds\n", tm.gmtoff);
}

// Numeric timezone offset
const char *tz_numeric = "2023-12-25 15:30:45 +0530";
const char *format2 = "%Y-%m-%d %H:%M:%S %z";

result = flb_strptime(tz_numeric, format2, &tm);
if (result != NULL) {
    printf("Numeric timezone parsed\n");
    printf("Offset: %d seconds\n", tm.gmtoff);
}
```

### Error Handling Pattern
```c
// Robust timestamp parsing with error handling
int parse_timestamp_safely(const char *timestamp, const char *format, struct flb_tm *tm) {
    char *result = flb_strptime(timestamp, format, tm);
    
    if (result == NULL) {
        flb_error("Failed to parse timestamp '%s' with format '%s'", timestamp, format);
        return -1;
    }
    
    // Check if entire string was consumed
    if (*result != '\0') {
        flb_warn("Trailing characters after timestamp: %s", result);
    }
    
    // Validate basic time range
    if (tm->tm.tm_year < 70 || tm->tm.tm_year > 130) {  // 1970-2030
        flb_warn("Suspicious year value: %d", tm->tm.tm_year + 1900);
    }
    
    return 0;
}

// Usage
struct flb_tm tm;
const char *timestamp = "2023-12-25 15:30:45";
const char *format = "%Y-%m-%d %H:%M:%S";

if (parse_timestamp_safely(timestamp, format, &tm) == 0) {
    printf("Timestamp parsed successfully\n");
} else {
    printf("Failed to parse timestamp\n");
}
```

### Integration with Fluent Bit Components
```c
// Example integration with a parser plugin
struct flb_parser_config {
    char *format;
    char *time_format;
    // ... other fields
};

int flb_parser_parse_timestamp(struct flb_parser_config *config,
                               const char *timestamp_str,
                               struct flb_time *out_time) {
    struct flb_tm tm;
    char *result;
    
    // Parse timestamp using flb_strptime
    result = flb_strptime(timestamp_str, config->time_format, &tm);
    if (result == NULL) {
        flb_error("Failed to parse timestamp '%s'", timestamp_str);
        return -1;
    }
    
    // Convert to flb_time structure
    out_time->tm.tv_sec = mktime(&tm.tm);
    out_time->tm.tv_nsec = 0;
    
    // Apply timezone offset if present
    out_time->tm.tv_sec += tm.gmtoff;
    
    return 0;
}

// Usage in parser plugin
struct flb_parser_config config = {
    .time_format = "%Y-%m-%dT%H:%M:%S%z"
};

struct flb_time parsed_time;
const char *log_timestamp = "2023-12-25T15:30:45+05:30";

if (flb_parser_parse_timestamp(&config, log_timestamp, &parsed_time) == 0) {
    printf("Timestamp successfully parsed and converted\n");
}
```

### Performance Considerations
```c
// Efficient timestamp parsing for high-throughput scenarios
static struct flb_tm cached_tm;
static const char *cached_format = NULL;

char *fast_strptime_cached(const char *buf, const char *fmt, struct flb_tm *tm) {
    // Reuse previous parsing context when possible
    if (cached_format == fmt) {
        // Potentially optimize based on previous successful parses
        return _flb_strptime(buf, fmt, tm, 0);  // Skip initialization
    } else {
        cached_format = fmt;
        return _flb_strptime(buf, fmt, tm, 1);  // Full initialization
    }
}

// Usage for repeated parsing with same format
struct flb_tm tm;
const char *format = "%Y-%m-%d %H:%M:%S";
const char *timestamps[] = {
    "2023-12-25 15:30:45",
    "2023-12-26 16:31:46",
    "2023-12-27 17:32:47"
};

for (int i = 0; i < 3; i++) {
    char *result = fast_strptime_cached(timestamps[i], format, &tm);
    if (result != NULL) {
        printf("Parsed timestamp %d\n", i);
    }
}
```

### Validation and Testing
```c
// Test function for timestamp parsing
void test_strptime_formats() {
    struct flb_tm tm;
    char *result;
    
    // Test various formats
    const char *test_cases[][2] = {
        {"2023-12-25 15:30:45", "%Y-%m-%d %H:%M:%S"},
        {"25 Dec 2023 15:30:45", "%d %b %Y %H:%M:%S"},
        {"2023-12-25T15:30:45Z", "%Y-%m-%dT%H:%M:%SZ"},
        {"2023-12-25 15:30:45 +0530", "%Y-%m-%d %H:%M:%S %z"},
        {NULL, NULL}
    };
    
    for (int i = 0; test_cases[i][0] != NULL; i++) {
        result = flb_strptime(test_cases[i][0], test_cases[i][1], &tm);
        if (result != NULL) {
            printf("✓ Format %d parsed successfully\n", i);
        } else {
            printf("✗ Format %d failed to parse\n", i);
        }
    }
}

// Run tests
test_strptime_formats();
```