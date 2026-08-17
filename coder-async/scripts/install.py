#!/usr/bin/env python3
"""
install.py — Install coder-async skill

Uses only Python standard library.
"""

import os
import sys
import shutil
import subprocess
from pathlib import Path


def run_cmd(cmd, cwd=None):
    """Run command and return (success, output)"""
    try:
        result = subprocess.run(
            cmd, shell=True, capture_output=True, text=True, cwd=cwd
        )
        return result.returncode == 0, result.stdout.strip()
    except Exception as e:
        return False, str(e)


def main():
    target_dir = sys.argv[1] if len(sys.argv) > 1 else "."
    target_path = Path(target_dir).resolve()

    print("Installing coder-async skill...")

    # Verify Git
    success, _ = run_cmd("git --version")
    if not success:
        print("Error: Git is not installed", file=sys.stderr)
        sys.exit(1)

    # Verify we're in a git repository
    success, _ = run_cmd("git rev-parse --git-dir", cwd=target_path)
    if not success:
        print("Error: Not in a Git repository", file=sys.stderr)
        sys.exit(1)

    # Get source directory (where this script lives)
    script_dir = Path(__file__).parent.parent.resolve()

    # Target skill directory
    skill_dir = target_path / ".claude" / "skills" / "coder-async"

    # Create target directory
    skill_dir.mkdir(parents=True, exist_ok=True)

    # Copy skill files
    print("Copying skill files...")
    for item in script_dir.iterdir():
        if item.name == ".git":
            continue
        dest = skill_dir / item.name
        if item.is_dir():
            shutil.copytree(item, dest, dirs_exist_ok=True)
        else:
            shutil.copy2(item, dest)

    # Verify installation
    if (skill_dir / "SKILL.md").exists() and (skill_dir / "README.md").exists():
        print(f"✓ coder-async skill installed successfully at {skill_dir}")
    else:
        print("Error: Installation verification failed", file=sys.stderr)
        sys.exit(1)

    print("Installation complete.")


if __name__ == "__main__":
    main()