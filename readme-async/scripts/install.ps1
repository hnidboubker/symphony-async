<#
.SYNOPSIS
    Install readme-async skill into a project

.DESCRIPTION
    Copies the readme-async skill to the target project's .claude/skills directory

.PARAMETER TargetPath
    Path to the target project (default: current directory)

.EXAMPLE
    .\scripts\install.ps1

.EXAMPLE
    .\scripts\install.ps1 "C:\path\to\project"
#>

param(
    [string]$TargetPath = (Get-Location).Path
)

$SkillName = "readme-async"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$SkillSourceDir = Split-Path -Parent $ScriptDir
$TargetDir = $TargetPath

Write-Host "[INFO] Installing $SkillName skill..." -ForegroundColor Green
Write-Host "[INFO] Source: $SkillSourceDir" -ForegroundColor Green
Write-Host "[INFO] Target: $TargetDir" -ForegroundColor Green

# Validate target
if (-not (Test-Path -Path $TargetDir -PathType Container)) {
    Write-Host "[ERROR] Target directory not found: $TargetDir" -ForegroundColor Red
    exit 1
}

$SkillsDir = Join-Path $TargetDir ".claude\skills"
$TargetSkillDir = Join-Path $SkillsDir $SkillName

# Create .claude\skills if needed
if (-not (Test-Path -Path $SkillsDir -PathType Container)) {
    New-Item -ItemType Directory -Path $SkillsDir -Force | Out-Null
}

# Check if already installed
if (Test-Path -Path $TargetSkillDir -PathType Container) {
    Write-Host "[WARN] Skill already installed at $TargetSkillDir" -ForegroundColor Yellow
    $Response = Read-Host "Overwrite? (y/N)"
    if ($Response -notmatch '^[Yy]$') {
        Write-Host "[INFO] Installation cancelled" -ForegroundColor Green
        exit 0
    }
    Remove-Item -Path $TargetSkillDir -Recurse -Force
}

# Copy skill files (excluding scripts/ folder and any install scripts)
Write-Host "[INFO] Copying skill files..." -ForegroundColor Green
$exclude = @('scripts', 'install.sh', 'install.ps1')
Get-ChildItem -Path $SkillSourceDir | Where-Object { $exclude -notcontains $_.Name } | Copy-Item -Destination $TargetSkillDir -Recurse -Force

Write-Host "[INFO] Skill installed successfully at $TargetSkillDir" -ForegroundColor Green
Write-Host ""
Write-Host "To use the skill, run:" -ForegroundColor Green
Write-Host "  /skill readme-async" -ForegroundColor Cyan
Write-Host ""
Write-Host "Or add to your CLAUDE.md:" -ForegroundColor Green
Write-Host "  - readme-async: Keep README.md synchronized with codebase" -ForegroundColor Cyan