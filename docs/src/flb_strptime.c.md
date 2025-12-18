# flb_strptime.c and flb_strptime.h Documentation

## Overview

The `flb_strptime` module provides a portable implementation of the `strptime` function for parsing date and time strings according to a specified format. This implementation is designed to work consistently across different platforms, including Windows and Unix-like systems.

## Key Functions

### flb_strptime()

```c
char *flb_strptime(const char *s, const char *format, struct flb_tm *tm);
```

Parses a date/time string according to a specified format and stores the result in a `struct flb_tm`.

**Parameters:**
- `s`: Input string to parse
- `format`: Format string specifying how to interpret the input
- `tm`: Pointer to a `struct flb_tm` where parsed values will be stored

**Returns:**
- Pointer to the first character after the last parsed character in the input string
- `NULL` if parsing fails

## Implementation Details

The implementation supports all standard `strptime` format specifiers:

- `%a`, `%A`: Abbreviated/full weekday name
- `%b`, `%B`, `%h`: Abbreviated/full month name
- `%c`: Date and time representation
- `%C`: Century number (year/100)
- `%d`, `%e`: Day of the month
- `%D`: Equivalent to `%m/%d/%y`
- `%F`: Equivalent to `%Y-%m-%d`
- `%g`: Year corresponding to ISO week number without century
- `%G`: Year corresponding to ISO week number with century
- `%H`: Hour (24-hour clock)
- `%I`: Hour (12-hour clock)
- `%j`: Day of the year
- `%k`: Hour (24-hour clock) with single digit
- `%l`: Hour (12-hour clock) with single digit
- `%m`: Month number
- `%M`: Minute
- `%n`: Arbitrary whitespace
- `%p`: AM/PM designation
- `%r`: 12-hour clock time
- `%R`: Equivalent to `%H:%M`
- `%S`: Seconds
- `%s`: Seconds since epoch
- `%t`: Arbitrary whitespace
- `%T`: Equivalent to `%H:%M:%S`
- `%u`: Day of week (1-7, Monday=1)
- `%V`: ISO 8601 week number
- `%w`: Day of week (0-6, Sunday=0)
- `%W`: Week number (Monday as first day)
- `%x`: Date representation
- `%X`: Time representation
- `%y`: Year without century
- `%Y`: Year with century
- `%z`: Timezone offset from UTC
- `%Z`: Timezone name or abbreviation

## Cross-Platform Considerations

The implementation handles platform-specific differences in timezone handling:

- On Windows: Uses `_tzset()` and `_get_timezone()` functions
- On Unix-like systems: Uses `tzset()` and `timezone` global variable
- Handles both standard and daylight saving time zones
- Supports known timezone abbreviations through a predefined list

## Usage Example

```c
#include <fluent-bit/flb_strptime.h>
#include <fluent-bit/flb_time.h>

struct flb_tm tm;
char *result;

// Parse a date string
result = flb_strptime("2023-12-25 14:30:00", "%Y-%m-%d %H:%M:%S", &tm);

if (result != NULL) {
    // Successfully parsed
    printf("Year: %d, Month: %d, Day: %d\n", 
           tm.tm.tm_year + 1900, 
           tm.tm.tm_mon + 1, 
           tm.tm.tm_mday);
} else {
    // Parsing failed
    printf("Failed to parse date string\n");
}
```