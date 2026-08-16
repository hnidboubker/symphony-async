---
name: auto-release
description: Analyzes Conventional Commits since the last release, determines the next semantic version, updates the changelog, and creates a Git release tag as part of the Symphony Async workflow.
---

# auto-release

`auto-release` is a specialized release skill.

Its responsibility is:

```text
Git history
    ↓
Find latest release
    ↓
Analyze commits
    ↓
Determine release level
    ↓
Calculate version
    ↓
Generate/update CHANGELOG.md
    ↓
Create Git tag
    ↓
Return release result to symphony-async
```

It must not directly invoke:

* `commit-async`;
* `tests-async`;
* `readme-async`;
* `symphony-async`.

The orchestrator decides what happens next.

---

## Conventional Commits

Use Conventional Commits to determine the release level.

### PATCH

A `fix` commit triggers a patch release:

```text
fix: correct authentication error
```

Example:

```text
v1.2.3 → v1.2.4
```

### MINOR

A `feat` commit triggers a minor release:

```text
feat: add OAuth authentication
```

Example:

```text
v1.2.3 → v1.3.0
```

### MAJOR

A breaking change triggers a major release.

Examples:

```text
feat!: redesign authentication API
```

or:

```text
feat(api): redesign authentication API

BREAKING CHANGE: the previous authentication endpoint has been removed.
```

Example:

```text
v1.2.3 → v2.0.0
```

---

## Release Priority

When multiple commit types exist, use the highest required level:

```text
MAJOR > MINOR > PATCH
```

Example:

```text
fix: correct login
feat: add OAuth
```

Result:

```text
MINOR
```

If:

```text
fix: correct login
feat: add OAuth
feat!: replace authentication API
```

Result:

```text
MAJOR
```

---

## Release Detection

Find the latest valid semantic version tag.

Supported format:

```text
vMAJOR.MINOR.PATCH
```

Examples:

```text
v1.0.0
v1.2.3
v10.4.21
```

Ignore unrelated tags.

If no valid release tag exists:

```text
v0.0.0
```

must be used as the baseline.

The first release should therefore become:

```text
v0.0.1
```

for a patch change or:

```text
v0.1.0
```

for a feature.

A breaking change from `v0.0.0` should produce:

```text
v1.0.0
```

---

## Commit Analysis

Use Git to retrieve commits since the latest release.

For example:

```bash
git log <last-tag>..HEAD
```

Use structured output when possible.

Analyze:

* commit type;
* scope;
* subject;
* body;
* breaking changes;
* commit hash.

Do not invent release information.

If there are no commits since the latest release:

```text
NO_RELEASE
```

must be returned.

---

## Changelog

Generate or update:

```text
CHANGELOG.md
```

Use a readable Markdown structure.

Example:

```markdown
# Changelog

## v1.4.0

### Features

- add OAuth authentication
- add user session management

### Bug Fixes

- fix login redirect

### Breaking Changes

- replace the authentication API
```

Use the release version and current date.

Group commits into:

```text
Features
Bug Fixes
Performance
Documentation
Refactoring
Tests
Build
CI
Chores
Breaking Changes
```

Only include relevant sections.

The changelog must preserve previous releases.

Never overwrite existing historical release information.

---

## Version Calculation

Implement semantic version calculation in Python.

Given:

```text
v1.4.2
```

PATCH:

```text
v1.4.3
```

MINOR:

```text
v1.5.0
```

MAJOR:

```text
v2.0.0
```

Do not use an external semantic-version package.

Use Python's standard library only.

---

## Tag Creation

After the release information has been determined and the changelog has been updated, create an annotated Git tag:

```bash
git tag -a vX.Y.Z -m "Release vX.Y.Z"
```

Do not overwrite an existing tag.

Before creating the tag, verify:

```bash
git rev-parse "vX.Y.Z"
```

If the tag already exists:

```text
RELEASE_FAILED
```

must be returned.

Never delete or replace an existing tag automatically.

---

## Git Push

`auto-release` must **not automatically push** the tag unless Symphony explicitly requests it.

The default behavior is:

```text
release created locally
    ↓
return result
    ↓
symphony-async decides whether/when to push
```

Never execute:

```bash
git push --force
```

Never push tags silently.

If Symphony explicitly provides permission to push the release tag, use:

```bash
git push origin vX.Y.Z
```

Otherwise, leave the tag local.

---

## Working Tree Safety

Before modifying `CHANGELOG.md`, inspect:

```bash
git status --short
```

Do not silently overwrite unrelated user changes.

If `CHANGELOG.md` already contains uncommitted modifications unrelated to the release:

```text
RELEASE_BLOCKED
```

must be returned.

Explain that the working tree must be resolved before continuing.

Never use:

```bash
git reset --hard
git checkout -- .
git clean -fd
```

to resolve conflicts.

---

## Commit Responsibility

`auto-release` must not silently create a commit unless Symphony explicitly requests that behavior.

The preferred Symphony workflow is:

```text
commit-async
      ↓
tests-async
      ↓
git push
      ↓
auto-release
      ↓
CHANGELOG + tag
      ↓
readme-async
```

If the changelog must be committed, return:

```text
CHANGELOG_UPDATED
```

to `symphony-async`.

The orchestrator can then use `commit-async` to create the documentation commit according to the normal validation rules.

Do not bypass `commit-async`'s approval mechanism.

---

## Symphony Contract

`auto-release` must return a clear machine-readable result to the orchestrator.

Possible states:

```text
NO_RELEASE
RELEASE_PROPOSED
RELEASE_CREATED
RELEASE_BLOCKED
RELEASE_FAILED
CHANGELOG_UPDATED
TAG_CREATED
```

A successful release should expose:

```text
release_version
release_level
previous_version
tag
changelog_updated
```

Example:

```text
RELEASE_CREATED

previous_version: v1.3.2
release_version: v1.4.0
release_level: minor
tag: v1.4.0
changelog_updated: true
```

---

## Symphony Flow

The expected integration is:

```text
                    symphony-async
                          │
                          ▼
                    commit-async
                          │
                          ▼
                     tests-async
                          │
                     ┌────┴────┐
                     │         │
                   FAIL       PASS
                     │         │
                    STOP       ▼
                              PUSH
                                │
                                ▼
                         auto-release
                                │
                         ┌──────┴──────┐
                         │             │
                    NO_RELEASE     RELEASE
                         │             │
                         ▼             ▼
                       FINISH      CHANGELOG
                                      +
                                     TAG
                                      │
                                      ▼
                                readme-async
```

If `tests-async` fails:

```text
STOP
```

No release must occur.

If no Conventional Commit requires a release:

```text
NO_RELEASE
```

and Symphony continues to `readme-async` if appropriate.

---

## Cascade Safety

`auto-release` must never restart the Symphony pipeline.

It must not call itself.

It must not trigger:

```text
commit-async
tests-async
readme-async
symphony-async
```

The orchestrator controls the cascade.

This prevents:

```text
release
 ↓
README
 ↓
commit
 ↓
release
 ↓
README
 ↓
...
```

---

## Installation

Run the installer for your platform:

**Linux/macOS:**
```bash
./auto-release/scripts/install.sh
```

**Windows:**
```powershell
./auto-release/scripts/install.ps1
```

The installer verifies:
- Git is available
- Current directory is a Git repository
- Python 3 is available
- The release script exists

It does NOT:
- Install npm or Node.js
- Install external Python packages
- Create Git hooks
- Create commits or tags
- Push anything

---

## Usage

Called by `symphony-async` after successful tests and push:

```bash
python auto-release/scripts/release.py
```

Returns machine-readable status and release details on stdout.