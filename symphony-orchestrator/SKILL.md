---
name: symphony-orchestrator
description: Orchestrates the complete development workflow by coordinating commit, TDD, BDD, testing, release, and documentation skills.
---

# symphony-orchestrator

**symphony-orchestrator** is the TOP-LEVEL ORCHESTRATOR of the entire development workflow.

It coordinates specialized skills but does not replace their responsibilities.

## Objective

`symphony-orchestrator` orchestrates the complete development lifecycle:

```
Change
  ↓
Tests
  ↓
Commit
  ↓
Push
  ↓
Release
  ↓
Documentation
  ↓
Detect new changes
  ↓
Repeat only if necessary
  ↓
STOP
```

The specialized skills are:

- `commit-async`
- `tests-async`
- `tdd-async`
- `bdd-async`
- `auto-release`
- `readme-async`

`symphony-orchestrator` is the only skill responsible for coordinating the complete workflow.

## Required Structure

Create or update:

```
symphony-orchestrator/
├── references/
│   └── Context.md
├── scripts/
│   ├── install.sh
│   ├── install.ps1
│   └── install.py
├── SKILL.md
└── README.md
```

Before modifying anything:

1. Inspect the repository.
2. Inspect all existing skills.
3. Read their SKILL.md files.
4. Understand their contracts.
5. Do not duplicate their responsibilities.
6. Do not modify unrelated skills unless strictly necessary.

## Core Architecture

The architecture is:

```
                         symphony-async
                              │
                              ▼
                         tests-async
                         /          \
                        ▼            ▼
                   tdd-async      bdd-async
                        \            /
                         ▼          ▼
                            TUnit
                              │
                              ▼
                         PASS / FAIL
                              │
                         PASS only
                              ▼
                        commit-async
                              │
                              ▼
                             PUSH
                              │
                              ▼
                        auto-release
                              │
                              ▼
                       readme-async
                              │
                              ▼
                       Change Detection
                              │
                    ┌─────────┴─────────┐
                    │                   │
                NO CHANGES          CHANGES
                    │                   │
                    ▼                   ▼
                   STOP             RESTART
```

The workflow is a controlled cascade.

## Important Principle

Each skill has ONE responsibility.

`symphony-orchestrator` orchestrates.

`tests-async` orchestrates testing.

`tdd-async` performs TDD.

`bdd-async` performs BDD.

`commit-async` handles commit creation and approval.

`auto-release` handles semantic versioning, changelog generation, and Git tags.

`readme-async` handles README synchronization.

Do not duplicate these responsibilities inside `symphony-orchestrator`.

## Workflow

The standard workflow is:

1. Detect changes.
2. Determine what kind of work is present.
3. Select the appropriate testing strategy.
4. Run `tests-async`.
5. Stop if tests fail.
6. Invoke `commit-async`.
7. Wait for commit approval.
8. Wait for push approval.
9. Push the commit.
10. Invoke `auto-release`.
11. Create the release if required.
12. Invoke `readme-async`.
13. Detect whether new changes were created.
14. If there are no new changes, stop.
15. If new changes exist, evaluate them again.
16. Prevent infinite loops.

## Step 1 — Initial Change Detection

Start with:

```bash
git status --short
```

If there are no relevant changes:

return:

```
SYMPHONY_NO_CHANGES
```

Do not start the pipeline.

Never invent work.

## Step 2 — Understand the Change

Inspect:

```bash
git status
git diff
git diff --cached
```

Understand:

* changed files;
* added files;
* deleted files;
* modified files;
* new functionality;
* bug fixes;
* refactoring;
* documentation changes;
* tests;
* configuration;
* breaking changes.

Do not modify files during analysis unless a delegated skill explicitly requires it.

## Step 3 — Select Test Strategy

Delegate testing to:

`tests-async`

`tests-async` decides whether to use:

`tdd-async`

or:

`bdd-async`

based on the task.

Explicit user intent has priority.

If the user explicitly requests:

TDD

use TDD.

If the user explicitly requests:

BDD

use BDD.

If the user requests both:

BDD
↓
TDD

Use BDD to establish business behavior and TDD to drive implementation.

Do not duplicate test logic unnecessarily.

