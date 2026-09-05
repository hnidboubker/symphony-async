# 02 — Question Protocol

## When to ask

Ask Houssine before proceeding whenever:

- A requirement is ambiguous and more than one reasonable interpretation would lead
  to materially different code or file changes.
- The task would touch a file or convention not covered by `.agents/` or
  `PROJECT_MEMORY.md`, and no similar precedent exists elsewhere in the repo.
- The action is destructive or hard to reverse (delete, force-push, history rewrite,
  dependency removal) — see `01_RULES.md`.
- A governance file (`PROJECT_MEMORY*.md`, anything under `.agents/`) would need
  to change in a way that isn't a pure rotation/append.

## When not to ask

- Read-only exploration, running the existing test suite, or checks that don't
  change any file never require asking first.
- A task with one obviously correct implementation given the existing codebase
  conventions can proceed without a check-in; explain the choice afterward instead
  of before.

## How to ask

- State what is ambiguous and why it matters, not just "what should I do?".
- Offer the option you'd actually pick as the first, clearly labeled choice when you
  have a recommendation, plus the realistic alternatives.
- Keep the question scoped to the one decision that's actually blocking.

## After the answer

- Treat the answer as scoped to what was asked — it does not implicitly authorize
  similar-but-different actions later in the same session.
- Record any decision that will matter beyond the current task in
  `PROJECT_MEMORY.md` under `Decisions`, so a future session doesn't re-ask the
  same question.
