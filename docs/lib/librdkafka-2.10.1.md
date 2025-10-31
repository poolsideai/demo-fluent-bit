# librdkafka Documentation

## Overview

librdkafka is a high-performance C/C++ client library implementation of the Apache Kafka protocol. It provides Producer, Consumer, and Admin clients designed with message delivery reliability and high performance in mind.

The library is licensed under the 2-clause BSD license and supports broker versions >=0.8. Current figures exceed 1 million msgs/second for the producer and 3 million msgs/second for the consumer.

Key features include:
- Full Exactly-Once-Semantics (EOS) support
- High-level producer, including Idempotent and Transactional producers
- High-level balanced KafkaConsumer (requires broker >= 0.9)
- Simple (legacy) consumer
- Admin client
- Compression: snappy, gzip, lz4, zstd
- SSL support
- SASL support (GSSAPI/Kerberos/SSPI, PLAIN, SCRAM, OAUTHBEARER)
- Statistics metrics
- Portable: runs on Linux, MacOS X, Windows, Solaris, FreeBSD, AIX, ...

## Key Functions

### Producer Functions

#### `rd_kafka_produce`
Produces a single message to a topic.

Parameters:
- `rk`: Producer instance
- `rkt`: Topic to produce to
- `partition`: Partition to produce to
- `msgflags`: Message flags
- `payload`: Message payload
- `len`: Message payload length
- `key`: Optional message key
- `keylen`: Message key length
- `msg_opaque`: Optional opaque pointer

Returns: 0 on success, -1 on error.

#### `rd_kafka_producev`
Produces a single message using a variadic interface.

Parameters:
- `rk`: Producer instance
- `...`: Variable arguments for message properties

Returns: 0 on success, -1 on error.

### Consumer Functions

#### `rd_kafka_consumer_poll`
Polls the consumer for new messages or events.

Parameters:
- `rk`: Consumer instance
- `timeout_ms`: Maximum time to block waiting for messages

Returns: Message or event, or NULL on timeout.

#### `rd_kafka_consumer_close`
Closes the consumer, committing offsets and releasing resources.

Parameters:
- `rk`: Consumer instance

Returns: Error code on failure, NULL on success.

### Configuration Functions

#### `rd_kafka_conf_new`
Creates a new configuration object.

Returns: New configuration object.

#### `rd_kafka_conf_set`
Sets a configuration property.

Parameters:
- `conf`: Configuration object
- `name`: Property name
- `value`: Property value
- `errstr`: Error string buffer
- `errstr_size`: Size of error string buffer

Returns: Error code on failure, RD_KAFKA_CONF_OK on success.

### Topic Functions

#### `rd_kafka_topic_new`
Creates a new topic object.

Parameters:
- `rk`: Client instance
- `topic`: Topic name
- `conf`: Topic configuration (may be NULL)

Returns: New topic object.

### Admin Functions

#### `rd_kafka_CreateTopics`
Creates one or more topics.

Parameters:
- `rk`: Admin client instance
- `new_topics`: Array of new topic specifications
- `new_topics_cnt`: Number of topics
- `options`: Admin options (may be NULL)
- `rkqu`: Queue to emit result on

Returns: Error code on failure, NULL on success.

## Usage Notes

1. Always create a configuration object using `rd_kafka_conf_new` before creating a client
2. Set required configuration properties using `rd_kafka_conf_set`
3. Create a producer or consumer instance using `rd_kafka_new`
4. For producers, create topic objects using `rd_kafka_topic_new`
5. For consumers, subscribe to topics using `rd_kafka_subscribe`
6. Always poll the client regularly using `rd_kafka_poll` or `rd_kafka_consumer_poll`
7. Clean up resources properly by calling `rd_kafka_destroy`

## Example Usage - Producer

```c
#include <rdkafka.h>
#include <stdio.h>
#include <string.h>

void dr_msg_cb(rd_kafka_t *rk, const rd_kafka_message_t *rkmessage,
               void *opaque) {
    if (rkmessage->err) {
        fprintf(stderr, "%% Message delivery failed: %s\n",
                rd_kafka_err2str(rkmessage->err));
    } else {
        fprintf(stdout, "%% Message delivered (%zd bytes, partition %d)\n",
                rkmessage->len, rkmessage->partition);
    }
}

int main(int argc, char **argv) {
    char errstr[512];
    rd_kafka_t *rk;
    rd_kafka_topic_t *rkt;
    rd_kafka_conf_t *conf;
    
    // Create configuration object
    conf = rd_kafka_conf_new();
    
    // Set configuration properties
    rd_kafka_conf_set(conf, "bootstrap.servers", "localhost:9092",
                      errstr, sizeof(errstr));
    rd_kafka_conf_set(conf, "acks", "all", errstr, sizeof(errstr));
    
    // Set delivery report callback
    rd_kafka_conf_set_dr_msg_cb(conf, dr_msg_cb);
    
    // Create producer
    rk = rd_kafka_new(RD_KAFKA_PRODUCER, conf, errstr, sizeof(errstr));
    if (!rk) {
        fprintf(stderr, "%% Failed to create producer: %s\n", errstr);
        return 1;
    }
    
    // Create topic
    rkt = rd_kafka_topic_new(rk, "my_topic", NULL);
    if (!rkt) {
        fprintf(stderr, "%% Failed to create topic: %s\n",
                rd_kafka_err2str(rd_kafka_last_error()));
        rd_kafka_destroy(rk);
        return 1;
    }
    
    // Produce message
    const char *msg = "Hello, World!";
    rd_kafka_produce(rkt, RD_KAFKA_PARTITION_UA, 0,
                     (void *)msg, strlen(msg), NULL, 0, NULL);
    
    // Poll for delivery reports
    rd_kafka_poll(rk, 0);
    
    // Clean up
    rd_kafka_topic_destroy(rkt);
    rd_kafka_destroy(rk);
    
    return 0;
}
```