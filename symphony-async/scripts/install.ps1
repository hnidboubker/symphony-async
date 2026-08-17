<#
.SYNOPSIS
    Symphony Async installer for Windows PowerShell
    Verifies the environment and Symphony structure
#>

Write-Host "=== Symphony Async Installer ===" -ForegroundColor Cyan
Write-Host ""

$allOk = $true

function Success($msg) { Write-Host "✓ $msg" -ForegroundColor Green }
function Error($msg) { Write-Host "✗ $msg" -ForegroundColor Red; $global:allOk = $false }
function Warn($msg) { Write-Host "⚠ $msg" -ForegroundColor Yellow }

# 1. Verify Git
Write-Host "Checking Git..."
try {
    $gitVersion = git --version 2>&1
    if ($LASTEXITCODE -eq 0) {
        Success "Git found: $gitVersion"
    } else {
        Error "Git not found in PATH"
    }
} catch {
    Error "Git not found in PATH"
}

# 2. Verify Python 3
Write-Host "Checking Python 3..."
try {
    $pythonVersion = python --version 2>&1
    if ($LASTEXITCODE -eq 0 -and $pythonVersion -match "Python 3") {
        Success "Python 3 found: $pythonVersion"
    } elseif ($LASTEXITCODE -eq 0) {
        Error "Python 3 required, found: $pythonVersion"
    } else {
        Error "Python 3 not found in PATH"
    }
} catch {
    Error "Python 3 not found in PATH"
}

# 3. Verify Git repository
Write-Host "Checking Git repository..."
try {
    $repoRoot = git rev-parse --show-toplevel 2>&1
    if ($LASTEXITCODE -eq 0) {
        Success "Current directory is a Git repository"
        Success "Repository root: $repoRoot"
    } else {
        Error "Current directory is not a Git repository"
    }
} catch {
    Error "Current directory is not a Git repository"
}

# 4. Verify Symphony structure
Write-Host "Checking Symphony structure..."
$symphonyDir = Join-Path $repoRoot "symphony-async"

if (Test-Path $symphonyDir -PathType Container) {
    Success "symphony-async directory exists"
} else {
    Error "symphony-async directory not found at $symphonyDir"
}

# Check required subdirectories
$subdirs = @("scripts", "references")
foreach ($subdir in $subdirs) {
    $path = Join-Path $symphonyDir $subdir
    if (Test-Path $path -PathType Container) {
        Success "  $subdir/ exists"
    } else {
        Error "  $subdir/ missing"
    }
}

# Check required files
$files = @("SKILL.md", "README.md", "references/Context.md")
foreach ($file in $files) {
    $path = Join-Path $symphonyDir $file
    if (Test-Path $path -PathType Leaf) {
        Success "  $file exists"
    } else {
        Error "  $file missing"
    }
}

# Check install scripts
$scripts = @("install.sh", "install.ps1", "install.py")
foreach ($script in $scripts) {
    $path = Join-Path $symphonyDir "scripts" $script
    if (Test-Path $path -PathType Leaf) {
        Success "  scripts/$script exists"
    } else {
        Error "  scripts/$script missing"
    }
}

# 5. Verify expected skills exist
Write-Host "Checking expected skills..."
$skillsDir = $repoRoot
$expectedSkills = @("commit-async", "tests-async", "auto-release", "readme-async")
$expectedSubSkills = @("tests-async/tdd-async", "tests-async/bdd-async")

foreach ($skill in $expectedSkills) {
    $skillPath = Join-Path $skillsDir $skill
    $skillFile = Join-Path $skillPath "SKILL.md"
    if (Test-Path $skillPath -PathType Container -and Test-Path $skillFile -PathType Leaf) {
        Success "  $skill exists"
    } else {
        Error "  $skill missing or incomplete"
    }
}

foreach ($skill in $expectedSubSkills) {
    $skillPath = Join-Path $skillsDir $skill
    $skillFile = Join-Path $skillPath "SKILL.md"
    if (Test-Path $skillPath -PathType Container -and Test-Path $skillFile -PathType Leaf) {
        Success "  $skill exists"
    } else {
        Error "  $skill missing or incomplete"
    }
}

# Summary
Write-Host ""
Write-Host "=== Installation Summary ===" -ForegroundColor Cyan
if ($allOk) {
    Success "All verifications passed. Symphony Async is ready."
    exit 0
} else {
    Error "Some verifications failed. Please resolve the issues above."
    exit 1
}