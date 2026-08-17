# Symphony Orchestrator

Symphony Orchestrator is a top-level orchestrator for a complete development workflow. It coordinates specialized skills to create a controlled, deterministic, and approval-aware development pipeline.

## Orchestration Philosophy

Symphony Orchestrator does **not** implement the specialized responsibilities itself. Instead, it orchestrates independent skills, each with a single responsibility:

| Skill | Responsibility |
|-------|----------------|
| `tests-async` | Orchestrates TDD/BDD testing workflows |
| `tdd-async` | Performs Test-Driven Development (Red-Green-Refactor) |
| `bdd-async` | Performs Behavior-Driven Development (Given-When-Then) |
| `commit-async` | Handles commit creation and push with human approval |
| `auto-release` | Semantic versioning, changelog generation, Git tags |
| `readme-async` | Keeps README synchronized with the codebase |

## The Complete Cascade

```
                    Symphony Orchestrator
                          │
                          ▼
                    tests-async
                     /       \
                    ▼         ▼
               tdd-async   bdd-async
                    \         /
                     ▼       ▼
                        TUnit
                          │
                       PASS
                          │
                          ▼
                   commit-async
                          │
                     APPROVAL
                          │
                        PUSH
                          │
                          ▼
                   auto-release
                          │
                          ▼
                   readme-async
                          │
                          ▼
                  CHANGE DETECTION
                          │
                    ┌─────┴─────┐
                    ▼           ▼
                  CLEAN      CHANGES
                    │           │
                    ▼           └────→ RESTART
                   STOP
```

## Human Approval Points

**Mandatory approval is required for:**
- Commit creation
- Pushing commits
- Destructive or remote operations
- Release tag pushing (when applicable)

Symphony Orchestrator **never** simulates, assumes, or automatically answers approval prompts.

## Loop Prevention

The pipeline can repeat but **never loops indefinitely**:

- **Natural stopping condition**: `git status --short` returns no relevant changes
- **Maximum iterations**: Default `MAX_ITERATIONS = 3`
- **Automation detection**: Distinguishes user changes from automation-generated changes (CHANGELOG.md, README.md, tags)
- **Unstable detection**: Stops if the same automation repeatedly modifies the same file without stabilizing

## Installation

```bash
# Linux/macOS
./scripts/install.sh

# Windows PowerShell
.\scripts\install.ps1

# Python (cross-platform)
python scripts/install.py
```

The installer verifies:
- Git is available
- Python 3 is available
- Current directory is a Git repository
- Expected Symphony structure exists
- Required skills exist

The installer does **NOT**:
- Install Node.js or npm
- Create Git hooks
- Create commits or tags
- Push anything

## Starting the Workflow

From the repository root:

```bash
# Invoke the orchestrator
symphony-orchestrator
```

Or via Python:

```bash
python symphony-orchestrator/scripts/symphony.py
```

## Global States

Symphony Orchestrator communicates through explicit machine-readable states:

| State | Meaning |
|-------|---------|
| `SYMPHONY_STARTED` | Workflow initiated |
| `SYMPHONY_NO_CHANGES` | No relevant changes detected |
| `SYMPHONY_TESTS_FAILED` | Tests failed, pipeline stopped |
| `SYMPHONY_TESTS_BLOCKED` | Tests blocked, pipeline stopped |
| `SYMPHONY_COMMIT_REJECTED` | User rejected commit |
| `SYMPHONY_PUSH_REJECTED` | User rejected push |
| `SYMPHONY_COMPLETED` | Workflow completed successfully |
| `SYMPHONY_LOOP_LIMIT_REACHED` | Maximum iterations reached |
| `SYMPHONY_UNSTABLE` | Automation not stabilizing |
| `SYMPHONY_FAILED` | General failure |

## Skill Contracts

Each skill returns explicit states:

```
tests-async:        TESTS_PASSED | TESTS_FAILED | TESTS_BLOCKED | TESTS_NOT_REQUIRED
commit-async:       COMMIT_CREATED | PUSH_COMPLETED | COMMIT_REJECTED | PUSH_REJECTED | COMMIT_FAILED | PUSH_FAILED | NO_CHANGES
auto-release:       NO_RELEASE | RELEASE_CREATED | RELEASE_BLOCKED | RELEASE_FAILED | CHANGELOG_UPDATED | TAG_CREATED
readme-async:       README_UNCHANGED | README_UPDATED | README_BLOCKED | README_FAILED
```

## Security

Symphony Orchestrator never executes:
- `git reset --hard`
- `git clean -fd`
- `git push --force`

It never deletes user changes, overwrites unrelated files, automatically resolves conflicts by discarding changes, commits unrelated files, pushes without explicit approval, or creates infinite loops.