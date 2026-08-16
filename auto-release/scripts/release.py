#!/usr/bin/env python3
"""
auto-release: Release engine for Symphony Async

Analyzes Conventional Commits, determines semantic version,
updates CHANGELOG.md, and creates Git tags.
"""

import subprocess
import re
import sys
import os
from datetime import datetime
from typing import Optional, List, Dict, Tuple, Any
from dataclasses import dataclass
from enum import Enum


class ReleaseLevel(Enum):
    NONE = "none"
    PATCH = "patch"
    MINOR = "minor"
    MAJOR = "major"


class ReleaseStatus(Enum):
    NO_RELEASE = "NO_RELEASE"
    RELEASE_PROPOSED = "RELEASE_PROPOSED"
    RELEASE_CREATED = "RELEASE_CREATED"
    RELEASE_BLOCKED = "RELEASE_BLOCKED"
    RELEASE_FAILED = "RELEASE_FAILED"
    CHANGELOG_UPDATED = "CHANGELOG_UPDATED"
    TAG_CREATED = "TAG_CREATED"


@dataclass
class Commit:
    hash: str
    type: str
    scope: Optional[str]
    subject: str
    body: str
    breaking: bool
    raw: str


@dataclass
class ReleaseInfo:
    previous_version: str
    release_version: str
    release_level: ReleaseLevel
    tag: str
    changelog_updated: bool
    commits: List[Commit]


def run_git(args: List[str], cwd: Optional[str] = None) -> Tuple[int, str, str]:
    """Run a git command safely using subprocess."""
    cmd = ["git"] + args
    try:
        result = subprocess.run(
            cmd,
            cwd=cwd,
            capture_output=True,
            text=True,
            check=False
        )
        return result.returncode, result.stdout.strip(), result.stderr.strip()
    except Exception as e:
        return -1, "", str(e)


def get_repository_root() -> str:
    """Get the root directory of the Git repository."""
    code, stdout, stderr = run_git(["rev-parse", "--show-toplevel"])
    if code != 0:
        raise RuntimeError(f"Not a Git repository: {stderr}")
    return stdout


def get_latest_release_tag(repo_root: str) -> str:
    """Find the latest valid semantic version tag (vMAJOR.MINOR.PATCH)."""
    code, stdout, stderr = run_git(
        ["tag", "--list", "v[0-9]*.[0-9]*.[0-9]*", "--sort=-v:refname"],
        cwd=repo_root
    )
    if code != 0:
        raise RuntimeError(f"Failed to list tags: {stderr}")

    tags = stdout.splitlines()
    for tag in tags:
        if re.match(r'^v\d+\.\d+\.\d+$', tag):
            return tag
    return "v0.0.0"


def get_commits_since_tag(repo_root: str, tag: str) -> List[str]:
    """Get commits since the given tag."""
    if tag == "v0.0.0":
        code, stdout, stderr = run_git(["log", "--pretty=format:%H|%s|%b"], cwd=repo_root)
    else:
        code, stdout, stderr = run_git(
            ["log", f"{tag}..HEAD", "--pretty=format:%H|%s|%b"],
            cwd=repo_root
        )
    if code != 0:
        raise RuntimeError(f"Failed to get commits: {stderr}")
    return stdout.splitlines() if stdout else []


def parse_conventional_commit(raw_line: str) -> Optional[Commit]:
    """Parse a conventional commit line."""
    parts = raw_line.split("|", 2)
    if len(parts) < 2:
        return None

    commit_hash = parts[0]
    subject = parts[1]
    body = parts[2] if len(parts) > 2 else ""

    # Conventional commit regex: type(scope)!?: subject
    pattern = r'^(\w+)(?:\(([^)]+)\))?(!)?:\s*(.+)$'
    match = re.match(pattern, subject)

    if not match:
        return None

    commit_type = match.group(1)
    scope = match.group(2)
    breaking_marker = match.group(3)
    subject_text = match.group(4)

    # Check for BREAKING CHANGE in body
    breaking = breaking_marker == "!" or "BREAKING CHANGE:" in body.upper()

    return Commit(
        hash=commit_hash,
        type=commit_type,
        scope=scope,
        subject=subject_text,
        body=body,
        breaking=breaking,
        raw=raw_line
    )


