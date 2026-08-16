#!/usr/bin/env pwsh
# commit-async installation verification script (PowerShell)
# Verifies that Git is installed and the current directory is a Git repository

$ErrorActionPreference = "Stop"

Write-Host "=== commit-async Installation Verification ==="
Write-Host ""

# 1. Verify Git is installed
try {
    $gitVersion = git --version
    Write-Host "✓ Git found: $gitVersion" -ForegroundColor Green
}
catch {
    Write-Host "ERROR: Git is not installed or not in PATH" -ForegroundColor Red
    exit 1
}

# 2. Verify current directory is a Git repository
try {
    $null = git rev-parse --git-dir 2>$null
    Write-Host "✓ Current directory is a Git repository" -ForegroundColor Green
}
catch {
    Write-Host "ERROR: Current directory is not a Git repository" -ForegroundColor Red
    exit 1
}

# 3. Display repository root
$repoRoot = git rev-parse --show-toplevel
Write-Host "✓ Repository root: $repoRoot" -ForegroundColor Green

# 4. Verify skill can be used (check for required structure)
$skillDir = Join-Path $repoRoot "commit-async"
if (-not (Test-Path -Path $skillDir -PathType Container)) {
    Write-Host "ERROR: commit-async skill directory not found at $skillDir" -ForegroundColor Red
    exit 1
}

$skillMd = Join-Path $skillDir "SKILL.md"
if (-not (Test-Path -Path $skillMd -PathType Leaf)) {
    Write-Host "ERROR: SKILL.md not found in commit-async directory" -ForegroundColor Red
    exit 1
}

Write-Host "✓ commit-async skill structure verified" -ForegroundColor Green

# 5. No external dependencies to install
Write-Host ""
Write-Host "=== Verification Complete ==="
Write-Host "No external dependencies required (no Node.js, npm, or external packages)"
Write-Host "No Git hooks created"
Write-Host "No commits or pushes performed"
Write-Host ""
Write-Host "commit-async is ready to use."