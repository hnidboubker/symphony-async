<#PSScriptInfo
.VERSION 1.0.0
.GUID 5a2b8c4d-7e9f-4a1b-8c2d-3e4f5a6b7c8d
.AUTHOR Symphony Async Team
.COPYRIGHT 2026
.TAGS test-fixer, async, refactoring, dotnet
.LICENSE MIT
.PROJECTURI https://github.com/symphony-async
#>

<#PSScriptInfo
.SYNOPSIS
    test-fixer-refact-async Installer - Verifies prerequisites for fixing failing async tests and refactoring

.DESCRIPTION
    Cross-platform installer that checks for Git, .NET SDK, test projects, and skill structure.

.NOTES
    Run from the root of your Git repository.
#>

[CmdletBinding()]
param()

# Colors
$GREEN = [ConsoleColor]::Green
$RED = [ConsoleColor]::Red
$YELLOW = [ConsoleColor]::Yellow
$BLUE = [ConsoleColor]::Cyan
$GRAY = [ConsoleColor]::Gray

$CHECK = "[OK]"
$CROSS = "[X]"
$WARN = "[!]"
$INFO = "[i]"

function Write-Header {
    param([string]$Title)
    Write-Host ""
    Write-Host ("=" * 40) -ForegroundColor $BLUE
    Write-Host $Title -ForegroundColor $BLUE
    Write-Host ("=" * 40) -ForegroundColor $BLUE
}

function Write-Success {
    param([string]$Message)
    Write-Host "$CHECK $Message" -ForegroundColor $GREEN
}

function Write-Error {
    param([string]$Message)
    Write-Host "$CROSS $Message" -ForegroundColor $RED
}

function Write-Warning {
    param([string]$Message)
    Write-Host "$WARN $Message" -ForegroundColor $YELLOW
}

function Write-Info {
    param([string]$Message)
    Write-Host "$INFO $Message" -ForegroundColor $BLUE
}

function Test-Git {
    try {
        $version = git --version 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Success "Git found: $version"
            return $true
        }
    } catch {
        # Git not found
    }
    Write-Error "Git is not installed or not in PATH"
    Write-Info "Please install Git: https://git-scm.com/"
    return $false
}

function Test-GitRepo {
    try {
        $result = git rev-parse --git-dir 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Success "Inside a Git repository"
            return $true
        }
    } catch {
        # Not a git repo
    }
    Write-Error "Current directory is not a Git repository"
    Write-Info "Run this installer from the root of your Git repository"
    return $false
}

function Test-DotNet {
    try {
        $version = dotnet --version 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Success ".NET SDK found: $version"
            $major = [int]($version.Split('.')[0])
            if ($major -lt 8) {
                Write-Warning ".NET SDK version is $version, recommended 8.0+"
            }
            return $true
        }
    } catch {
        # dotnet not found
    }
    Write-Error ".NET SDK is not installed or not in PATH"
    Write-Info "Please install .NET SDK 8.0+: https://dotnet.microsoft.com/download"
    return $false
}

function Test-TestProjects {
    Write-Host ""
    Write-Host "Checking for test projects..."

    $testProjects = Get-ChildItem -Recurse -Filter "*.csproj" | Where-Object {
        $content = Get-Content $_.FullName -Raw -ErrorAction SilentlyContinue
        $content -match "xunit|NUnit|MSTest|TUnit|FluentAssertions|Moq"
    }

    if (-not $testProjects) {
        Write-Info "No test project found with common testing packages"
        Write-Info "Expected packages: xunit, NUnit, MSTest, TUnit, FluentAssertions, Moq"
    } else {
        Write-Success "Found test project(s):"
        foreach ($proj in $testProjects) {
            Write-Host "   $($proj.FullName)"
        }
    }
}

function Test-SkillStructure {
    param([string]$SkillDir)

    $requiredFiles = @(
        "SKILL.md",
        "README.md",
        "references\Context.md",
        "scripts\install.sh",
        "scripts\install.ps1",
        "scripts\install.py"
    )

    $allPresent = $true

    Write-Host ""
    Write-Host "Verifying skill structure..."

    foreach ($file in $requiredFiles) {
        $fullPath = Join-Path $SkillDir $file
        if (Test-Path $fullPath) {
            Write-Success $file
        } else {
            Write-Error "Missing: $file"
            $allPresent = $false
        }
    }

    return $allPresent
}

# Main
Write-Header "test-fixer-refact-async Installer (Windows PowerShell)"

$allChecksPass = $true

# Check Git
if (-not (Test-Git)) { $allChecksPass = $false }

# Check Git repository
if (-not (Test-GitRepo)) { $allChecksPass = $false }

# Check .NET SDK
if (-not (Test-DotNet)) { $allChecksPass = $false }

# Check for test projects
Test-TestProjects

# Verify skill structure
$scriptDir = Split-Path $MyInvocation.MyCommand.Path -Parent
$skillDir = Split-Path $scriptDir -Parent

if (-not (Test-SkillStructure $skillDir)) { $allChecksPass = $false }

# Summary
Write-Header "Installation Verification Complete"
if ($allChecksPass) {
    Write-Success "All checks passed!"
} else {
    Write-Warning "Some checks failed - see above"
    exit 1
}

Write-Host ""
Write-Host "Next steps:"
Write-Host "1. Ensure your test project references a test framework (xUnit, NUnit, MSTest, TUnit)"
Write-Host "2. Add FluentAssertions and Moq for better assertions and mocking"
Write-Host "3. Follow the async test fixing workflow in SKILL.md"
Write-Host "4. Run failing tests with: dotnet test --filter \"FullyQualifiedName~TestName\""
Write-Host ""