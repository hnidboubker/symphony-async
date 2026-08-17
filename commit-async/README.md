# commit-async

`commit-async` is a specialized Claude Code skill designed to manage the Git commit and push workflow with strict human-in-the-loop approvals.

## Description

The skill automates the process of detecting changes, analyzing them, and proposing a Conventional Commit message, ensuring that no local commits and remote pushes are only executed after explicit user approval.

## Workflow

The skill follows a strict sequential process:

```text
Changes
    ↓
Analysis
    ↓
Proposal
    ↓
Approval (Commit)
    ↓
Commit (Local)
    ↓
Approval (Push)
    ↓
Push (Remote)
```

## Example Usage

1. **Detection**: The skill runs `git status` and `git diff` to see what changed.
2. **Analysis**: It identifies that a bug was fixed in the authentication module.
3. **Proposal**: It proposes: `fix(auth): resolve session timeout issue`.
4. **Commit Approval**:
   - Claude: "Approve this commit message?"
   - User: "Yes"
5. **Commit**: Executes `git commit -m "fix(auth): resolve session timeout issue"`.
6. **Push Approval**:
   - Claude: "Commit created successfully. Would you like to push this commit to the remote?"
   - User: "Yes"
7. **Push**: Executes `git push`.

## Installation

The skill has no external dependencies (no Node.js, npm, or external libraries). To verify the environment is ready, run the installation script for your platform:

- **Bash**: `bash commit-async/scripts/install.sh`
- **PowerShell**: `pwsh commit-async/scripts/install.ps1`
- **Python**: `python commit-async/scripts/install.py`

## Security

To prevent accidental data loss or unauthorized changes, `commit-async` adheres to the following security constraints:

- **Explicit Approval**: Every `git commit` and `git push` requires separate, explicit user confirmation.
- **No Blind Staging**: The skill avoids `git add .` to prevent committing unrelated or sensitive files.
- **No Destructive Commands**: Commands like `git reset --hard` or `git push --force` are strictly forbidden.
- **No Silent Automation**: No action is performed silently; every step is communicated to the user.

## Integration with symphony-orchestrator

`commit-async` is a component of the `symphony-orchestrator` orchestration framework. It acts as the entry point for the development lifecycle:

`symphony-orchestrator` → **`commit-async`** → `tests-async` → `auto-release` → `readme-async`

The skill returns a status code (e.g., `COMMIT_CREATED`, `PUSH_COMPLETED`, `NO_CHANGES`) to the orchestrator to trigger the next stage of the pipeline.