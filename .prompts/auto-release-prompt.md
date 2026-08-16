You are working in the `symphony-async` repository.

Create a new Claude Code skill named **`auto-release`**.

The skill must integrate cleanly into the `symphony-async` orchestration pipeline and follow the same architecture and conventions as the other skills in the repository.

# Objective

`auto-release` is responsible for analyzing the commits since the last release, determining whether a release is required, calculating the next semantic version, generating or updating the changelog, and creating the Git tag.

It must **not use npm, Node.js, semantic-release, or any external release framework**.

The implementation must use Python and Git only.

The skill is designed to be called by `symphony-async`.

It must not independently start the entire Symphony workflow.

---

# Required Structure

Create:

```text
auto-release/
├── references/
│   └── Context.md
├── scripts/
│   ├── install.sh
│   ├── install.ps1
│   └── release.py
├── SKILL.md
└── README.md
```

Before creating anything:

1. Inspect the existing repository.
2. Inspect `commit-async`.
3. Inspect `tests-async`.
4. Inspect `readme-async`.
5. Inspect the root `SKILL.md` and `README.md`.
6. Follow the repository's existing conventions.
7. Do not modify unrelated skills.

---

# SKILL.md

Create a complete Claude Code skill with:

```yaml
---
name: auto-release
description: Analyzes Conventional Commits since the last release, determines the next semantic version, updates the changelog, and creates a Git release tag as part of the Symphony Async workflow.
---
```

## Role

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

# Conventional Commits

Use Conventional Commits to determine the release level.

## PATCH

A `fix` commit triggers a patch release:

```text
fix: correct authentication error
```

Example:

```text
v1.2.3 → v1.2.4
```

## MINOR

A `feat` commit triggers a minor release:

```text
feat: add OAuth authentication
```

Example:

```text
v1.2.3 → v1.3.0
```

## MAJOR

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

# Release Priority

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

# Release Detection

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

# Commit Analysis

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

# Changelog

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

# Version Calculation

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

# Tag Creation

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

# Git Push

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

# Working Tree Safety

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

# Commit Responsibility

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

# Symphony Contract

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

# Symphony Flow

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

# Cascade Safety

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

# scripts/install.sh

Create an idempotent Bash installer.

It must:

1. verify Git;
2. verify the current directory is a Git repository;
3. verify Python 3 is available;
4. display the repository root;
5. verify the release script;
6. not install npm;
7. not install Node.js;
8. not install external Python packages;
9. not create Git hooks;
10. not create commits;
11. not create tags;
12. not push anything.

Use only system tools and Python standard library.

---

# scripts/install.ps1

Create the PowerShell equivalent.

It must perform the same checks and follow the same constraints.

It must work on Windows without requiring Node.js or npm.

---

# scripts/release.py

Implement the actual release engine.

Requirements:

* Python 3;
* standard library only;
* Git CLI;
* no npm;
* no Node.js;
* no external Python dependencies.

Implement functions for:

```text
get_repository_root()
get_latest_release_tag()
get_commits_since_tag()
parse_conventional_commit()
detect_breaking_change()
determine_release_level()
calculate_next_version()
generate_changelog()
update_changelog()
create_release_tag()
```

Keep the code modular and testable.

Use subprocess safely.

Never construct shell commands through unsafe string concatenation when arguments can be passed directly to `subprocess`.

Handle Git errors gracefully.

Return meaningful exit codes.

---

# README.md

Create concise documentation covering:

## What is auto-release?

Explain that it is the release engine used by `symphony-async`.

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

Clearly state that the skill:

* does not use npm;
* does not use Node.js;
* does not use semantic-release;
* uses Python + Git.

## Symphony Integration

Explain that:

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

and that `symphony-async` remains the orchestrator.

---

# Important Constraints

Do not introduce:

```text
npm
node
package.json
semantic-release
```

Do not create Git hooks.

Do not automatically push.

Do not force-push.

Do not overwrite tags.

Do not delete tags.

Do not reset or clean the user's working tree.

Do not bypass `commit-async`.

Do not trigger another skill directly.

Do not create unnecessary files.

The implementation must remain modular, deterministic, safe, and compatible with the existing `symphony-async` architecture.

At the end, verify that exactly these files exist:

```text
auto-release/
├── references/Context.md
├── scripts/install.sh
├── scripts/install.ps1
├── scripts/release.py
├── SKILL.md
└── README.md
```

Then provide a concise summary of what was created and any integration considerations for `symphony-async`.
