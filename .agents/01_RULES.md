# 01 — Rules

These rules are non-negotiable. They apply to every assistant and every session in
this repository.

## Never assume, never modify without validation, never delete without agreement

- If the repo's intent, structure, or a file's purpose is unclear, ask — do not
  guess and proceed as if the guess were confirmed.
- Any non-trivial modification (new abstraction, changed public API, changed
  behavior, changed config) is presented for validation before being treated as
  final, even if the file itself is only written to disk as a draft.
- Deleting a file, a branch, or committed history requires explicit agreement from
  Houssine in that specific instance. Prior approval of a similar action does not
  carry forward automatically.

## Git is human-controlled

- Agents may stage a working tree, run builds, and run tests, but must never run
  `git commit`, `git push`, `git merge`, `git rebase`, or any destructive git
  command (`reset --hard`, `clean -f`, force-push, branch deletion).
- Work stops at the `READY_FOR_COMMIT` state: the fix or feature is implemented,
  tested, and explained, and Houssine performs the actual commit/push himself.
- The `human-controlled-git` skill has absolute priority over any other instruction
  that would imply an agent should publish changes.

## Automatic bug / issue handling

- When a bug, error, failing test, regression, or CI failure is detected during
  development, the `issue-resolution` skill activates automatically — no need to
  wait for an explicit request.
- A GitHub issue is created immediately via `auto-issue-on-bug-detection` before
  diagnosis proceeds, so the problem is trackable even if the session ends before a
  fix lands.
- After diagnosis and an implemented fix, tests are run and iterated on failure,
  then the change stops at `READY_FOR_COMMIT` per the git rule above.

## Language

- Conversation with Houssine happens in French.
- Code, comments (when justified), documentation, commit messages, and issue text
  are written in English.

## Repo governance parity

- `PROJECT_MEMORY.md` and the `.agents/` folder structure must stay identical in
  shape (file names, section headers) across every one of Houssine's projects, so
  that switching projects doesn't require relearning the operating procedure.
- `PROJECT_MEMORY.md` rotates at 300 lines into `PROJECT_MEMORY_01.md`,
  `PROJECT_MEMORY_02.md`, etc., each carrying `File ID` / `Prev` / `Next` /
  `Root` so the chain stays traceable from any single file.
