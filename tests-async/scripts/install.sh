#!/usr/bin/env bash

# tests-async Installer for Linux/macOS
# Verifies prerequisites for test orchestration with TUnit

set -euo pipefail

echo "========================================"
echo "tests-async Installer (Linux/macOS)"
echo "========================================"
echo

# Check for Git
if ! command -v git &> /dev/null; then
    echo "❌ Git is not installed or not in PATH"
    echo "   Please install Git: https://git-scm.com/"
    exit 1
fi
echo "✅ Git found: $(git --version)"

# Check if we're in a Git repository
if ! git rev-parse --git-dir &> /dev/null; then
    echo "❌ Current directory is not a Git repository"
    echo "   Run this installer from the root of your Git repository"
    exit 1
fi
echo "✅ Inside a Git repository"

REPO_ROOT=$(git rev-parse --show-toplevel)

# Check for .NET SDK
if ! command -v dotnet &> /dev/null; then
    echo "❌ .NET SDK is not installed or not in PATH"
    echo "   Please install .NET SDK 8.0+: https://dotnet.microsoft.com/download"
    exit 1
fi

DOTNET_VERSION=$(dotnet --version)
echo "✅ .NET SDK found: $DOTNET_VERSION"

# Verify .NET version is 8.0+
MAJOR_VERSION=$(echo "$DOTNET_VERSION" | cut -d. -f1)
if [ "$MAJOR_VERSION" -lt 8 ]; then
    echo "⚠️  Warning: .NET SDK version is $DOTNET_VERSION, recommended 8.0+"
fi

# Check for existing test project
echo
echo "Checking for test projects..."
TEST_PROJECTS=$(find . -name "*.csproj" -exec grep -l "TUnit" {} \; 2>/dev/null || true)

if [ -z "$TEST_PROJECTS" ]; then
    echo "ℹ️  No TUnit test project found"
    echo "   You can add TUnit to a test project with:"
    echo "   dotnet add <test-project>.csproj package TUnit"
else
    echo "✅ Found TUnit test project(s):"
    echo "$TEST_PROJECTS" | sed 's/^/   /'
fi

# Verify skill structure
SKILL_DIR="$(dirname "$0")/.."
REQUIRED_FILES=(
    "SKILL.md"
    "README.md"
    "references/Context.md"
    "scripts/install.sh"
    "scripts/install.ps1"
    "scripts/install.py"
)

echo
echo "Verifying skill structure..."
for file in "${REQUIRED_FILES[@]}"; do
    if [ -f "$SKILL_DIR/$file" ]; then
        echo "✅ $file"
    else
        echo "❌ Missing: $file"
    fi
done

# Verify delegated skills exist (at root level)
echo
echo "Verifying delegated skills..."
DELEGATED_SKILLS=("tdd-async" "bdd-async")
for skill in "${DELEGATED_SKILLS[@]}"; do
    if [ -d "$REPO_ROOT/$skill" ]; then
        echo "✅ $skill"
    else
        echo "⚠️  Missing delegated skill: $skill"
    fi
done

echo
echo "========================================"
echo "Installation verification complete!"
echo "========================================"
echo
echo "Next steps:"
echo "1. Ensure your test project references TUnit"
echo "2. Follow the orchestration workflow in SKILL.md"
echo "3. Run tests with: dotnet test"
echo