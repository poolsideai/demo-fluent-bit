# Monkey Library

## Overview

Monkey is a fast and lightweight Web Server for Linux, designed to be very scalable with low memory and CPU consumption. It is the perfect solution for Embedded Linux and high-end production environments.

Besides the common features of an HTTP server, Monkey exposes a flexible C API which aims to behave as a fully HTTP development framework, so it can be extended as desired through the plugins interface.

Key features:
- HTTP/1.1 Compliant
- Hybrid Networking Model: Asynchronous mode + fixed Threads
- Indented configuration style
- Versatile plugin subsystem / API
- x86, x86_64 & ARM compatible
- SSL support
- IPv6 support
- Basic Auth
- Log writer
- Security features
- Directory Listing
- CGI support
- FastCGI support
- Embeddable as a shared library

## Key Methods/Functions

### Server Management

- `mk_ctx_t *mk_create()` - Creates a new Monkey context
- `int mk_start(mk_ctx_t *ctx)` - Starts the Monkey server
- `int mk_stop(mk_ctx_t *ctx)` - Stops the Monkey server
- `int mk_destroy(mk_ctx_t *ctx)` - Destroys the Monkey context

### Configuration

- `int mk_config_set(mk_ctx_t *ctx, ...)` - Sets configuration parameters

### Virtual Host Management

- `int mk_vhost_create(mk_ctx_t *ctx, char *name)` - Creates a new virtual host
- `struct mk_vhost *mk_vhost_lookup(mk_ctx_t *ctx, int id)` - Looks up a virtual host by ID
- `int mk_vhost_set(mk_ctx_t *ctx, int vid, ...)` - Sets virtual host parameters
- `int mk_vhost_handler(mk_ctx_t *ctx, int vid, char *regex, void (*cb)(mk_request_t *, void *), void *data)` - Registers a request handler for a virtual host

### HTTP Response Handling

- `int mk_http_status(mk_request_t *req, int status)` - Sets the HTTP status code for a response
- `int mk_http_header(mk_request_t *req, char *key, int key_len, char *val, int val_len)` - Adds an HTTP header to the response
- `int mk_http_send(mk_request_t *req, char *buf, size_t len, void (*cb_finish)(mk_request_t *))` - Sends data in the HTTP response
- `int mk_http_done(mk_request_t *req)` - Finishes the HTTP response

### Worker Callbacks

- `int mk_worker_callback(mk_ctx_t *ctx, void (*cb_func) (void *), void *data)` - Registers a worker callback function

### Message Queue

- `int mk_mq_create(mk_ctx_t *ctx, char *name, void (*cb), void *data)` - Creates a message queue
- `int mk_mq_send(mk_ctx_t *ctx, int qid, void *data, size_t size)` - Sends data to a message queue

## Usage Notes

Monkey can be used in two ways:
1. As a standalone web server
2. As an embedded library in other applications

When embedding Monkey as a library, you typically:
1. Create a context with `mk_create()`
2. Configure the server with `mk_config_set()`
3. Set up virtual hosts with `mk_vhost_create()` and `mk_vhost_handler()`
4. Start the server with `mk_start()`
5. Stop and clean up with `mk_stop()` and `mk_destroy()`

Example of setting up a simple request handler:

```c
void my_handler(mk_request_t *req, void *data) {
    mk_http_status(req, 200);
    mk_http_header(req, "Content-Type", 12, "text/plain", 10);
    mk_http_send(req, "Hello, World!\n", 14, NULL);
    mk_http_done(req);
}

// Setup code
mk_ctx_t *ctx = mk_create();
mk_config_set(ctx, "Listen", 8080);
int vid = mk_vhost_create(ctx, "localhost");
mk_vhost_handler(ctx, vid, "/", my_handler, NULL);
mk_start(ctx);
```