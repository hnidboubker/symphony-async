# Symphony Async

**Symphony Async** is a modular orchestration system for Claude Code that turns everyday development tasks into a coordinated, automated workflow.

Instead of relying on a single large skill, Symphony is built as a collection of specialized skills that work together like instruments in a symphony. Each skill has a clear responsibility and can be executed independently or orchestrated by `symphony-async`.

### Core Skills

* **`commit-async`** — detects changes, analyzes them, proposes a Conventional Commit message, asks for approval, creates the commit, and requests approval before pushing.
* **`tests-async`** — manages automated testing workflows, including TDD and BDD practices through its `tdd-async` and `bdd-async` sub-skills, and acts as a quality gate before releases.
* **`auto-release`** — analyzes Conventional Commits, determines the appropriate semantic version, generates release information, and creates Git tags.
* **`readme-async`** — keeps project documentation synchronized with the actual state of the codebase and updates the README when necessary.
* **`symphony-async`** — orchestrates the entire workflow and coordinates the skills in the correct order.

### The Philosophy

```text
                    Symphony Async
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
                         auto-release
                              │
                              ▼
                         readme-async
                              │
                       Changes needed?
                         /          \
                       NO            YES
                        │             │
                        ▼             ▼
                       END       Commit + Test
                                      │
                                      ▼
                                     END
```

The goal is not to remove the developer from the process, but to **reduce repetitive work while keeping important decisions under human control**.

Every skill is independently reusable, while `symphony-async` provides the orchestration layer that connects them.

> **One project. Multiple skills. One coordinated workflow.**

## Project Structure

```
symphony-async/
├── commit-async/          # Git commit/push workflow with human approvals
│   ├── scripts/           # install.sh, install.ps1, install.py
│   ├── references/        # Context.md
│   ├── SKILL.md
│   └── README.md
├── tests-async/           # Testing workflow orchestration
│   ├── bdd-async/         # Behavior-Driven Development skill
│   │   ├── scripts/
│   │   ├── references/
│   │   ├── SKILL.md
│   │   └── README.md
│   ├── tdd-async/         # Test-Driven Development skill
│   │   ├── scripts/
│   │   ├── references/
│   │   ├── SKILL.md
│   │   └── README.md
│   └── SKILL.md
├── auto-release/          # Semantic versioning and release automation
│   ├── scripts/
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
│   ├── CHANGELOG.md
│   └── README.md
├── references/            # Shared references
├── scripts/               # Shared scripts
├── SECURITY.md
├── CONTRIBUTING.md
├── LICENSE
├── SKILL.md
└── README.md
```

## Quick Start

Each skill is self-contained with its own installation scripts. To get started:

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd symphony-async
   ```

2. **Install a skill** (example for `commit-async`):
   - **Bash**: `bash commit-async/scripts/install.sh`
   - **PowerShell**: `pwsh commit-async/scripts/install.ps1`
   - **Python**: `python commit-async/scripts/install.py`

3. **Use the skill** via the Claude Code skill system or as a standalone tool.

## Security

See [SECURITY.md](SECURITY.md) for security policies and responsible disclosure guidelines.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for contribution guidelines.

## License

This project is licensed under the terms of the [LICENSE](LICENSE) file.