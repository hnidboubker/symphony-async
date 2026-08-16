#!/usr/bin/env bash
# commit-async installation verification script
# Verifies that Git is installed and the current directory is a Git repository

set -euo pipefail

echo "=== commit-async Installation Verification ==="
echo

# 1. Verify Git is installed
if ! command -v git &> /dev/null; then
    echo "ERROR: Git is not installed or not in PATH"
    exit 1
fi

GIT_VERSION=$(git --version)
echo "✓ Git found: $GIT_VERSION"

# 2. Verify current directory is a Git repository
if ! git rev-parse --git-dir &> /dev/null; then
    echo "ERROR: Current directory is not a Git repository"
    exit 1
fi

echo "✓ Current directory is a Git repository"

# 3. Display repository root
REPO_ROOT=$(git rev-parse --show-toplevel)
echo "✓ Repository root: $REPO_ROOT"

# 4. Verify skill can be used (check for required structure)
SKILL_DIR="$REPO_ROOT/commit-async"
if [[ ! -d "$SKILL_DIR" ]]; then
    echo "ERROR: commit-async skill directory not found at $SKILL_DIR"
    exit 1
fi

if [[ ! -f "$SKILL_DIR/SKILL.md" ]]; then
    echo "ERROR: SKILL.md not found in commit-async directory"
    exit 1
fi

echo "✓ commit-async skill structure verified"

# 5. No external dependencies to install
echo
echo "=== Verification Complete ==="
echo "No external dependencies required (no Node.js, npm, or external packages)"
echo "No Git hooks created"
echo "No commits or pushes performed"
echo
echo "commit-async is ready to use."