#!/bin/bash
# Script to automatically generate/update documentation for changed source files.
# This script is called by the GitHub Actions workflow.

set -e  # Exit on error

# Function to convert source path to doc path
# Example: src/utils/helper.py -> docs/utils/helper.py.md
get_doc_path() {
    local src_path="$1"
    
    if [[ ! "$src_path" =~ ^src/ ]]; then
        echo "Error: Source path must start with 'src/': $src_path" >&2
        return 1
    fi
    
    # Remove 'src/' prefix and add 'docs/' prefix, then append '.md'
    local relative_path="${src_path#src/}"
    echo "docs/${relative_path}.md"
}

# Function to generate documentation using pool CLI
generate_documentation() {
    local file_path="$1"
    local file_content="$2"
    
    # Create the prompt for Claude
    local prompt="Please analyze the following source code file and generate comprehensive documentation for it.

File path: ${file_path}

Source code:
\`\`\`
${file_content}
\`\`\`

Generate documentation that includes:
1. A brief overview of what this file does
2. Description of key functions, classes, or components
3. Important parameters and return values
4. Usage examples where appropriate
5. Any notable dependencies or relationships with other files

Format the documentation in clear, readable Markdown. Use appropriate headers, code blocks, and formatting."
    
    # Use Claude CLI in print mode to generate documentation
    # The -p flag is for "print mode" which is non-interactive
    echo "$prompt" | claude -p --output-format text 2>/dev/null || {
        echo "# ${file_path}

Error generating documentation. Please ensure Claude CLI is properly configured." >&2
        return 1
    }
}

# Function to write documentation to file
write_documentation() {
    local doc_path="$1"
    local content="$2"
    
    # Create directory structure if it doesn't exist
    mkdir -p "$(dirname "$doc_path")"
    
    # Write content to file
    echo "$content" > "$doc_path"
    
    if [[ $? -eq 0 ]]; then
        echo "✓ Updated documentation: $doc_path"
    else
        echo "✗ Error writing $doc_path" >&2
        return 1
    fi
}

# Main execution
main() {
    # Check if ANTHROPIC_API_KEY is set
    if [[ -z "$ANTHROPIC_API_KEY" ]]; then
        echo "Error: ANTHROPIC_API_KEY environment variable not set" >&2
        exit 1
    fi
    
    # Get changed files from environment variable
    if [[ -z "$CHANGED_FILES" ]]; then
        echo "No changed files to process"
        exit 0
    fi
    
    # Convert space-separated string to array
    read -ra changed_files_array <<< "$CHANGED_FILES"
    
    if [[ ${#changed_files_array[@]} -eq 0 ]]; then
        echo "No changed files to process"
        exit 0
    fi
    
    echo "Processing ${#changed_files_array[@]} changed file(s)..."

    # Create a description of the task with file paths
          cat > /tmp/documentation-task.txt << 'EOF'
          Please create comprehensive documentation for the following source files.

          For each file, create a corresponding documentation file in the docs/ directory with the same relative path structure and add a .md extension.

          Files to document:
          EOF
          
          # Add the list of files
          for src_file in "${changed_files_array[@]}"; do
            if [ -z "$src_file" ]; then
              continue
            fi
            echo "- $src_file" >> /tmp/documentation-task.txt
          done
          
          # Add documentation requirements
          cat >> /tmp/documentation-task.txt << 'EOF'

          For each file, create documentation that includes:
          1. A brief overview of what this file does
          2. Key functions/classes/components and their purposes
          3. Important variables or constants
          4. Dependencies and relationships with other parts of the system
          5. Any notable implementation details or algorithms
          6. Usage examples if applicable

          Format the documentation in clear, professional Markdown suitable for a technical documentation site.
          
          Save each documentation file to: docs/{relative_path}.md
          For example: src/foo/bar.js → docs/foo/bar.js.md
          EOF
          
          # Generate documentation using pool CLI
          pool --api-url "${{ env.API_URL }}" \
            --agent-name "${{ env.AGENT_NAME }}" \
            --prompt "$(cat /tmp/documentation-task.txt)" \
            --unsafe-auto-allow
          
          echo ""
          echo "✅ Documentation generation complete!"

    
    

}

# Run main function
main
