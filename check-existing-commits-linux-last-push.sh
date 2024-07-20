#!/bin/bash

# Bash script to check unpushed commit messages for Conventional Commits format

# Regular expression pattern for Conventional Commits
pattern='^(feat|fix|docs|style|refactor|perf|test|chore|init|add|upgrade|ref)(\([a-z-]+\))?: .+$'
# Get the current branch name
current_branch=$(git rev-parse --abbrev-ref HEAD)

# Get the remote tracking branch
remote_branch=$(git for-each-ref --format='%(upstream:short)' $(git symbolic-ref -q HEAD))

if [ -z "$remote_branch" ]; then
    echo "No tracking information for the current branch. Are you sure it's set up to track a remote branch?"
    exit 1
fi

echo "Checking unpushed commit messages on branch $current_branch..."

# Get all unpushed commit messages
commits=$(git log $remote_branch..$current_branch --pretty=format:"%H %s")

# Initialize counter for non-compliant commits
non_compliant_count=0

# Check each commit message
while IFS= read -r commit; do
    if [ -n "$commit" ]; then
        hash=$(echo "$commit" | cut -d' ' -f1)
        message=$(echo "$commit" | cut -d' ' -f2-)
        if ! [[ $message =~ $pattern ]]; then
            echo "Non-compliant commit:"
            echo "  Hash: $hash"
            echo "  Message: $message"
            echo
            ((non_compliant_count++))
        fi
    fi
done <<< "$commits"

# Output results
if [ $non_compliant_count -eq 0 ]; then
    echo "All unpushed commit messages follow the Conventional Commits format."
else
    echo "Total non-compliant unpushed commits: $non_compliant_count"
fi

# Show total number of unpushed commits
total_commits=$(echo "$commits" | grep -c '^')
echo "Total unpushed commits: $total_commits"
