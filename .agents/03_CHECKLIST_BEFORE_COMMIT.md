# 03 — Checklist Before Commit

TODO: this checklist was scaffolded generically. Fill in real build/test commands
for symphony-async's actual stack the next time work happens here (see PeasyPilot's
`.agents/03_CHECKLIST_BEFORE_COMMIT.md` for a filled-in .NET example).

## Build & test

- [ ] TODO: project builds cleanly (fill in the actual build command)
- [ ] TODO: test suite passes (fill in the actual test command)
- [ ] New behavior has a corresponding test; a bug fix has a regression test

## Code quality

- [ ] Change respects this repo's existing formatting/linting conventions
- [ ] No unrelated refactor bundled into the same change

## Governance

- [ ] If a bug/error/failing test was involved, a GitHub issue was created via
      `auto-issue-on-bug-detection` first (see `08_AUTO_ISSUE_SKILL.md`)
- [ ] `PROJECT_MEMORY.md` updated if the change introduces a standing decision
- [ ] No `git commit`/`push`/`merge` run by the agent (`01_RULES.md`)

## Secrets & safety

- [ ] `git status`/`git diff` reviewed before staging
- [ ] No destructive shell command run without explicit confirmation