def detect_breaking_change(commit: Commit) -> bool:
    """Check if a commit contains a breaking change."""
    return commit.breaking


def determine_release_level(commits: List[Commit]) -> ReleaseLevel:
    """Determine the release level from a list of commits."""
    has_major = False
    has_minor = False
    has_patch = False

    for commit in commits:
        if detect_breaking_change(commit):
            has_major = True
        elif commit.type == "feat":
            has_minor = True
        elif commit.type == "fix":
            has_patch = True

    if has_major:
        return ReleaseLevel.MAJOR
    elif has_minor:
        return ReleaseLevel.MINOR
    elif has_patch:
        return ReleaseLevel.PATCH
    return ReleaseLevel.NONE


def calculate_next_version(current_version: str, level: ReleaseLevel) -> str:
    """Calculate the next semantic version."""
    match = re.match(r'^v(\d+)\.(\d+)\.(\d+)$', current_version)
    if not match:
        raise ValueError(f"Invalid version format: {current_version}")

    major, minor, patch = map(int, match.groups())

    if level == ReleaseLevel.MAJOR:
        return f"v{major + 1}.0.0"
    elif level == ReleaseLevel.MINOR:
        return f"v{major}.{minor + 1}.0"
    elif level == ReleaseLevel.PATCH:
        return f"v{major}.{minor}.{patch + 1}"
    else:
        return current_version


def group_commits_for_changelog(commits: List[Commit]) -> Dict[str, List[Commit]]:
    """Group commits by changelog section."""
    groups = {
        "Breaking Changes": [],
        "Features": [],
        "Bug Fixes": [],
        "Performance": [],
        "Documentation": [],
        "Refactoring": [],
        "Tests": [],
        "Build": [],
        "CI": [],
        "Chores": []
    }

    type_mapping = {
        "feat": "Features",
        "fix": "Bug Fixes",
        "perf": "Performance",
        "docs": "Documentation",
        "refactor": "Refactoring",
        "test": "Tests",
        "build": "Build",
        "ci": "CI",
        "chore": "Chores"
    }

    for commit in commits:
        if detect_breaking_change(commit):
            groups["Breaking Changes"].append(commit)
        elif commit.type in type_mapping:
            groups[type_mapping[commit.type]].append(commit)

    # Remove empty groups
    return {k: v for k, v in groups.items() if v}


def generate_changelog_entry(version: str, commits: List[Commit]) -> str:
    """Generate a changelog entry for a version."""
    date_str = datetime.now().strftime("%Y-%m-%d")
    groups = group_commits_for_changelog(commits)

    lines = [f"## {version} ({date_str})", ""]

    for section, section_commits in groups.items():
        lines.append(f"### {section}")
        lines.append("")
        for commit in section_commits:
            scope_str = f"({commit.scope})" if commit.scope else ""
            lines.append(f"- {commit.type}{scope_str}: {commit.subject}")
        lines.append("")

    return "\n".join(lines).rstrip() + "\n"


def update_changelog(repo_root: str, version: str, commits: List[Commit]) -> bool:
    """Update CHANGELOG.md with the new release entry."""
    changelog_path = os.path.join(repo_root, "CHANGELOG.md")
    new_entry = generate_changelog_entry(version, commits)

    if os.path.exists(changelog_path):
        with open(changelog_path, "r", encoding="utf-8") as f:
            content = f.read()

        # Check if file starts with "# Changelog"
        if not content.startswith("# Changelog"):
            content = "# Changelog\n\n" + content

        # Insert after the first heading
        lines = content.splitlines()
        insert_idx = 1
        while insert_idx < len(lines) and lines[insert_idx].strip() == "":
            insert_idx += 1

        new_lines = lines[:insert_idx] + [""] + new_entry.splitlines() + lines[insert_idx:]
        new_content = "\n".join(new_lines)
    else:
        new_content = f"# Changelog\n\n{new_entry}"

    with open(changelog_path, "w", encoding="utf-8") as f:
        f.write(new_content)

    return True


