#!/usr/bin/env python3
"""
tests-async Installer - Cross-platform
Verifies prerequisites for test orchestration with TUnit
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


def check_tunit_projects() -> List[Path]:
    """Find TUnit test projects."""
    test_projects = []
    for csproj in Path(".").rglob("*.csproj"):
        try:
            content = csproj.read_text(encoding="utf-8")
            if "TUnit" in content:
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


def verify_delegated_skills(skill_dir: Path) -> bool:
    """Verify delegated skills exist at root level."""
    delegated_skills = ["tdd-async", "bdd-async", "test-fixer-async"]
    all_present = True
    print("\nVerifying delegated skills...")
    for skill in delegated_skills:
        skill_path = skill_dir.parent / skill
        if skill_path.exists() and skill_path.is_dir():
            print_success(skill)
        else:
            print_warning(f"Missing delegated skill: {skill}")
            all_present = False
    return all_present


def main():
    print_header("tests-async Installer (Cross-platform)")

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

    # Check for TUnit test projects
    print("\nChecking for test projects...")
    tunit_projects = check_tunit_projects()
    if not tunit_projects:
        print_info("No TUnit test project found")
        print_info("You can add TUnit to a test project with:")
        print_info("  dotnet add <test-project>.csproj package TUnit")
    else:
        print_success("Found TUnit test project(s):")
        for proj in tunit_projects:
            print(f"   {proj}")

    # Verify skill structure
    skill_dir = Path(__file__).parent.parent
    if not verify_skill_structure(skill_dir):
        all_checks_pass = False

    # Verify delegated skills
    if not verify_delegated_skills(skill_dir):
        all_checks_pass = False

    # Summary
    print_header("Installation Verification Complete")
    if all_checks_pass:
        print_success("All checks passed!")
    else:
        print_warning("Some checks failed - see above")
        sys.exit(1)

    print("\nNext steps:")
    print("1. Ensure your test project references TUnit")
    print("2. Follow the orchestration workflow in SKILL.md")
    print("3. Run tests with: dotnet test")
    print()


if __name__ == "__main__":
    main()