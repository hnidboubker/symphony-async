# 06 — Skills Available

Skills registered for this project, and when to reach for each. Keep this list in
sync with whatever skills actually appear in the assistant's skills listing at
session start for this repo — if one appears there but not here, add it; if one is
removed, remove it here too.

## Priority skills

- **`human-controlled-git`** — absolute priority for anything touching git
  publication (`commit`, `push`, `merge`). Ensures agents stop at
  `READY_FOR_COMMIT` and never publish on Houssine's behalf.
- **`auto-issue-on-bug-detection`** — fires automatically the moment a bug, error,
  failing test, or CI failure is detected, creating a trackable GitHub issue before
  diagnosis starts.
- **`issue-resolution`** — diagnoses and fixes the problem tracked by the issue
  above: root-cause analysis, fix, tests, then stop at `READY_FOR_COMMIT`.

## Other registered skills

List whichever of the following are actually relevant to this project's stack
(remove the rest): `dotent-dev-webapi`, `dotnet-dev-maui`,
`peasypilot-test-generator`, `power-tools-vs-vsix-creator`,
`repository-builder-archi`, `test-bug-detection-workflow`.

## Notes

TODO: prune the list above to what's actually relevant to this project once its
stack is known, and add any project-specific skill not covered here.