## Step 4 — Test Gate

Invoke:

`tests-async`

Wait for its result.

Possible results:

```
TESTS_PASSED
TESTS_FAILED
TESTS_BLOCKED
TESTS_NOT_REQUIRED
```

If:

```
TESTS_FAILED
```

STOP.

Do not commit.

Do not push.

Do not release.

Return:

```
SYMPHONY_TESTS_FAILED
```

If:

```
TESTS_BLOCKED
```

STOP.

Return:

```
SYMPHONY_TESTS_BLOCKED
```

If:

```
TESTS_PASSED
```

continue.

## Step 5 — Commit

Invoke:

`commit-async`

`commit-async` is responsible for:

1. detecting changes;
2. analyzing changes;
3. proposing a Conventional Commit;
4. asking the user for approval;
5. creating the commit;
6. asking for push approval;
7. pushing the commit.

`symphony-orchestrator` must NOT bypass these approvals.

Do not create commits directly.

Do not automatically approve a commit.

Do not automatically push.

Wait for the result from `commit-async`.

Possible results:

```
COMMIT_CREATED
PUSH_COMPLETED
COMMIT_REJECTED
PUSH_REJECTED
COMMIT_FAILED
PUSH_FAILED
NO_CHANGES
```

## Commit Rejection

If the user rejects the commit:

STOP.

Return:

```
SYMPHONY_COMMIT_REJECTED
```

Do not continue to release.

## Push Rejection

If the user rejects the push:

STOP.

Do not release a commit that has not been pushed unless the user explicitly requests a local release.

Return:

```
SYMPHONY_PUSH_REJECTED
```

## Step 6 — Release

After a successful push, invoke:

`auto-release`

`auto-release` must:

1. inspect commits since the last release;
2. determine whether a release is required;
3. calculate semantic version;
4. update CHANGELOG.md;
5. create the Git tag;
6. return the release result.

`symphony-orchestrator` must not calculate versions itself.

Do not use npm.

Do not use Node.js.

Do not use semantic-release.

## Release Result

Possible results:

```
NO_RELEASE
RELEASE_CREATED
RELEASE_BLOCKED
RELEASE_FAILED
CHANGELOG_UPDATED
TAG_CREATED
```

If:

```
RELEASE_FAILED
```

STOP and report the failure.

If:

```
NO_RELEASE
```

continue to `readme-async` if documentation synchronization is relevant.

If:

```
RELEASE_CREATED
```

continue to `readme-async`.

## Tag Pushing

Do not force-push tags.

Never execute:

```bash
git push --force
```

Never delete or replace an existing release tag.

If `auto-release` creates a local tag that must be pushed, follow the release skill's explicit approval contract.

Never silently push release tags.

## Step 7 — README

Invoke:

`readme-async`

Its responsibility is to determine whether the README needs updating.

Do not edit README.md directly from `symphony-orchestrator`.

Possible results:

```
README_UNCHANGED
README_UPDATED
README_BLOCKED
README_FAILED
```

If README is updated, it may create new working-tree changes.

Those changes must be evaluated before the workflow ends.

## The Cascade

The complete cascade is:

```
                 ┌──────────────────┐
                 │ symphony-async   │
                 └────────┬─────────┘
                          │
                          ▼
                   Detect Changes
                          │
                          ▼
                   tests-async
                     /        \
                    ▼          ▼
               tdd-async    bdd-async
                    \          /
                     ▼        ▼
                        TUnit
                          │
                     PASS / FAIL
                          │
                        PASS
                          ▼
                   commit-async
                          │
                 User approval
                          │
                          ▼
                        COMMIT
                          │
                 User approval
                          │
                          ▼
                        PUSH
                          │
                          ▼
                    auto-release
                          │
                          ▼
                    CHANGELOG
                          +
                         TAG
                          │
                          ▼
                    readme-async
                          │
                          ▼
                   Detect Changes
```

## Loop Behavior

The pipeline is allowed to repeat.

However, it must NEVER loop indefinitely.

The fundamental stopping condition is:

```
NO NEW RELEVANT CHANGES
```

Example:

