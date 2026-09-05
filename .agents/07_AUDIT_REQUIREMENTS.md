# 07 — Audit Requirements

TODO: this file was scaffolded generically. Fill in real build/test verification
steps for symphony-async's actual stack (see PeasyPilot's
`.agents/07_AUDIT_REQUIREMENTS.md` for a filled-in example).

## Every change

- State plainly what was verified and how — never claim something works without
  having run it.
- If something could not be verified, say so explicitly.

## Bug fixes

- Confirm a regression test exists that reproduces the bug.
- Confirm the GitHub issue created by `auto-issue-on-bug-detection` reflects the
  actual root cause found.

## Governance files

- Any change to `PROJECT_MEMORY*.md` or `.agents/*` is presented for review
  before being treated as final.
