# File Documentation: CONTRIBUTING.md

## File path
CONTRIBUTING.md

## File type
Markdown documentation file

## Purpose
This file contains guidelines for contributing to the Fluent Bit project. It explains the development workflow, coding standards, commit message conventions, licensing requirements, and other important information for contributors.

## Key components
- Developer guide reference
- Git repositories workflow
- Coding style guidelines
- Commit changes instructions
- Licensing requirements
- Code review process
- Release branches information
- Unit tests information

## Detailed documentation
The CONTRIBUTING.md file serves as a comprehensive guide for anyone who wants to contribute to the Fluent Bit project. It contains:

1. **Developer Guide Reference**: Points to the DEVELOPER_GUIDE.md file which contains code examples and additional development information.

2. **Git Repositories Workflow**: Explains that all code changes happen on GitHub, with instructions to clone the repository, make local changes, and submit pull requests.

3. **Coding Style Guidelines**:
   - Based on Apache C style guidelines
   - Tabs are 4 spaces
   - Line length should not exceed 90 characters
   - Braces usage rules for conditionals, loops, and functions
   - Variable definitions must be at the beginning of functions
   - Functions should be split if they become too long
   - Comment formatting rules (single line and multiline)

4. **Commit Changes Instructions**:
   - Commit messages must be prefixed with the core section name in lowercase plus a colon
   - One commit should not include changes to files from different components
   - Commit subjects must not exceed 80 characters
   - Commit body lines must not exceed 80 characters
   - Use the -s flag when committing to add a Signed-off comment
   - Common component prefixes include utils:, pack:, sds:, http_client:, etc.
   - Plugin-related changes should be prefixed with the plugin name

5. **Licensing Requirements**:
   - All code must be under Apache License v2.0
   - Source code files must include the standard Apache license header

6. **Code Review Process**:
   - Code submissions must follow coding style
   - Code should be clear and documented if required
   - Patches must have well-formed subjects and descriptions
   - Reviewers may request improvements

7. **Release Branches Information**:
   - master branch is for the next major version
   - <major> branches are for existing stable releases
   - PRs typically target master for the next major release
   - Changes for specific releases should target the appropriate branch

8. **Unit Tests Information**:
   - Uses ctest for unit testing
   - Tests are separated into internal and runtime tests
   - Tests can be enabled with cmake flags
   - Tests can be run individually or in parallel

## Usage examples
Contributors should follow these guidelines when submitting pull requests to the Fluent Bit repository.

## Dependencies
None (this is a documentation file)

## Additional notes
This file is essential for maintaining code quality and consistency in the Fluent Bit project. It helps ensure that all contributions follow the same standards and processes.
