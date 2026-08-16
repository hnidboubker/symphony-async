#!/usr/bin/env bash
# auto-release installer (Bash)
# Verifies prerequisites for the auto-release skill

set -euo pipefail

echo "=== auto-release installer ==="
echo ""

# 1. Verify Git
if ! command -v git &> /dev/null; then
    echo "❌ Git is not installed or not in PATH"
    exit 1
fi
echo "✓ Git: $(git --version)"

# 2. Verify current directory is a Git repository
if ! git rev-parse --git-dir &> /dev/null; then
    echo "❌ Current directory is not a Git repository"
    exit 1
fi

REPO_ROOT=$(git rev-parse --show-toplevel)
echo "✓ Repository root: $REPO_ROOT"

# 3. Verify Python 3
if ! command -v python3 &> /dev/null; then
    echo "❌ Python 3 is not installed or not in PATH"
    exit 1
fi
echo "✓ Python: $(python3 --version)"

# 4. Verify release script exists
RELEASE_SCRIPT="$REPO_ROOT/auto-release/scripts/release.py"
if [[ ! -f "$RELEASE_SCRIPT" ]]; then
    echo "❌ Release script not found at: $RELEASE_SCRIPT"
    exit 1
fi
echo "✓ Release script: $RELEASE_SCRIPT"

# 5. Verify Python script is executable (or can be run with python3)
if [[ ! -r "$RELEASE_SCRIPT" ]]; then
    echo "❌ Release script is not readable"
    exit 1
fi
echo "✓ Release script is readable"

# 6. Test that the script can run (dry run - just check syntax)
if ! python3 -m py_compile "$RELEASE_SCRIPT" &> /dev/null; then
    echo "❌ Release script has syntax errors"
    exit 1
fi
echo "✓ Release script syntax is valid"

echo ""
echo "=== All checks passed ==="
echo ""
echo "auto-release is ready to use."
echo "Run with: python3 auto-release/scripts/release.py"
echo ""
echo "Note: This installer does NOT:"
echo "  - Install npm or Node.js"
echo "  - Install external Python packages"
echo "  - Create Git hooks"
echo "  - Create commits or tags"
echo "  - Push anything"