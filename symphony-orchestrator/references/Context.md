# Symphony Orchestrator Context

This document provides comprehensive context for the Symphony Orchestrator orchestrator and its integration with specialized skills.

## Symphony's Role

Symphony Orchestrator is the **top-level orchestrator** of the complete development workflow. It coordinates but does not replace specialized skills.

### Responsibilities:
- Detect changes in the repository
- Select appropriate testing strategy
- Invoke skills in the correct order
- Enforce quality gates (tests must pass)
- Require human approval for commits and pushes
- Coordinate release creation
- Synchronize documentation
- Detect and prevent infinite loops
- Report clear machine-readable states

### Non-Responsibilities:
- Implement TDD or BDD
- Generate commit messages
- Calculate semantic versions
- Directly modify README or CHANGELOG
- Create release tags
- Run tests directly

## Specialized Skills

### tests-async
**Role**: Test orchestrator
**Decides**: TDD vs BDD based on task
**Delegates to**: tdd-async, bdd-async
**Runs**: TUnit tests
**Returns**: TESTS_PASSED, TESTS_FAILED, TESTS_BLOCKED, TESTS_NOT_REQUIRED

### tdd-async
**Role**: Test-Driven Development (Red-Green-Refactor)
**Framework**: TUnit
**Returns**: TDD_PASSED, TDD_FAILED, TDD_RED, TDD_GREEN, TDD_REFACTOR, TDD_COMPLETED

### bdd-async
**Role**: Behavior-Driven Development (Given-When-Then)
**Framework**: TUnit
**Returns**: BDD_PASSED, BDD_FAILED, BDD_SCENARIO_IDENTIFIED, BDD_TEST_CREATED, BDD_TEST_FAILED, BDD_TEST_PASSED, BDD_COMPLETED

### commit-async
**Role**: Conventional Commit creation with human approval
**Process**: Detect → Analyze → Propose → Approve → Commit → Approve → Push
**Returns**: COMMIT_CREATED, PUSH_COMPLETED, COMMIT_REJECTED, PUSH_REJECTED, COMMIT_FAILED, PUSH_FAILED, NO_CHANGES

### auto-release
**Role**: Semantic versioning, changelog, Git tags
**Input**: Conventional Commits since last release
**Process**: Analyze commits → Determine level → Calculate version → Update CHANGELOG → Create tag
**Returns**: NO_RELEASE, RELEASE_CREATED, RELEASE_BLOCKED, RELEASE_FAILED, CHANGELOG_UPDATED, TAG_CREATED

### readme-async
**Role**: README synchronization
**Process**: Inspect project → Read README → Identify discrepancies → Update minimally
**Returns**: README_UNCHANGED, README_UPDATED, README_BLOCKED, README_FAILED

## Orchestration Order

```
1. Detect Changes (git status --short)
2. If no changes → SYMPHONY_NO_CHANGES → STOP
3. Analyze changes (git status, git diff)
4. Delegate to tests-async
5. If TESTS_FAILED → SYMPHONY_TESTS_FAILED → STOP
6. If TESTS_BLOCKED → SYMPHONY_TESTS_BLOCKED → STOP
7. If TESTS_PASSED → continue
8. Invoke commit-async
9. If COMMIT_REJECTED → SYMPHONY_COMMIT_REJECTED → STOP
10. If PUSH_REJECTED → SYMPHONY_PUSH_REJECTED → STOP
11. If PUSH_COMPLETED → continue
12. Invoke auto-release
13. If RELEASE_FAILED → STOP
14. If RELEASE_CREATED or NO_RELEASE → continue
15. Invoke readme-async
16. If README_UPDATED → check for new changes → RESTART
17. If no new changes → SYMPHONY_COMPLETED → STOP
```

## TDD/BDD Selection

### Explicit Priority
User explicit request always wins:
- "TDD" → tdd-async
- "BDD" → bdd-async
- "Both" → BDD then TDD

### Implicit Selection (tests-async decides)
**Prefer BDD** for:
- Business behavior
- User behavior
- Business rules
- Acceptance criteria
- User journeys
- Domain scenarios
- Externally observable behavior

**Prefer TDD** for:
- Technical component implementation
- Technical defect fixing
- Algorithmic behavior
- Refactoring
- Internal application logic
- Unit-level behavior
- Regression testing

### Ambiguous Cases
Inspect: task description, existing tests, project architecture, testing conventions, business acceptance criteria.
If uncertain, ask user: "Which testing strategy should be used? Options: TDD, BDD, Both"

