# Symphony Async

**Symphony Async** is a modular orchestration system for Claude Code that transforms everyday development tasks into a coordinated, automated workflow. Instead of relying on a single monolithic skill, Symphony is built as a collection of specialized skills that work together like instruments in a symphony—each with a clear responsibility, independently reusable, yet orchestrated by `symphony-orchestrator` into a complete development pipeline.

## Core Skills

| Skill | Responsibility | Description |
|-------|----------------|-------------|
| **`commit-async`** | Commit & Push | Detects changes, proposes Conventional Commit messages, requires explicit human approval before committing and pushing |
| **`tests-async`** | Test Orchestration | Coordinates TDD/BDD testing workflows, delegates to specialized skills, runs TUnit tests as quality gate |
| **`tdd-async`** | Test-Driven Development | Enforces strict Red → Green → Refactor cycle for C#/.NET using TUnit |
| **`bdd-async`** | Behavior-Driven Development | Transforms business requirements into executable Given → When → Then tests using TUnit |
| **`auto-release`** | Release Automation | Analyzes Conventional Commits, determines semantic version, generates CHANGELOG, creates Git tags (Python + Git only) |
| **`readme-async`** | Documentation Sync | Keeps README synchronized with codebase by detecting discrepancies and making minimal targeted updates |
| **`symphony-orchestrator`** | Orchestration | Top-level orchestrator coordinating the complete workflow with loop prevention and human approval gates |

## Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                        SYMPHONY ASYNC                               │
│                    (Top-Level Orchestrator)                         │
└─────────────────────────────┬───────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────────┐
│                        TESTS-ASYNC                                  │
│              ┌─────────────────┬─────────────────┐                 │
│              ▼                 ▼                 ▼                 │
│         TDD-ASYNC          BDD-ASYNC           TUNIT              │
│              └─────────────────┴─────────────────┘                 │
│                              │                                     │
│                       PASS / FAIL                                  │
│                              │                                     │
│                              ▼ (PASS only)                         │
└─────────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────────┐
│                      COMMIT-ASYNC                                   │
│   Detect → Analyze → Propose → Approve → Commit → Approve → Push   │
└─────────────────────────────┬───────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────────┐
│                      AUTO-RELEASE                                   │
│   Conventional Commits → Semantic Version → CHANGELOG → Git Tag    │
└─────────────────────────────┬───────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────────┐
│                      README-ASYNC                                   │
│   Inspect → Analyze Changes → Read → Update → Validate → Detect    │
└─────────────────────────────┬───────────────────────────────────────┘
                              │
                              ▼
                    ┌─────────┴─────────┐
                    ▼                   ▼
               NO CHANGES            CHANGES
                    │                   │
                    ▼                   ▼
                   STOP            RESTART PIPELINE
```

## The Philosophy

> **One project. Multiple skills. One coordinated workflow.**

The goal is not to remove the developer from the process, but to **reduce repetitive work while keeping important decisions under human control**. Every skill is independently reusable, while `symphony-orchestrator` provides the orchestration layer that connects them.

### Human Approval Gates

Mandatory explicit approval is required for:
- **Commit creation** — `commit-async` proposes, you approve
- **Pushing commits** — local commit created, you approve remote push
- **Destructive/remote operations** — never executed automatically
- **Release tag pushing** — when applicable, follows skill approval contract

Symphony Async **never** simulates, assumes, or automatically answers approval prompts.

## Project Structure

```
symphony-orchestrator/     # Top-level orchestrator
│   ├── scripts/           # install.sh, install.ps1, install.py
│   ├── references/        # Context.md
│   ├── SKILL.md
│   └── README.md
├── commit-async/          # Git commit/push workflow with human approvals
│   ├── scripts/           # install.sh, install.ps1, install.py
│   ├── references/        # Context.md
│   ├── SKILL.md
│   ├── README.md
│   └── CONTRIBUTING.md
├── tests-async/           # Testing workflow orchestration
│   ├── scripts/
│   ├── references/
│   ├── SKILL.md
│   └── README.md
├── tdd-async/             # Test-Driven Development skill
│   ├── scripts/
│   ├── references/
│   ├── SKILL.md
│   └── README.md
├── bdd-async/             # Behavior-Driven Development skill
│   ├── scripts/
│   ├── references/
│   ├── SKILL.md
│   └── README.md
├── test-fixer-async/      # Test fixing skill
│   ├── SKILL.md
├── auto-release/          # Semantic versioning and release automation
│   ├── scripts/           # release.py, install.sh, install.ps1
│   ├── references/
│   ├── SKILL.md
│   └── README.md
├── readme-async/          # Documentation synchronization
│   ├── scripts/           # install.js, install.sh, install.ps1, prompt.js
│   ├── references/        # CONTEXT.md
│   ├── package.json
│   ├── release.config.cjs
│   ├── SKILL.md
│   ├── CONTRIBUTING.md
│   └── README.md
├── SECURITY.md            # Security policies and responsible disclosure
├── CONTRIBUTING.md        # Contribution guidelines
├── LICENSE                # MIT License
└── README.md              # This file
```

## Quick Start

### Prerequisites

- **Git** (required for all skills)
- **Python 3.8+** (required for `auto-release` and `symphony-orchestrator` installer)
- **.NET SDK 8.0+** (required for `tdd-async` / `bdd-async` / `tests-async` when working with C# projects)
- **Node.js 18+** (optional, only for standalone `readme-async` distribution via npx)

### Installation

Each skill is self-contained with its own installation verification scripts:

```bash
# Clone the repository
git clone <repository-url>
cd symphony-orchestrator

