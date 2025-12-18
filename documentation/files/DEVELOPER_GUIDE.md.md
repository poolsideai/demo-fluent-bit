# File Documentation: DEVELOPER_GUIDE.md

## File path
DEVELOPER_GUIDE.md

## File type
Markdown documentation file

## Purpose
This file serves as a comprehensive guide for developers who want to contribute to the Fluent Bit project. It provides detailed information about the development environment, libraries, concurrency model, plugin API, and testing procedures.

## Key components
- Development environment setup
- Libraries overview
- Concurrency model explanation
- Plugin API documentation
- Testing procedures
- Additional resources

## Detailed documentation
The DEVELOPER_GUIDE.md file is a detailed resource for developers working with Fluent Bit. It contains:

1. **Development Environment Setup**:
   - Devcontainer setup instructions for containerized development
   - Vagrant setup for reproducible development environments
   - Requirements and setup procedures for both approaches

2. **Libraries Overview**:
   - Memory management functions (flb_malloc, flb_calloc, flb_realloc, flb_free)
   - String handling with SDS (Simple Dynamic Strings) library
   - HTTP client implementation details
   - Linked list implementation using mk_list
   - Message Pack integration for data storage

3. **Concurrency Model**:
   - Explanation of coroutines and how they work in Fluent Bit
   - How the event loop manages coroutine scheduling
   - Practical advice for filter and output plugins regarding concurrency
   - Code examples showing coroutine behavior

4. **Plugin API Documentation**:
   - Input plugin structure and implementation
   - Filter plugin structure and implementation
   - Output plugin structure and implementation
   - Config maps for plugin configuration management
   - Examples of plugin implementations

5. **Testing Procedures**:
   - Building Fluent Bit for development
   - Running unit tests (internal and runtime)
   - Building and testing on Windows
   - Using Valgrind for memory issue detection
   - Container-based testing with run_code_analysis.sh

## Usage examples
Developers should refer to this guide when:
- Setting up their development environment
- Understanding Fluent Bit's architecture and libraries
- Implementing new plugins
- Debugging concurrency issues
- Running tests and ensuring code quality

## Dependencies
None (this is a documentation file)

## Additional notes
This guide is essential for anyone looking to contribute to Fluent Bit. It provides practical examples and explanations that help developers understand the codebase and follow best practices.
