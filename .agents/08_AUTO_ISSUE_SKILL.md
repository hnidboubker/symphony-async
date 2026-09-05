# 08 — Auto Issue Skill (Priority)

This is the highest-priority skill file in `.agents/`: it governs what happens the
moment something goes wrong during development, before any fix is attempted.

## Trigger

Any of the following, detected at any point during development or testing, triggers
this skill immediately — no need to wait for Houssine to ask:

- A bug or incorrect behavior observed while running or testing code.
- An unhandled error or exception.
- A failing test (new or pre-existing).
- A CI failure surfaced from the repo's CI configuration.
- Any other concrete software problem blocking the current task.

## Sequence

1. **Create the GitHub issue first**, via `auto-issue-on-bug-detection`, before
   diagnosis begins. This makes the problem trackable even if the session ends
   before it's resolved. This step is mandatory, not optional.
2. **Diagnose** — analyze the problem, identify root cause, using
   `issue-resolution`.
3. **Resolve** — implement the fix.
4. **Test** — validate the fix; iterate on failures where possible.
5. **Stop at `READY_FOR_COMMIT`** — implementation and tests are complete and
   explained, but the change is not committed or pushed by the agent.
6. **Human control** — only Houssine runs `git commit`, `git push`, or
   `git merge`, per `human-controlled-git` (see `01_RULES.md`).

## Why this order matters

Creating the issue before fixing keeps a record of what broke and why, independent
of whether the fix attempt succeeds in the same session. It also gives Houssine a
trackable trail across sessions, consistent with the project-memory rotation
described in `PROJECT_MEMORY.md`.

## Relationship to other skills

- `auto-issue-on-bug-detection` and `issue-resolution` are the two halves of this
  workflow (issue creation, then diagnosis/fix); `human-controlled-git` overrides
  both the moment a git publish action would otherwise happen.
- `test-bug-detection-workflow` exists to test this pipeline itself — use it only
  when validating the automation, not as part of normal bug-fixing work.
