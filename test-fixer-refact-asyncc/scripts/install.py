#!/usr/bin/env python3
"""
test-fixer-refact-async Installer - Cross-platform
Verifies prerequisites for fixing failing async tests and refactoring
"""

import subprocess
import sys
import os
from pathlib import Path
from typing import List, Tuple


def run_command(cmd: List[str]) -> Tuple[int, str, str]:
    """Run a command and return (exit_code, stdout, stderr)."""
    try:
        result = subprocess.run(cmd, capture_output=True, text=True, timeout=30)
        return result.returncode, result.stdout.strip(), result.stderr.strip()
    except subprocess.TimeoutExpired:
        return -1, "", "Command timed out"
    except FileNotFoundError:
        return -1, "", "Command not found"
    except Exception as e:
        return -1, "", str(e)


def print_header(title: str):
    print(f"\n{'=' * 40}")
    print(title)
    print(f"{'=' * 40}")


# Use ASCII-safe markers to avoid encoding issues on Windows
CHECK = "[OK]"
CROSS = "[X]"
WARN = "[!]"
INFO = "[i]"


def print_success(msg: str):
    print(f"{CHECK} {msg}")


def print_error(msg: str):
    print(f"{CROSS} {msg}")


def print_warning(msg: str):
    print(f"{WARN} {msg}")


def print_info(msg: str):
    print(f"{INFO} {msg}")


def check_git() -> bool:
    """Check if Git is available."""
    code, stdout, stderr = run_command(["git", "--version"])
    if code == 0:
        print_success(f"Git found: {stdout}")
        return True
    else:
        print_error("Git is not installed or not in PATH")
        print_info("Please install Git: https://git-scm.com/")
        return False


def check_git_repo() -> bool:
    """Check if current directory is a Git repository."""
    code, stdout, stderr = run_command(["git", "rev-parse", "--git-dir"])
    if code == 0:
        print_success("Inside a Git repository")
        return True
    else:
        print_error("Current directory is not a Git repository")
        print_info("Run this installer from the root of your Git repository")
        return False


def check_dotnet() -> bool:
    """Check if .NET SDK is available and version >= 8.0."""
    code, stdout, stderr = run_command(["dotnet", "--version"])
    if code != 0:
        print_error(".NET SDK is not installed or not in PATH")
        print_info("Please install .NET SDK 8.0+: https://dotnet.microsoft.com/download")
        return False

    print_success(f".NET SDK found: {stdout}")

    # Check major version
    try:
        major = int(stdout.split('.')[0])
        if major < 8:
            print_warning(f".NET SDK version is {stdout}, recommended 8.0+")
    except (ValueError, IndexError):
        print_warning(f"Could not parse .NET version: {stdout}")

    return True


def check_test_projects() -> List[Path]:
    """Find test projects."""
    test_projects = []
    for csproj in Path(".").rglob("*.csproj"):
        try:
            content = csproj.read_text(encoding="utf-8")
            if any(pkg in content for pkg in ["xunit", "NUnit", "MSTest", "TUnit", "FluentAssertions", "Moq"]):
                test_projects.append(csproj)
        except Exception:
            pass
    return test_projects


def verify_skill_structure(skill_dir: Path) -> bool:
    """Verify all required skill files exist."""
    required_files = [
        "SKILL.md",
        "README.md",
        "references/Context.md",
        "scripts/install.sh",
        "scripts/install.ps1",
        "scripts/install.py",
    ]

    all_present = True
    print("\nVerifying skill structure...")
    for file in required_files:
        full_path = skill_dir / file
        if full_path.exists():
            print_success(file)
        else:
            print_error(f"Missing: {file}")
            all_present = False
    return all_present


def main():
    print_header("test-fixer-refact-async Installer (Cross-platform)")

    all_checks_pass = True

    # Check Git
    if not check_git():
        all_checks_pass = False

    # Check Git repository
    if not check_git_repo():
        all_checks_pass = False

    # Check .NET SDK
    if not check_dotnet():
        all_checks_pass = False

    # Check for test projects
    print("\nChecking for test projects...")
    test_projects = check_test_projects()
    if not test_projects:
        print_info("No test project found with common testing packages")
        print_info("Expected packages: xunit, NUnit, MSTest, TUnit, FluentAssertions, Moq")
    else:
        print_success("Found test project(s):")
        for proj in test_projects:
            print(f"   {proj}")

    # Verify skill structure
    skill_dir = Path(__file__).parent.parent
    if not verify_skill_structure(skill_dir):
        all_checks_pass = False

    # Summary
    print_header("Installation Verification Complete")
    if all_checks_pass:
        print_success("All checks passed!")
    else:
        print_warning("Some checks failed - see above")
        sys.exit(1)

    print("\nNext steps:")
    print("1. Ensure your test project references a test framework (xUnit, NUnit, MSTest, TUnit)")
    print("2. Add FluentAssertions and Moq for better assertions and mocking")
    print("3. Follow the async test fixing workflow in SKILL.md")
    print("4. Run failing tests with: dotnet test --filter \"FullyQualifiedName~TestName\"")
    print()


if __name__ == "__main__":
    main()