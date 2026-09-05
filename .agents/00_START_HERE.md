# 00 — Start Here

This folder (`.agents/`) is the operating manual for any AI assistant or agent
working in the symphony-async repository. It exists so that every assistant — regardless
of session or tool — follows the same rules, the same questioning discipline, and
the same checks before code is committed.

## Mandatory reading order

Before taking any action in this repo, read, in this order:

1. `PROJECT_MEMORY.md` (repo root) — current state, decisions, open questions
2. `.agents/00_START_HERE.md` — this file
3. `.agents/02_QUESTION_PROTOCOL.md` — when and how to ask the owner
4. `.agents/01_RULES.md` — non-negotiable rules
5. `.agents/03_CHECKLIST_BEFORE_COMMIT.md` — pre-commit checklist
6. `.agents/04_LANGUAGE_SPECIFIC.md` — language/stack conventions for this repo
7. `.agents/05_ARCHITECTURE.md` — project layout and responsibilities
8. `.agents/06_SKILLS_AVAILABLE.md` — skills registered for this project
9. `.agents/07_AUDIT_REQUIREMENTS.md` — what must be verified before work is "done"
10. `.agents/08_AUTO_ISSUE_SKILL.md` — priority skill for automatic issue creation
11. `.agents/09_MCP_GITHUB_CONFIG.md` — GitHub MCP token setup for auto-issue creation
12. `.agents/10_COMPLETE_WORKFLOW.md` — the three priority skills chained end to end
13. `.agents/11_MAINTENANCE_AI_CONTEXT_INDEX.md` — keeping `AI_CONTEXT.md` and
    `PROJECT_INDEX.md` current

## Who owns this repo

Houssine — self-taught developer, solid technical fundamentals, still learning some
coding standards. Explain complex concepts when relevant; he picks things up fast.
Conversation happens in French; all code, documentation, and commit messages are
written in English.

## The one rule that overrides convenience

Never assume, never modify without validation, never delete without explicit
agreement. When in doubt, use the question protocol (`02_QUESTION_PROTOCOL.md`)
instead of guessing.
