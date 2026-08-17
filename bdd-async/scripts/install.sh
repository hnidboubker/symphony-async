#!/bin/bash
# TUnit + BDD environment bootstrap for Linux/macOS

set -euo pipefail

echo "Installing TUnit BDD test environment..."

# TUnit is a NuGet package, not a .NET tool
# Verify .NET SDK is available
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

echo "BDD environment ready."
echo "Add TUnit to your test project with:"
echo "  dotnet add <test-project>.csproj package TUnit"
echo "Then run tests with: dotnet test"