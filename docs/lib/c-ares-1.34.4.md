# lib/c-ares-1.34.4 Documentation

## Overview

c-ares is a modern DNS (stub) resolver library, written in C. It provides interfaces for asynchronous queries while trying to abstract the intricacies of the underlying DNS protocol. It was originally intended for applications which need to perform DNS queries without blocking, or need to perform multiple DNS queries in parallel.

One of the goals of c-ares is to be a better DNS resolver than is provided by your system, regardless of which system you use. We recommend using the c-ares library in all network applications even if the initial goal of asynchronous resolution is not necessary to your application.

c-ares will build with any C89 compiler and is MIT licensed, which makes it suitable for both free and commercial software. c-ares runs on Linux, FreeBSD, OpenBSD, MacOS, Solaris, AIX, Windows, Android, iOS and many more operating systems.

## Key Functions

### Library Initialization

* `ares_library_init()` - Initialize the c-ares library
* `ares_library_cleanup()` - Clean up the c-ares library
* `ares_library_initialized()` - Check if the library is initialized
* `ares_version()` - Get the version of the c-ares library

### Channel Management

* `ares_init()` - Initialize a channel
* `ares_init_options()` - Initialize a channel with options
* `ares_destroy()` - Destroy a channel
* `ares_cancel()` - Cancel all queries on a channel
* `ares_reinit()` - Reinitialize a channel

### Query Functions

* `ares_query()` - Perform a DNS query
* `ares_search()` - Search for a DNS query
* `ares_gethostbyname()` - Get host by name
* `ares_gethostbyaddr()` - Get host by address
* `ares_getnameinfo()` - Get name information
* `ares_getaddrinfo()` - Get address information
* `ares_send()` - Send a raw DNS query

### Server Configuration

* `ares_set_servers()` - Set the list of DNS servers
* `ares_set_servers_csv()` - Set the list of DNS servers from a CSV string
* `ares_set_servers_ports()` - Set the list of DNS servers with ports
* `ares_set_servers_ports_csv()` - Set the list of DNS servers with ports from a CSV string
* `ares_get_servers()` - Get the list of DNS servers
* `ares_get_servers_csv()` - Get the list of DNS servers as a CSV string
* `ares_get_servers_ports()` - Get the list of DNS servers with ports

### Socket Management

* `ares_process()` - Process events on a channel
* `ares_process_fd()` - Process events on a channel for specific file descriptors
* `ares_process_fds()` - Process events on multiple file descriptors
* `ares_timeout()` - Get the timeout for a channel
* `ares_fds()` - Get the file descriptors for a channel
* `ares_getsock()` - Get information about the sockets for a channel

### Data Parsing

* `ares_parse_a_reply()` - Parse an A record reply
* `ares_parse_aaaa_reply()` - Parse an AAAA record reply
* `ares_parse_caa_reply()` - Parse a CAA record reply
* `ares_parse_ptr_reply()` - Parse a PTR record reply
* `ares_parse_ns_reply()` - Parse an NS record reply
* `ares_parse_srv_reply()` - Parse an SRV record reply
* `ares_parse_mx_reply()` - Parse an MX record reply
* `ares_parse_txt_reply()` - Parse a TXT record reply
* `ares_parse_naptr_reply()` - Parse a NAPTR record reply
* `ares_parse_soa_reply()` - Parse a SOA record reply
* `ares_parse_uri_reply()` - Parse a URI record reply

### Utility Functions

* `ares_strerror()` - Get a string description of an error code
* `ares_free_string()` - Free a string allocated by c-ares
* `ares_free_hostent()` - Free a hostent structure
* `ares_free_data()` - Free data allocated by c-ares
* `ares_set_local_ip4()` - Set the local IPv4 address for outgoing queries
* `ares_set_local_ip6()` - Set the local IPv6 address for outgoing queries
* `ares_set_local_dev()` - Set the local device for outgoing queries

## Usage Notes

1. **Asynchronous Nature**: c-ares is designed to be used asynchronously. Queries are initiated and then processed when events occur on the sockets.

2. **Channel Management**: Each application should create one or more channels using `ares_init()` or `ares_init_options()`. Channels are used to maintain state for DNS queries.

3. **Event Processing**: After initiating queries, the application must process events on the sockets using `ares_process()`, `ares_process_fd()`, or `ares_process_fds()`.

4. **Callback Functions**: Most query functions take a callback function that will be called when the query completes or fails.

5. **Error Handling**: Functions return `ares_status_t` values to indicate success or failure. Use `ares_strerror()` to get a human-readable description of error codes.

6. **Memory Management**: c-ares allocates memory for results that must be freed using the appropriate free functions.

## Example Usage

```c
#include <ares.h>
#include <stdio.h>

void callback(void *arg, int status, int timeouts, struct hostent *hostent) {
    if (status != ARES_SUCCESS) {
        printf("Error: %s\n", ares_strerror(status));
        return;
    }
    
    printf("Host: %s\n", hostent->h_name);
    // Process the hostent structure
}

int main() {
    ares_channel channel;
    
    // Initialize the library
    if (ares_library_init(ARES_LIB_INIT_ALL) != ARES_SUCCESS) {
        printf("Failed to initialize c-ares\n");
        return 1;
    }
    
    // Initialize a channel
    if (ares_init(&channel) != ARES_SUCCESS) {
        printf("Failed to initialize channel\n");
        ares_library_cleanup();
        return 1;
    }
    
    // Perform a DNS query
    ares_gethostbyname(channel, "example.com", AF_INET, callback, NULL);
    
    // Process events until all queries are complete
    fd_set read_fds, write_fds;
    struct timeval tv, *tvp;
    
    while (1) {
        int nfds = ares_fds(channel, &read_fds, &write_fds);
        if (nfds == 0) {
            break; // No more queries
        }
        
        tvp = ares_timeout(channel, NULL, &tv);
        select(nfds, &read_fds, &write_fds, NULL, tvp);
        ares_process(channel, &read_fds, &write_fds);
    }
    
    // Clean up
    ares_destroy(channel);
    ares_library_cleanup();
    
    return 0;
}
```