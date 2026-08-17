# readme-async

`readme-async` is a specialized Claude Code skill designed to keep project documentation synchronized with the actual state of the codebase.

## Description

The skill analyzes the project's codebase, configuration files, Git history, and existing README.md to detect discrepancies between documentation and implementation. It then makes minimal, targeted updates to restore accuracy.

## Workflow

The skill follows a structured process:

```text
Inspect Project
    ↓
Analyze Recent Changes
    ↓
Read Existing README
    ↓
Update Only What's Necessary
    ↓
Validate Consistency
```

## Example Usage

1. **Inspection**: The skill runs `git status`, `git diff`, and checks for configuration files (package.json, pyproject.toml, etc.)
2. **Analysis**: It identifies that a new CLI command was added but not documented.
3. **Reading**: It reads the current README.md to find the commands section.
4. **Update**: It adds the missing command to the documented commands list.
5. **Validation**: It verifies the documented command matches the actual implementation.

## Installation

### Within symphony-orchestrator

The skill is part of the `symphony-orchestrator` project. To verify the environment is ready:

- **Bash**: `bash readme-async/scripts/install.sh`
- **PowerShell**: `pwsh readme-async/scripts/install.ps1`
- **Node.js**: `node readme-async/scripts/install.js`

### As a standalone skill (for other projects)

```bash
# Via npx (recommended)
npx readme-async [target-project-path]

# Or from cloned repo
bash readme-async/scripts/install.sh [target-project-path]
pwsh readme-async/scripts/install.ps1 [target-project-path]
```

This copies the skill to `<target-project>/.claude/skills/readme-async/`.

## Security

To prevent accidental data loss or unauthorized changes, `readme-async` adheres to the following security constraints:

- **No Secret Exposure**: Never exposes real secrets, tokens, passwords, API keys, or credentials. Uses placeholders when necessary.
- **No Destructive Commands**: Does not execute destructive commands like `git reset --hard` or `git push --force`.
- **Minimal Changes**: Only updates what is necessary; never rewrites the entire README unless required.
- **No Silent Automation**: Every step is communicated; no action is performed silently.

## Integration with symphony-orchestrator

`readme-async` is a component of the `symphony-orchestrator` orchestration framework. It acts as the final stage in the development lifecycle:

`symphony-orchestrator` → `commit-async` → `tests-async` → `auto-release` → **`readme-async`**

The skill returns a status to the orchestrator to indicate whether documentation updates were made.

## Configuration

The skill uses the following configuration files:

- **SKILL.md** — Skill definition and metadata
- **references/CONTEXT.md** — Operational context and constraints
- **release.config.cjs** — Semantic release configuration (for standalone distribution)
- **package.json** — Node.js package configuration (for npm/npx distribution)

## Dependencies

- Node.js >= 18.0.0 (for npm/npx distribution and standalone use)
- Git (required for change detection)
- No external dependencies when used within symphony-async (uses shell scripts)

## Supported Project Types

The skill can synchronize README.md for projects using:

- Node.js (package.json, package-lock.json, pnpm-lock.yaml, yarn.lock)
- Python (pyproject.toml, requirements.txt)
- Rust (Cargo.toml)
- Go (go.mod)
- PHP (composer.json)
- Docker (Dockerfile, docker-compose.yml)
- Make (Makefile)
- .NET (csproj, sln)
- And any project with a README.md and Git history