```
Initial changes
    ↓
Tests
    ↓
Commit
    ↓
Push
    ↓
Release
    ↓
README update
    ↓
Check Git status
    ↓
No changes
    ↓
STOP
```

## Change Cascade

If `readme-async` creates changes:

```
README update
    ↓
new changes detected
    ↓
tests-async
    ↓
commit-async
    ↓
push
    ↓
auto-release if required
    ↓
readme-async
    ↓
check changes again
```

Only continue when there are genuinely new relevant changes.

## Loop Prevention

The orchestrator must detect repeated cycles.

Maintain an internal execution context containing:

- iteration number;
- initial HEAD;
- current HEAD;
- files changed;
- skills executed;
- commits created;
- release version;
- README modifications.

Set a reasonable maximum number of iterations.

Default:

```
MAX_ITERATIONS = 3
```

If the workflow reaches the maximum:

STOP.

Return:

```
SYMPHONY_LOOP_LIMIT_REACHED
```

Explain which files or skills caused the repeated cycle.

Never continue indefinitely.

## Self-Generated Changes

The orchestrator must distinguish between:

USER_CHANGES

and:

AUTOMATION_CHANGES

Examples of automation changes:

- CHANGELOG.md;
- README.md;
- generated documentation;
- generated release metadata.

Automation-generated changes may trigger another iteration.

However, if the same automation repeatedly modifies the same file without stabilizing, stop.

Return:

```
SYMPHONY_UNSTABLE
```

## No Change Termination

The workflow terminates successfully when:

```bash
git status --short
```

returns no relevant changes.

Return:

```
SYMPHONY_COMPLETED
```

Example:

```
SYMPHONY_COMPLETED

iterations: 2
tests: passed
commits: 2
releases: 1
readme_updates: 1
working_tree: clean
```

## Release Loop Prevention

A release must not cause another release unless a new Conventional Commit requiring a release exists.

Do not create a release from:

- the same commit;
- the same tag;
- an unchanged repository.

A README-only change may produce a documentation commit.

Whether that documentation commit requires a release depends on the Conventional Commit type.

For example:

```
docs: update README
```

may produce no release depending on the project's release policy.

## Conventional Commits

`symphony-orchestrator` does not generate commit messages itself.

Delegate this to:

`commit-async`

The commit skill owns Conventional Commit proposal and approval.

## Human Approval

Human approval is mandatory for:

- commit creation;
- pushing commits;
- destructive or remote operations;
- release tag pushing when applicable.

Never simulate approval.

Never assume approval.

Never automatically answer approval prompts.

## Error Handling

Any failure must stop the dependent part of the pipeline.

Examples:

```
TESTS_FAILED
    → STOP

COMMIT_FAILED
    → STOP

PUSH_FAILED
    → STOP

RELEASE_FAILED
    → STOP

README_FAILED
    → STOP or report according to the documentation contract
```

Never continue after a failed quality gate.

## Skill Contracts

`symphony-orchestrator` must communicate with skills through explicit results.

Expected contracts:

tests-async:

```
TESTS_PASSED
TESTS_FAILED
TESTS_BLOCKED
TESTS_NOT_REQUIRED
```

commit-async:

```
COMMIT_CREATED
PUSH_COMPLETED
COMMIT_REJECTED
PUSH_REJECTED
COMMIT_FAILED
PUSH_FAILED
NO_CHANGES
```

auto-release:

```
NO_RELEASE
RELEASE_CREATED
RELEASE_BLOCKED
RELEASE_FAILED
CHANGELOG_UPDATED
TAG_CREATED
```

readme-async:

```
README_UNCHANGED
README_UPDATED
README_BLOCKED
README_FAILED
```

## Skill Independence

Specialized skills must remain independent.

`symphony-orchestrator` must not:

- implement TDD;
- implement BDD;
- implement Conventional Commit generation;
- calculate semantic versions;
- directly modify README;
- directly modify CHANGELOG;
- directly create release tags.

Delegate those responsibilities.

## Security

Never execute:

```bash
git reset --hard
git clean -fd
git push --force
```

Never delete user changes.

Never overwrite unrelated files.

Never automatically resolve conflicts by discarding changes.

Never commit unrelated files.

Never push without explicit approval.

Never create infinite loops.