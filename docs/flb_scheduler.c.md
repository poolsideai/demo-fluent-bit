# flb_scheduler.c

## Overview

The `flb_scheduler.c` file implements the scheduling system for Fluent Bit, responsible for managing timed events, retries, and periodic tasks. This component handles:

- Retry scheduling for failed output operations
- Periodic timer callbacks for various components
- Coroutine-based timer execution
- Event loop integration for timed operations
- Backoff algorithms for retry timing

The scheduler is a core component that ensures reliable delivery of log data by managing retry attempts with exponential backoff and jitter, preventing overwhelming downstream systems during failures.

## Key Functions/Components

### Core Data Structures

#### `struct flb_sched`
The main scheduler context containing:
- Event loop reference (`evl`)
- Configuration reference (`config`)
- Lists for managing requests, timers, and coroutines
- Frame timer for periodic processing
- Communication channels for coroutine notifications

#### `struct flb_sched_request`
Represents a scheduled retry request with:
- File descriptor for event notification (`fd`)
- Creation timestamp (`created`)
- Timeout value (`timeout`)
- Associated data (`data`)
- Timer reference (`timer`)

#### `struct flb_sched_timer`
Timer context for scheduled events with:
- Timer type (request, frame, callback)
- Active status flag
- File descriptor for timer event (`timer_fd`)
- Associated data and callback function
- Coroutine flag for coroutine-based execution

#### `struct flb_sched_timer_coro`
Coroutine timer context with:
- Unique identifier (`id`)
- Coroutine reference (`coro`)
- Timer reference (`timer`)
- Configuration reference (`config`)
- Associated data (`data`)

### Main Functions

#### `flb_sched_create(struct flb_config *config, struct mk_event_loop *evl)`
Initializes the scheduler system:
1. Allocates and initializes scheduler context
2. Initializes linked lists for request and timer management
3. Creates frame timer for periodic processing
4. Sets up communication channels for coroutine notifications
5. Returns the initialized scheduler context

#### `flb_sched_destroy(struct flb_sched *sched)`
Cleans up all scheduler resources:
1. Destroys all pending requests
2. Destroys all active timers
3. Cleans up dropped timer contexts
4. Frees scheduler memory

#### `flb_sched_request_create(struct flb_config *config, void *data, int tries)`
Creates a scheduled retry request:
1. Allocates timer and request contexts
2. Calculates retry delay using backoff algorithm
3. Schedules request for immediate or delayed execution
4. Returns the calculated delay time

#### `flb_sched_event_handler(struct flb_config *config, struct mk_event *event)`
Handles scheduler events triggered by the event loop:
1. Processes retry requests by dispatching to engine
2. Manages frame timer for periodic request promotion
3. Executes callback timers (one-shot and periodic)
4. Handles coroutine timer notifications

### Timer Management Functions

#### `flb_sched_timer_cb_create(struct flb_sched *sched, int type, int ms, void (*cb)(struct flb_config *, void *), void *data, struct flb_sched_timer **out_timer)`
Creates a timer for callback execution:
1. Validates timer type (one-shot or permanent)
2. Allocates and initializes timer context
3. Sets up event loop timeout
4. Returns timer reference if requested

#### `flb_sched_timer_coro_cb_create(struct flb_sched *sched, int type, int64_t ms, void (*cb)(struct flb_config *, void *), void *data, struct flb_sched_timer **out_timer)`
Creates a coroutine-based timer for callback execution:
1. Creates standard timer callback
2. Marks timer for coroutine execution
3. Returns appropriate error codes

#### `flb_sched_timer_invalidate(struct flb_sched_timer *timer)`
Invalidates a timer without destroying it:
1. Disables timer notifications
2. Marks timer as inactive
3. Moves timer to drop list for later cleanup

### Request Management Functions

#### `flb_sched_request_invalidate(struct flb_config *config, void *data)`
Finds and invalidates a scheduled request by data reference:
1. Searches active requests list
2. Searches waiting requests list
3. Invalidates and destroys matching request
4. Returns success/failure status

#### `flb_sched_retry_now(struct flb_config *config, struct flb_task_retry *retry)`
Schedules an immediate retry:
1. Creates timer and request contexts
2. Sets zero timeout for immediate execution
3. Schedules request for immediate processing
4. Returns appropriate error codes

