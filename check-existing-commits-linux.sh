#!/bin/bash

# Bash script to check existing commit messages for Conventional Commits format

# Regular expression pattern for Conventional Commits
pattern='^(feat|fix|docs|style|refactor|perf|test|chore|init|add|upgrade|ref)(\([a-z-]+\))?: .+$'

# Get all commit messages
commits=$(git log --pretty=format:"%H %s")

# Initialize counter for non-compliant commits
non_compliant_count=0

echo "Checking commit messages..."

# Check each commit message
while IFS= read -r commit; do
    hash=$(echo "$commit" | cut -d' ' -f1)
    message=$(echo "$commit" | cut -d' ' -f2-)
    if ! [[ $message =~ $pattern ]]; then
        echo "Non-compliant commit:"
        echo "  Hash: $hash"
        echo "  Message: $message"
        echo
        ((non_compliant_count++))
    fi
done <<< "$commits"

# Output results
if [ $non_compliant_count -eq 0 ]; then
    echo "All commit messages follow the Conventional Commits format."
else
    echo "Total non-compliant commits: $non_compliant_count"
fi
