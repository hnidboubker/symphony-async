#!/usr/bin/env python3
"""
Symphony Async installer (Python standard library only)
Verifies the environment and Symphony structure
"""

import os
import sys
import subprocess
import shutil
from pathlib import Path


def success(msg: str) -> None:
    print(f"\033[0;32m✓\033[0m {msg}")


def error(msg: str) -> None:
    print(f"\033[0;31m✗\033[0m {msg}")


def warn(msg: str) -> None:
    print(f"\033[1;33m⚠\033[0m {msg}")


def run_command(cmd: list[str]) -> tuple[int, str]:
    """Run a command and return (exit_code, output)."""
    try:
        result = subprocess.run(cmd, capture_output=True, text=True, timeout=10)
        return result.returncode, result.stdout.strip()
    except (subprocess.TimeoutExpired, FileNotFoundError, OSError):
        return -1, ""


def check_git() -> bool:
    """Verify Git is available."""
    print("Checking Git...")
    code, output = run_command(["git", "--version"])
    if code == 0:
        success(f"Git found: {output}")
        return True
    else:
        error("Git not found in PATH")
        return False


def check_python3() -> bool:
    """Verify Python 3 is available."""
    print("Checking Python 3...")
    code, output = run_command(["python3", "--version"])
    if code == 0 and output.startswith("Python 3"):
        success(f"Python 3 found: {output}")
        return True

    code, output = run_command(["python", "--version"])
    if code == 0 and output.startswith("Python 3"):
        success(f"Python 3 found: {output}")
        return True

    error("Python 3 not found in PATH")
    return False


def check_git_repo() -> tuple[bool, str]:
    """Verify current directory is a Git repository."""
    print("Checking Git repository...")
    code, output = run_command(["git", "rev-parse", "--show-toplevel"])
    if code == 0:
        success("Current directory is a Git repository")
        success(f"Repository root: {output}")
        return True, output
    else:
        error("Current directory is not a Git repository")
        return False, ""


def check_symphony_structure(repo_root: str) -> bool:
    """Verify Symphony directory structure exists."""
    print("Checking Symphony structure...")
    symphony_dir = Path(repo_root) / "symphony-async"
    all_ok = True

    if symphony_dir.is_dir():
        success("symphony-async directory exists")
    else:
        error(f"symphony-async directory not found at {symphony_dir}")
        return False

    # Check required subdirectories
    for subdir in ("scripts", "references"):
        path = symphony_dir / subdir
        if path.is_dir():
            success(f"  {subdir}/ exists")
        else:
            error(f"  {subdir}/ missing")
            all_ok = False

    # Check required files
    for file in ("SKILL.md", "README.md", "references/Context.md"):
        path = symphony_dir / file
        if path.is_file():
            success(f"  {file} exists")
        else:
            error(f"  {file} missing")
            all_ok = False

    # Check install scripts
    for script in ("install.sh", "install.ps1", "install.py"):
        path = symphony_dir / "scripts" / script
        if path.is_file():
            success(f"  scripts/{script} exists")
        else:
            error(f"  scripts/{script} missing")
            all_ok = False

    return all_ok


def check_expected_skills(repo_root: str) -> bool:
    """Verify expected skills exist."""
    print("Checking expected skills...")
    skills_dir = Path(repo_root)
    all_ok = True

    expected_skills = ("commit-async", "tests-async", "auto-release", "readme-async")
    expected_sub_skills = ("tests-async/tdd-async", "tests-async/bdd-async")

    for skill in expected_skills:
        skill_path = skills_dir / skill
        skill_file = skill_path / "SKILL.md"
        if skill_path.is_dir() and skill_file.is_file():
            success(f"  {skill} exists")
        else:
            error(f"  {skill} missing or incomplete")
            all_ok = False

    for skill in expected_sub_skills:
        skill_path = skills_dir / skill
        skill_file = skill_path / "SKILL.md"
        if skill_path.is_dir() and skill_file.is_file():
            success(f"  {skill} exists")
        else:
            error(f"  {skill} missing or incomplete")
            all_ok = False

    return all_ok


def main() -> int:
    print("=== Symphony Async Installer ===")
    print("")

    all_ok = True

    # 1. Verify Git
    all_ok &= check_git()

    # 2. Verify Python 3
    all_ok &= check_python3()

    # 3. Verify Git repository
    ok, repo_root = check_git_repo()
    all_ok &= ok

    if not repo_root:
        print("")
        print("=== Installation Summary ===")
        error("Cannot continue without a valid Git repository")
        return 1

    # 4. Verify Symphony structure
    all_ok &= check_symphony_structure(repo_root)

    # 5. Verify expected skills
    all_ok &= check_expected_skills(repo_root)

    # Summary
    print("")
    print("=== Installation Summary ===")
    if all_ok:
        success("All verifications passed. Symphony Async is ready.")
        return 0
    else:
        error("Some verifications failed. Please resolve the issues above.")
        return 1


if __name__ == "__main__":
    sys.exit(main())