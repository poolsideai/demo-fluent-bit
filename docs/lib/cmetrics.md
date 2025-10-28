# CMetrics

## Overview

CMetrics is a standalone C library to create and maintain a context of different sets of metrics with labels support such as:

- Counters
- Gauges
- Histograms
- Summaries

This project is heavily based on Go Prometheus Client API design.

## Key Methods/Functions

### Core Context Management

- `cmt_initialize()` - Initialize the CMetrics library
- `cmt_create()` - Create a new CMetrics context
- `cmt_destroy(struct cmt *cmt)` - Destroy a CMetrics context
- `cmt_label_add(struct cmt *cmt, char *key, char *val)` - Add a static label to the context
- `cmt_version()` - Get the library version

### Counter Metrics

- `cmt_counter_create(struct cmt *cmt, char *ns, char *subsystem, char *name, char *help, int label_count, char **label_keys)` - Create a new counter metric
- `cmt_counter_allow_reset(struct cmt_counter *counter)` - Allow counter resets
- `cmt_counter_destroy(struct cmt_counter *counter)` - Destroy a counter metric
- `cmt_counter_inc(struct cmt_counter *counter, uint64_t timestamp, int labels_count, char **label_vals)` - Increment counter by 1
- `cmt_counter_add(struct cmt_counter *counter, uint64_t timestamp, double val, int labels_count, char **label_vals)` - Add value to counter
- `cmt_counter_set(struct cmt_counter *counter, uint64_t timestamp, double val, int labels_count, char **label_vals)` - Set counter value
- `cmt_counter_get_val(struct cmt_counter *counter, int labels_count, char **label_vals, double *out_val)` - Get current counter value

### Gauge Metrics

- `cmt_gauge_create(struct cmt *cmt, char *ns, char *subsystem, char *name, char *help, int label_count, char **label_keys)` - Create a new gauge metric
- `cmt_gauge_destroy(struct cmt_gauge *gauge)` - Destroy a gauge metric
- `cmt_gauge_set(struct cmt_gauge *gauge, uint64_t timestamp, double val, int labels_count, char **label_vals)` - Set gauge value
- `cmt_gauge_inc(struct cmt_gauge *gauge, uint64_t timestamp, int labels_count, char **label_vals)` - Increment gauge by 1
- `cmt_gauge_dec(struct cmt_gauge *gauge, uint64_t timestamp, int labels_count, char **label_vals)` - Decrement gauge by 1
- `cmt_gauge_add(struct cmt_gauge *gauge, uint64_t timestamp, double val, int labels_count, char **label_vals)` - Add value to gauge
- `cmt_gauge_sub(struct cmt_gauge *gauge, uint64_t timestamp, double val, int labels_count, char **label_vals)` - Subtract value from gauge
- `cmt_gauge_get_val(struct cmt_gauge *gauge, int labels_count, char **label_vals, double *out_val)` - Get current gauge value

### Histogram Metrics

- `cmt_histogram_buckets_create_size(double *bkts, size_t count)` - Create histogram buckets with predefined sizes
- `cmt_histogram_buckets_create(size_t count, ...)` - Create histogram buckets with variable arguments
- `cmt_histogram_buckets_destroy(struct cmt_histogram_buckets *buckets)` - Destroy histogram buckets
- `cmt_histogram_buckets_default_create()` - Create default histogram buckets
- `cmt_histogram_buckets_linear_create(double start, double width, size_t count)` - Create linear histogram buckets
- `cmt_histogram_buckets_exponential_create(double start, double factor, size_t count)` - Create exponential histogram buckets
- `cmt_histogram_create(struct cmt *cmt, char *ns, char *subsystem, char *name, char *help, struct cmt_histogram_buckets *buckets, int label_count, char **label_keys)` - Create a new histogram metric
- `cmt_histogram_observe(struct cmt_histogram *histogram, uint64_t timestamp, double val, int labels_count, char **label_vals)` - Observe a value in the histogram
- `cmt_histogram_set_default(struct cmt_histogram *histogram, uint64_t timestamp, uint64_t *bucket_defaults, double sum, uint64_t count, int labels_count, char **label_vals)` - Set default values for histogram
- `cmt_histogram_destroy(struct cmt_histogram *h)` - Destroy a histogram metric

## Usage Notes

CMetrics supports four types of metrics:

1. **Counters**: Monotonically increasing values (e.g., request counts)
2. **Gauges**: Values that can go up and down (e.g., current memory usage)
3. **Histograms**: Track distributions of events (e.g., request duration)
4. **Summaries**: Similar to histograms but track quantiles

All metrics support labels for dimensional data.

## Examples

Basic usage:

```c
struct cmt *cmt;
struct cmt_counter *counter;

cmt = cmt_create();

// Create a counter with labels
counter = cmt_counter_create(cmt, "http", "requests_total", "Total HTTP requests", 2, (char*[]) {"method", "status"});

// Increment counter
cmt_counter_inc(counter, cfl_time_now(), 2, (char*[]) {"GET", "200"});

// Clean up
cmt_destroy(cmt);
```