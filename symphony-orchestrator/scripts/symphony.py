#!/usr/bin/env python3
"""Safe command-line entry point for the Symphony orchestration workflow."""

from __future__ import annotations

import subprocess
import sys
from pathlib import Path


def run_git(arguments: list[str], repository: Path) -> tuple[int, str, str]:
    """Run a Git command without invoking a shell."""
    result = subprocess.run(
        ["git", *arguments],
        cwd=repository,
        capture_output=True,
        text=True,
        check=False,
    )
    return result.returncode, result.stdout.strip(), result.stderr.strip()


def repository_root() -> Path:
    """Return the current Git repository root."""
    result = subprocess.run(
        ["git", "rev-parse", "--show-toplevel"],
        capture_output=True,
        text=True,
        check=False,
    )
    if result.returncode != 0:
        raise RuntimeError(result.stderr.strip() or "Current directory is not a Git repository")
    return Path(result.stdout.strip())


def main() -> int:
    try:
        repository = repository_root()
    except RuntimeError as error:
        print("SYMPHONY_FAILED")
        print(f"error: {error}")
        return 1

    status, changes, error = run_git(["status", "--short"], repository)
    if status != 0:
        print("SYMPHONY_FAILED")
        print(f"error: {error or 'Unable to inspect repository changes'}")
        return 1

    if not changes:
        print("SYMPHONY_NO_CHANGES")
        return 0

    print("SYMPHONY_STARTED")
    print("next_action: delegate to tests-async through the Claude Code skill runtime")
    return 0


if __name__ == "__main__":
    sys.exit(main())