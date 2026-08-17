#!/bin/bash
# TUnit + BDD environment bootstrap for Linux/macOS

set -euo pipefail

echo "Installing TUnit BDD test environment..."

dotnet tool install --global tunit || true
dotnet restore

echo "BDD environment ready."
echo "Run: dotnet tunit --test-project <your-test-project>"