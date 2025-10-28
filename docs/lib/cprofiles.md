# CProfiles

## Overview

CProfiles provides a simple API to create and manage profiles for monitoring and observability purposes. The internal data structure is based on OpenTelemetry Profiles schema (v1/development).

## Key Methods/Functions

### Core Context Management

- `cprof_create()` - Create a new CProfiles context
- `cprof_destroy(struct cprof *cprof)` - Destroy a CProfiles context
- `cprof_version()` - Get the library version

### Profile Management

- `cprof_profile_create()` - Create a new profile
- `cprof_profile_add_location_index(struct cprof_profile *profile, int64_t index)` - Add location index to profile
- `cprof_profile_destroy(struct cprof_profile *instance)` - Destroy a profile
- `cprof_profile_string_add(struct cprof_profile *profile, char *str, int str_len)` - Add string to profile string table
- `cprof_profile_add_comment(struct cprof_profile *profile, int64_t comment)` - Add comment to profile

### Attribute Units

- `cprof_attribute_unit_create(struct cprof_profile *profile)` - Create attribute unit
- `cprof_attribute_unit_destroy(struct cprof_attribute_unit *instance)` - Destroy attribute unit

### Mappings

- `cprof_mapping_create(struct cprof_profile *profile)` - Create mapping
- `cprof_mapping_destroy(struct cprof_mapping *instance)` - Destroy mapping
- `cprof_mapping_add_attribute(struct cprof_mapping *mapping, uint64_t attribute)` - Add attribute to mapping

### Lines

- `cprof_line_create(struct cprof_location *location)` - Create line
- `cprof_line_destroy(struct cprof_line *instance)` - Destroy line

### Locations

- `cprof_location_create(struct cprof_profile *profile)` - Create location
- `cprof_location_add_attribute(struct cprof_location *location, uint64_t attribute)` - Add attribute to location
- `cprof_location_destroy(struct cprof_location *instance)` - Destroy location

### Resources

- `cprof_resource_create(struct cfl_kvlist *attributes)` - Create resource
- `cprof_resource_destroy(struct cprof_resource *resource)` - Destroy resource
- `cprof_resource_profiles_add(struct cprof *context, struct cprof_resource_profiles *resource_profiles)` - Add resource profiles to context

### Instrumentation Scopes

- `cprof_instrumentation_scope_create(char *name, char *version, struct cfl_kvlist *attributes, uint32_t dropped_attributes_count)` - Create instrumentation scope
- `cprof_instrumentation_scope_destroy(struct cprof_instrumentation_scope *instance)` - Destroy instrumentation scope

### Scope Profiles

- `cprof_scope_profiles_create(struct cprof_resource_profiles *resource_profiles, char *schema_url)` - Create scope profiles
- `cprof_scope_profiles_destroy(struct cprof_scope_profiles *instance)` - Destroy scope profiles

### Resource Profiles

- `cprof_resource_profiles_create(char *schema_url)` - Create resource profiles
- `cprof_resource_profiles_destroy(struct cprof_resource_profiles *instance)` - Destroy resource profiles

### Functions

- `cprof_function_create(struct cprof_profile *profile)` - Create function
- `cprof_function_destroy(struct cprof_function *instance)` - Destroy function

### Links

- `cprof_link_create(struct cprof_profile *profile)` - Create link
- `cprof_link_destroy(struct cprof_link *instance)` - Destroy link

### Samples

- `cprof_sample_create(struct cprof_profile *profile)` - Create sample
- `cprof_sample_destroy(struct cprof_sample *sample)` - Destroy sample
- `cprof_sample_destroy_all(struct cprof_profile *profile)` - Destroy all samples in profile
- `cprof_sample_add_timestamp(struct cprof_sample *sample, uint64_t timestamp)` - Add timestamp to sample
- `cprof_sample_add_value(struct cprof_sample *sample, int64_t value)` - Add value to sample
- `cprof_sample_add_location_index(struct cprof_sample *sample, uint64_t location_index)` - Add location index to sample
- `cprof_sample_add_attribute(struct cprof_sample *sample, uint64_t attribute)` - Add attribute to sample

### Sample Types

- `cprof_sample_type_destroy(struct cprof_value_type *sample_type)` - Destroy sample type
- `cprof_sample_type_destroy_all(struct cprof_profile *profile)` - Destroy all sample types in profile
- `cprof_sample_type_create(struct cprof_profile *profile, int64_t type, int64_t unit, int aggregation_temporality)` - Create sample type
- `cprof_sample_type_str_create(struct cprof_profile *profile, char *type_str, char *unit_str, int aggregation_temporality)` - Create sample type from strings

## Usage Notes

CProfiles is designed to work with the OpenTelemetry Profiles schema. It provides a comprehensive API for creating and managing profiles, including:

- Profiles with metadata and timing information
- Location tracking with mappings and line information
- Function definitions
- Sample data with values and timestamps
- Attribute management
- Resource and instrumentation scope handling

The library supports both delta and cumulative aggregation temporalities.

## Examples

Basic usage:

```c
struct cprof *cprof;
struct cprof_profile *profile;
struct cprof_sample *sample;

cprof = cprof_create();
profile = cprof_profile_create();

// Add sample to profile
sample = cprof_sample_create(profile);
cprof_sample_add_value(sample, 1000); // CPU time in nanoseconds
cprof_sample_add_location_index(sample, 0);

// Clean up
cprof_destroy(cprof);
```