### Support Functions

#### `backoff_full_jitter(int base, int cap, int n)`
Implements AWS-recommended full jitter backoff algorithm:
1. Calculates exponential backoff with cap
2. Generates random value within backoff range
3. Applies uniform distribution for jitter
4. Returns randomized backoff time

#### `random_uniform(int min, int max)`
Generates uniformly distributed random integers:
1. Seeds random number generator with system entropy
2. Implements rejection sampling for uniform distribution
3. Returns value within specified range

## Important Variables/Constants

### Timing Constants
- `FLB_SCHED_REQUEST_FRAME`: Time frame for request scheduling (typically 1 second)
- Backoff parameters for retry timing calculations
- Timer event priorities for event loop processing

### Timer Types
- `FLB_SCHED_TIMER_REQUEST`: Retry request timer
- `FLB_SCHED_TIMER_FRAME`: Periodic frame timer
- `FLB_SCHED_TIMER_CB_ONESHOT`: One-shot callback timer
- `FLB_SCHED_TIMER_CB_PERM`: Permanent callback timer

### Data Structures
- Linked lists for request and timer management
- Coroutine timer lists for coroutine-based execution
- Communication channels for coroutine notifications

## Dependencies and Relationships

This module depends on:
- `flb_config`: Configuration management
- `flb_engine`: Core engine functionality
- `flb_engine_dispatch`: Retry dispatching
- `mk_event`: Event loop integration
- `flb_coro`: Coroutine support
- `flb_random`: Random number generation
- `flb_mem`: Memory management
- `flb_log`: Logging functionality

It integrates with:
- Output plugin retry mechanisms
- Event loop for timed operations
- Engine dispatch system for retry processing
- Coroutine system for async timer execution
- Configuration system for timing parameters

## Implementation Details

The scheduler implements several key algorithms and patterns:

### Backoff Algorithm
Uses AWS-recommended full jitter backoff:
```
temp = min(cap, base * 2^n)
delay = random_between(base, temp)
```

Where:
- `base`: Base delay time
- `cap`: Maximum delay time
- `n`: Retry attempt number
- `delay`: Randomized backoff time

### Request Scheduling
Requests are managed in two lists:
1. `requests`: Active requests ready for immediate scheduling
2. `requests_wait`: Requests waiting for their timeout period

The frame timer periodically promotes requests from wait to active list based on elapsed time.

### Timer Event Handling
Different timer types are handled differently:
- Request timers: Trigger engine retry dispatch
- Frame timers: Promote waiting requests
- Callback timers: Execute user-defined callbacks
- Coroutine timers: Resume coroutine execution

### Memory Management
All scheduler components follow consistent allocation/deallocation patterns:
- Context allocation with `flb_calloc`
- Context destruction with `flb_free`
- Timer invalidation before destruction
- List management for resource tracking

### Error Handling
The scheduler gracefully handles resource exhaustion:
- Failed timer creation results in request destruction
- Memory allocation failures are propagated upward
- Invalid operations are logged with appropriate error levels

## Usage Examples

### Creating a Scheduled Retry
```c
// Schedule a retry for failed output operation
struct flb_config *config;
struct flb_output_instance *out_ins;
struct flb_task_retry *retry;
int tries = 3;

// Create retry context
retry = flb_task_retry_create(out_ins, chunk);

// Schedule retry with backoff
int delay = flb_sched_request_create(config, retry, tries);

if (delay > 0) {
    printf("Retry scheduled in %d seconds\n", delay);
} else {
    printf("Retry could not be scheduled\n");
}
```

### Creating a Callback Timer
```c
// Schedule periodic callback
struct flb_sched *sched;
struct flb_sched_timer *timer;

// Callback function
void my_periodic_callback(struct flb_config *config, void *data) {
    printf("Periodic task executed\n");
    // Perform periodic maintenance
}

// Create timer for 5-second intervals
int ret = flb_sched_timer_cb_create(sched, 
                                   FLB_SCHED_TIMER_CB_PERM,
                                   5000, /* 5 seconds */
                                   my_periodic_callback,
                                   NULL, /* data */
                                   &timer);

if (ret == 0) {
    printf("Periodic timer created successfully\n");
} else {
    printf("Failed to create periodic timer\n");
}
```

