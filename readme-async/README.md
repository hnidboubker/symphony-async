[![Release](https://github.com/hnidboubker/readme-async/actions/workflows/build-release.yml/badge.svg)](https://github.com/hnidboubker/readme-async/actions/workflows/build-release.yml)
[![npm Publish](https://github.com/hnidboubker/readme-async/actions/workflows/build-npm-publish.yml/badge.svg)](https://github.com/hnidboubker/readme-async/actions/workflows/build-npm-publish.yml)

# readme-async

Keep your project's README.md synchronized with the actual codebase by detecting relevant changes, updating outdated documentation, and verifying that commands, configuration, examples, and project structure remain accurate.

## Installation

### Via npm/npx (not available yet)

> **Note:** The `npm/npx` method is not available yet. Until the package is published, use the script method below.

```bash
# Install globally, then run anywhere
npm install -g readme-async
readme-async [target-project-path]

# Or run directly without installing
npx readme-async [target-project-path]
```

### Via script (from cloned repo)

```bash
# From the skill source directory
./scripts/install.sh [target-project-path]

# Or on Windows PowerShell
.\scripts\install.ps1 [target-project-path]
```

All methods copy the skill to `<target-project>/.claude/skills/readme-async/`.

## Purpose

Ensures `README.md` describes **what the project currently does**, not what it used to do. The codebase and project configuration are the source of truth.

## When to Run

Run after changes that may affect documentation:
- New or removed features
- Changed behavior
- Installation/setup changes
- Dependency or configuration changes
- CLI commands, scripts, or API endpoints
- Project structure or development workflows

## Core Workflow

1. **Inspect the project** — Check package.json, pyproject.toml, Cargo.toml, Dockerfile, Makefile, src/, docs/, etc.
2. **Inspect recent changes** — `git status`, `git diff`, `git log -n 10`
3. **Read existing README** — Identify outdated, missing, or incorrect information
4. **Update only what's necessary** — Preserve existing structure, tone, badges, links unless outdated
5. **Validate** — Verify documented commands exist, paths are valid, examples match implementation

## Documentation Rules

- **Installation**: Match actual package manager, runtime, dependencies, commands
- **Configuration**: Sync env vars, config files, defaults; use placeholders for secrets
- **Commands**: Match actual scripts in package.json/Makefile/etc.
- **Features**: Document added/removed/renamed/changed features accurately
- **API**: Verify endpoints, methods, parameters, auth match implementation
- **Examples**: Update or remove outdated examples; never invent behavior

## Principles

- **Minimal changes** — Smallest edit that restores consistency
- **No invention** — Never document features that don't exist
- **Git awareness** — Use history to understand why behavior changed