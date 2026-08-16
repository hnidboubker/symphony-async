# auto-release

## What is auto-release?

`auto-release` is the release engine used by `symphony-async`. It automates the release process by analyzing Conventional Commits, determining the next semantic version, updating the changelog, and creating Git tags.

## What it does

```text
Conventional Commits
        ↓
Release analysis
        ↓
Semantic version
        ↓
CHANGELOG
        ↓
Git tag
```

## Examples

```text
fix: fix login
→ PATCH
→ v1.0.1
```

```text
feat: add OAuth
→ MINOR
→ v1.1.0
```

```text
feat!: replace authentication API
→ MAJOR
→ v2.0.0
```

## No npm

This skill:
- does not use npm
- does not use Node.js
- does not use semantic-release
- uses Python + Git only (standard library)

## Symphony Integration

```text
commit-async
    ↓
tests-async
    ↓
push
    ↓
auto-release
    ↓
readme-async
```

`symphony-async` remains the orchestrator. `auto-release` is called after successful tests and push.

## Installation

**Linux/macOS:**
```bash
./auto-release/scripts/install.sh
```

**Windows:**
```powershell
./auto-release/scripts/install.ps1
```

## Usage

Called by `symphony-async`:
```bash
python auto-release/scripts/release.py
```

Returns machine-readable status:
- `NO_RELEASE` - No commits requiring release
- `RELEASE_CREATED` - Release tag and changelog created
- `RELEASE_BLOCKED` - Working tree has conflicts
- `RELEASE_FAILED` - Tag already exists or other error
- `CHANGELOG_UPDATED` - Changelog modified, needs commit

On success, also outputs:
```
previous_version: v1.3.2
release_version: v1.4.0
release_level: minor
tag: v1.4.0
changelog_updated: true
```

## Conventional Commits

| Commit Type | Release Level |
|-------------|---------------|
| `fix:` | PATCH |
| `feat:` | MINOR |
| `feat!:`, `BREAKING CHANGE:` | MAJOR |

Priority: MAJOR > MINOR > PATCH

## Changelog Format

```markdown
# Changelog

## v1.4.0 (2026-08-16)

### Features

- add OAuth authentication
- add user session management

### Bug Fixes

- fix login redirect

### Breaking Changes

- replace the authentication API
```

Preserves previous releases. Only includes relevant sections.

## Safety

- Never overwrites existing tags
- Never pushes tags automatically (orchestrator decides)
- Checks working tree before modifying CHANGELOG.md
- Does not bypass `commit-async` for commits
- Does not trigger other skills directly