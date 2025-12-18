# flb_kafka.c

## Overview

This file contains the implementation for Kafka integration in Fluent Bit. It provides functionality for configuring Kafka producers and consumers, parsing Kafka topic specifications, and managing opaque data structures for Kafka operations.

The module serves as a bridge between Fluent Bit and the librdkafka library, handling configuration mapping, topic parsing, and opaque data management. It enables Fluent Bit to produce and consume data from Apache Kafka clusters with full support for Kafka's configuration options and topic partitioning.

Kafka integration is primarily used by input and output plugins that need to interact with Kafka clusters for data ingestion or forwarding. The module handles the complexities of Kafka client configuration and provides convenient APIs for topic and partition management.

## Key Functions

### Configuration Management

#### `flb_kafka_conf_create()`
Creates a Kafka configuration object from Fluent Bit properties. This function maps Fluent Bit configuration properties to librdkafka configuration options, including client ID, group ID, brokers, and custom properties prefixed with "rdkafka."

### Topic Parsing

#### `flb_kafka_parse_topics()`
Parses Kafka topic specifications from string format into librdkafka topic partition lists. Supports both simple topic names and complex specifications with partition ranges.

### Opaque Data Management

#### `flb_kafka_opaque_create()`
Creates an opaque data structure for Kafka operations, used to pass context information between Fluent Bit and Kafka callbacks.

#### `flb_kafka_opaque_destroy()`
Destroys an opaque data structure, freeing all associated resources.

#### `flb_kafka_opaque_set()`
Sets context pointers in an opaque data structure, including generic pointers and AWS MSK IAM context.

### Internal Helper Functions

#### `add_topic_partitions()`
Helper function to parse and add topic partitions to a Kafka partition list, supporting both single partitions and partition ranges.

## Important Variables/Constants

### Default Configuration Values
- `FLB_KAFKA_BROKERS`: Default Kafka brokers address ("127.0.0.1")
- `FLB_KAFKA_TOPIC`: Default Kafka topic name ("fluent-bit")

### Data Structures
- `struct flb_kafka`: Main Kafka context structure containing the librdkafka client handle and broker configuration
- `struct flb_kafka_opaque`: Opaque data structure for passing context between Fluent Bit and Kafka callbacks

## Dependencies

- `fluent-bit/flb_config.h`: Configuration management
- `fluent-bit/flb_mem.h`: Memory management utilities
- `fluent-bit/flb_str.h`: String manipulation utilities
- `fluent-bit/flb_utils.h`: Utility functions
- `monkey/mk_core/mk_list.h`: List data structure
- `fluent-bit/flb_kafka.h`: Header file defining the interface
- `fluent-bit/flb_kv.h`: Key-value storage
- `rdkafka.h`: librdkafka library interface

## Implementation Details

1. **Configuration Mapping**: Comprehensive mapping of Fluent Bit configuration properties to librdkafka configuration options with proper error handling.

2. **Topic Specification Parsing**: Robust parsing of complex topic specifications including support for partition ranges and multiple topics.

3. **Memory Management**: Proper allocation and deallocation of Kafka-related data structures with error checking.

4. **Error Handling**: Comprehensive error detection and reporting throughout all Kafka operations.

5. **Opaque Data Support**: Flexible opaque data structures for passing context information between Fluent Bit components and Kafka callbacks.

6. **AWS MSK IAM Integration**: Special handling for AWS Managed Streaming for Apache Kafka (MSK) IAM authentication contexts.

7. **String Splitting**: Efficient parsing of comma-separated topic lists and colon-separated topic/partition specifications.

## Usage Example

```c
// Example of creating Kafka configuration
struct flb_kafka *kafka;
struct mk_list *properties;
// ... initialize kafka and properties ...

// Create Kafka configuration with group ID
rd_kafka_conf_t *conf = flb_kafka_conf_create(kafka, properties, 1);
if (conf != NULL) {
    printf("Kafka configuration created successfully\n");
    
    // Use the configuration to create a Kafka client
    rd_kafka_t *rk = rd_kafka_new(RD_KAFKA_PRODUCER, conf, errstr, sizeof(errstr));
    if (rk) {
        kafka->rk = rk;
        printf("Kafka client created successfully\n");
    } else {
        printf("Failed to create Kafka client: %s\n", errstr);
    }
} else {
    printf("Failed to create Kafka configuration\n");
}

// Example of parsing Kafka topics
const char *topics_spec = "my-topic:0-2,another-topic:3";
rd_kafka_topic_partition_list_t *topics = flb_kafka_parse_topics(topics_spec);
if (topics != NULL) {
    printf("Successfully parsed %d topics\n", topics->cnt);
    
    // Use the topics for Kafka operations
    // ...
    
    // Clean up
    rd_kafka_topic_partition_list_destroy(topics);
} else {
    printf("Failed to parse topics specification\n");
}

// Example of opaque data management
struct flb_kafka_opaque *opaque = flb_kafka_opaque_create();
if (opaque != NULL) {
    printf("Opaque data structure created\n");
    
    // Set context pointers
    void *context_ptr = malloc(sizeof(int));
    void *msk_ctx = NULL; // AWS MSK IAM context if needed
    
    flb_kafka_opaque_set(opaque, context_ptr, msk_ctx);
    
    // Use opaque in Kafka operations
    // ...
    
    // Clean up
    flb_kafka_opaque_destroy(opaque);
    free(context_ptr);
} else {
    printf("Failed to create opaque data structure\n");
}

// Complete example showing typical usage pattern
struct flb_kafka *kafka;
struct mk_list *properties;
// ... initialize kafka and properties ...

// Create Kafka configuration
rd_kafka_conf_t *conf = flb_kafka_conf_create(kafka, properties, 0); // No group ID needed for producer
if (conf == NULL) {
    printf("Failed to create Kafka configuration\n");
    return -1;
}

// Set additional Kafka properties
char errstr[512];
if (rd_kafka_conf_set(conf, "acks", "all", errstr, sizeof(errstr)) != RD_KAFKA_CONF_OK) {
    printf("Failed to set acks property: %s\n", errstr);
    rd_kafka_conf_destroy(conf);
    return -1;
}

// Create Kafka producer
rd_kafka_t *rk = rd_kafka_new(RD_KAFKA_PRODUCER, conf, errstr, sizeof(errstr));
if (rk == NULL) {
    printf("Failed to create Kafka producer: %s\n", errstr);
    return -1;
}

kafka->rk = rk;
printf("Kafka producer created successfully\n");

// Parse topics for consumption (if needed)
const char *consumer_topics = "logs-topic:0-5,metrics-topic:all";
rd_kafka_topic_partition_list_t *topics = flb_kafka_parse_topics(consumer_topics);
if (topics != NULL) {
    printf("Parsed consumer topics successfully\n");
    
    // Subscribe to topics
    if (rd_kafka_subscribe(rk, topics) == -1) {
        printf("Failed to subscribe to topics: %s\n", rd_kafka_err2str(rd_kafka_last_error()));
        rd_kafka_topic_partition_list_destroy(topics);
        return -1;
    }
    
    rd_kafka_topic_partition_list_destroy(topics);
} else {
    printf("Failed to parse consumer topics\n");
    return -1;
}

// Cleanup
rd_kafka_destroy(rk);
```