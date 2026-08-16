# commit-async Context

## Purpose

The `commit-async` skill automates the complete Git commit workflow with explicit user approval at each critical step. It analyzes changes, proposes Conventional Commit messages, and ensures no action is taken without user consent.

## Role within symphony-async

`commit-async` is a specialized skill in the `symphony-async` orchestration pipeline. It sits at the beginning of the flow:

```text
symphony-async
      ↓
commit-async
      ↓
tests-async
      ↓
auto-release
      ↓
readme-async
```

The skill does not directly invoke other skills. It returns its result state to the orchestrator (`symphony-async`), which then decides the next step.

## Workflow

```text
Changes
    ↓
Analysis
    ↓
Proposal
    ↓
Approval
    ↓
Commit
    ↓
Approval
    ↓
Push
```

1. **Change Detection** - Run `git status --short`, `git diff`, `git diff --cached`
2. **Analysis** - Identify change type, scope, summary, affected files, functional changes, breaking changes
3. **Proposal** - Generate Conventional Commit message
4. **Commit Approval** - Ask user to approve the commit message
5. **Commit Creation** - Stage relevant files and create commit
6. **Push Approval** - Ask user to approve pushing to remote
7. **Push** - Execute `git push`

## Conventional Commits

Format: `type(scope): description`

Supported types:
- `feat` - New feature
- `fix` - Bug fix
- `docs` - Documentation changes
- `refactor` - Code refactoring
- `test` - Test additions/changes
- `chore` - Maintenance tasks
- `ci` - CI/CD changes
- `perf` - Performance improvements
- `build` - Build system changes

Scope is optional but recommended for clarity.

## Commit Approval vs Push Approval

These are two distinct approval gates:

| Gate | Action | User Question |
|------|--------|---------------|
| Commit Approval | Create local commit | "Approve this commit message?" |
| Push Approval | Push to remote | "Would you like to push this commit to the remote?" |

Both require explicit user consent. Never bypass either.

## Staging Rules

- Never use `git add .` blindly
- Stage only files related to the logical change
- Avoid including unrelated modified files
- Verify staged files before committing

## State Definitions

| State | Description |
|-------|-------------|
| NO_CHANGES | No relevant changes detected |
| COMMIT_PROPOSED | Commit message proposed, awaiting approval |
| COMMIT_APPROVED | User approved commit message |
| COMMIT_REJECTED | User rejected commit message |
| COMMIT_CREATED | Commit successfully created locally |
| COMMIT_FAILED | Commit creation failed |
| PUSH_APPROVED | User approved push to remote |
| PUSH_REJECTED | User rejected push |
| PUSH_COMPLETED | Push successfully completed |
| PUSH_FAILED | Push failed |

## Security Rules

The skill must never:
- Commit without explicit approval
- Push without explicit approval
- Delete modifications
- Use `git reset --hard`
- Automatically use `git push --force`
- Overwrite existing work
- Intentionally include unrelated files

## Contracts with Other Skills

`commit-async` returns one of these states to `symphony-async`:
- `COMMIT_CREATED` - Commit made, ready for next skill
- `PUSH_COMPLETED` - Full workflow complete
- `NO_CHANGES` - Nothing to do, stop pipeline
- `COMMIT_REJECTED` - User rejected, stop pipeline
- `PUSH_REJECTED` - User declined push, stop pipeline
- `COMMIT_FAILED` - Error during commit
- `PUSH_FAILED` - Error during push

The orchestrator (`symphony-async`) handles transitions to `tests-async`, `auto-release`, `readme-async` based on these states.