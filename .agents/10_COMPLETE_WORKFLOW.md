# 10 — Complete Workflow: The Three Skills Together

Clarifies how the three priority skills chain together to handle a bug end to end:
`auto-issue-on-bug-detection` → `issue-resolution` → `human-controlled-git`.

## Full flow

```
STEP 1 — Bug detected
  Compile error, test failure, runtime crash, or any exception surfaces
  during development.

STEP 2 — auto-issue-on-bug-detection (the reporter)
  - Reads the GitHub token from claude_desktop_config.json (see 09_MCP_GITHUB_CONFIG.md)
  - Opens Issue #N on hnidboubker/symphony-async immediately, before diagnosis starts
  - Title: [AUTO] {Error Type}: {Brief Description}
  - Labels: bug, auto-detected, plus severity

STEP 3 — issue-resolution (the engineer)
  - Activates automatically once the issue exists
  - Diagnoses root cause, implements the fix
  - Runs the affected tests, iterates on failures
  - Stops at READY_FOR_COMMIT — changes prepared, nothing committed

STEP 4 — human-controlled-git (the approver)
  - Houssine reviews the prepared change
  - Houssine (only) runs:
      git add <files>
      git commit -m "Fixes #N: <description>"
      git push origin main
  - GitHub closes Issue #N automatically because the commit message contains
    "Fixes #N"
```

## The three distinct roles

| Skill | Role | Does | Touches GitHub token |
|---|---|---|---|
| `auto-issue-on-bug-detection` | Reporter | Detects bug → opens Issue #N | Yes (via MCP) |
| `issue-resolution` | Engineer | Diagnoses → fixes → validates | No — reads issue context only |
| `human-controlled-git` | Approver | Reviews → commits → pushes | No — Houssine only |

## Why the order matters

- The issue is opened before any fix is attempted, so the problem stays trackable
  even if the session ends mid-fix.
- The fix is prepared and tested before any git publish action.
- Only Houssine (or an agent explicitly authorized in that instance) runs the
  actual publish step — see `01_RULES.md`.

## Common mistakes to avoid

- Committing before `issue-resolution` has actually finished and validated the fix.
- Skipping `issue-resolution` because the fix "looks obvious".
- Creating the issue manually when the automatic skill should have done it.
- Forgetting `Fixes #N` in the commit message, leaving the issue open after the
  fix is live.
