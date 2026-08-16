# Symphony Async

**Symphony Async** is a modular orchestration system for Claude Code that turns everyday development tasks into a coordinated, automated workflow.

Instead of relying on a single large skill, Symphony is built as a collection of specialized skills that work together like instruments in a symphony. Each skill has a clear responsibility and can be executed independently or orchestrated by `symphony-async`.

### Core Skills

* **`commit-async`** — detects changes, analyzes them, proposes a Conventional Commit message, asks for approval, creates the commit, and requests approval before pushing.
* **`tests-async`** — manages automated testing workflows, including TDD and BDD practices, and acts as a quality gate before releases.
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