## TUnit

All automated tests use TUnit exclusively.
- No xUnit, NUnit, MSTest, SpecFlow, Cucumber unless project explicitly requires
- Use project's TUnit conventions
- Preferred command: `dotnet test`
- Run smallest relevant scope first

## Commit Approval

commit-async requires explicit human approval:
1. Present detected changes
2. Propose Conventional Commit message
3. Ask: "Approve this commit message?"
4. Only after approval: create commit
5. After commit: ask "Would you like to push this commit to the remote?"
6. Only after approval: git push

Never bypass. Never simulate. Never assume.

## Push Approval

Same pattern as commit approval. Separate explicit approval required.

## Release Behavior

auto-release analyzes Conventional Commits:
- `fix` → PATCH
- `feat` → MINOR
- `feat!` or `BREAKING CHANGE:` → MAJOR
- Priority: MAJOR > MINOR > PATCH

Does NOT automatically push tags unless Symphony explicitly requests.

Changelog updates returned as CHANGELOG_UPDATED for Symphony to commit via commit-async.

## README Synchronization

readme-async updates README.md to match codebase.
May create new working-tree changes.
Those changes trigger another Symphony iteration.

Minimal change principle: only update what's necessary.

## Loop Detection

Symphony maintains execution context:
- iteration number (starts at 1)
- initial HEAD
- current HEAD
- files changed per iteration
- skills executed per iteration
- commits created
- release version
- README modifications

### Termination Conditions

1. **Natural**: `git status --short` returns no relevant changes → SYMPHONY_COMPLETED
2. **Maximum iterations**: MAX_ITERATIONS = 3 → SYMPHONY_LOOP_LIMIT_REACHED
3. **Unstable automation**: Same automation modifies same file repeatedly without stabilizing → SYMPHONY_UNSTABLE
4. **Quality gate failure**: Any TESTS_FAILED, COMMIT_REJECTED, PUSH_REJECTED, RELEASE_FAILED → STOP

### Change Classification

**USER_CHANGES**: Changes made by human developers
**AUTOMATION_CHANGES**: CHANGELOG.md, README.md, generated documentation, release tags

Automation changes may trigger restart, but stabilization is required.

## Release Loop Prevention

A release must not cause another release unless:
- New Conventional Commit requiring a release exists
- Not the same commit
- Not the same tag
- Not an unchanged repository

README-only changes (docs: update README) may not trigger release per project policy.

## Global States

| State | Trigger | Action |
|-------|---------|--------|
| SYMPHONY_STARTED | Workflow initiated | Begin pipeline |
| SYMPHONY_NO_CHANGES | No relevant changes | STOP |
| SYMPHONY_TESTS_FAILED | tests-async returns TESTS_FAILED | STOP |
| SYMPHONY_TESTS_BLOCKED | tests-async returns TESTS_BLOCKED | STOP |
| SYMPHONY_COMMIT_REJECTED | User rejects commit | STOP |
| SYMPHONY_PUSH_REJECTED | User rejects push | STOP |
| SYMPHONY_COMPLETED | Clean working tree after iterations | STOP (success) |
| SYMPHONY_LOOP_LIMIT_REACHED | MAX_ITERATIONS exceeded | STOP |
| SYMPHONY_UNSTABLE | Automation not stabilizing | STOP |
| SYMPHONY_FAILED | General/unexpected failure | STOP |

## Failure States

Any failure stops dependent pipeline parts:
- TESTS_FAILED → STOP (no commit, push, release)
- COMMIT_FAILED → STOP
- PUSH_FAILED → STOP
- RELEASE_FAILED → STOP
- README_FAILED → STOP or report per contract

## Security Rules

Never execute:
- `git reset --hard`
- `git clean -fd`
- `git push --force`

Never:
- Delete user changes
- Overwrite unrelated files
- Automatically resolve conflicts by discarding changes
- Commit unrelated files
- Push without explicit approval
- Create infinite loops

## Installation Scripts

All installers (install.sh, install.ps1, install.py) must:
1. Verify Git
2. Verify Python 3
3. Verify repository
4. Verify Symphony structure
5. Verify expected skills exist
6. Be idempotent
7. Use no external dependencies
8. NOT install Node.js
9. NOT install npm
10. NOT create Git hooks
11. NOT create commits
12. NOT create tags
13. NOT push anything

install.py: Python standard library only.