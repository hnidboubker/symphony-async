You are working in the `symphony-async` repository.

I want to create a new Claude Code skill named **`commit-async`**.

## Objective

`commit-async` is responsible for the complete commit workflow, with explicit user approval before creating the commit and then before pushing it.

The skill must:

1. detect Git changes;
2. analyze the changes;
3. propose a Conventional Commit message;
4. ask the user for approval;
5. create the commit only after approval;
6. explicitly ask for permission to push;
7. push only after approval.

It must **never** commit or push silently.

---

# Required Structure

Create:

```text
commit-async/
├── references/
│   └── Context.md
├── scripts/
│   ├── install.sh
│   ├── install.ps1
│   └── install.py
├── SKILL.md
└── README.md
```

Follow the conventions and style already used in the `symphony-async` repository.

Before creating the files, inspect the current repository structure and existing skills to ensure consistency with the existing architecture.

---

# SKILL.md

Create a complete `SKILL.md` with Claude Code-compatible frontmatter:

```yaml
---
name: commit-async
description: Analyzes Git changes, proposes a Conventional Commit message, asks for approval before creating the commit, then asks for a second approval before pushing.
---
```

The skill must clearly explain its workflow.

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

## Integration with symphony-async

`commit-async` is a specialized skill.

It must not directly invoke:

* `tests-async`;
* `auto-release`;
* `readme-async`.

`symphony-async` is responsible for orchestrating the skills.

The expected global flow is:

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

---

# references/Context.md

Create a `Context.md` explaining:

* the purpose of the skill;
* its role within `symphony-async`;
* the workflow;
* Conventional Commits;
* the difference between commit approval and push approval;
* staging rules;
* possible errors;
* security rules;
* contracts with the other skills.

Also document these states:

```text
NO_CHANGES
COMMIT_PROPOSED
COMMIT_APPROVED
COMMIT_REJECTED
COMMIT_CREATED
COMMIT_FAILED
PUSH_APPROVED
PUSH_REJECTED
PUSH_COMPLETED
PUSH_FAILED
```

---

# scripts/install.sh

Create a Bash installation script.

It must:

1. verify that Git is installed;
2. verify that the current directory is a Git repository;
3. display the repository root;
4. verify that the skill can be used;
5. not install Node.js;
6. not install npm;
7. not install external dependencies;
8. not create Git hooks;
9. not create commits;
10. not perform pushes.

The script must be idempotent.

It exists only to verify/prepare the use of the skill.

---

# scripts/install.ps1

Create the PowerShell equivalent of `install.sh`.

It must have the same behavior and constraints.

---

# scripts/install.py

Create the Python equivalent.

It must have the same behavior and constraints.

Use only the Python standard library.

No external dependencies.

---

# README.md

Create concise and clear documentation containing:

* description;
* workflow;
* example;
* installation;
* security;
* integration with `symphony-async`.

Clearly explain:

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

---

# Important Constraints

## No npm

This skill must not depend on:

```text
npm
node
package.json
semantic-release
```

## No Git Hooks

Do not use:

```text
post-commit
pre-commit
post-push
```

The workflow must be triggered by Claude Code / `symphony-async`.

## No Silent Automation

Every destructive or remote action must require explicit approval:

```text
commit → approval
push   → approval
```

## Repository Consistency

Before modifying anything:

1. inspect the existing skills;
2. read their `SKILL.md` files;
3. read their `README.md` files when necessary;
4. follow the existing conventions;
5. do not modify other skills unless necessary and clearly justified.

At the end, verify that:

```text
commit-async/
├── references/Context.md
├── scripts/install.sh
├── scripts/install.ps1
├── scripts/install.py
├── SKILL.md
└── README.md
```

are all present and consistent.

Do not create additional files unless there is a clear reason.