def check_working_tree_clean(repo_root: str) -> Tuple[bool, str]:
    """Check if working tree has uncommitted changes to CHANGELOG.md."""
    code, stdout, stderr = run_git(["status", "--short"], cwd=repo_root)
    if code != 0:
        return False, f"Git status failed: {stderr}"

    for line in stdout.splitlines():
        if "CHANGELOG.md" in line and not line.startswith("??"):
            return False, f"CHANGELOG.md has uncommitted changes: {line}"

    return True, ""


def tag_exists(repo_root: str, tag: str) -> bool:
    """Check if a tag already exists."""
    code, _, _ = run_git(["rev-parse", tag], cwd=repo_root)
    return code == 0


def create_release_tag(repo_root: str, tag: str, version: str) -> bool:
    """Create an annotated Git tag."""
    if tag_exists(repo_root, tag):
        return False

    code, _, stderr = run_git(["tag", "-a", tag, "-m", f"Release {version}"], cwd=repo_root)
    return code == 0


def print_release_result(status: ReleaseStatus, info: Optional[ReleaseInfo] = None) -> None:
    """Print machine-readable release result."""
    print(status.value)
    if info:
        print(f"previous_version: {info.previous_version}")
        print(f"release_version: {info.release_version}")
        print(f"release_level: {info.release_level.value}")
        print(f"tag: {info.tag}")
        print(f"changelog_updated: {str(info.changelog_updated).lower()}")


def main() -> int:
    try:
        repo_root = get_repository_root()
    except RuntimeError as e:
        print(f"RELEASE_FAILED")
        print(f"error: {e}")
        return 1

    # Check working tree safety
    clean, msg = check_working_tree_clean(repo_root)
    if not clean:
        print(ReleaseStatus.RELEASE_BLOCKED.value)
        print(f"error: {msg}")
        return 1

    # Get latest release tag
    try:
        latest_tag = get_latest_release_tag(repo_root)
    except RuntimeError as e:
        print(ReleaseStatus.RELEASE_FAILED.value)
        print(f"error: {e}")
        return 1

    # Get commits since last release
    try:
        raw_commits = get_commits_since_tag(repo_root, latest_tag)
    except RuntimeError as e:
        print(ReleaseStatus.RELEASE_FAILED.value)
        print(f"error: {e}")
        return 1

    # Parse commits
    commits = []
    for raw in raw_commits:
        parsed = parse_conventional_commit(raw)
        if parsed:
            commits.append(parsed)

    if not commits:
        print(ReleaseStatus.NO_RELEASE.value)
        return 0

    # Determine release level
    level = determine_release_level(commits)
    if level == ReleaseLevel.NONE:
        print(ReleaseStatus.NO_RELEASE.value)
        return 0

    # Calculate next version
    next_version = calculate_next_version(latest_tag, level)
    tag = next_version

    # Check if tag already exists
    if tag_exists(repo_root, tag):
        print(ReleaseStatus.RELEASE_FAILED.value)
        print(f"error: Tag {tag} already exists")
        return 1

    # Update changelog
    try:
        update_changelog(repo_root, next_version, commits)
        changelog_updated = True
    except Exception as e:
        print(ReleaseStatus.RELEASE_FAILED.value)
        print(f"error: Failed to update changelog: {e}")
        return 1

    # Create tag
    if not create_release_tag(repo_root, tag, next_version):
        print(ReleaseStatus.RELEASE_FAILED.value)
        print(f"error: Failed to create tag {tag}")
        return 1

    # Return success
    info = ReleaseInfo(
        previous_version=latest_tag,
        release_version=next_version,
        release_level=level,
        tag=tag,
        changelog_updated=changelog_updated,
        commits=commits
    )
    print_release_result(ReleaseStatus.RELEASE_CREATED, info)
    return 0


if __name__ == "__main__":
    sys.exit(main())