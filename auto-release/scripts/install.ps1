#!/usr/bin/env pwsh
# auto-release installer (PowerShell)
# Verifies prerequisites for the auto-release skill

Write-Host "=== auto-release installer ==="
Write-Host ""

# 1. Verify Git
try {
    $gitVersion = git --version
    Write-Host "✓ Git: $gitVersion"
} catch {
    Write-Host "❌ Git is not installed or not in PATH"
    exit 1
}

# 2. Verify current directory is a Git repository
try {
    $repoRoot = git rev-parse --show-toplevel
    Write-Host "✓ Repository root: $repoRoot"
} catch {
    Write-Host "❌ Current directory is not a Git repository"
    exit 1
}

# 3. Verify Python 3
try {
    $pythonVersion = python3 --version
    Write-Host "✓ Python: $pythonVersion"
} catch {
    try {
        $pythonVersion = python --version
        Write-Host "✓ Python: $pythonVersion"
    } catch {
        Write-Host "❌ Python 3 is not installed or not in PATH"
        exit 1
    }
}

# 4. Verify release script exists
$releaseScript = Join-Path $repoRoot "auto-release/scripts/release.py"
if (-not (Test-Path $releaseScript)) {
    Write-Host "❌ Release script not found at: $releaseScript"
    exit 1
}
Write-Host "✓ Release script: $releaseScript"

# 5. Verify Python script is readable
try {
    Get-Content $releaseScript -ErrorAction Stop | Out-Null
    Write-Host "✓ Release script is readable"
} catch {
    Write-Host "❌ Release script is not readable"
    exit 1
}

# 6. Test that the script can run (syntax check)
try {
    python3 -m py_compile $releaseScript 2>$null
    Write-Host "✓ Release script syntax is valid"
} catch {
    try {
        python -m py_compile $releaseScript 2>$null
        Write-Host "✓ Release script syntax is valid"
    } catch {
        Write-Host "❌ Release script has syntax errors"
        exit 1
    }
}

Write-Host ""
Write-Host "=== All checks passed ==="
Write-Host ""
Write-Host "auto-release is ready to use."
Write-Host "Run with: python3 auto-release/scripts/release.py"
Write-Host ""
Write-Host "Note: This installer does NOT:"
Write-Host "  - Install npm or Node.js"
Write-Host "  - Install external Python packages"
Write-Host "  - Create Git hooks"
Write-Host "  - Create commits or tags"
Write-Host "  - Push anything"