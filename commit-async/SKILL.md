---
name: commit-async
description: Analyzes Git changes, proposes a Conventional Commit message, asks for approval before creating the commit, then asks for a second approval before pushing.
---

# commit-async

## Workflow

```text
git status
    ↓
git diff
    ↓
analyze changes
    ↓
propose Conventional Commit
    ↓
user approval
    ↓
git commit
    ↓
user approval for push
    ↓
git push
```

## Change Detection

Use, when appropriate:

```bash
git status --short
git diff
git diff --cached
```

If no relevant changes are detected, stop cleanly with:

> No changes detected.

Never invent changes.

## Analysis

Identify:

* change type;
* optional scope;
* summary;
* affected files;
* important functional changes;
* potential breaking changes.

Use Conventional Commits.

Supported types include:

```text
feat
fix
docs
refactor
test
chore
ci
perf
build
```

Format:

```text
type(scope): description
```

The scope is optional.

Example:

```text
feat(auth): add OAuth authentication
```

## Commit Approval

Present the user with:

```text
Detected changes:
- ...
- ...

Proposal:
feat(auth): add OAuth authentication
```

Then explicitly ask:

```text
Approve this commit message?
```

Never create the commit before this approval.

If the user rejects it:

* do not create a commit;
* propose a new formulation;
* ask for approval again.

If the user modifies the message:

* use the approved message;
* do not silently alter it.

## Creating the Commit

After approval, stage the appropriate files.

Avoid:

```bash
git add .
```

whenever it could include unrelated files.

Prefer staging only the files actually related to the change.

Then run:

```bash
git commit -m "<approved message>"
```

After the commit, verify the repository status.

## Push Approval

Once the commit has been successfully created, explicitly ask:

```text
Commit created successfully.

Would you like to push this commit to the remote?
```

Never execute `git push` before this approval.

After approval:

```bash
git push
```

Never automatically execute:

```bash
git push --force
```

or any destructive variant.

## Integration with symphony-orchestrator

`commit-async` is a specialized skill.

It must not directly invoke:

* `tests-async`;
* `auto-release`;
* `readme-async`.

`symphony-orchestrator` is responsible for orchestrating the skills.

The expected global flow is:

```text
symphony-orchestrator
      ↓
commit-async
      ↓
tests-async
      ↓
auto-release
      ↓
readme-async
```

`commit-async` must clearly return its result to the orchestrator.

Possible success states:

```text
COMMIT_CREATED
PUSH_COMPLETED
```

Possible stop/error states:

```text
NO_CHANGES
COMMIT_REJECTED
PUSH_REJECTED
COMMIT_FAILED
PUSH_FAILED
```

## Security

The skill must never:

* commit without approval;
* push without approval;
* delete modifications;
* use `git reset --hard`;
* automatically use `git push --force`;
* overwrite existing work;
* intentionally include unrelated files.