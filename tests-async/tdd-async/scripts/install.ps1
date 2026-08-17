<#
.SYNOPSIS
    tdd-async Installer for Windows PowerShell
    Verifies prerequisites for TDD workflow with TUnit
#>

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "tdd-async Installer (Windows PowerShell)" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check for Git
try {
    $gitVersion = git --version 2>&1
    if ($LASTEXITCODE -ne 0) { throw "Git not found" }
    Write-Host "✅ Git found: $gitVersion" -ForegroundColor Green
}
catch {
    Write-Host "❌ Git is not installed or not in PATH" -ForegroundColor Red
    Write-Host "   Please install Git: https://git-scm.com/" -ForegroundColor Yellow
    exit 1
}

# Check if we're in a Git repository
try {
    $gitDir = git rev-parse --git-dir 2>&1
    if ($LASTEXITCODE -ne 0) { throw "Not a git repo" }
    Write-Host "✅ Inside a Git repository" -ForegroundColor Green
}
catch {
    Write-Host "❌ Current directory is not a Git repository" -ForegroundColor Red
    Write-Host "   Run this installer from the root of your Git repository" -ForegroundColor Yellow
    exit 1
}

# Check for .NET SDK
try {
    $dotnetVersion = dotnet --version 2>&1
    if ($LASTEXITCODE -ne 0) { throw "dotnet not found" }
    Write-Host "✅ .NET SDK found: $dotnetVersion" -ForegroundColor Green

    # Verify .NET version is 8.0+
    $majorVersion = [int]($dotnetVersion.Split('.')[0])
    if ($majorVersion -lt 8) {
        Write-Host "⚠️  Warning: .NET SDK version is $dotnetVersion, recommended 8.0+" -ForegroundColor Yellow
    }
}
catch {
    Write-Host "❌ .NET SDK is not installed or not in PATH" -ForegroundColor Red
    Write-Host "   Please install .NET SDK 8.0+: https://dotnet.microsoft.com/download" -ForegroundColor Yellow
    exit 1
}

# Check for existing test project
Write-Host ""
Write-Host "Checking for test projects..." -ForegroundColor Cyan
$testProjects = Get-ChildItem -Recurse -Filter "*.csproj" | Where-Object {
    (Get-Content $_.FullName) -match "TUnit"
}

if (-not $testProjects) {
    Write-Host "ℹ️  No TUnit test project found" -ForegroundColor Yellow
    Write-Host "   You can add TUnit to a test project with:" -ForegroundColor Gray
    Write-Host "   dotnet add <test-project>.csproj package TUnit" -ForegroundColor Gray
}
else {
    Write-Host "✅ Found TUnit test project(s):" -ForegroundColor Green
    $testProjects | ForEach-Object { Write-Host "   $($_.FullName)" -ForegroundColor Gray }
}

# Verify skill structure
$skillDir = Split-Path $PSScriptRoot -Parent
$requiredFiles = @(
    "SKILL.md",
    "README.md",
    "references/Context.md",
    "scripts/install.sh",
    "scripts/install.ps1",
    "scripts/install.py"
)

Write-Host ""
Write-Host "Verifying skill structure..." -ForegroundColor Cyan
foreach ($file in $requiredFiles) {
    $fullPath = Join-Path $skillDir $file
    if (Test-Path $fullPath) {
        Write-Host "✅ $file" -ForegroundColor Green
    }
    else {
        Write-Host "❌ Missing: $file" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Installation verification complete!" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. Ensure your test project references TUnit" -ForegroundColor Gray
Write-Host "2. Follow the TDD workflow in SKILL.md" -ForegroundColor Gray
Write-Host "3. Run tests with: dotnet test" -ForegroundColor Gray
Write-Host ""