# Verify symphony-orchestrator environment (from repo root)
bash symphony-orchestrator/scripts/install.sh
# or
pwsh symphony-orchestrator/scripts/install.ps1
# or
python symphony-orchestrator/scripts/install.py
```

The installer verifies:
- Git is available
- Python 3 is available
- Current directory is a Git repository
- Expected Symphony structure exists
- All required skills exist with valid SKILL.md files

### Starting the Workflow

From the repository root, invoke the orchestrator:

```bash
# Via shell (requires skill to be installed in .claude/skills/)
symphony-orchestrator

# Or directly via Python
python symphony-orchestrator/scripts/symphony.py
```

### Individual Skill Usage

You can also use skills independently:

```bash
# Commit workflow
bash commit-async/scripts/install.sh  # verify environment
# Then use via Claude Code skill system

# Release automation
python auto-release/scripts/release.py

# Documentation sync (standalone via npx)
npx readme-async [target-project-path]
```

## Workflow States

Symphony Async communicates through explicit machine-readable states:

| State | Meaning |
|-------|---------|
| `SYMPHONY_STARTED` | Workflow initiated |
| `SYMPHONY_NO_CHANGES` | No relevant changes detected |
| `SYMPHONY_TESTS_FAILED` | Tests failed, pipeline stopped |
| `SYMPHONY_TESTS_BLOCKED` | Tests blocked (e.g., no test project), pipeline stopped |
| `SYMPHONY_COMMIT_REJECTED` | User rejected commit proposal |
| `SYMPHONY_PUSH_REJECTED` | User rejected push |
| `SYMPHONY_COMPLETED` | Workflow completed successfully |
| `SYMPHONY_LOOP_LIMIT_REACHED` | Maximum iterations (default 3) reached |
| `SYMPHONY_UNSTABLE` | Automation not stabilizing (same file modified repeatedly) |
| `SYMPHONY_FAILED` | General failure |

### Skill Contracts

Each skill returns explicit states:

```
tests-async:        TESTS_PASSED | TESTS_FAILED | TESTS_BLOCKED | TESTS_NOT_REQUIRED
commit-async:       COMMIT_CREATED | PUSH_COMPLETED | COMMIT_REJECTED | PUSH_REJECTED | COMMIT_FAILED | PUSH_FAILED | NO_CHANGES
auto-release:       NO_RELEASE | RELEASE_CREATED | RELEASE_BLOCKED | RELEASE_FAILED | CHANGELOG_UPDATED | TAG_CREATED
readme-async:       README_UNCHANGED | README_UPDATED | README_BLOCKED | README_FAILED
```

## Loop Prevention

The pipeline can repeat but **never loops indefinitely**:

- **Natural stopping condition**: `git status --short` returns no relevant changes
- **Maximum iterations**: Default `MAX_ITERATIONS = 3`
- **Automation detection**: Distinguishes user changes from automation-generated changes (CHANGELOG.md, README.md, tags)
- **Unstable detection**: Stops if the same automation repeatedly modifies the same file without stabilizing

## Conventional Commits

All commits follow [Conventional Commits](https://www.conventionalcommits.org/) specification:

| Type | Release Level | Example |
|------|---------------|---------|
| `fix:` | PATCH | `fix(auth): resolve session timeout` |
| `feat:` | MINOR | `feat: add OAuth authentication` |
| `feat!:`, `BREAKING CHANGE:` | MAJOR | `feat!: replace authentication API` |

Priority: MAJOR > MINOR > PATCH

## Security

See [SECURITY.md](SECURITY.md) for security policies, responsible disclosure guidelines, and security constraints enforced by each skill.

### Security Constraints Enforced

- **No destructive Git commands**: Never executes `git reset --hard`, `git clean -fd`, or `git push --force`
- **No blind staging**: Avoids `git add .` to prevent committing unrelated/sensitive files
- **Explicit approval**: Every commit and push requires separate, explicit user confirmation
- **No silent automation**: Every step is communicated; no action performed silently
- **No secret exposure**: Never exposes real secrets, tokens, passwords, API keys; uses placeholders
- **Minimal changes**: Only updates what is necessary; never rewrites entire files unless required

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for contribution guidelines, pull request process, and development workflow.

### Quick Contributing Rules

- Create a new branch for each change
- Write clear, Conventional Commit messages
- Keep code clean and readable
- Test your changes before submitting
- Clearly describe changes in the Pull Request
- Respect the codebase and other contributors

## License

This project is licensed under the terms of the [LICENSE](LICENSE) file (MIT License).

```
MIT License

Copyright (c) 2026 NID BOUBKER Houssine

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

---

**Symphony Async** — *Orchestrating development workflows, one skill at a time.*