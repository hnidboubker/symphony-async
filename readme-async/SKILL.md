---
name: readme-async
description: Keep the project README synchronized with the current codebase by detecting relevant changes, updating outdated documentation, and verifying that commands, configuration, examples, and project structure remain accurate.
---

## Installation

### Via npm/npx (recommended)

```bash
# Install globally, then run anywhere
npm install -g @skills-collection/readme-async
readme-async [target-project-path]

# Or run directly without installing
npx @skills-collection/readme-async [target-project-path]
```

### Via script (from cloned repo)

```bash
# From the skill source directory
./scripts/install.sh [target-project-path]

# Or on Windows PowerShell
.\scripts\install.ps1 [target-project-path]
```

All methods copy the skill to `<target-project>/.claude/skills/readme-async/`.

# README Sync

## Purpose

Keep `README.md` synchronized with the actual state of the project.

The README must describe **what the project currently does**, not what it used to do.

The codebase and project configuration are the source of truth.

## When to run

Run this skill after changes that may affect the project's public or developer-facing documentation, including:

* New or removed features
* Changed behavior
* Installation or setup changes
* Dependency changes
* Configuration changes
* Environment variables
* CLI commands or scripts
* API endpoints or parameters
* Project structure or architecture
* Development workflows
* Build or deployment processes
* New prerequisites
* Important limitations

It can also be run explicitly by the user at any time.

## Core workflow

### 1. Inspect the current project

First inspect the repository and identify the relevant sources of truth.

Check files that exist, such as:

```text
README.md
package.json
pnpm-lock.yaml
yarn.lock
package-lock.json
pyproject.toml
requirements.txt
Cargo.toml
go.mod
composer.json
Dockerfile
docker-compose.yml
.env.example
Makefile
src/
app/
scripts/
docs/
```

Do not assume that any of these files exist.

### 2. Inspect recent changes

When Git is available, inspect the current state and recent changes:

```bash
git status
git diff
git diff --stat
git log -n 10 --oneline
```

Pay particular attention to changes that affect user-facing behavior or developer workflows.

Uncommitted changes are part of the current project context and must be considered.

### 3. Read the existing README

Read the complete `README.md` before editing it.

Identify:

* Outdated information
* Missing information
* Incorrect commands
* Incorrect paths
* Removed features
* Missing features
* Outdated configuration
* Broken examples
* Incorrect project structure
* Documentation that no longer matches the code

### 4. Update only what is necessary

Modify the README to reflect the current project.

Do **not** rewrite the entire README when a targeted change is sufficient.

Preserve the existing:

* Structure
* Tone
* Badges
* Links
* Images
* Markdown conventions
* Section organization

unless they are themselves outdated.

## Documentation rules

### Installation

Verify that installation instructions match the actual project.

Check:

* Package manager
* Required runtime
* Dependencies
* Required versions
* Installation commands
* Setup steps

Never document commands that do not exist.

### Configuration

Synchronize documented configuration with the actual project.

Check:

* Environment variables
* Configuration files
* Required settings
* Optional settings
* Default values

Never expose real secrets, tokens, passwords, API keys, or credentials.

Use placeholders when necessary:

```env
API_KEY=your_api_key
DATABASE_URL=your_database_url
```

### Commands

Compare documented commands with the project's actual scripts and tooling.

For example, if `package.json` contains:

```json
{
  "scripts": {
    "dev": "...",
    "build": "...",
    "test": "..."
  }
}
```

the README should document those commands accurately.

Remove commands that no longer exist.

### Features

Keep feature documentation synchronized with the implementation.

When a feature is:

* Added → document it when relevant
* Removed → remove obsolete documentation
* Renamed → update references
* Changed → update its description and examples

Do not claim a feature exists unless the codebase supports it.

### Project structure

If the architecture or important directory structure changes, update the relevant README section.

Do not generate a huge file tree unless the existing README already uses one or it provides meaningful value.

### API

If the project exposes an API, verify that documented:

* Endpoints
* HTTP methods
* Parameters
* Request bodies
* Responses
* Authentication
* Examples

match the implementation.

Never invent API behavior.

### Examples

Examples must remain consistent with the current project.

When an example is outdated:

1. Update it if the intended behavior is clear.
2. Remove it if it is no longer relevant.
3. Do not invent missing behavior.

## Validation

After editing `README.md`, perform a final consistency check.

Verify:

* Documented commands exist
* Important documented paths exist
* Environment variables are accurate
* Installation steps are correct
* Examples match the current implementation
* Feature descriptions match the code
* API documentation matches the implementation
* Internal links remain valid when practical
* No secrets have been introduced
* No obsolete terminology remains

If practical, run lightweight validation commands relevant to the project.

Do not run destructive commands.

## Git awareness

Use Git history to understand why a documented behavior changed when necessary.

Do not modify commits, branches, tags, or Git history as part of this skill.

The skill only updates documentation.

## Handling ambiguity

Never invent information.

If the codebase does not provide enough evidence to determine the intended behavior:

1. Keep existing documentation if it is not demonstrably incorrect.
2. Avoid adding speculative information.
3. Ask for clarification only when it is necessary to produce accurate documentation.

## Minimal-change principle

Prefer the smallest README change that restores consistency.

For example:

* A renamed command → update the command.
* A new environment variable → add it to configuration documentation.
* A removed feature → remove its documentation.
* A changed API parameter → update the relevant API section.

Do not restructure unrelated sections.

## Final state

After running the skill, `README.md` should be:

* Accurate
* Current
* Concise
* Consistent with the codebase
* Useful to a new developer or user

The README should answer:

> "If I clone this project today and follow this README, will the documented workflow match the actual project?"

If the answer is no, continue updating the README until the discrepancy is resolved.