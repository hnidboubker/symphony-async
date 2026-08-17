<#
.SYNOPSIS
    Install coder-async skill

.DESCRIPTION
    Copies the coder-async skill to a target project's .claude/skills directory

.PARAMETER TargetDir
    Target project directory (default: current directory)
#>

param(
    [string]$TargetDir = "."
)

Write-Host "Installing coder-async skill..." -ForegroundColor Cyan

# Verify Git
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "Error: Git is not installed" -ForegroundColor Red
    exit 1
}

# Verify we're in a git repository
try {
    git rev-parse --git-dir | Out-Null
} catch {
    Write-Host "Error: Not in a Git repository" -ForegroundColor Red
    exit 1
}

# Get the source directory (where this script lives)
$SourceDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$SourceDir = Split-Path -Parent $SourceDir

# Target skill directory
$SkillDir = Join-Path $TargetDir ".claude/skills/coder-async"

# Create target directory
New-Item -ItemType Directory -Force -Path $SkillDir | Out-Null

# Copy skill files
Write-Host "Copying skill files..." -ForegroundColor Yellow
Copy-Item -Path (Join-Path $SourceDir "*") -Destination $SkillDir -Recurse -Force

# Verify installation
if (Test-Path (Join-Path $SkillDir "SKILL.md") -and Test-Path (Join-Path $SkillDir "README.md")) {
    Write-Host "✓ coder-async skill installed successfully at $SkillDir" -ForegroundColor Green
} else {
    Write-Host "Error: Installation verification failed" -ForegroundColor Red
    exit 1
}

Write-Host "Installation complete." -ForegroundColor Cyan