### Creating a Coroutine-Based Timer
```c
// Schedule coroutine-based callback
struct flb_sched *sched;
struct flb_sched_timer *timer;

// Coroutine callback function
void my_coro_callback(struct flb_config *config, void *data) {
    printf("Coroutine task started\n");
    
    // Simulate async work
    flb_coro_sleep(1000); // Sleep for 1 second
    
    printf("Coroutine task completed\n");
}

// Create coroutine timer
int ret = flb_sched_timer_coro_cb_create(sched,
                                        FLB_SCHED_TIMER_CB_ONESHOT,
                                        2000, /* 2 seconds */
                                        my_coro_callback,
                                        NULL, /* data */
                                        &timer);

if (ret == 0) {
    printf("Coroutine timer created successfully\n");
} else {
    printf("Failed to create coroutine timer\n");
}
```

### Immediate Retry Scheduling
```c
// Schedule immediate retry
struct flb_config *config;
struct flb_task_retry *retry;

// Create retry context
retry = flb_task_retry_create(out_ins, chunk);

// Schedule immediate retry
int ret = flb_sched_retry_now(config, retry);

if (ret == 0) {
    printf("Immediate retry scheduled\n");
} else {
    printf("Failed to schedule immediate retry\n");
}
```

### Invalidating Scheduled Requests
```c
// Cancel a scheduled retry
struct flb_config *config;
struct flb_task_retry *retry;

// Find and invalidate scheduled request
int ret = flb_sched_request_invalidate(config, retry);

if (ret == 0) {
    printf("Scheduled retry canceled\n");
} else {
    printf("No scheduled retry found\n");
}
```

### Configuration Example
```ini
[SERVICE]
    # Scheduler configuration
    sched_base 1.0
    sched_cap 60.0

[INPUT]
    name cpu
    tag cpu.*

[OUTPUT]
    name http
    match *
    host example.com
    port 80
    # Retries will use scheduler with backoff
```

In this example:
- Scheduler configured with base delay of 1 second
- Maximum backoff cap of 60 seconds
- HTTP output will use scheduler for retry management
- Failed requests will be retried with exponential backoff

### Performance Optimization Pattern
```c
// Optimized retry pattern using scheduler
struct flb_task_retry *retry;
struct flb_output_instance *out_ins;
struct flb_event_chunk *chunk;

// Create retry context
retry = flb_task_retry_create(out_ins, chunk);

// Try immediate retry first
int ret = flb_output_flush(out_ins, chunk);

if (ret == -1) {
    // Flush failed, schedule retry
    int delay = flb_sched_request_create(out_ins->config, retry, retry->tries);
    
    if (delay > 0) {
        printf("Retry scheduled for %d seconds\n", delay);
    } else {
        printf("Retry could not be scheduled, dropping data\n");
        flb_task_retry_destroy(retry);
    }
}
```

### Memory Management
```c
// Proper scheduler lifecycle management
struct flb_config *config;
struct flb_sched *sched;

// Create scheduler during initialization
sched = flb_sched_create(config, config->evl);
if (!sched) {
    flb_error("Failed to create scheduler");
    return -1;
}

// Store scheduler in config
config->sched = sched;

// Later, during cleanup
int cleanup_count = flb_sched_destroy(sched);
printf("Cleaned up %d scheduler resources\n", cleanup_count);
```

### Debugging Scheduler Operations
```c
// Debug function to inspect scheduler state
void debug_print_scheduler_state(struct flb_sched *sched) {
    int active_requests = 0;
    int waiting_requests = 0;
    int active_timers = 0;
    
    struct mk_list *head;
    
    // Count active requests
    mk_list_foreach(head, &sched->requests) {
        active_requests++;
    }
    
    // Count waiting requests
    mk_list_foreach(head, &sched->requests_wait) {
        waiting_requests++;
    }
    
    // Count active timers
    mk_list_foreach(head, &sched->timers) {
        active_timers++;
    }
    
    printf("Scheduler State:\n");
    printf("  Active Requests: %d\n", active_requests);
    printf("  Waiting Requests: %d\n", waiting_requests);
    printf("  Active Timers: %d\n", active_timers);
}

// Usage
debug_print_scheduler_state(config->sched);
```