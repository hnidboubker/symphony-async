# 11 — Maintaining AI_CONTEXT.md and PROJECT_INDEX.md

Guide for keeping the two navigation files at the repo root current.

## What these files are

- **`AI_CONTEXT.md`** — a 2–5 minute read orienting anyone new to the project:
  what it is, the stack, the architecture, current state.
- **`PROJECT_INDEX.md`** — a GPS telling the reader which file to open for which
  kind of task.

## When to update AI_CONTEXT.md

Automatically (by the assistant): after a major change, after a bug fix, when the
stack changes. Manually (by Houssine): monthly review, when architecture changes,
when project status changes.

## When to update PROJECT_INDEX.md

Automatically: when `.agents/` gains a new file, when structure changes
significantly. Manually: new checklist introduced, a referenced file disappears or
is renamed.

## Required sections in AI_CONTEXT.md

Title + metadata (date, status), one-sentence description, tech stack, high-level
architecture, key components, how it works (5 steps max), current state, important
constraints, essential commands, links to 4–5 key files. Must NOT contain full
source code, low-level detail, full history (that's `PROJECT_MEMORY.md`), full
procedures (that's `.agents/*.md`), or exceed roughly 1000 lines.

## What the assistant must / must not do here

Must: update the date on every meaningful change, keep the fixed section
structure, verify linked files exist, keep "current state" accurate, flag new
constraints.

Must not: invent unverified details, exceed the length guidance, copy source code
in, remove sections or change structure without asking.

## Ownership

Houssine validates; the assistant drafts/updates on request or after a
commit-worthy change. Neither file is version-pinned — they are living documents.
