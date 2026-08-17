#!/usr/bin/env bash
# symphony-async installer for Linux/macOS
# Verifies the environment and Symphony structure

set -euo pipefail

echo "=== Symphony Async Installer ==="
echo ""

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

success() { echo -e "${GREEN}✓${NC} $1"; }
error() { echo -e "${RED}✗${NC} $1"; }
warn() { echo -e "${YELLOW}⚠${NC} $1"; }

# Track verification results
ALL_OK=true

# 1. Verify Git
echo "Checking Git..."
if command -v git >/dev/null 2>&1; then
    GIT_VERSION=$(git --version)
    success "Git found: $GIT_VERSION"
else
    error "Git not found in PATH"
    ALL_OK=false
fi

# 2. Verify Python 3
echo "Checking Python 3..."
if command -v python3 >/dev/null 2>&1; then
    PYTHON_VERSION=$(python3 --version)
    success "Python 3 found: $PYTHON_VERSION"
elif command -v python >/dev/null 2>&1; then
    PYTHON_VERSION=$(python --version)
    if [[ $PYTHON_VERSION == *"Python 3"* ]]; then
        success "Python 3 found: $PYTHON_VERSION"
    else
        error "Python 3 required, found: $PYTHON_VERSION"
        ALL_OK=false
    fi
else
    error "Python 3 not found in PATH"
    ALL_OK=false
fi

# 3. Verify Git repository
echo "Checking Git repository..."
if git rev-parse --git-dir >/dev/null 2>&1; then
    success "Current directory is a Git repository"
    REPO_ROOT=$(git rev-parse --show-toplevel)
    success "Repository root: $REPO_ROOT"
else
    error "Current directory is not a Git repository"
    ALL_OK=false
fi

# 4. Verify Symphony structure
echo "Checking Symphony structure..."
SYMPHONY_DIR="$REPO_ROOT/symphony-async"

if [[ -d "$SYMPHONY_DIR" ]]; then
    success "symphony-async directory exists"
else
    error "symphony-async directory not found at $SYMPHONY_DIR"
    ALL_OK=false
fi

# Check required subdirectories
for subdir in "scripts" "references"; do
    if [[ -d "$SYMPHONY_DIR/$subdir" ]]; then
        success "  $subdir/ exists"
    else
        error "  $subdir/ missing"
        ALL_OK=false
    fi
done

# Check required files
for file in "SKILL.md" "README.md" "references/Context.md"; do
    if [[ -f "$SYMPHONY_DIR/$file" ]]; then
        success "  $file exists"
    else
        error "  $file missing"
        ALL_OK=false
    fi
done

# Check install scripts
for script in "install.sh" "install.ps1" "install.py"; do
    if [[ -f "$SYMPHONY_DIR/scripts/$script" ]]; then
        success "  scripts/$script exists"
    else
        error "  scripts/$script missing"
        ALL_OK=false
    fi
done

# 5. Verify expected skills exist
echo "Checking expected skills..."
SKILLS_DIR="$REPO_ROOT"
EXPECTED_SKILLS=("commit-async" "tests-async" "auto-release" "readme-async")
EXPECTED_SUB_SKILLS=("tests-async/tdd-async" "tests-async/bdd-async")

for skill in "${EXPECTED_SKILLS[@]}"; do
    if [[ -d "$SKILLS_DIR/$skill" ]] && [[ -f "$SKILLS_DIR/$skill/SKILL.md" ]]; then
        success "  $skill exists"
    else
        error "  $skill missing or incomplete"
        ALL_OK=false
    fi
done

for skill in "${EXPECTED_SUB_SKILLS[@]}"; do
    if [[ -d "$SKILLS_DIR/$skill" ]] && [[ -f "$SKILLS_DIR/$skill/SKILL.md" ]]; then
        success "  $skill exists"
    else
        error "  $skill missing or incomplete"
        ALL_OK=false
    fi
done

# Summary
echo ""
echo "=== Installation Summary ==="
if [[ "$ALL_OK" == true ]]; then
    success "All verifications passed. Symphony Async is ready."
    exit 0
else
    error "Some verifications failed. Please resolve the issues above."
    exit 1
fi